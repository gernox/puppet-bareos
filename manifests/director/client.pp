# @summary
#   Manages the bareos client configuration
#
# @param director_name
#
class gernox_bareos::director::client (
  String $director_name = $gernox_bareos::director::director_name,
) {
  $password = fqdn_rand_string(20, '', 'bareos-fd-password')

  # setup filedaemon
  contain gernox_bareos::client

  ::bareos::director::job { 'RestoreFiles':
    job_defs => 'RestoreFiles',
    client   => $director_name,
    messages => 'Standard',
  }

  ::bareos::director::job { 'BackupBareosCatalog':
    job_defs => 'BackupBareosCatalog',
    client   => $director_name,
    messages => 'Standard',
  }

  # Ignore puppetdb during bootstrap
  $clients = $::settings::storeconfigs ? {
    true    => puppetdb_query('resources { type = "Class" and title = "Gernox_bareos::Client" }'),
    default => {}
  }

  each($clients) |$client| {
    $client_params = $client['parameters']
    $client_hostname = $client_params['client_hostname']
    $client_address = $client_params['client_address']

    ::bareos::director::client { $client_hostname:
      description             => "Client resource of ${client_hostname}",
      password                => $client_params['client_password'],
      address                 => $client_address,
      tls_enable              => true,
      tls_require             => true,
      tls_ca_certificate_file => '/etc/bareos/tls/ca.pem',
      tls_certificate         => '/etc/bareos/tls/cert.pem',
      tls_key                 => '/etc/bareos/tls/key.pem',
      tls_dh_file             => '/etc/bareos/tls/dh.pem',
      tls_allowed_cn          => $client_hostname,
    }

    $jobs = $client_params['jobs']

    if $jobs != undef {
      $jobs.each |$k, $v| {
        ::bareos::director::job { "${client_hostname}-${k}":
          *      => $v,
          client => $client_hostname,
        }
      }
    }
  }
}
