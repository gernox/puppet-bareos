# @summary
#   Installs bareos
#
class gernox_bareos::install (
  $fqdn = $::fqdn,
) {
  class { '::bareos':
    manage_repo    => true,
    manage_user    => true,
    manage_package => true,
    package_name   => 'bareos-common',
    package_ensure => present,
    service_ensure => running,
  }

  file { '/etc/bareos/tls':
    ensure  => directory,
    owner   => 'bareos',
    group   => 'bareos',
    require => Class['bareos'],
  }
  -> file { '/etc/bareos/tls/ca.pem':
    ensure => present,
    owner  => 'bareos',
    group  => 'bareos',
    mode   => '0644',
    source => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
  }
  -> file { '/etc/bareos/tls/cert.pem':
    ensure => present,
    owner  => 'bareos',
    group  => 'bareos',
    mode   => '0644',
    source => "/etc/puppetlabs/puppet/ssl/certs/${fqdn}.pem",
  }
  -> file { '/etc/bareos/tls/key.pem':
    ensure => present,
    owner  => 'bareos',
    group  => 'bareos',
    mode   => '0640',
    source => "/etc/puppetlabs/puppet/ssl/private_keys/${fqdn}.pem"
  }

}
