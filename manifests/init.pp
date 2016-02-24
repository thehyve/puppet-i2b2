class i2b2 inherits i2b2::params {
  file { $::i2b2::params::intermediate_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
  }

  if $::i2b2::params::manage_packages {
    contain i2b2::packages
  }

  if $::i2b2::params::manage_user {
    user { $::i2b2::params::user:
      ensure => present
    }
  }
}
