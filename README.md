puppet-i2b2
===========

[![Build Status](https://travis-ci.org/thehyve/puppet-i2b2.svg?branch=master)](https://travis-ci.org/thehyve/puppet-i2b2)
[![Code Climate](https://codeclimate.com/github/thehyve/puppet-i2b2/badges/gpa.svg)](https://codeclimate.com/github/thehyve/puppet-i2b2)

Module for installing i2b2, including the server part, the webclient and the
admin interface.

System tests
------------

To run the system tests, you need Vagrant installed. Then, run:

    bundle exec rspec spec/acceptance

Some environment variables may be useful:

    BEAKER_debug=true
    BEAKER_provision=no
    BEAKER_destroy=no

The `BEAKER_debug` variable shows the commands being run on the STU and their
output. `BEAKER_destroy=no` prevents the machine destruction after the tests
finish so you can inspect the state. `BEAKER_provision=no` prevents the machine
from being recreated. This can save a lot of time while you're writing the
tests. You will want to comment out the commands run on the host on
`spec_helper_acceptance.rb` as well.
