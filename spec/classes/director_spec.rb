require 'spec_helper'

describe 'gernox_bareos::director' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:pre_condition) do
        <<-PUPPET
        class gernox_bareos::director::client {}
        PUPPET
      end

      context 'compile' do
        let(:params) do
          {
            webui_password: 'pwd1',
            director_password: 'pwd2',
            storage_password: 'pwd3',
            db_password: 'pwd4',
            manage_apache: false,
          }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
