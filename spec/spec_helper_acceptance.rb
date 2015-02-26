require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

def curl(args, &block)
  shell(Beaker::Command.new('curl', args), &block)
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    puppet_module_install(:source => proj_root, :module_name => 'i2b2')
  end

  tomcat_distr_url = 'https://gist.github.com/cataphract/' \
      'aad72ccf7c1d8c3208c7/raw/3bbf6f269d7dce05e5e596736ecd555b454c854f/' \
      'tomcat_distr-7ab0c6a.tar.bz2'
  port_uq_convert_url = 'https://gist.github.com/cataphract/' \
      'aad72ccf7c1d8c3208c7/raw/ca0d042d3f63f1f29c380fc125c3d14a385fc4d6/' \
      'port_uq_convert.rb'

  c.logger = Beaker::Logger.new(log_level: 'debug', color: false)

  if ENV['BEAKER_provision'] == 'yes' 
    hosts.each do |host|
      on host, 'apt-get update'
      on host, 'apt-get install -y puppet wget'
      on host, 'touch /etc/puppet/hiera.yaml'
  
      # TODO: checkout our private modules repository instead
      on host, puppet('module', 'install', 'puppetlabs-stdlib', '--version', '4.2.1')
      on host, puppet('module', 'install', 'puppetlabs-postgresql', '--version', '4.0.0')
      on host, puppet('module', 'install', '--force', 'puppetlabs-concat', '--version', '1.1.0-rc1')
      on host, puppet('module', 'install', 'puppetlabs-apache', '--version', '1.1.1')
      on host, puppet('module', 'install', 'b4ldr-logrotate', '--version', '1.1.2')
      on host, puppet('module', 'install', 'maestrodev-wget', '--version', '1.1.0')
      on host, 'mkdir -p /etc/puppet/modules'
      on host, "wget -O - '#{tomcat_distr_url}' | tar -C /etc/puppet/modules -xJf -"
      on host, "mkdir -p /var/lib/puppet/lib/puppet/parser/functions/"
      on host, "wget -O /var/lib/puppet/lib/puppet/parser/functions/port_uq_convert.rb " \
               "'#{port_uq_convert_url}'"
    end
  end
end
