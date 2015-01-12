source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake',                   '~> 10.4.2', :require => false
  gem 'puppetlabs_spec_helper', '~> 0.8.2',  :require => false
  gem 'rspec',                  '< 3.0.0',   :require => false
  gem 'rspec-puppet',           '~> 1.0.1',  :require => false
  gem 'puppet-lint',            '~> 1.1.0',  :require => false
end

group :system_tests do
  gem 'beaker-rspec', :require => false
  gem 'serverspec',   :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '3.4.3', :require => false
end

gem 'java-properties', '~> 0.0.2',  :require => false
gem 'pg',              '~> 0.17.1', :require => false

# vim:ft=ruby et ts=2
