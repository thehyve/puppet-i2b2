require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'thehyve', 'i2b2_param_mixin.rb'))

Puppet::Type.newtype(:i2b2_user_roles) do
  extend PuppetX::Thehyve::I2b2ParamMixin

  const VALID_ROLES = %{DATA_OBFSC DATA_AGG DATA_LDS DATA_DEID DATA_PROT USER MANAGER ADMIN}

  @doc = <<-'EOT'
      Represents a set of roles that a user has in a project.
  EOT

  newparam :username do
    isnamevar

    desc 'The i2b2 username.'
  end

  newparam :project do
    isnamevar

    desc 'The project id.'
  end

  newproperty :roles do
    isrequired

    desc 'An array with the roles to assign.'

    validate do |value|
      fail 'Must be an array' unless value.instance_of?(Array)

      def insync?(is)
        is.sort == should.sort
      end

      value.each do |v|
        # allow a role we don't recognize if it was already there
        if retrieve.include?(v) and not VALID_ROLES.include?(v)
          warn "Found current unrecognized role: #{v}"
        end
        fail "Not a valid role: #{v}. Valid roles are #{VALID_ROLES}" unless
            VALID_ROLES.include?(v) or retrieve.include?(v)
      end
    end
  end

  # end of parameters

  def table
    "#{schema}.pm_project_user_roles"
  end

  def self.title_patterns
    [
        [
            /\A(.+):(.+)\z/m,
            [
                [:username, lambda{|x| x}],
                [:project,  lambda{|x| x}],
            ]
        ]
    ]
  end

  autorequire(:'i2b2::user_roles') do
    [self[:username]]
  end

  autorequire(:'i2b2::project') do
    [self[:project]]
  end

  private

  def schema
    resource = catalog.resource('Class[I2b2::Params]')
    fail "Could not find resource Class[I2b2::Params]" if resource.nil?

    result = resource[:pm_db_user]
    fail "Value for param 'pm_db_user' of Class[I2b2::Params] is nil" if result.nil?

    result
  end

end
