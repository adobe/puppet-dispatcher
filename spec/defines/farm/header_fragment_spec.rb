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

  describe 'header' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:params) { default_params }

        describe 'default parameters' do
          it { is_expected.to contain_concat__fragment('namevar-farm-header').with(target: 'dispatcher.00-namevar.inc.any', order: 0, content: %r{^/namevar}) }
        end
      end

      context 'custom parameters' do
        let(:facts) { os_facts.merge(testname: 'customparams') }
        let(:title) { 'customparams' }

        it { is_expected.to contain_concat__fragment('customparams-farm-header').with(target: 'dispatcher.50-customparams.inc.any', order: 0, content: %r{^/customparams}) }
      end
    end
  end
end
