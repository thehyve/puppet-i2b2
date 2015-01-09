class i2b2::profile::apache inherits i2b2::params
{
  $webroot_dir = $i2b2::params::webroot_dir

  ensure_resource('package', 'php5-curl', {'ensure' => present})

  class {'::apache' :
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  class {'::apache::mod::php' : }

  apache::vhost { 'localhost':
    port    => 80,
    docroot => $webroot_dir,
  }

  class { 'webclient' :
    webclient_dir => "$webroot_dir/webclient",
  }
  class{ 'i2b2::admin' :
    admin_dir => "$webroot_dir/admin",
  }
}
