class i2b2::exploded_war inherits i2b2::params {
  require i2b2

  $axis_url = "http://files.thehyve.net/axis2-${params::axis_version}-war.zip"
  $axis_war = "$params::intermediate_dir/axis2-${params::axis_version}-war.zip"

  $dir                = $params::exploded_war_dir
  $root_logging_level = $params::root_logging_level
  $log_dir            = $params::log_dir

  $password = hiera( 'i2b2::axis2::password' )

  Exec {
    path => '/bin:/usr/bin'
  }

  file { $dir:
    ensure => directory,
    owner  => $params::user,
  } ->
  wget::fetch { $axis_war:
    source      => $axis_url,
    destination => $axis_war,
  } ~>
  exec { "clean-$dir":
    cwd         => $dir,
    command     => 'find -delete',
    refreshonly => true,
  } ->
  exec { "extract $axis_war":
    cwd      => $dir,
    user     => $params::user,
    command  => "bsdtar -xOf '$axis_war' axis2.war | bsdtar -xf -",
    creates  => "$dir/WEB-INF",
    provider => shell,
  } ->
  file { "$dir/WEB-INF/classes/log4j.properties":
    owner   => $params::user,
    content => template('i2b2/log4j.properties.erb'),
  }

  Exec["extract $axis_war"] ->
  file { "$dir/WEB-INF/conf":
    ensure  => directory,
  }

  # TODO: not rubost
  exec { 'replace-axis-password' :
    cwd     => "$dir/WEB-INF/conf",
    unless  => "grep $password axis2.xml",
    command => "sed -i 's#<parameter name=\"password\">.*</parameter>#<parameter name=\"password\">$password</parameter>#' axis2.xml",
  }

  file { $axis_war:
    require => Wget::Fetch[$axis_war],
  }
}
