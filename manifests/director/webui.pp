# @summary
#   Manages the bareos webui
#
class gernox_bareos::director::webui (
  String $version,
) {
  contain ::gernox_docker
  contain ::gernox_bareos::director::webui::images
  contain ::gernox_bareos::director::webui::run

  # Order of execution
  Class['::gernox_docker']
  -> Class['::gernox_bareos::director::webui::images']
  ~> Class['::gernox_bareos::director::webui::run']
}
