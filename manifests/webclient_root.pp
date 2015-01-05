class i2b2::webclient_root inherits i2b2::params
{
  require i2b2 # if the i2b2 backend is run on a different server this line is to be removed.

  ensure_resource('package', 'unzip', {'ensure' => present})

  class {'::apache' : }
  class {'::apache::mod::php' : }

  $webclient_zip = "$intermediary_files_dir/i2b2webclient-$version.zip"
  $docroot = $apache::docroot
  $webclient_dir = "$docroot/webclient"

  Exec {
    path => '/bin:/usr/bin',
  }

  wget::fetch { $webclient_zip :
    source      => "http://files.thehyve.net/i2b2-$version/i2b2webclient-$version.zip",
    destination => $webclient_zip,
  }
  ~>
  exec { "extract-$webclient_zip":
    command     => "rm -rf $webclient_dir && unzip '$webclient_zip' -d '$docroot' ",
    refreshonly => true,
    require     => [ Class[::apache], Class[::apache::mod::php] ],
  }
  ~>
  file { "$docroot/webclient/i2b2_config_data.js" :
    ensure => present,
    source => 'puppet:///modules/webclient/i2b2_config_data.js',
  }
}


