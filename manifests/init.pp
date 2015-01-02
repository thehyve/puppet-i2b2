class i2b2 inherits i2b2::params {
  file { $params::intermediate_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
  }

  ensure_resource('package', 'bsdtar', {'ensure' => present})
  ensure_resource('package', 'ant', {'ensure' => present})

  if $params::manage_user {
    user { $params::user:
      ensure => present
    }
  }
}
