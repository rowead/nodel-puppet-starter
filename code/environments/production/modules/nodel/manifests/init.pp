# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nodel
class nodel (
  $ensure = present,
  Enum['running', 'stopped'] $service_ensure = 'running',
) {

  $nodel = lookup({
    'name'  => 'nodel',
    'merge' => {
      'strategy' => 'deep',
    },
  })

  contain nodel::install
  contain nodel::config
  contain nodel::service

  Class['::nodel::install']
  -> Class['::nodel::config']
  ~> Class['::nodel::service']
}
