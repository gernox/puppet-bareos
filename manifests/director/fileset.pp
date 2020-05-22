# @summary
#   Manages the bareos fileset configuration
#
class gernox_bareos::director::fileset {
  ::bareos::director::fileset { 'BareosCatalog':
    description => 'Backup the catalog dump and Bareos configuration files.',
    include     => {
      'Options' => {
        'Signature' => 'MD5'
      },
      'File'    => [
        '/etc/bareos', # configuration
        '/var/lib/bareos'
      ]
    },
    exclude     => {
      'File' => [
        '/var/lib/bareos/storage'
      ]
    }
  }

  ::bareos::director::fileset { 'LinuxDefault':
    description => 'Default FileSet for all Linux machines',
    include     => {
      'File' => [
        '"\\\\</gernox/backup-fileset"',
      ],
    },
  }

  ::bareos::director::fileset { 'LinuxAll':
    description => 'Backup all regular filesystems, determined by filesystem type.',
    include     => {
      'Options' => {
        'Signature' => 'MD5',
        'One FS'    => 'no', # change into other filessytems
        # filesystems of given types will be backed up
        # others will be ignored
        'FS Type'   => [
          'btrfs',
          'ext2',
          'ext3',
          'ext4',
          'reiserfs',
          'jfs',
          'xfs',
          'zfs'
        ],
      },
      'File'    => [
        '/',
      ]
    },
    # Things that usually have to be excluded
    # You have to exclude /var/lib/bareos/storage
    # on your bareos server
    exclude     => {
      'File' => [
        '/var/lib/bareos',
        '/var/lib/bareos/storage',
        '/proc',
        '/tmp',
        '/.journal',
        '/.fsck',
        '/var/tmp',
        '/var/cache',
        '/var/lib/apt',
        '/var/lib/dpkg',
        '/var/lib/puppet',
        #    # Ignore database stuff; this will need to be handled
        # using some sort of a dump script
        '/var/lib/mysql',
        '/var/lib/postgresql',
        '/var/lib/ldap',
      ]
    }
  }
}
