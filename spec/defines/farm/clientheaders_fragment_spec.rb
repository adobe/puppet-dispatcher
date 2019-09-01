# frozen_string_literal: true

require 'spec_helper'

describe 'dispatcher::farm', type: :define do
  let(:hiera_config) { 'spec/hiera.yaml' }
  let(:title) { 'namevar' }
  let(:pre_condition) do
    <<~PUPPETFILE
      class { 'apache' : }
    PUPPETFILE
  end
  let(:default_params) { {} }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params }

      describe 'default parameters' do
        it { is_expected.to contain_concat__fragment('namevar-farm-clientheaders').with(target: 'dispatcher.00-namevar.inc.any', order: 10) }
        it { is_expected.to contain_concat__fragment('namevar-farm-clientheaders').with(content: %r{^\s+/clientheaders\s\{$}) }
      end

      context 'custom parameters' do
        let(:facts) { os_facts.merge(testname: 'customparams') }
        let(:title) { 'customparams' }

        describe 'clientheaders' do
          it { is_expected.to contain_concat__fragment('customparams-farm-clientheaders').with(target: 'dispatcher.50-customparams.inc.any', order: 10) }
          it { is_expected.to contain_concat__fragment('customparams-farm-clientheaders').with(content: %r{^\s+/clientheaders\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-clientheaders').with(content: %r{^\s+"A-Client-Header"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-clientheaders').with(content: %r{^\s+"Another-Client-Header"$}) }
        end
      end
    end
  end
end
