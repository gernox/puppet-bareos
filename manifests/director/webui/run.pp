# @summary
#   Manages the Bareos WebUI docker containers
#
# @param version
#
class gernox_bareos::director::webui::run (
  Integer $http_port      = 8090,
  String $version         = $gernox_bareos::director::webui::version,
  String $php_fpm_version = $gernox_bareos::director::webui::php_fpm_version,
) {
  $director_ip = $facts[networking][interfaces][br-bareos][ip]

  $docker_environment = [
    "BAREOS_DIR_HOST=${director_ip}",
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
    net                   => $network_name,
    ports                 => [
      "${http_port}:80",
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
    health_check_interval => 30,
    net                   => $network_name,
  }
}
