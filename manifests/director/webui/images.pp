# @summary
#   Manages the Bareos WebUI docker images
#
# @param version
#
class gernox_bareos::director::webui::images (
  String $version         = $gernox_bareos::director::webui::version,
) {
  ::docker::image { 'bareos-webui':
    ensure    => present,
    image     => 'barcus/bareos-webui',
    image_tag => $version,
  }

  ::docker::image { 'bareos-php-fpm':
    ensure    => present,
    image     => 'barcus/php-fpm-alpine',
  }
}
