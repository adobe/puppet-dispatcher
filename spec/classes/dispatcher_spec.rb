require 'spec_helper'

describe 'dispatcher' do

  let(:pre_condition) do
    'class { "apache" : }'
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end

  context 'requires Apache' do
    let(:pre_condition) { '' }

    it { is_expected.to raise_error(%r{You must include the Apache class}) }
  end
end
