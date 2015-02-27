class i2b2::webclient
(
  $webclient_dir,
  $domains = $i2b2::params::webclient_domains
) inherits i2b2::params
{
  $webclient_zip = "$intermediate_dir/i2b2webclient-$version.zip"
  $css_declaration = '<link href="cmi_data_portal_override.php" title="override" rel="stylesheet" type="text/css" \/>'
  $css_sed_expr = "/<\\/head>/i$css_declaration"

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
    cwd         => $webclient_dir,
    command     => "bsdtar -xf '$webclient_zip' --strip-components=1",
    refreshonly => true,
  }
  ->
  file { "$webclient_dir/i2b2_config_data.js" :
    ensure  => file,
    content => template('i2b2/webclient_config_data.js.erb'),
  }

  file { "$webclient_dir/cmi_data_portal_override.php" :
    ensure => file,
    source => 'puppet:///modules/i2b2/cmi_data_portal_override.php',
  }

  exec { 'insert-css' :
    cwd     => $webclient_dir,
    command => "sed -i '$css_sed_expr' default.htm",
    unless  => "grep '$css_declaration' default.htm",
    require => Exec[ "extract-$webclient_zip" ],
  }

  file { $webclient_zip:
    require => Wget::Fetch[$webclient_zip],
  }
}
