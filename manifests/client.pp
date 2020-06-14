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
  String $pki_key_pair,
  String $pki_master_key,
  String $client_hostname = $::fqdn,
  String $client_address  = $::fqdn,
  String $client_password = fqdn_rand_string(20, '', 'bareos-client-password'),
  Hash $jobs              = {},
) {
  contain gernox_bareos::install

  file { '/etc/bareos/pki.pem':
    ensure  => present,
    owner   => 'bareos',
    group   => 'bareos',
    mode    => '0640',
    content => $pki_key_pair,
  }

  file { '/etc/bareos/master.cert':
    ensure  => present,
    owner   => 'bareos',
    group   => 'bareos',
    mode    => '0644',
    content => $pki_master_key,
  }

  class { '::bareos::client::client':
    name_client             => $client_hostname,
    tls_enable              => true,
    tls_require             => true,
    tls_allowed_cn          => $client_hostname,
    tls_ca_certificate_file => '/etc/bareos/tls/ca.pem',
    tls_certificate         => '/etc/bareos/tls/cert.pem',
    tls_key                 => '/etc/bareos/tls/key.pem',
    tls_dh_file             => '/etc/bareos/tls/dh.pem',
    pki_signatures          => true,
    pki_encryption          => true,
    pki_cipher              => 'aes256',
    pki_key_pair            => '/etc/bareos/pki.pem',
    pki_master_key          => '/etc/bareos/master.cert',
  }

  # allow bareos server to connect
  ::bareos::client::director { $director_hostname:
    address                 => $director_address,
    password                => $client_password,
    tls_enable              => true,
    tls_require             => true,
    tls_ca_certificate_file => '/etc/bareos/tls/ca.pem',
    tls_certificate         => '/etc/bareos/tls/cert.pem',
    tls_key                 => '/etc/bareos/tls/key.pem',
    tls_dh_file             => '/etc/bareos/tls/dh.pem',
    tls_verify_peer         => true,
    tls_allowed_cn          => $director_hostname,
  }

  ::bareos::client::messages { 'Standard':
    description => 'Send relevant messages to the Director.',
    director    => "${director_hostname} = all, !skipped, !restored",
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
}
