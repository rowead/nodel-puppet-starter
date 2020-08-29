# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kiosk
class kiosk {
  # We run puppet standalone so this is not needed.
  service { 'puppet':
    ensure => stopped,
    enable => false
  }
}
