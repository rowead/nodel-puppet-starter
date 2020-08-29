# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nodel::install
class nodel::install inherits nodel {

  # @TODO: turn into 'directory' or 'absent' based on global
  file { '/opt/nodel':
    ensure => directory,
  }

  file { '/opt/nodel/nodes':
    ensure  => directory,
    require => File['/opt/nodel']
  }

  file { '/opt/nodel/recipes':
    ensure  => directory,
    require => File['/opt/nodel']
  }

  file { '/opt/nodel/version':
    ensure  => present,
    require => File['/opt/nodel'],
    content => $nodel['nodel_jar'],
    notify  => Exec['download nodel.jar']
  }

  # Should really be able to use file resource but corporate proxy breaks that.
  # @TODO: make this aware of changes...
  exec { 'download nodel.jar':
    command     => "wget ${nodel['nodel_jar']} -O /opt/nodel/nodel.jar",
    path        => $path,
    require     => File['/opt/nodel'],
    refreshonly => true
  }

  package {'openjdk-8-jre-headless':
    ensure => installed
  }

  package {'jsvc':
    ensure => installed
  }
}
