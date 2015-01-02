class i2b2::cells::pm inherits i2b2::params {
  require i2b2::i2b2src_files
  require i2b2::cells::hive

  $src_dir = "$i2b2::i2b2src_files::dir/edu.harvard.i2b2.pm"

  i2b2::cells::common { 'pm':
    cell_source_dir    => $src_dir,
    user               => $params::user,
    file_to_check      => 'ProjectManagement-core.jar',
    bootstrap_prefix   => 'PM',
    bootstrap_user     => $params::pm_db_user,
    bootstrap_password => $params::pm_db_password,
    ant_build_xml      => 'build.xml',
    targets            => ['clean', 'dist', 'deploy']
  }
}
