# @summary
#   Manages the bareos webui
#
class gernox_bareos::director::webui (
) {
  class { 'bareos::webui':
    package_ensure => false,
    service_ensure => false,
    service_enable => false,
  }
}
