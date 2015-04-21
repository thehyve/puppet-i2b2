class i2b2::admin
(
  $admin_dir = $i2b2::params::admin_dir,
  $domains = $i2b2::params::admin_domains
) inherits i2b2::params
{
  require i2b2::i2b2src_files

  $admin_src_dir = "$i2b2::i2b2src_files::dir/admin"
  $admin_only = true # for template

  Exec {
    path => '/bin:/usr/bin',
  }

  file { $admin_dir :
    ensure  => directory,
    source  => $admin_src_dir,
    recurse => remote,
  }

  file { "$admin_dir/i2b2_config_data.js" :
    ensure  => file,
    content => template('i2b2/config_data.js.erb'),
  }

  }
}
