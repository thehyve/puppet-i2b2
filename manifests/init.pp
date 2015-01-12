class i2b2 inherits i2b2::params {
  file { $params::intermediate_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
  }

  if $params::manage_packages {
    contain i2b2::packages
  }

  if $params::manage_user {
    user { $params::user:
      ensure => present
    }
  }
}
