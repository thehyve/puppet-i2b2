require 'spec_helper_acceptance'

describe 'i2b2 full stack with postgresql/apache' do
  it 'applies the manifest without problems' do
    pp = <<-EOS
      include i2b2::profile::postgresql::i2b2_params
      include i2b2::profile::tomcat::i2b2_params
      $merged_params = merge(
          $i2b2::profile::tomcat::i2b2_params::data,
          $i2b2::profile::postgresql::i2b2_params::data)

      $t = {
          'i2b2::params' => $merged_params,
      }
      create_resources('class', $t)

      include i2b2::profile::postgres
      include i2b2::profile::tomcat
      include i2b2::profile::apache
      include i2b2::export_xls

      # database must be set up before
      Class['I2b2::Profile::Postgres'] -> Class['I2b2::Profile::Tomcat']
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  request = <<-EOS
<i2b2:request xmlns:i2b2="http://www.i2b2.org/xsd/hive/msg/1.1/" xmlns:pm="http://www.i2b2.org/xsd/cell/pm/1.1/">
    <message_header>
        <proxy>
            <redirect_url>http://localhost:8080/i2b2/services/PMService/getServices</redirect_url>
        </proxy>

        <i2b2_version_compatible>1.1</i2b2_version_compatible>
        <hl7_version_compatible>2.4</hl7_version_compatible>
        <sending_application>
            <application_name>i2b2 Project Management</application_name>
            <application_version>1.6</application_version>
        </sending_application>
        <sending_facility>
            <facility_name>i2b2 Hive</facility_name>
        </sending_facility>
        <receiving_application>
            <application_name>Project Management Cell</application_name>
            <application_version>1.6</application_version>
        </receiving_application>
        <receiving_facility>
            <facility_name>i2b2 Hive</facility_name>
        </receiving_facility>
        <datetime_of_message>2015-01-12T03:20:40+01:00</datetime_of_message>
        <security>
          <domain>i2b2default</domain>
          <username>i2b2</username>
          <password>foobar</password>
        </security>
        <message_control_id>
            <message_num>LGys5pt92z1TXJVza5Q1Z</message_num>
            <instance_num>0</instance_num>
        </message_control_id>
        <processing_id>
            <processing_id>P</processing_id>
            <processing_mode>I</processing_mode>
        </processing_id>
        <accept_acknowledgement_type>AL</accept_acknowledgement_type>
        <application_acknowledgement_type>AL</application_acknowledgement_type>
        <country_code>US</country_code>
        <project_id>undefined</project_id>
    </message_header>
    <request_header>
        <result_waittime_ms>180000</result_waittime_ms>
    </request_header>
    <message_body>
        <pm:get_user_configuration>
            <project>undefined</project>
        </pm:get_user_configuration>
    </message_body>
</i2b2:request>
  EOS

  it 'logs in to the webclient' do
    body_path = '/tmp/i2b2_request.xml'
    create_remote_file default, body_path, request
    curl(['https://localhost/webclient/index.php',
         '-kH', "'Content-type: text/xml; charset=UTF-8'",
         '--data-binary', "@/#{body_path}"]) do |r|
      result = r.stdout
      expect(result).to match(/<cell_data id="WORK">/)
      expect(result).to match(/<cell_data id="IM">/)
      expect(result).to match(/<cell_data id="ONT">/)
      expect(result).to match(/<cell_data id="FRC">/)
      expect(result).to match(/<cell_data id="CRC">/)
    end

  end
end
