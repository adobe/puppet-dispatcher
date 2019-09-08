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

  describe 'cache' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:params) { default_params }

        describe 'minimal parameters' do
          it { is_expected.to contain_concat__fragment('namevar-farm-cache').with(target: 'dispatcher.00-namevar.inc.any', order: 80) }
          it { is_expected.to contain_concat__fragment('namevar-farm-cache').with(content: %r{^\s{2}/cache\s\{$}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-cache').with(content: %r{^\s{4}/docroot\s"/path/to/docroot"$}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-cache').with(content: %r{\s{4}/rules\s\{$}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-cache').with(content: %r{\s{6}/0000 \{ /type "allow" /glob "\*.html" \}$}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-cache').with(content: %r{\s{4}/allowedClients\s\{$}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-cache').with(content: %r{\s{6}/0000 \{ /type "deny" /glob "*.*.*.*" \}$}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/statfile}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/serveStaleOnError}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/allowAuthorized}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/statfileslevel}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/invalidate}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/invalidateHandler}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/ignoreUrlParams}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/headers}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/mode}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/gracePeriod}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-cache').with(content: %r{/enableTTL}) }
        end

        context 'custom parameters' do
          let(:facts) { os_facts.merge(testname: 'customparams') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(target: 'dispatcher.50-customparams.inc.any', order: 80) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{2}/cache\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/docroot\s"/different/path/to/docroot"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/statfile\s"/path/to/statfile"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/serveStaleOnError\s"1"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/allowAuthorized\s"1"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/rules\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}/0000 \{ /type "allow" /glob "\*.html" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}/0001 \{ /type "deny" /glob "\*.js" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/statfileslevel\s"3"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/invalidate\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}/0000 \{ /type "deny" /glob "\*.html" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}/0001 \{ /type "allow" /glob "\*.jpg" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/invalidateHandler\s"/opt/dispatcher/scripts/invalidate.sh"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/allowedClients\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}/0000 \{ /type "deny" /glob "*.*.*.*" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}/0001 \{ /type "allow" /glob "127.0.0.1" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/ignoreUrlParams\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}/0000 \{ /type "deny" /glob "\*" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}/0001 \{ /type "allow" /glob "q" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/headers\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}"Content-Type"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{6}"Cache-Control"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/mode\s"0660"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/gracePeriod\s"10"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{\s{4}/enableTTL\s"1"$}) }
        end
      end
    end
  end
end
