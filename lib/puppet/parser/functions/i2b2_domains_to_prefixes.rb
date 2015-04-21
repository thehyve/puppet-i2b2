module Puppet::Parser::Functions
  newfunction(:i2b2_domains_to_prefixes, :type => :rvalue, :doc => <<-'EOS'
    Extracts default prefixes to allow for a list of i2b2 domain specifications.
  EOS
  ) do |arguments|
    domains, = arguments

    if (domains.instance_of?(Hash))
      raise(Puppet::ParseError, "i2b2_domains_to_prefixes(): expected a hash," \
          "got #{domains} with type #{domains.class}")
    end

    domains.map { |d|
      pmUrl = d['urlCellPM']
      if !pmUrl
        raise(Puppet::ParseError, "i2b2_domains_to_prefixes(): expected to " \
          "find urlCellPm key in domain specification, got #{d}")
      end

      result = pmUrl.sub(/(\/services\/)PMService(:?\/)?\z/, '\\1')
      if result == pmUrl
        raise(Puppet::ParseError, "i2b2_domains_to_prefixes(): don't know " \
            "how to create allowed prefix from #{pmUrl}, fix the PM cell URL " \
            "or, if actually correct, provide an explicit list of allowed " \
            "prefixes")
      end

      result
    }
  end
end
