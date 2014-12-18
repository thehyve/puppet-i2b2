require 'spec_helper'
require_relative 'uses_temp_files'
require 'fileutils'
require 'java-properties'

describe Puppet::Type.type(:modified_properties_file) do
  provider_class = described_class.provider(:modified_properties_provider)

  let :resource_hash do
    {
        title: 'foo',
        name: '/non_existant',
        source: File.expand_path('./spec/integration/files/1.properties'),
        values: { a: 3 }, # not in sync with files/1.properties
    }
  end

  let :type_instance do
    result = described_class.new(resource_hash)
    provider_instance = provider_class.new(resource_hash)
    result.provider = provider_instance
    result
  end

  let :result_hash do
    JavaProperties.load(type_instance[:name])
  end

  describe 'bad parameters' do

    context 'when target is not a fully qualified file' do
      before { resource_hash[:name] = 'foobar' }
      it 'raises error' do
        expect { type_instance }.to raise_error Puppet::Error, /Parameter target failed.*not 'foobar'/
      end
    end

    context 'when source is not a fully qualified file' do
      before { resource_hash[:source] = 'bar'}
      it 'raises error' do
        expect { type_instance }.to raise_error Puppet::Error, /Parameter source failed.*not 'bar'/
      end
    end

    context 'when source does not exist' do
      before { resource_hash[:source] = '/not-here'}
      it 'raises error' do
        expect { type_instance }.to raise_error Puppet::Error, /File '\/not-here' does not exist/
      end
    end

    context 'when source is not specified' do
      let(:resource_hash) { r = super(); r.delete :source; r }
      it 'needs target to exist' do
        expect { type_instance }.to raise_error Puppet::Error, /File '\/non_existant' must exist and be a file unless/
      end
    end

    context 'when values contains is not a hash' do
      before { resource_hash[:values] = 'bar' }
      it 'raises error' do
        expect { type_instance }.to raise_error Puppet::Error, /replacements must be a hash, got 'bar'/
      end
    end

    context 'when values contains an array as value' do
      before { resource_hash[:values][:bar] = [1, 2] }
      it 'raises error' do
        expect { type_instance }.to raise_error(
                                        Puppet::Error,
                                        /replacement values cannot be hashes or arrays, got \[1, 2\]/)
      end
    end
  end # end describe bad parameters

  context 'when source is not set' do
    include UsesTempFiles

    let(:resource_hash) do
      r = super()

      new_file = full_path_for('our_file')
      FileUtils.cp(r[:source], new_file)

      r.delete :source
      r[:name] = new_file
      r
    end

    context 'when the values are the same as the template' do
      before { resource_hash[:values] = {a: 1, b: '2 3'} }
      it 'is in sync' do
        expect(
          type_instance.insync?(type_instance.retrieve)
        ).to be true
      end
    end

    context 'when the values differ from the template' do
      it 'is not in sync' do
        expect(type_instance.insync?(type_instance.retrieve)).to be false
      end
    end

    describe '#refresh' do
      context 'when there are different values' do
        it 'is reflected in the output' do
          type_instance.refresh

          expect(result_hash).to include({a: '3', b: '2 3'})
        end
      end

      context 'when there are extra keys' do
        before { resource_hash[:values] = {a: 1, b: '2 3', c: 4} }

        context 'and we do not allow such thing' do
          it 'raises an error' do
            expect { type_instance.refresh }.to raise_error(Puppet::Error, /Parameter allow_new not set/)
          end
        end

        context 'and allow_new is set to true' do
          before { resource_hash[:allow_new] = :true }

          it 'is written to the output' do
            type_instance.refresh

            expect(result_hash).to include(c: '4')
          end
        end
      end
    end
  end

  context 'when source is set' do
    include UsesTempFiles

    let(:resource_hash) do
      r = super()

      new_file = full_path_for('template_file')
      FileUtils.cp(r[:source], new_file)
      r[:source] = new_file
      r[:name] = full_path_for('result_file')
      r
    end

    describe '#refresh' do
      it 'does not change the template' do
        type_instance.refresh

        result = JavaProperties.load(type_instance[:source])
        expect(result).to include({a: '1', b: '2 3'})
      end

      it 'creates the output file' do
        type_instance.refresh
        expect(result_hash).to include({a: '3', b: '2 3'})
      end
    end
  end


end
