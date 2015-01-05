require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'thehyve', 'i2b2_param_mixin.rb'))

Puppet::Type.newtype(:i2b2_user_roles) do
  extend PuppetX::Thehyve::I2b2ParamMixin

  VALID_ROLES = %w{DATA_OBFSC DATA_AGG DATA_LDS DATA_DEID DATA_PROT USER MANAGER ADMIN}

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

  newproperty :roles, :array_matching => :all do
    isrequired

    desc 'An array with the roles to assign.'

    def insync?(is)
      is.sort == should.sort
    end

    def sync
      deferred_validate(should)
      set(should)
    end

    # validation must be deferred because whether a value is valid
    # depends on the current value, and the current value cannot be
    # made available when the validation occurs (depends on parameters
    # not assigned yet, like system_user)
    def deferred_validate(values)
      cur_values = retrieve
      devfail("#{cur_values} is not an array") unless cur_values.instance_of?(Array)

      values.each do |v|
        # allow a role we don't recognize if it was already there
        if cur_values.include?(v) and not VALID_ROLES.include?(v)
          warn "Found current unrecognized role: #{v}"
        end
        fail "Not a valid role: #{v}. Valid roles are #{VALID_ROLES}" unless
            VALID_ROLES.
                include?(v) or cur_values.include?(v)
      end
    end
  end

  create_system_user_param

  create_connect_params_param

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

  def autorequire(rel_catalog = nil)
    res = []
    role = rel_catalog.resource(:'I2b2::I2b2_user', self[:username])
    fail("Could not find I2b2::I2b2_user[#{self[:username]}]") if role.nil?

    res << Puppet::Relationship.new(role, self)

    unless self[:project] == '@'
      project = rel_catalog.resource(:'I2b2::Project', self[:project])
      fail("Could not find I2b2::Project[#{self[:project]}]") if project.nil?

      res << Puppet::Relationship.new(project, self)
    end

    res
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
