Puppet::Type.newtype(:modified_properties_file) do

  @doc = "Makes property value replacements in a Java property file, either
          overwriting the original file or creating a new one. This
          generation is triggered either when this type receives a
          refresh even, when the target file does not exist or when one of
          the property values doesn't match or does not exist.
          This type will automatically depend on the source file and
          subscribe to it, provided its title is the path."

  def self.new_file_param(name, options = {}, &block)
    newparam name, options do
      instance_eval &block

      old_validate = instance_method(:unsafe_validate)
      validate do |value|
        unless Puppet::Util.absolute_path?(value)
          fail Puppet::Error, "File paths must be fully qualified, not '#{value}'"
        end
        old_validate.bind(self)[value] unless !old_validate
      end

      old_munge = instance_method(:unsafe_munge)
      munge do |value|
        r_value = File.join(File.split(File.expand_path(value)))
        old_munge.bind(self)[r_value] unless !old_munge
      end
    end
  end

  new_file_param :target, :namevar => true do
    desc <<-'EOT'
      The path to the properties file to manage. Either this should file should
      already exist, or the source parameter needs to be specified.
    EOT
  end

  new_file_param :source do
    desc <<-'EOT'
      The source file to use as a template. Otherwise, :target is used as the
      template, in which case it should preexist.
    EOT

    validate do |value|
      unless value.nil? or File.file?(value)
        fail "File '#{value}' does not exist or is not a file"
      end
    end
  end

  # :boolean => true generates an allow_new? method in the type
  newparam :allow_new, :boolean => true do
    desc 'Whether it should be allowed to add values that are not in the template'

    defaultto :false
    newvalues :true, :false
  end

  newproperty :values do
    isrequired

    desc 'The properties and their values'

    validate do |value|
      fail "replacements must be a hash, got '#{value}'" unless value.instance_of?(Hash)
      value.each_value do |v|
        fail "replacement values cannot be hashes or arrays, got #{v} (class #{v.class})" if
            v.instance_of? Hash or v.instance_of? Array
      end
    end

    munge do |value|
      # normalize to symbol -> string (UTF-8)
      value.inject({}) do |memo, (k, v)|
        memo[k.to_sym] = v.to_s.encode('utf-8')
        memo
      end
    end

    def retrieve
      return :absent unless File.file?(@resource[:target])
      provider.current_values
    end

    def set(value)
      provider.refresh
    end

    def insync?(is)
      return false if is == :absent

      # go over each one
      result = true
      should.each_pair do |key, desired_value|
        cur_value = is[key]
        if cur_value.nil? or not cur_value == desired_value
          Puppet.notice "Key #{key} is out of sync: '#{cur_value}' should be '#{desired_value}'"
          result = false
        end
      end

      result
    end
  end

  # end properties / params

  def template_file
    self[:source] || self[:target]
  end

  validate do
    # global validation
    unless self[:source] or File.file?(self[:target])
      fail "File '#{self[:target]}' must exist and be a file unless source is specified"
    end
  end

  # respond to refreshes by calling refresh on the provider
  def refresh
    provider.refresh
  end

  def autorequire(rel_catalog = nil)
    reqs = super

    rel_catalog ||= catalog

    if dep = rel_catalog.resource(:file, template_file)
      reqs << Puppet::Relationship.new(dep, self, :event => :ALL_EVENTS, :callback => :refresh)
    end

    reqs
  end
end
