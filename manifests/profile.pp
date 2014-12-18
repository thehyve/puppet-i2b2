class i2b2::profile {

  $include_webclient = hiera('i2b2::webclient::install')
  if $include_webclient == true {

  }
}
