define i2b2::cell_data::pm_cell_registration(
  $url,
  $cell_id,
  $cell_name,
  $method,
) {
  include i2b2::params

  validate_re($method, '\AREST|SOAP\z')

  Class['I2b2::Cell_schemas::Pm']
  ->
  table_row { "${name}-cell-data":
    table    => "${::i2b2::params::pm_db_user}.pm_cell_data",
    identity => {
      'cell_id'      => $cell_id,
      'project_path' => '/',
    },
    values   => {
      method_cd    => 'REST',
      can_override => '1',
      status_cd    => 'A',
      name         => $cell_name,
      url          => $url,
    }
  }
}
