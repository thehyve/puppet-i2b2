require 'digest'

module Puppet::Parser::Functions
  newfunction(:i2b2_password_hash, :type => :rvalue, :doc => <<-'EOS'
    A bug-compatible implementation of the md5 hashing that i2b2 uses.
    The bug is in the binary to hex string conversion. Bytes are converted into
    their hexadecimal values, but any leading 0 is omitted.
  EOS
  ) do |arguments|
    plain_password, = arguments

    md5 = Digest::MD5.new
    md5 << plain_password.encode('UTF-8')
    intermediate = md5.hexdigest

    result = ''
    consider_skip = true
    intermediate.each_char do |c|
      skip = (consider_skip and c == '0')
      result << c unless skip
      consider_skip = ! consider_skip
    end

    result
  end
end
