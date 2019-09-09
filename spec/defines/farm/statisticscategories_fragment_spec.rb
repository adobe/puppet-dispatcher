# frozen_string_literal: true

require 'spec_helper'

describe 'dispatcher::farm', type: :define do
  let(:hiera_config) { 'spec/hiera.yaml' }
  let(:pre_condition) do
    <<~PUPPETFILE
      class { 'apache' : }
    PUPPETFILE
  end

  describe 'statistics_categories' do
    on_supported_os.each do |os, os_facts|
      describe "on #{os}" do
        context 'default parameters' do
          let(:facts) { os_facts }
          let(:title) { 'namevar' }

          it { is_expected.not_to contain_concat__fragment('namevar-farm-statisticscategories').with(target: 'dispatcher.00-namevar.inc.any', order: 100) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-statisticscategories').with(content: %r{/statistics\s+/categories}) }
        end
        context 'custom parameters' do
          let(:facts) { os_facts.merge(testname: 'customparams') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat__fragment('customparams-farm-statisticscategories').with(target: 'dispatcher.50-customparams.inc.any', order: 100) }
          it { is_expected.to contain_concat__fragment('customparams-farm-statisticscategories').with(content: %r{^\s{2}/statistics\s\{\n\s{4}/categories\s\{}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-statisticscategories').with(content: %r{^\s{6}/html \{ /glob "\*\.html" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-statisticscategories').with(content: %r{^\s{6}/others \{ /glob "\*" \}$}) }
        end
      end
    end
  end
end
