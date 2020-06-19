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
  String $db_user,
  String $db_password,
  String $db_name,
  String $db_host,
  Integer $db_port,
  Integer $http_port,
  Boolean $manage_apache,
  Hash $storages = {},
  Hash $jobdefs  = {},
  Hash $pools    = {},
) {
  contain gernox_bareos::install

  contain ::bareos::console

  ::bareos::director::console { $webui_user:
    password   => $webui_password,
    profile    => 'webui-admin',
    tls_enable => false,
  }

  ::bareos::console::director { $director_name:
    description             => 'Bareos console credentials for local director',
    address                 => 'localhost',
    password                => $director_password,
    tls_enable              => true,
    tls_ca_certificate_file => '/etc/bareos/tls/ca.pem',
    tls_certificate         => '/etc/bareos/tls/cert.pem',
    tls_key                 => '/etc/bareos/tls/key.pem',
    tls_dh_file             => '/etc/bareos/tls/dh.pem',
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
    name_director           => $director_name,
    messages                => 'Daemon',
    password                => $director_password,
    auditing                => true,
    tls_enable              => true,
    tls_require             => true,
    tls_ca_certificate_file => '/etc/bareos/tls/ca.pem',
    tls_certificate         => '/etc/bareos/tls/cert.pem',
    tls_key                 => '/etc/bareos/tls/key.pem',
    tls_dh_file             => '/etc/bareos/tls/dh.pem',
    tls_verify_peer         => true,
    tls_allowed_cn          => $director_name,
  }

  $storage_defaults = {
    tls_enable              => true,
    tls_require             => true,
    tls_ca_certificate_file => '/etc/bareos/tls/ca.pem',
    tls_certificate         => '/etc/bareos/tls/cert.pem',
    tls_key                 => '/etc/bareos/tls/key.pem',
    tls_dh_file             => '/etc/bareos/tls/dh.pem',
  }

  create_resources('::bareos::director::storage', $storages, $storage_defaults)
  create_resources('::bareos::director::jobdefs', $jobdefs)
  create_resources('::bareos::director::pool', $pools)

  contain gernox_bareos::director::client
  contain gernox_bareos::director::fileset
  contain gernox_bareos::director::messages
  contain gernox_bareos::director::profile
  contain gernox_bareos::director::schedule
  contain gernox_bareos::director::webui
}
