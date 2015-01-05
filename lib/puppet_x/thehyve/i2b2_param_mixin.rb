module PuppetX
module Thehyve
module I2b2ParamMixin

  def self.create_param_type(target_class, method_suffix, &block_constant)
    target_class.send(:define_method,
                      "new_#{method_suffix}") do |name, options = {}, &block_specific|

      gen_method = options[:create_property] ? :newproperty : :newparam
      options.delete :create_property

      method(gen_method).call name, options do
        # needs to be class_eval, not instance_eval. self is a class object
        # at this point, and instance_eval would make the default definee
        # (i.e. the target of unqualified definitions) inside the block
        # the singleton class of the self class object, instead of the class
        # itself (hence define_method would need to be called instead of just
        # def foo do ... end in order to override parameter methods)
        class_eval &block_constant

        first_validate = instance_method(:unsafe_validate)
        first_munge    = instance_method(:unsafe_munge)

        class_eval &block_specific if block_given?

        second_validate = instance_method(:unsafe_validate)
        second_munge    = instance_method(:unsafe_munge)

        # allow specific block to remove constant block's munge/validation

        if first_validate and second_validate and first_validate != second_validate
          validate do |value|
            first_validate.bind(self)[value]
            second_validate.bind(self)[value]
          end
        end

        if first_munge and second_munge and first_munge != second_munge
          munge do |value|
            first_value = first_munge.bind(self)[value]
            second_munge.bind(self)[first_value]
          end
        end
      end
    end
  end

  def create_param_type(method_suffix, &block_constant)
    # self will be a class object (this module will be extended, not included),
    # hence we'll be creating a method on the class's singleton class, i.e.
    # a class method on the class extending this module
    I2b2ParamMixin.create_param_type self.singleton_class,
                                     method_suffix, &block_constant
  end

  # creates instance method new_string_valued_hash_param on the module
  create_param_type self, 'string_valued_hash_param' do
    validate do |value|
      fail "'#{name}' must be a hash, got '#{value}'" unless value.instance_of?(Hash)
      value.each_pair do |k, v|
        fail 'cannot have hashes or arrays in hash values, ' \
              "got #{v} (class #{v.class}) for key '#{k}'" if
            v.instance_of? Hash or v.instance_of? Array
      end
    end

    munge do |value|
      value.inject({}) do |memo, (k, v)|
        memo[k.to_sym] = v.to_s.encode('utf-8')
        memo
      end
    end
  end

  def create_system_user_param
    newparam :system_user do
      desc 'If setting the uid is required, the system user to change to.'
    end

    autorequire(:user) do
      [self[:system_user]]
    end
  end
end
end
end
