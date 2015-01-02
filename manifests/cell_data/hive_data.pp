class i2b2::cell_data::hive_data {
  require i2b2::cell_schemas::pm
  include i2b2::params

  table_row { 'hive-data':
    table    => "$params::pm_db_user.pm_hive_data",
    identity => {
      domain_id =>
      $params::hive_domain_id
    },
    values   => {
      helpurl        => $params::hive_help_url,
      domain_name    => $params::hive_domain_name,
      environment_cd => $params::hive_environment,
      active         => 1,
      status_cd      => 'A',
    },
  }
}
