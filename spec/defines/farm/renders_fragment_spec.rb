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

  describe 'renders' do
    on_supported_os.each do |os, os_facts|
      describe "on #{os}" do
        context 'minimal parameters' do
          let(:facts) { os_facts }
          let(:title) { 'namevar' }

          it { is_expected.to contain_concat__fragment('namevar-farm-renders').with(target: 'dispatcher.00-namevar.inc.any', order: 40) }
          it { is_expected.to contain_concat__fragment('namevar-farm-renders').with(content: %r{^\s{2}/renders\s\{$}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-renders').with(content: %r{^\s{4}/renderer0\s\{$}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-renders').with(content: %r{^\s{6}/hostname "localhost"$}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-renders').with(content: %r{^\s{6}/port "4503"$}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-renders').with(content: %r{/timeout}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-renders').with(content: %r{/receive_timeout}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-renders').with(content: %r{/ipv4}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-renders').with(content: %r{/secure}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-renders').with(content: %r{/always-resolve}) }
        end
        context 'custom parameters' do
          let(:facts) { os_facts.merge(testname: 'customparams') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(target: 'dispatcher.50-customparams.inc.any', order: 40) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{2}/renders\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{4}/renderer0\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/hostname "localhost"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/port "4503"$}) }
          it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/timeout}) }
          it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/receive_timeout}) }
          it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/ipv4}) }
          it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/secure}) }
          it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/always-resolve}) }
          context 'timeout' do
            let(:params) { { renderers: [{ hostname: 'localhost', port: 4503, timeout: 1000 }] } }

            it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/timeout "1000"$}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/receive_timeout}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/ipv4}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/secure}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/always-resolve}) }
          end
          context 'receiveTimeout' do
            let(:params) { { renderers: [{ hostname: 'localhost', port: 4503, receive_timeout: 100_000 }] } }

            it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/receiveTimeout "100000"$}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/timeout}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/ipv4}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/secure}) }
            it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/always-resolve}) }
          end
          context 'ipv4' do
            context 'true' do
              let(:params) { { renderers: [{ hostname: 'localhost', port: 4503, ipv4: true }] } }

              it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/ipv4 "1"$}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/timeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/receiveTimeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/secure}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/always-resolve}) }
            end
            context 'false' do
              let(:params) { { renderers: [{ hostname: 'localhost', port: 4503, ipv4: false }] } }

              it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/ipv4 "0"$}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/timeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/receiveTimeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/secure}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/always-resolve}) }
            end
          end
          context 'secure' do
            context 'true' do
              let(:params) { { renderers: [{ hostname: 'localhost', port: 4503, secure: true }] } }

              it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/secure "1"$}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/timeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/receiveTimeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/ipv4}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/always-resolve}) }
            end
            context 'false' do
              let(:params) { { renderers: [{ hostname: 'localhost', port: 4503, secure: false }] } }

              it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/secure "0"$}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/timeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/receiveTimeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/ipv4}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/always-resolve}) }
            end
          end
          context 'always_resolve' do
            context 'true' do
              let(:params) { { renderers: [{ hostname: 'localhost', port: 4503, always_resolve: true }] } }

              it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/always-resolve "1"$}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/timeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/receiveTimeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/ipv4}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/secure}) }
            end
            context 'false' do
              let(:params) { { renderers: [{ hostname: 'localhost', port: 4503, always_resolve: false }] } }

              it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/always-resolve "0"$}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/timeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/receiveTimeout}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/ipv4}) }
              it { is_expected.not_to contain_concat__fragment('customparams-farm-renders').with(content: %r{/secure}) }
            end
          end
        end
        context 'multiple' do
          let(:facts) { os_facts.merge(testname: 'multiple-renders') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat('dispatcher.00-customparams.inc.any') }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(target: 'dispatcher.00-customparams.inc.any', order: 40) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{2}/renders\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{4}/renderer0\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/hostname "192.168.0.1"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/port "4503"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{4}/renderer1\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/hostname "192.168.0.2"$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-renders').with(content: %r{^\s{6}/port "4505"$}) }
        end
      end
    end
  end
end
