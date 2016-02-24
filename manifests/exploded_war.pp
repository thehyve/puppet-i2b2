class i2b2::exploded_war inherits i2b2::params {
  require i2b2

  include i2b2::axis2_password

  $axis_url = "http://files.thehyve.net/axis2-${::i2b2::params::axis_version}-war.zip"
  $axis_war = "$::i2b2::params::intermediate_dir/axis2-${::i2b2::params::axis_version}-war.zip"

  $dir                = $::i2b2::params::exploded_war_dir
  $root_logging_level = $::i2b2::params::root_logging_level
  $log_dir            = $::i2b2::params::log_dir

  Exec {
    path => '/bin:/usr/bin'
  }

  file { $dir:
    ensure => directory,
    owner  => $::i2b2::params::user,
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
    user     => $::i2b2::params::user,
    command  => "bsdtar -xOf '$axis_war' axis2.war | bsdtar -xf -",
    creates  => "$dir/WEB-INF",
    provider => shell,
  } ->
  file { "$dir/WEB-INF/classes/log4j.properties":
    owner   => $::i2b2::params::user,
    content => template('i2b2/log4j.properties.erb'),
  }

  Exec["extract $axis_war"] ->
  file { "$dir/WEB-INF/conf":
    ensure  => directory,
  }

  file { $axis_war:
    require => Wget::Fetch[$axis_war],
  }
}
