class i2b2::packages(
  $bsdtar_package     = $params::bsdtar_package,
  $ant_package        = $params::ant_package,
  $java_package       = $params::java_package,
  $gems_deps_packages = $params::gems_deps_packages,
) inherits i2b2::params {

  ensure_resource('package', $bsdtar_package)
  ensure_resource('package', $ant_package)
  ensure_resource('package', $java_package)
  ensure_resource('package', $gems_deps_packages)

  package { ['java-properties', 'pg']:
    provider =>  gem,
    require  => Package[$gems_deps_packages],
  }
}
