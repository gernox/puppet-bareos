# @summary
#   Manages the Bareos WebUI docker images
#
# @param version
#
class gernox_bareos::director::webui::images (
  String $version         = $gernox_bareos::director::webui::version,
  String $php_fpm_version = $gernox_bareos::director::webui::php_fpm_version,
) {
  ::docker::image { 'bareos-webui':
    ensure    => present,
    image     => 'barcus/bareos-webui',
    image_tag => $version,
  }

  ::docker::image { 'bareos-php-fpm':
    ensure    => present,
    image     => 'barcus/php-fpm-alpine',
    image_tag => $php_fpm_version,
  }
}
