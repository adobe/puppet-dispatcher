# frozen_string_literal: true

require 'spec_helper'

describe 'dispatcher::farm', type: :define do
  let(:hiera_config) { 'spec/hiera.yaml' }
  let(:pre_condition) do
    <<~PUPPETFILE
      class { 'apache' : }
    PUPPETFILE
  end

  describe 'sessionmanagement' do
    on_supported_os.each do |os, os_facts|
      describe "on #{os}" do
        context 'default parameters' do
          let(:facts) { os_facts }
          let(:title) { 'namevar' }

          it { is_expected.not_to contain_concat__fragment('namevar-farm-sessionmanagement') }
        end

        context 'custom parameters' do
          let(:facts) { os_facts.merge(testname: 'customparams') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(target: 'dispatcher.50-customparams.inc.any', order: 30) }
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s{2}/sessionmanagement\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s{4}/directory "/path/to/sessions"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s{4}/encode "sha1"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s{4}/header "HTTP:authorization"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s{4}/timeout "90"$}) }
          context 'encode' do
            let(:params) { { sessionmanagement: { directory: '/path/to/sessions', encode: 'md5' } } }

            it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s{4}/encode "md5"$}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/header}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/timeout}) }
          end
          context 'header' do
            let(:params) { { sessionmanagement: { directory: '/path/to/sessions', header: 'Cookie:name-of-cookie' } } }

            it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s{4}/header "Cookie:name-of-cookie"$}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/encode}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/timeout}) }
          end
          context 'timeout' do
            let(:params) { { sessionmanagement: { directory: '/path/to/sessions', timeout: 1000 } } }

            it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s{4}/timeout "1000"$}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/encode}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/header}) }
          end
        end
      end
    end
  end
end
