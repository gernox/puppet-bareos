# @summary
#   Installs and configures bareos client
#
# @param director_hostname
#
# @param director_address
#
# @param client_hostname
#
# @param client_password
#
# @param jobs
#
class gernox_bareos::client (
  String $director_hostname,
  String $director_address,
  String $client_hostname = $::fqdn,
  String $client_address  = $::fqdn,
  String $client_password = fqdn_rand_string(20, '', 'bareos-client-password'),
  Hash $jobs              = {},
) {
  contain gernox_bareos::install

  class { '::bareos::client::client':
    name_client => $client_hostname,
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
  ::bareos::client::director { $director_hostname:
    address  => $director_address,
    password => $client_password,
    # tls_enable => false,
  }

  ::bareos::client::messages { 'Standard':
    description => 'Send relevant messages to the Director.',
    director    => "${director_hostname} = all, !skipped, !restored",
  }
}
