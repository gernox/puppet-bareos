# @summary
#   Installs and configures bareos client
#
# @param client_name
#
# @param director_name
#
# @param client_password
#
# @param jobs
#
class gernox_bareos::client (
  String $client_name,
  String $director_name,
  String $client_password = fqdn_rand_string(20, '', 'bareos-client-password'),
  Hash $jobs              = {},
) {
  contain gernox_bareos::install

  class { '::bareos::client::client':
    name_client => $client_name,
    # tls_enable  => false,
  }

  file { [
    '/etc/bareos/bareos-fd.d/client/myself.conf',
    '/etc/bareos/bareos-fd.d/director/bareos-dir.conf',
    '/etc/bareos/bareos-fd.d/director/bareos-mon.conf',
  ]:
    ensure  => present,
    content => '',
    require => Package['bareos-filedaemon'],
  }

  # allow bareos server to connect
  ::bareos::client::director { $director_name:
    password => $client_password,
    # tls_enable => false,
  }

  ::bareos::client::messages { 'Standard':
    description => 'Send relevant messages to the Director.',
    director    => "${director_name} = all, !skipped, !restored",
  }
}
