# @summary
#   Manages the Bareos WebUI docker containers
#
# @param version
#
class gernox_bareos::director::webui::run (
  Integer $http_port      = 8080,
  String $version         = $gernox_bareos::director::webui::version,
  String $php_fpm_version = $gernox_bareos::director::webui::php_fpm_version,
) {
  $docker_environment = [
    'BAREOS_DIR_HOST=bareos-dir',
    'PHP_FPM_HOST=php-fpm',
    'PHP_FPM_PORT=9000',
  ]

  $network_name = 'bareos-network'

  docker_network { $network_name:
    ensure  => present,
    options => 'com.docker.network.bridge.name=br-bareos',
  }

  firewall { '002 - IPv4: accept all br-bareos':
    iniface => 'br-bareos',
    action  => 'accept',
  }

  ::docker::run { 'bareos-webui':
    image                 => "barcus/bareos-webui:${version}",
    volumes               => [
      'webui_config:/etc/bareos-webui',
      'webui_data:/usr/share/bareos-webui',
    ],
    net                   => $network_name,
    ports                 => [
      "${http_port}:9100",
    ],
    health_check_interval => 30,
    env                   => $docker_environment,
    depends               => [
      'bareos-php-fpm',
    ],
  }

  ::docker::run { 'bareos-php-fpm':
    image                 => "barcus/php-fpm-alpine:${php_fpm_version}",
    env                   => $docker_environment,
    volumes               => [
      'webui_config:/etc/bareos-webui',
      'webui_data:/usr/share/bareos-webui',
    ],
    health_check_interval => 30,
    net                   => $network_name,
  }
}