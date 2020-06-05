# @summary
#   Installs bareos
#
class gernox_bareos::install {
  class { '::bareos':
    manage_repo    => true,
    manage_user    => true,
    manage_package => true,
    package_name   => 'bareos-common',
    package_ensure => present,
    service_ensure => running,
  }
}
