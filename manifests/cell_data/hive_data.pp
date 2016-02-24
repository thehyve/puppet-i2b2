class i2b2::cell_data::hive_data {
  require i2b2::cell_schemas::pm
  include i2b2::params

  table_row { 'hive-data':
    table    => "$::i2b2::params::pm_db_user.pm_hive_data",
    identity => {
      domain_id =>
      $::i2b2::params::hive_domain_id
    },
    values   => {
      helpurl        => $::i2b2::params::hive_help_url,
      domain_name    => $::i2b2::params::hive_domain_name,
      environment_cd => $::i2b2::params::hive_environment,
      active         => 1,
      status_cd      => 'A',
    },
  }
}
