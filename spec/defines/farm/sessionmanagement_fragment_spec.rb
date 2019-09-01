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
        describe 'sessionmanagement' do
          it do
            is_expected.not_to contain_concat__fragment('namevar-farm-sessionmanagement')
          end
        end
      end

      context 'custom parameters' do
        let(:facts) { os_facts.merge(testname: 'customparams') }
        let(:title) { 'customparams' }

        describe 'sessionmanagement' do
          it do
            is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(
              target: 'dispatcher.50-customparams.inc.any',
              order:  30,
            )
          end
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/sessionmanagement\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/directory "/path/to/sessions"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/encode "sha1"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/header "HTTP:authorization"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/timeout "90"$}) }
          context 'encode' do
            let(:params) do
              tmp = default_params.merge(sessionmanagement: { directory: '/path/to/sessions', encode: 'md5' })
              tmp
            end

            it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/encode "md5"$}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/header}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/timeout}) }
          end
          context 'header' do
            let(:params) do
              tmp = default_params.merge(sessionmanagement: { directory: '/path/to/sessions', header: 'Cookie:name-of-cookie' })
              tmp
            end

            it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/header "Cookie:name-of-cookie"$}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/encode}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/timeout}) }
          end
          context 'timeout' do
            let(:params) do
              tmp = default_params.merge(sessionmanagement: { directory: '/path/to/sessions', timeout: 1000 })
              tmp
            end

            it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/timeout "1000"$}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/encode}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{/header}) }
          end
        end
      end
    end
  end
end
