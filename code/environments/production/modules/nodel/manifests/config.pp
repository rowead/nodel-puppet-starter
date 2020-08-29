# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nodel::config
class nodel::config inherits nodel {

  file { "/opt/nodel/nodes/${fqdn}":
    ensure  => directory,
    require => File['/opt/nodel/nodes']
  }

  file { '/opt/nodel/recipes/WAM_Computer':
    ensure  => directory,
    require => File['/opt/nodel/recipes']
  }

  file { '/opt/nodel/recipes/WAM_Computer/script.py':
    ensure  => present,
    content => template('nodel/config/computer.erb'),
    require => File['/opt/nodel/recipes/WAM_Computer']
  }

  if ( $nodel['manage_config'] == true ) {
    file { "/opt/nodel/nodes/${fqdn}/script.py":
      ensure  => present,
      content => template('nodel/config/computer.erb'),
      require => File["/opt/nodel/nodes/${fqdn}"]
    }
  } else {
    exec { 'copy nodel computer node':
      command => "cp /opt/nodel/recipes/WAM_Computer/script.py /opt/nodel/nodes/${fqdn}/",
      creates => "/opt/nodel/nodes/${fqdn}/script.py",
      path    => $path,
      require => [
        File["/opt/nodel/nodes/${fqdn}"],
        File["/opt/nodel/recipes/WAM_Computer/script.py"]
      ]
    }
  }

}
