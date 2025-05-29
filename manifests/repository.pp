# @summary
#   Manages the bareos repository. Parameters should be configured in the bareos class. This class will be automatically included when a resource is defined. This class will be automatically included when a resource is defined. It is not intended to be used directly by external resources like node definitions or other modules.
#
# @param release
#   The major bareos release version which should be used
# @param gpg_key_fingerprint
#   The GPG fingerprint of the repos key
# @param subscription
#   Activate the (paid) subscription repo. Otherwise the opensource repos will be selected
# @param username
#   The major bareos release version which should be used
# @param password
#   The major bareos release version which should be used
# @param https
#   Whether https should be used in repo URL
#
class bareos::repository (
  Enum['19.2', '20', '21', '24'] $release             = '24',
  Optional[String[1]]            $gpg_key_fingerprint = '82834CF002D89BA55C1ED0AA42DA24A6DFEF9127',
  Boolean                        $subscription        = false,
  Optional[String]               $username            = undef,
  Optional[String]               $password            = undef,
  Boolean                        $https               = true,
) {
  if $https {
    $scheme = 'https://'
  } else {
    $scheme = 'http://'
  }
  if $subscription {
    if empty($username) or empty($password) {
      fail('For Bareos subscription repos both username and password are required.')
    }
    # note the .com
    $address = 'download.bareos.com/current/'
  } else {
    $address = 'download.bareos.org/current/'
  }

  $os = $facts['os']['name']
  $osrelease = $facts['os']['release']['full']
  $osmajrelease = $facts['os']['release']['major']

  $yum_username = $username ? {
    undef   => 'absent',
    default => $username,
  }
  $yum_password = $password ? {
    undef   => 'absent',
    default => $password,
  }

  case $os {
    /(?i:redhat|centos|rocky|almalinux|fedora|virtuozzolinux|amazon)/: {
      $url = "${scheme}${address}"
      case $os {
        'RedHat', 'VirtuozzoLinux': {
          $location = "${url}RHEL_${osmajrelease}"
        }
        'Centos', 'Rocky', 'AlmaLinux': {
          if versioncmp($release, '21') >= 0 and versioncmp($osmajrelease, '8') >= 0 {
            $location = "${url}EL_${osmajrelease}"
          } else {
            $location = "${url}CentOS_${osmajrelease}"
          }
        }
        'Fedora': {
          $location = "${url}Fedora_${osmajrelease}"
        }
        'Amazon': {
          case $osmajrelease {
            '2': {
              $location = "${url}RHEL_7"
            }
            default: {
              fail('Operatingsystem is not supported by this module')
            }
          }
        }
        default: {
          fail('Operatingsystem is not supported by this module')
        }
      }
      yumrepo { 'bareos':
        name     => 'bareos',
        descr    => 'Bareos Repository',
        username => $yum_username,
        password => $yum_password,
        baseurl  => $location,
        gpgcheck => '1',
        gpgkey   => "${location}/repodata/repomd.xml.key",
        priority => '1',
      }
    }
    /(?i:debian|ubuntu)/: {
      if $subscription {
        $url = "${scheme}${username}:${password}@${address}"
      } else {
        $url = "${scheme}${address}"
      }
      if $os  == 'Ubuntu' {
        $location = "${url}xUbuntu_${osrelease}"
      } else {
        if $osmajrelease == '10' {
          $location = "${url}Debian_${osmajrelease}"
        } else {
          $location = "${url}Debian_${osmajrelease}.0"
        }
      }
      if $subscription {
        # release key file is not avaiable without login and
        # apt-key cannot handle username and password in URI
        $key = {
          id => $gpg_key_fingerprint,
        }
      } else {
        $key = {
          id     => $gpg_key_fingerprint,
          source => "${location}/Release.key",
        }
      }

      include apt
      ::apt::source { 'bareos':
        location => $location,
        repos    => '/',
        key      => $key,
      }
      Apt::Source['bareos'] -> Package <| provider == 'apt' |>
      Class['Apt::Update']  -> Package <| provider == 'apt' |>
    }
    default: {
      fail('Operatingsystem is not supported by this module')
    }
  }
}
