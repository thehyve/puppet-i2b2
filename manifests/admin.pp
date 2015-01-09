class i2b2::admin
(
  $admin_dir,
) inherits i2b2::params
{
  require i2b2::i2b2src_files

  $domains = $i2b2::params::domains
  $admin_src_dir = "$i2b2::i2b2src_files::dir/admin"

  Exec {
    path => '/bin:/usr/bin',
  }

  file{ '/tmp/bladiebla' :
    ensure  => file,
    content => "cp -r '$admin_src_dir' '$admin_dir'",
  }

  file { $admin_dir :
    ensure  => directory,
    source  => $admin_src_dir,
    recurse => remote,
  }
  ->
  file { "$admin_dir/i2b2_config_data.js" :
    ensure  => file,
    content => template('admin/i2b2_config_data.js.erb'),
  }
}
