require 'spec_helper'

describe 'i2b2_project_massage_lookup', :type => :puppet_function do
  let(:project) { 'sample_project' }
  let(:domain) { 'sample_domain' }
  let(:hive_user) { 'i2b2hive' }
  let(:db_type) { 'postgresql' }

  let(:args) { [project, domain, hive_user, db_type, associations] }

  describe 'result of the call with two cells' do
    subject {
      super().call args
    }

    let(:associations) {
      {
          'ontology' => 'i2b2metadata',
          'im'       => 'i2b2im',
      }
    }

    it 'returns an array with two elements' do
      expect(subject.size).to eq 2
    end

    it 'contains the correct hash keys' do
      expect(subject.keys).to include("lookup-#{project}-ontology",
                                      "lookup-#{project}-im")
      p subject
    end

    describe "value of ontology entry" do
      subject {
        super()["lookup-#{project}-ontology"]
      }

      it "has the correct table" do
        is_expected.to include(table: "#{hive_user}.ont_db_lookup",)
      end

      it "has the correct identity" do
        is_expected.to include(identity:
                                   {
                                       c_domain_id: domain,
                                       c_project_path: "#{project}/",
                                       c_owner_id: '@'
                                   }
                       )
      end

      it "has the correct values" do
        is_expected.to include(values:
                              {
                                  c_db_fullschema: 'i2b2metadata',
                                  c_db_datasource: 'java:/i2b2metadata',
                                  c_db_servertype: 'POSTGRESQL',
                                  c_db_nicename:   'ontology',
                              }
                       )
      end
    end
  end

  describe 'call with crc cell' do
    subject {
      super().call args
    }

    let(:associations) { { 'crc' => 'i2b2demodata', } }

    it "project is in form /project/" do
      expect(subject["lookup-#{project}-crc"][:identity]).to(
          include(c_project_path: "/#{project}/"))
    end
  end

  context 'called with invalid cell' do
    let(:associations) {
      {
          'foo' => 'i2b2metadata',
      }
    }

    it 'raises error' do
      is_expected.to run.with_params(*args).
                         and_raise_error /bad cell/
    end
  end
end
