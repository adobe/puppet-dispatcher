# frozen_string_literal: true

require 'spec_helper'

describe 'dispatcher::farm', type: :define do
  let(:hiera_config) { 'spec/hiera.yaml' }
  let(:pre_condition) do
    <<~PUPPETFILE
      class { 'apache' : }
    PUPPETFILE
  end

  describe 'header' do
    on_supported_os.each do |os, os_facts|
      describe "on #{os}" do
        context 'default parameters' do
          let(:facts) { os_facts }
          let(:title) { 'namevar' }

          it { is_expected.to contain_concat__fragment('namevar-farm-header').with(target: 'dispatcher.00-namevar.inc.any', order: 0, content: %r{^/namevar}) }
        end
        context 'custom parameters' do
          let(:facts) { os_facts.merge(testname: 'customparams') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat__fragment('customparams-farm-header').with(target: 'dispatcher.50-customparams.inc.any', order: 0, content: %r{^/customparams}) }
        end
      end
    end
  end
end
