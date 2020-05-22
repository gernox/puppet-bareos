# @summary
#   Installs and configures bareos
#
# @param webui_user
#
# @param webui_password
#
# @param director_name
#
# @param director_password
#
# @param storage_name
#
# @param storage_password
#
# @param db_user
#
# @param db_password
#
# @param db_name
#
# @param db_host
#
# @param db_port
#
# @param http_port
#
# @param manage_apache
#
class gernox_bareos::director (
  String $webui_user,
  String $webui_password,
  String $director_name,
  String $director_password,
  String $storage_name,
  String $storage_password,
  String $db_user,
  String $db_password,
  String $db_name,
  String $db_host,
  Integer $db_port,
  Integer $http_port,
  Boolean $manage_apache,
) {
  contain gernox_bareos::install

  contain ::bareos::console

  ::bareos::director::console { $webui_user:
    password   => $webui_password,
    profile    => 'webui-admin',
    tls_enable => false,
  }

  ::bareos::console::director { $director_name:
    description => 'Bareos console credentials for local director',
    address     => 'localhost',
    password    => $director_password,
  }

  ::bareos::director::catalog { 'MyCatalog':
    db_driver   => 'postgresql',
    db_name     => $db_name,
    db_address  => $db_host,
    db_port     => $db_port,
    db_user     => $db_user,
    db_password => $db_password,
  }

  class { '::bareos::director::director':
    name_director => $director_name,
    messages      => 'Daemon',
    password      => $director_password,
    auditing      => true,
  }

  class { 'gernox_bareos::director::storage':
    address  => $storage_name,
    password => $storage_password,
  }

  contain gernox_bareos::director::client
  contain gernox_bareos::director::fileset
  contain gernox_bareos::director::jobdefs
  contain gernox_bareos::director::messages
  contain gernox_bareos::director::pool
  contain gernox_bareos::director::profile
  contain gernox_bareos::director::schedule
  contain gernox_bareos::director::storage

  ::bareos::webui::director { $director_name: }

  if $manage_apache {
    class { '::apache':
      mpm_module    => 'prefork',
      default_vhost => false,
    }

    class { '::apache::mod::php':
      php_version => '7.2',
    }

    class { '::apache::mod::rewrite': }

    apache::vhost { 'default-bareos-webui':
      default_vhost => false,
      servername    => 'default',
      port          => $http_port,
      docroot       => '/var/www/html',
    }

    file { '/etc/apache2/conf.d/bareos-webui.conf':
      source  => 'puppet:///modules/gernox_bareos/bareos-webui/bareos-webui.conf',
      require => Class['apache'],
      notify  => Service['apache2'],
    }
  }
}
