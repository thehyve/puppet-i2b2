class i2b2::profile::tomcat::context_file(
  $path
) inherits i2b2::params {
  $doc_base = $::i2b2::params::exploded_war_dir
  $context  = $::i2b2::params::context

  $resources_fragments = "$i2b2::params::intermediate_dir/tomcat_resources.xml.fragments"

  $begin_template = '<Context docBase="<%= @doc_base %>" path="/<%= @context %>" crossContext="true">'
  concat::fragment { "${path}-begin":
    target  => $path,
    order   => '1',
    content => inline_template("$begin_template\n"),
  }

  concat { $resources_fragments: }
  ->
  concat::fragment { "${path}-resources":
    target => $path,
    order  => '2',
    source => $resources_fragments,
  }

  concat::fragment { "${path}-epilog":
    target  => $path,
    order   => '3',
    content => "</Context>\n",
  }

  concat { $path: }
}
