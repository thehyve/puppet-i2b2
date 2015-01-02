class i2b2::pseudo_jboss inherits i2b2::params {
  include i2b2::exploded_war

  $dir = "$params::intermediate_dir/pseudo-jboss"
  $standalone = "$dir/standalone"
  $deployments = "$standalone/deployments"
  $war_dir = "$deployments/i2b2"

  file { [$dir, $standalone, $deployments]:
    ensure => directory,
    owner  => $params::user,
  }

  file { $war_dir:
    ensure => link,
    target => $params::exploded_war_dir,
  }
}
