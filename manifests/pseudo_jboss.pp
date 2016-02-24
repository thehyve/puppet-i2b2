class i2b2::pseudo_jboss inherits i2b2::params {
  require i2b2::exploded_war

  $dir = "$::i2b2::params::intermediate_dir/pseudo-jboss" # public
  $standalone = "$dir/standalone"
  $deployments = "$standalone/deployments"
  $war_dir = "$deployments/i2b2" # public

  file { [$dir, $standalone, $deployments]:
    ensure => directory,
    owner  => $::i2b2::params::user,
  }

  file { $war_dir:
    ensure => link,
    target => $::i2b2::params::exploded_war_dir,
  }
}
