# frozen_string_literal: true

require 'spec_helper'

describe 'dispatcher::farm', type: :define do
  let(:hiera_config) { 'spec/hiera.yaml' }
  let(:pre_condition) do
    <<~PUPPETFILE
      class { 'apache' : }
    PUPPETFILE
  end

  describe 'vanityurls' do
    on_supported_os.each do |os, os_facts|
      describe "on #{os}" do
        context 'default parameters' do
          let(:facts) { os_facts }
          let(:title) { 'namevar' }

          it { is_expected.not_to contain_concat__fragment('namevar-farm-vanityurls') }
        end
        context 'custom parameters' do
          let(:facts) { os_facts.merge(testname: 'customparams') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat__fragment('customparams-farm-vanityurls').with(target: 'dispatcher.50-customparams.inc.any', order: 60) }
          it { is_expected.to contain_concat__fragment('customparams-farm-vanityurls').with(content: %r{^\s{2}/vanity_urls\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-vanityurls').with(content: %r{^\s{4}/url "/libs/granite/dispatcher/content/vanityUrls.html"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-vanityurls').with(content: %r{^\s{4}/file "/path/to/vanity/urls"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-vanityurls').with(content: %r{^\s{4}/delay 6000$}) }
        end
      end
    end
  end
end
