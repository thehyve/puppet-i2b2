source 'https://rubygems.org'

group :development, :test do
  gem 'rake',                   '~> 10.4.2', :require => false
  gem 'puppetlabs_spec_helper', '~> 1.1.1',  :require => false
  gem 'rspec',                  '< 3.0.0',   :require => false
  gem 'rspec-puppet',           '~> 2.4.0',  :require => false
  gem 'puppet-lint',            '~> 1.1.0',  :require => false
end

group :system_tests do
  gem 'beaker-rspec', :require => false
  gem 'serverspec',   :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '~> 4.5.1', :require => false
end

gem 'java-properties', '~> 0.0.2',  :require => false
gem 'pg',              '~> 1.0.0', :require => false

# vim:ft=ruby et ts=2
