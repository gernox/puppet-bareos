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

  # configure client on bareos director
  # ::bareos::director::client { $::fqdn:
  #   description => 'Client resource of the Director itself.',
  #   password    => $password,
  #   address     => 'localhost',
  #   # tls_enable  => false,
  # }

  # ::bareos::director::job { 'backup-bareos-fd':
  #   job_defs => 'BackupBareosCatalog',
  #   client   => 'bareos-director-fd',
  #   messages => 'Standard',
  # }

  ::bareos::director::job { 'RestoreFiles':
    job_defs => 'RestoreFiles',
    client   => $director_name,
  }

  # Ignore puppetdb during bootstrap
  $clients = $::settings::storeconfigs ? {
    true    => query_resources(false,
      ['and',
        ['=', 'type', 'Class'],
        ['=', 'title', 'gernox_bareos::Client'],
      ]),
    default => {}
  }

  each($clients) |$client| {
    $client_params = $client['parameters']

    ::bareos::director::client { $client_params['client_name']:
      description => "Client resource of ${client_params['client_name']}",
      password    => $client_params['client_password'],
      address     => $client_params['client_name'],
      # tls_enable  => false,
    }

    $jobs = $client_params['jobs']

    if $jobs != undef {
      $jobs.each |$k, $v| {
        ::bareos::director::job { "${client_params['client_name']}-${k}":
          *      => $v,
          client => $client_params['client_name'],
        }
      }
    }
  }
}
