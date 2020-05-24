# @summary
#   Manages the bareos webui
#
class gernox_bareos::director::webui (
) {
  class { 'bareos::webui':
  }
}
