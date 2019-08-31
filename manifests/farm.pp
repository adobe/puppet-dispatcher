# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   dispatcher::farm { 'namevar': }
define dispatcher::farm (
  # Do i need ensure?
  Enum['absent', 'present'] $ensure = 'present',
  Integer $priority                                           = lookup("dispatcher::farm::${name}::priority", Integer, 'first', 0),
  Array[String] $virtualhosts                                 = lookup("dispatcher::farm::${name}::virtualhosts", Array[String], 'deep', [$name]),
  Array[String] $clientheaders                                = lookup("dispatcher::farm::${name}::clientheaders", Array[String], 'deep', []),

  Optional[Stdlib::Absolutepath] $sessionmanagement_directory
          = lookup("dispatcher::farm::${name}::sessionmanagement::directory", Optional[Stdlib::Absolutepath], 'first', undef),
  Optional[String] $sessionmanagement_encode                  = lookup("dispatcher::farm::${name}::sessionmanagement::encode", Optional[String], 'first', undef),
  Optional[String] $sessionmanagement_header                  = lookup("dispatcher::farm::${name}::sessionmanagement::header", Optional[String], 'first', undef),
  Optional[Integer[0]] $sessionmanagement_timeout             = lookup("dispatcher::farm::${name}::sessionmanagement::timeout", Optional[Integer[0]], 'first', undef),
  # Secure
) {

  if $priority < 10 {
    $_priority = "0${priority}"
  }
  else {
    $_priority = $priority
  }

  concat { "dispatcher.${_priority}-${name}.inc.any":
    ensure  => $ensure,
    path    => "${::apache::vhost_dir}/dispatcher.${_priority}-${name}.inc.any",
    owner   => 'root',
    group   => $::apache::params::root_group,
    mode    => $::apache::params::file_mode,
    order   => 'numeric',
    require => Package['httpd'],
    notify  => Class['apache::service'],
  }

  concat::fragment { "${name}-farm-header":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 0,
    content => template('dispatcher/farm/_file_header.erb')
  }

  concat::fragment { "${name}-farm-clientheaders":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 10,
    content => template('dispatcher/farm/_clientheaders.erb')
  }

  concat::fragment { "${name}-farm-virtualhosts":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 20,
    content => template('dispatcher/farm/_virtualhosts.erb')
  }

  if ($sessionmanagement_directory) {
    concat::fragment { "${name}-farm-sessionmanagement":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 30,
      content => template('dispatcher/farm/_sessionmanagement.erb')
    }
  }
}
