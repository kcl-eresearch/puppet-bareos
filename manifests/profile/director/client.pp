# == Class: bareos::profile::director::client
# Default client, backup bareos director itself
class bareos::profile::director::client {
  $password = fqdn_rand_string(20,'','bareos-fd-password')

  # setup filedaemon
  class { 'bareos::profile::client':
    name_client => 'bareos-director-fd',
    password    => $password,
  }

  # configure client on bareos director
  bareos::director::client { 'bareos-director-fd':
    description             => 'Client resource of the Director itself.',
    password                => $password,
    address                 => 'localhost',
    maximum_concurrent_jobs => $facts['tape_drive_count'],
  }
#  bareos::director::job { 'backup-bareos-fd':
#    job_defs               => 'BackupBareosCatalog',
#    client                 => 'bareos-director-fd',
#    messages               => 'Standard',
#    storage                => 'Tape',
#    pool                   => 'Full',
#    full_backup_pool       => 'Full',
#    prefer_mounted_volumes => false,
#  }
}
