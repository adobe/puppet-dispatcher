# frozen_string_literal: true

#
# Puppet Dispatcher Module - A module to manage AEM Dispatcher installations and configuration files.
#
# Copyright 2019 Adobe Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe 'dispatcher', type: :class do

  let(:pre_condition) do
    'class { "apache" : }'
  end
  let(:default_params) { { module_file: '/full/path/to/file-with-version.so' } }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params }

      case os_facts[:osfamily]
      when 'RedHat'
        let(:lib_path) do
          "#{catalogue.resource('Class[apache]').parameters[:httpd_dir]}/#{catalogue.resource('Class[apache]').parameters[:lib_path]}"
        end
        let(:mod_dir) { catalogue.resource('Class[apache]').parameters[:mod_dir] }
        let(:log_root) { catalogue.resource('Class[apache]').parameters[:logroot] }
      when 'Debian'
        let(:lib_path) { catalogue.resource('Class[apache]').parameters[:lib_path] }
        let(:mod_dir) { catalogue.resource('Class[apache]').parameters[:mod_enable_dir] }
        let(:log_root) { catalogue.resource('Class[apache]').parameters[:logroot] }
      end

      context 'requires Apache' do
        let(:pre_condition) { '' }

        it { is_expected.to raise_error(%r{You must include the Apache class}) }
      end

      context 'missing module file' do
        let(:params) { default_params.delete('module_file') }

        it { is_expected.to raise_error(%r{expects a value for parameter 'module_file'}) }
      end

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it do
          apache = catalogue.resource('Class[apache]')
          is_expected.to contain_class('dispatcher').only_with(
            name:               'Dispatcher',
            module_file:        '/full/path/to/file-with-version.so',
            decline_root:       true,
            log_file:           "#{apache.parameters[:logroot]}/dispatcher.log",
            log_level:          'warn',
            farms:              [],
            pass_error:         false,
            use_processed_url:  true,
          )
        end

        it do
          is_expected.to contain_file("#{lib_path}/file-with-version.so").with(
            ensure: 'file',
            owner: 'root',
            group: 'root',
            source: '/full/path/to/file-with-version.so',
          )
        end

        it do
          is_expected.to contain_apache__mod('dispatcher')
        end

        it do
          is_expected.to contain_file("#{lib_path}/mod_dispatcher.so").with(
            ensure: 'link',
            owner:  'root',
            group:  'root',
            target: "#{lib_path}/file-with-version.so",
          ).that_requires('Package[httpd]').that_notifies('Class[Apache::Service]')
        end

        it do
          is_expected.to contain_file("#{mod_dir}/dispatcher.conf").with(
            ensure: 'file',
            owner:  'root',
            group:  'root',
          ).with_content(
            %r{.*DispatcherConfig\s+#{mod_dir}/dispatcher.farms.any},
          ).with_content(
            %r{.*DispatcherLog\s+#{log_root}/dispatcher.log},
          ).with_content(
            %r{.*DispatcherLogLevel\s+warn},
          ).with_content(
            %r{.*DispatcherDeclineRoot\s+On},
          ).with_content(
            %r{.*DispatcherUseProcessedURL\s+On},
          ).with_content(
            %r{.*DispatcherPassError\s+0},
          ).without_content(
            %r{.*DispatcherKeepAliveTimeout.*},
          ).without_content(
            %r{.*DispatcherNoCanonURL.*},
          ).that_requires('Package[httpd]').that_notifies('Class[Apache::Service]')
        end

        it do
          is_expected.to contain_file("#{mod_dir}/dispatcher.farms.any").with(
            ensure: 'file',
            owner:  'root',
            group:  'root',
            source: 'puppet:///modules/dispatcher/dispatcher.farms.any',
          ).that_requires('Package[httpd]').that_notifies('Class[Apache::Service]')
        end
      end

      context 'with custom parameters' do
        let(:params) do
          {
            module_file: '/path/to/module/file.so',
            decline_root: false,
            log_file: '/custom/path/to/logfile.log',
            log_level: 'debug',
            pass_error: '400-411,413-417,500',
            use_processed_url: false,
            keep_alive_timeout: 0,
            no_cannon_url: true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_class('dispatcher').only_with(
            name:               'Dispatcher',
            module_file:        '/path/to/module/file.so',
            decline_root:       false,
            log_file:           '/custom/path/to/logfile.log',
            log_level:          'debug',
            pass_error:         '400-411,413-417,500',
            use_processed_url:  false,
            farms:              [],
            keep_alive_timeout: 0,
            no_cannon_url:      true,
          )
        end

        it do
          is_expected.to contain_file("#{lib_path}/file.so").with(
            ensure: 'file',
            owner: 'root',
            group: 'root',
            source: '/path/to/module/file.so',
          ).that_requires('Package[httpd]').that_notifies('Class[Apache::Service]')
        end

        it do
          is_expected.to contain_apache__mod('dispatcher')
        end

        it do
          is_expected.to contain_file("#{lib_path}/mod_dispatcher.so").with(
            ensure: 'link',
            owner:  'root',
            group:  'root',
            target: "#{lib_path}/file.so",
          ).that_requires('Package[httpd]').that_notifies('Class[Apache::Service]')
        end

        it do
          is_expected.to contain_file("#{mod_dir}/dispatcher.conf").with(
            ensure: 'file',
            owner:  'root',
            group:  'root',
          ).with_content(
            %r{.*DispatcherConfig\s+#{mod_dir}/dispatcher.farms.any},
          ).with_content(
            %r{.*DispatcherLog\s+\/custom\/path\/to\/logfile.log$},
          ).with_content(
            %r{.*DispatcherLogLevel\s+debug$},
          ).with_content(
            %r{.*DispatcherDeclineRoot\s+Off$},
          ).with_content(
            %r{.*DispatcherUseProcessedURL\s+Off$},
          ).with_content(
            %r{.*DispatcherPassError\s+400-411,413-417,500$},
          ).with_content(
            %r{.*DispatcherKeepAliveTimeout\s+0$},
          ).with_content(
            %r{.*DispatcherNoCanonURL\s+On$},
          ).that_requires('Package[httpd]').that_notifies('Class[Apache::Service]')
        end

        it do
          is_expected.to contain_file("#{mod_dir}/dispatcher.farms.any").with(
            ensure: 'file',
            owner:  'root',
            group:  'root',
            source: 'puppet:///modules/dispatcher/dispatcher.farms.any',
          ).that_requires('Package[httpd]').that_notifies('Class[Apache::Service]')
        end
      end

      context 'farm list' do
        let(:hiera_config) { 'spec/hiera.yaml' }
        let(:params) { default_params.merge(farms: %w[vhost1 vhost2 vhost3]) }

        it { is_expected.to contain_dispatcher__farm('vhost1') }
        it { is_expected.to contain_concat('dispatcher.00-vhost1.inc.any') }
        it { is_expected.to contain_concat_fragment('vhost1-farm-header') }
        it { is_expected.to contain_concat_fragment('vhost1-farm-clientheaders') }
        it { is_expected.to contain_dispatcher__farm('vhost2') }
        it { is_expected.to contain_concat('dispatcher.00-vhost2.inc.any') }
        it { is_expected.to contain_concat_fragment('vhost2-farm-header') }
        it { is_expected.to contain_concat_fragment('vhost2-farm-clientheaders') }
        it { is_expected.to contain_dispatcher__farm('vhost3') }
        it { is_expected.to contain_concat('dispatcher.00-vhost3.inc.any') }
        it { is_expected.to contain_concat_fragment('vhost3-farm-header') }
        it { is_expected.to contain_concat_fragment('vhost3-farm-clientheaders') }
      end
    end
  end

  describe 'parameter validation' do

    supported_os = [{ 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => ['7'] }]
    on_supported_os(supported_os: supported_os).each do |_os, os_facts|
      let(:facts) { os_facts }
      let(:params) { { module_file: '/full/path/to/file-with-version.so' } }
      let(:lib_path) do
        "#{catalogue.resource('Class[apache]').parameters[:httpd_dir]}/#{catalogue.resource('Class[apache]').parameters[:lib_path]}"
      end

      context 'module_file' do
        context 'fully qualified file' do
          it { is_expected.to compile.with_all_deps.with_all_deps }
        end

        context 'URL path' do
          let(:params) { { module_file: 'https://full/path/to/file-with-version.so' } }

          it { is_expected.to compile.with_all_deps.with_all_deps }
          it do
            is_expected.to contain_file("#{lib_path}/file-with-version.so").with(
              ensure: 'file',
              owner: 'root',
              group: 'root',
              source: 'https://full/path/to/file-with-version.so',
            )
          end
        end

        context 'File reference' do
          let(:params) { { module_file: 'file:///full/path/to/file-with-version.so' } }

          it { is_expected.to compile.with_all_deps.with_all_deps }
          it do
            is_expected.to contain_file("#{lib_path}/file-with-version.so").with(
              ensure: 'file',
              owner: 'root',
              group: 'root',
              source: 'file:///full/path/to/file-with-version.so',
            )
          end
        end

        context 'puppet file reference' do
          let(:params) { { module_file: 'puppet:///full/path/to/file-with-version.so' } }

          it { is_expected.to compile.with_all_deps.with_all_deps }
          it do
            is_expected.to contain_file("#{lib_path}/file-with-version.so").with(
              ensure: 'file',
              owner:  'root',
              group:  'root',
              source: 'puppet:///full/path/to/file-with-version.so',
            )
          end
        end

      end

      context 'decline_root' do
        context 'true' do
          let(:params) { default_params.merge(decline_root: true) }

          it { is_expected.to compile.with_all_deps.with_all_deps }
        end
        context 'false' do
          let(:params) { default_params.merge(decline_root: false) }

          it { is_expected.to compile.with_all_deps.with_all_deps }
        end

        context 'invalid' do
          let(:params) { default_params.merge(decline_root: 'invalid') }

          it { is_expected.to raise_error(%r{parameter 'decline_root' expects a Boolean value}) }
        end
      end

      context 'keep_alive_timeout' do
        context 'positive number' do
          let(:params) { default_params.merge(keep_alive_timeout: 120) }

          it { is_expected.to compile.with_all_deps.with_all_deps }
        end
        context 'invalid number' do
          let(:params) { default_params.merge(keep_alive_timeout: -60) }

          it { is_expected.to raise_error(%r{parameter 'keep_alive_timeout' expects a value of type Undef or Integer}) }
        end

        context 'NaN' do
          let(:params) { default_params.merge(keep_alive_timeout: 'invalid') }

          it { is_expected.to raise_error(%r{parameter 'keep_alive_timeout' expects a value of type Undef or Integer}) }
        end
      end

      context 'log_level' do
        context 'error' do
          let(:params) { default_params.merge(log_level: 'error') }

          it { is_expected.to compile.with_all_deps.with_all_deps }
        end
        context 'warn' do
          let(:params) { default_params.merge(log_level: 'warn') }

          it { is_expected.to compile.with_all_deps.with_all_deps }
        end
        context 'info' do
          let(:params) { default_params.merge(log_level: 'info') }

          it { is_expected.to compile.with_all_deps.with_all_deps }
        end
        context 'debug' do
          let(:params) { default_params.merge(log_level: 'debug') }

          it { is_expected.to compile.with_all_deps.with_all_deps }
        end
        context 'trace' do
          let(:params) { default_params.merge(log_level: 'trace') }

          it { is_expected.to compile.with_all_deps.with_all_deps }
        end
        context 'invalid' do
          let(:params) { default_params.merge(log_level: 'invalid') }

          it { is_expected.to raise_error(%r{parameter 'log_level' expects a match for Enum\['debug', 'error', 'info', 'trace', 'warn'\]}) }
        end
      end

      context 'log_file' do
        context 'fully qualified path' do
          let(:params) { default_params.merge(log_file: '/full/path/to/file.log') }

          it { is_expected.to compile.with_all_deps }
        end
        context 'invalid: relative path' do
          let(:params) { default_params.merge(log_file: '../path/to/file.log') }

          it { is_expected.to raise_error(%r{parameter 'log_file' expects a Stdlib::Absolutepath}) }
        end

        context 'invalid: no path' do
          let(:params) { default_params.merge(log_file: 'file.log') }

          it { is_expected.to raise_error(%r{parameter 'log_file' expects a Stdlib::Absolutepath}) }
        end
      end

      context 'pass_error' do
        context 'false' do
          let(:params) { default_params.merge(pass_error: true) }

          it { is_expected.to compile.with_all_deps }
        end
        context 'true' do
          let(:params) { default_params.merge(pass_error: false) }

          it { is_expected.to compile.with_all_deps }
        end
        context 'single response code' do
          let(:params) { default_params.merge(pass_error: '500') }

          it { is_expected.to compile.with_all_deps }
        end
        context 'multiple response codes' do
          let(:params) { default_params.merge(pass_error: '404,500') }

          it { is_expected.to compile.with_all_deps }
        end
        context 'response codes ranges' do
          let(:params) { default_params.merge(pass_error: '400-411,413-417') }

          it { is_expected.to compile.with_all_deps }
        end
        context 'response codes ranges with single code' do
          let(:params) { default_params.merge(pass_error: '400-411,413-417,500') }

          it { is_expected.to compile.with_all_deps }
        end

        context 'invalid' do
          let(:params) { default_params.merge(pass_error: 'invalid') }

          it { is_expected.to raise_error(%r{parameter 'pass_error' expects a value of type Boolean or Pattern}) }
        end
      end

      context 'use_processed_url' do
        context 'true' do
          let(:params) { default_params.merge(use_processed_url: true) }

          it { is_expected.to compile.with_all_deps }
        end
        context 'false' do
          let(:params) { default_params.merge(use_processed_url: false) }

          it { is_expected.to compile.with_all_deps }
        end

        context 'invalid' do
          let(:params) { default_params.merge(use_processed_url: 'invalid') }

          it { is_expected.to raise_error(%r{parameter 'use_processed_url' expects a Boolean value}) }
        end
      end

      context 'keep_alive_timeout' do
        context 'positive number' do
          let(:params) { default_params.merge(keep_alive_timeout: 120) }

          it { is_expected.to compile.with_all_deps }
        end
        context 'invalid number' do
          let(:params) { default_params.merge(keep_alive_timeout: -60) }

          it { is_expected.to raise_error(%r{parameter 'keep_alive_timeout' expects a value of type Undef or Integer}) }
        end

        context 'invalid' do
          let(:params) { default_params.merge(keep_alive_timeout: 'invalid') }

          it { is_expected.to raise_error(%r{parameter 'keep_alive_timeout' expects a value of type Undef or Integer}) }
        end
      end

      context 'no_cannon_url' do
        context 'true' do
          let(:params) { default_params.merge(no_cannon_url: true) }

          it { is_expected.to compile.with_all_deps }
        end
        context 'false' do
          let(:params) { default_params.merge(no_cannon_url: false) }

          it { is_expected.to compile.with_all_deps }
        end

        context 'invalid' do
          let(:params) { default_params.merge(no_cannon_url: 'invalid') }

          it { is_expected.to raise_error(%r{parameter 'no_cannon_url' expects a value of type Undef or Boolean}) }
        end
      end
    end
  end
end
