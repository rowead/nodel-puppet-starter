# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kiosk::users
class kiosk::users {
  require stdlib

  $kiosk_users = lookup({
    'name'  => 'kiosk::users',
    'merge' => {
      'strategy' => 'deep',
    },
  })

  if ($facts['os']['distro']['codename'] == 'bionic' ) {
    package { 'lightdm':
      ensure => present,
    }

    package { 'gdm3':
      ensure  => absent,
      require => Package['lightdm'],
    }

    file { '/etc/X11/default-display-manager':
      ensure  => present,
      content => "/usr/sbin/lightdm\n",
      require => Package['lightdm'],
    }
  }

  if count($kiosk_users) > 0 {

    if ($facts['os']['distro']['codename'] == 'bionic' ) {
      group { 'nopasswdlogin':
        ensure => present,
      }
    }

    each($kiosk_users) |$key, $kiosk_user| {
      if ($kiosk_user['ensure'] == present) {
        group { $kiosk_user['gid']:
          ensure => present,
          gid    => $kiosk_user['uid']
        }
        if ($facts['os']['distro']['codename'] == 'bionic' ) {
          if ($kiosk_user['autologin']) {
            file { '/etc/lightdm/lightdm.conf':
              path    => '/etc/lightdm/lightdm.conf',
              ensure  => present,
              content => template('kiosk/users/lightdm-conf.erb'),
              require => [
                Package['lightdm'],
                File['/etc/X11/default-display-manager'],
              ]
            }
          }
        } else {
          if ($kiosk_user['autologin']) {
            file { '/etc/lightdm/lightdm.conf':
              path    => '/etc/lightdm/lightdm.conf',
              ensure  => present,
              content => template('kiosk/users/lightdm-conf.erb'),
            }
          }
        }

        file { "${key} home":
          ensure  => directory,
          path    => $kiosk_user['home'],
          group   => $kiosk_user['gid'],
          owner   => $kiosk_user['uid'],
          require => [ User[$key], Group[$kiosk_user['gid']] ]
        }

        user { "${key}":
          ensure   => $kiosk_user['ensure'],
          gid      => $kiosk_user['gid'],
          groups   => $kiosk_user['groups'],
          home     => $kiosk_user['home'],
          password => pw_hash($kiosk_user['password'], 'SHA-512', 'mysalt'),
          shell    => $kiosk_user['shell'],
          uid      => $kiosk_user['uid'],
          require  => Group[$kiosk_user['gid']]
        }
      }
    }
  }
}
