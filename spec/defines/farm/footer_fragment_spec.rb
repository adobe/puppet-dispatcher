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

  describe 'footer' do
    on_supported_os.each do |os, os_facts|
      describe "on #{os}" do
        context 'default parameters' do
          let(:facts) { os_facts }
          let(:title) { 'namevar' }

          it { is_expected.to contain_concat__fragment('namevar-farm-footer').with(target: 'dispatcher.00-namevar.inc.any', order: 999, content: %r{^\}}) }
        end
        context 'custom parameters' do
          let(:facts) { os_facts.merge(testname: 'customparams') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat__fragment('customparams-farm-footer').with(target: 'dispatcher.50-customparams.inc.any', order: 999, content: %r{^\}}) }
        end
        context 'secure' do
          let(:facts) { os_facts.merge(testname: 'secure') }
          let(:title) { 'secure' }

          it { is_expected.to contain_concat__fragment('secure-farm-footer').with(target: 'dispatcher.00-secure.inc.any', order: 999, content: %r{^\}}) }
        end
      end
    end
  end
end
