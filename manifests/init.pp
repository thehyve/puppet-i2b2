class i2b2 inherits i2b2::params {
  file { $params::intermediary_files_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
  }

  ensure_resource('package', 'bsdtar', {'ensure' => present})
}
