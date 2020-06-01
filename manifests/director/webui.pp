# @summary
#   Manages the bareos webui
#
class gernox_bareos::director::webui (
  String $version,
) {
  class { 'bareos::webui':
    package_ensure   => true,
    service_ensure   => false,
    service_enable   => false,
    manage_local_dir => true,
  }
}
