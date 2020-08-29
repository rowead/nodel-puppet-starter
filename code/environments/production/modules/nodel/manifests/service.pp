# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nodel::service
class nodel::service inherits nodel {

  file { '/lib/systemd/system/nodel.service':
    ensure => present,
    content => template('nodel/service/systemd.erb'),
  }~>
  exec { 'nodel-systemd-reload':
    path => $path,
    command => 'systemctl daemon-reload',
    refreshonly => true
  }

  if ( $nodel['service_ensure'] == 'running') {
    $service_enable = true
  } else {
    $service_enable = false
  }

  service { 'nodel':
    ensure    => $nodel['service_ensure'],
    enable    => $service_enable,
    provider  => systemd,
    require   => File['/lib/systemd/system/nodel.service'],
    subscribe => Exec['download nodel.jar']
  }
}
