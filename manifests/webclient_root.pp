class i2b2::webclient_root inherits i2b2::params
{
  $domains =
  [
    {
      domain => 'i2b2demo',
      name => 'HarvardDemo',
      urlCellPM => 'http://services.i2b2.org/i2b2/services/PMService/',
      allowAnalysis => true,
      debug => false,
    },
  ]

  $webclient_dir = "$intermediary_files_dir/i2b2webclient-$version"
  $webclient_zip = "$webclient_dir.zip"

  class {'::apache' :
    default_vhost => false,
    mpm_module    => 'prefork',
  }
  class {'::apache::mod::php' : }
  apache::vhost { 'localhost':
    port    => 80,
    docroot => "$webclient_dir/webclient",
  }

  Exec {
    path => '/bin:/usr/bin',
  }

  wget::fetch { $webclient_zip :
    source      => "http://files.thehyve.net/i2b2-$version/i2b2webclient-$version.zip",
    destination => $webclient_zip,
  }
  ~>
  exec { "create-empty-dir-$webclient_dir" :
    command     => "rm -rf '$webclient_dir' && mkdir '$webclient_dir'",
    refreshonly => true,
  }
  ~>
  exec { "extract-$webclient_zip":
    cwd     => $webclient_dir,
    command => "bsdtar -xf '$webclient_zip'",
  }
  ->
  file { "$webclient_dir/webclient/i2b2_config_data.js" :
    ensure  => file,
    content => template('webclient/i2b2_config_data.js.erb'),
  }
}
