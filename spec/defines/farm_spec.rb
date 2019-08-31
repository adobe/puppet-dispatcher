# frozen_string_literal: true

require 'spec_helper'

describe 'dispatcher::farm', type: :define do
  let(:hiera_config) { 'spec/hiera.yaml' }
  let(:title) { 'namevar' }
  let(:pre_condition) do
    <<~PUPPETFILE
      class { 'apache' : }
      class { 'dispatcher' :
        module_file => '/path/tot/module/file.so'
      }
    PUPPETFILE
  end
  let(:default_params) { {} }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params }
      let(:vhost_dir) { catalogue.resource('Class[apache]').parameters[:vhost_dir] }
      let(:file_mode) { catalogue.resource('Class[apache]').parameters[:file_mode] }

      describe 'default parameters' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_dispatcher__farm('namevar').only_with(
            ensure:        'present',
            priority:      0,
            virtualhosts:  %w[namevar],
            clientheaders: [],
          )
        end
        it do
          is_expected.to contain_concat('dispatcher.00-namevar.inc.any').with(
            ensure: 'present',
            path:   "#{vhost_dir}/dispatcher.00-namevar.inc.any",
            owner:  'root',
            group:  'root',
            mode:   file_mode,
            order:  'numeric',
          ).that_requires('Package[httpd]').that_notifies('Class[apache::service]')
        end
        describe 'concat fragments' do
          describe 'farm header' do
            it do
              is_expected.to contain_concat__fragment('namevar-farm-header').with(
                target:  'dispatcher.00-namevar.inc.any',
                order:   0,
                content: %r{^/namevar},
              )
            end
          end
          describe 'clientheaders' do
            it do
              is_expected.to contain_concat__fragment('namevar-farm-clientheaders').with(
                target: 'dispatcher.00-namevar.inc.any',
                order:  10,
              )
            end
            it { is_expected.to contain_concat__fragment('namevar-farm-clientheaders').with(content: %r{^\s+/clientheaders\s\{$}) }
          end
          describe 'virtualhosts' do
            it do
              is_expected.to contain_concat__fragment('namevar-farm-virtualhosts').with(
                target: 'dispatcher.00-namevar.inc.any',
                order:  20,
              )
            end
            it { is_expected.to contain_concat__fragment('namevar-farm-virtualhosts').with(content: %r{^\s+/virtualhosts\s\{$}) }
            it { is_expected.to contain_concat__fragment('namevar-farm-virtualhosts').with(content: %r{^\s+"namevar"$}) }
          end
          describe 'sessionmanagement' do
            it do
              is_expected.not_to contain_concat__fragment('namevar-farm-sessionmanagement')
            end
          end

          describe 'renders' do
            it { raise('Not Implemented') }
          end

          describe 'filter' do
            it { raise('Not Implemented') }
          end

          describe 'vanity_urls' do
            it { raise('Not Implemented') }
          end

          describe 'cache rules' do
            it { raise('Not Implemented') }
          end

          describe 'cache invalidate' do
            it { raise('Not Implemented') }
          end

          describe 'statistics' do
            it { raise('Not Implemented') }
          end

          describe 'stickyConnectionsFor' do
            it { raise('Not Implemented') }
          end

          describe 'health_check' do
            it { raise('Not Implemented') }
          end

          describe 'retry_delay' do
            it { raise('Not Implemented') }
          end

          describe 'retries' do
            it { raise('Not Implemented') }
          end

          describe 'unavailable_penalty' do
            it { raise('Not Implemented') }
          end

          describe 'failover' do
            it { raise('Not Implemented') }
          end
        end
      end
      context 'custom params' do
        let(:facts) { os_facts.merge(testname: 'customparams') }
        let(:title) { 'customparams' }

        it do
          is_expected.to contain_dispatcher__farm('customparams').only_with(
            ensure:                      'present',
            priority:                    50,
            virtualhosts:                %w[www.example.com another.example.com],
            clientheaders:               %w[A-Client-Header Another-Client-Header],
            sessionmanagement_directory: '/path/to/sessions',
            sessionmanagement_encode:    'sha1',
            sessionmanagement_header:    'HTTP:authorization',
            sessionmanagement_timeout:   90,
          )
        end
        it do
          is_expected.to contain_concat('dispatcher.50-customparams.inc.any').with(
            ensure: 'present',
            path:   "#{vhost_dir}/dispatcher.50-customparams.inc.any",
            owner:  'root',
            group:  'root',
            mode:   file_mode,
            order:  'numeric',
          ).that_requires('Package[httpd]').that_notifies('Class[apache::service]')
        end
        describe 'concat fragments' do
          describe 'farm header' do
            it do
              is_expected.to contain_concat__fragment('customparams-farm-header').with(
                target:  'dispatcher.50-customparams.inc.any',
                order:   0,
                content: %r{^/customparams},
              )
            end
          end
          describe 'client headers' do
            it do
              is_expected.to contain_concat__fragment('customparams-farm-clientheaders').with(
                target: 'dispatcher.50-customparams.inc.any',
                order:  10,
              )
            end
            it { is_expected.to contain_concat__fragment('customparams-farm-clientheaders').with(content: %r{^\s+/clientheaders\s\{$}) }
            it { is_expected.to contain_concat__fragment('customparams-farm-clientheaders').with(content: %r{^\s+"A-Client-Header"$}) }
            it { is_expected.to contain_concat__fragment('customparams-farm-clientheaders').with(content: %r{^\s+"Another-Client-Header"$}) }
          end
          describe 'client virtualhosts' do
            it do
              is_expected.to contain_concat__fragment('customparams-farm-virtualhosts').with(
                target: 'dispatcher.50-customparams.inc.any',
                order:  20,
              )
            end
            it { is_expected.to contain_concat__fragment('customparams-farm-virtualhosts').with(content: %r{^\s+/virtualhosts\s\{$}) }
            it { is_expected.to contain_concat__fragment('customparams-farm-virtualhosts').with(content: %r{^\s+"www.example.com"$}) }
            it { is_expected.to contain_concat__fragment('customparams-farm-virtualhosts').with(content: %r{^\s+"another.example.com"$}) }
          end

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
              let(:params) { default_params.merge(sessionmanagement_encode: 'md5') }

              it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/encode "md5"$}) }
            end
            context 'header' do
              let(:params) { default_params.merge(sessionmanagement_header: 'Cookie:name-of-cookie') }

              it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/header "Cookie:name-of-cookie"$}) }
            end
            context 'timeout' do
              let(:params) { default_params.merge(sessionmanagement_timeout: 1000) }

              it { is_expected.to contain_concat__fragment('customparams-farm-sessionmanagement').with(content: %r{^\s+/timeout "1000"$}) }
            end
          end

          describe 'renders' do
            it { raise('Not Implemented') }
          end

          describe 'filter' do
            it { raise('Not Implemented') }
          end

          describe 'vanity_urls' do
            it { raise('Not Implemented') }
          end

          describe 'cache rules' do
            it { raise('Not Implemented') }
          end

          describe 'cache invalidate' do
            it { raise('Not Implemented') }
          end

          describe 'statistics' do
            it { raise('Not Implemented') }
          end

          describe 'stickyConnectionsFor' do
            it { raise('Not Implemented') }
          end

          describe 'health_check' do
            it { raise('Not Implemented') }
          end

          describe 'retry_delay' do
            it { raise('Not Implemented') }
          end

          describe 'retries' do
            it { raise('Not Implemented') }
          end

          describe 'unavailable_penalty' do
            it { raise('Not Implemented') }
          end

          describe 'failover' do
            it { raise('Not Implemented') }
          end
        end
      end
    end
  end
end
