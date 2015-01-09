class i2b2::export_xls inherits i2b2::params
{
  require i2b2::webclient

  $export_xls_dir = "$i2b2::params::intermediate_dir/export_xls"
  $export_xls_zip = "$export_xls_dir.zip"
  $webclient_dir = $i2b2::webclient::webclient_dir

  $sed_add_jquery = 'sed -i \'0,/<script/ s#<script#<script type="text/javascript" src="js-ext/jquery-1.6.1.min.js"></script>\n<script>\n\tvar $j = jQuery.noConflict();\n</script>\n<script#\' '
  $sed_add_cell = 'sed -i \'0,/i2b2.hive.tempCellsList/ s#i2b2.hive.tempCellsList = \[#i2b2.hive.tempCellsList = \[\n{ code: "ExportXLS",\nforceLoading: true,\nforceConfigMsg: { params: [] },\nforceDir: "cells/plugins/standard"\n},#\' '

  Exec {
    path => '/bin:/usr/bin',
  }

  wget::fetch { $export_xls_zip :
    source      => 'http://files.thehyve.net/ExportXLS-v3.3_20140423.zip',
    destination => $export_xls_zip,
  }
  ~>
  exec { "create-empty-dir-$export_xls_dir" :
    command     => "rm -rf '$export_xls_dir' && mkdir '$export_xls_dir'",
    refreshonly => true,
  }
  ~>
  exec { "extract-$export_xls_dir":
    cwd         => $export_xls_dir,
    command     => "bsdtar -xf '$export_xls_zip' --strip-components=1",
    refreshonly => true,
  }
  ~>
  exec { "copy-$export_xls_dir" :
    command     => "cp -r '$export_xls_dir/webclient/' '$webclient_dir/..'",
    refreshonly => true,
  }
  ~>
  exec { 'insert-script-tag-jQuery' :
    command     => "$sed_add_jquery $webclient_dir/default.htm",
    refreshonly => true,
  }
  ~>
  exec { 'insert-cell-list' :
    command     => "$sed_add_cell $webclient_dir/js-i2b2/i2b2_loader.js",
    refreshonly => true,
  }

  file { $export_xls_zip:
    require => Wget::Fetch[$export_xls_zip],
  }
}
