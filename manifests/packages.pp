class i2b2::packages(
  $bsdtar_package     = $::i2b2::params::bsdtar_package,
  $ant_package        = $::i2b2::params::ant_package,
  $java_package       = $::i2b2::params::java_package,
  $gems_deps_packages = $::i2b2::params::gems_deps_packages,
) inherits i2b2::params {

  ensure_resource('package', $bsdtar_package)
  ensure_resource('package', $ant_package)
  ensure_resource('package', $java_package)
  ensure_resource('package', $gems_deps_packages)

  # Puppet 4 has a bundled copy of ruby
  $gem_provider = (versioncmp($::puppetversion, '4') < 0) ? {
    true    => 'gem',
    default => 'puppet_gem',
  }

  package { ['java-properties', 'pg']:
    provider => $gem_provider,
    require  => Package[$gems_deps_packages],
  }
}
