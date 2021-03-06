class i2b2::cells::hive inherits i2b2::params {
  # pseudo-cell
  require i2b2::i2b2src_files
  # if exploded_war runs later it will replace some files copied here
  require i2b2::exploded_war

  $src_dir = "$i2b2::i2b2src_files::dir/edu.harvard.i2b2.server-common"

  i2b2::cells::common { 'hive':
    cell_source_dir => $src_dir,
    user            => $::i2b2::params::user,
    file_to_check   => 'i2b2Common-core.jar',
    ant_build_xml   => 'build.xml',
    targets         => ['clean', 'dist', 'deploy', 'jboss_pre_deployment_setup']
  }
}
