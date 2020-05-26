# @summary
#   Manages the bareos webui
#
class gernox_bareos::director::webui (
  String $version,
  String $php_fpm_version,
) {
  class { 'bareos::webui':
    package_ensure => false,
    service_ensure => false,
    service_enable => false,
  }

  contain ::gernox_docker
  contain ::gernox_bareos::director::webui::images
  contain ::gernox_bareos::director::webui::run

  # Order of execution
  Class['bareos::webui']
  -> Class['::gernox_docker']
  -> Class['::gernox_bareos::director::webui::images']
  ~> Class['::gernox_bareos::director::webui::run']
}
