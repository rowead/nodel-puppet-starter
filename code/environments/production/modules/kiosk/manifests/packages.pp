# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kiosk::packages
class kiosk::packages {
  $kiosk_packages = lookup({
    'name'  => 'kiosk::packages',
    'merge' => {
      'strategy' => 'deep',
    },
  })

  if count($kiosk_packages) > 0 {
    each($kiosk_packages) |$key, $package| {
      package { "${key}":
        ensure => $package['ensure'],
      }
    }
  }

  $kiosk_packages_pins = lookup({
    'name'  => 'kiosk::packages::pins',
    'merge' => {
      'strategy' => 'deep',
    },
  })

  if count($kiosk_packages_pins) > 0 {
    each($kiosk_packages_pins) |$key, $pin| {
      apt::pin { "${key}":
        ensure          => $pin['ensure'],
        packages        => $key,
        release_version => $pin['package_version'],
        priority        => $pin['priority']
      }
    }
  }
}
