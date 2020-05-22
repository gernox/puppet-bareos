# @summary
#   Manages the bareos storage configuration
#
# @param address
#
# @param password
#
# @param devices
#
class gernox_bareos::director::storage (
  String $address,
  String $password,
  Array  $devices = [],
) {
  ::bareos::director::storage { 'File':
    address    => $address,
    password   => $password,
    device     => $devices,
    media_type => 'File',
  }
}
