# private class
class i2b2::profile::cells {
  include ::i2b2::cells::pm
  include ::i2b2::cells::hive
  include ::i2b2::cells::ontology
  include ::i2b2::cells::crc
  include ::i2b2::cells::workspace
  include ::i2b2::cells::im
  include ::i2b2::cells::frc
}
