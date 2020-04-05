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

describe 'dispatcher::farm', type: :define do
  let(:hiera_config) { 'spec/hiera.yaml' }
  let(:pre_condition) do
    <<~PUPPETFILE
      class { 'apache' : }
    PUPPETFILE
  end

  describe 'cache' do
    on_supported_os.each do |os, os_facts|
      describe "on #{os}" do
        context 'minimal parameters' do
          let(:facts) { os_facts }
          let(:title) { 'namevar' }

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
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/statfile\s"/path/to/statfile"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/serveStaleOnError\s"1"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/allowAuthorized\s"1"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/rules\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}/0000 \{ /type "allow" /glob "\*.html" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}/0001 \{ /type "deny" /glob "\*.js" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/statfileslevel\s"3"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/invalidate\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}/0000 \{ /type "deny" /glob "\*.html" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}/0001 \{ /type "allow" /glob "\*.jpg" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/invalidateHandler\s"/opt/dispatcher/scripts/invalidate.sh"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/allowedClients\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}/0000 \{ /type "deny" /glob "\*\.\*\.\*\.\*" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}/0001 \{ /type "allow" /glob "127.0.0.1" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/ignoreUrlParams\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}/0000 \{ /type "deny" /glob "\*" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}/0001 \{ /type "allow" /glob "q" \}$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/headers\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}"Content-Type"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{6}"Cache-Control"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/mode\s"0660"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/gracePeriod\s"10"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-cache').with(content: %r{^\s{4}/enableTTL\s"1"$}) }
        end
        context 'secure' do
          let(:facts) { os_facts.merge(testname: 'secure') }
          let(:title) { 'secure' }

          it { is_expected.to contain_concat__fragment('secure-farm-cache').with(target: 'dispatcher.00-secure.inc.any', order: 80) }
          it { is_expected.to contain_concat__fragment('secure-farm-cache').with(content: %r{^\s{2}/cache\s\{$}) }
          it { is_expected.to contain_concat__fragment('secure-farm-cache').with(content: %r{^\s{4}/allowedClients\s\{$}) }
          it { is_expected.to contain_concat__fragment('secure-farm-cache').with(content: %r{^\s{6}/0000 \{ /type "deny" /glob "\*" \}$}) }
          it { is_expected.to contain_concat__fragment('secure-farm-cache').with(content: %r{^\s{6}/0001 \{ /type "allow" /glob "127\.0\.0\.1" \}$}) }
        end
        context 'manage docroot' do
          let(:facts) { os_facts.merge(testname: 'managedocroot') }
          let(:title) { 'managedocroot' }

          it { is_expected.to contain_file('/path/to/docroot').with(owner: 'root', group: 'root') }

          context 'selinux' do
            let(:facts) { os_facts.merge(testname: 'managedocroot', selinux_enforced: true) }
            let(:title) { 'managedocroot' }

            it { is_expected.to contain_file('/path/to/docroot').with(owner: 'root', group: 'root', seltype: 'httpd_sys_rw_content_t') }
            it { is_expected.to contain_concat('dispatcher.00-managedocroot.inc.any') }
            it { is_expected.to contain_concat__fragment('managedocroot-farm-header') }
            it { is_expected.to contain_concat__fragment('managedocroot-farm-renders') }
            it { is_expected.to contain_concat__fragment('managedocroot-farm-virtualhosts') }
            it { is_expected.to contain_concat__fragment('managedocroot-farm-cache') }
            it { is_expected.to contain_concat__fragment('managedocroot-farm-filter') }
            it { is_expected.to contain_concat__fragment('managedocroot-farm-footer') }
          end
        end
      end
    end
  end
end
