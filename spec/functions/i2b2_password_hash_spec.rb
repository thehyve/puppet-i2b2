require 'spec_helper'

describe 'i2b2_password_hash', :type => :puppet_function do
  it 'gives results without zeros in odd positions' do
    is_expected.to run.with_params('demouser').
               and_return '9117d59a69dc49807671a51f10ab7f'
  end
end
