# @summary
#   Installs and configures bareos storage
#
# @param director_name
#
# @param storage_name
#
# @param storage_password
#
# @param devices
#
class gernox_bareos::storage (
  String $director_name,
  String $storage_name,
  String $storage_password,
  Array  $devices = [],
) {
  contain gernox_bareos::install

  class { '::bareos::storage::storage':
    name_storage            => $storage_name,
    messages                => 'Standard',
    tls_enable              => true,
    tls_require             => true,
    tls_ca_certificate_file => '/etc/bareos/tls/ca.pem',
    tls_certificate         => '/etc/bareos/tls/cert.pem',
    tls_key                 => '/etc/bareos/tls/key.pem',
    tls_dh_file             => '/etc/bareos/tls/dh.pem',
    tls_verify_peer         => false,
  }

  ::bareos::storage::director { $director_name:
    password                => $storage_password,
    tls_enable              => true,
    tls_require             => true,
    tls_ca_certificate_file => '/etc/bareos/tls/ca.pem',
    tls_certificate         => '/etc/bareos/tls/cert.pem',
    tls_key                 => '/etc/bareos/tls/key.pem',
    tls_dh_file             => '/etc/bareos/tls/dh.pem',
    tls_verify_peer         => true,
    tls_allowed_cn          => $director_name,
  }

  # Note: in the current implementation, the Director Name is ignored, and the message is sent to the Director that started the Job.
  ::bareos::storage::messages { 'Standard':
    description => 'Send relevant messages to the Director.',
    director    => "${director_name} = all",
  }

  each($devices) |$device| {
    ::bareos::storage::device { $device['name']:
      archive_device  => $device['path'],
      media_type      => 'File',
      label_media     => true,
      random_access   => true,
      automatic_mount => true,
      removable_media => false,
      always_open     => false,
    }
  }
}
