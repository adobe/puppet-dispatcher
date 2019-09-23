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

  describe 'filters' do
    on_supported_os.each do |os, os_facts|
      describe "on #{os}" do
        context 'minimal parameters' do
          let(:facts) { os_facts }
          let(:title) { 'namevar' }

          it { is_expected.to contain_concat__fragment('namevar-farm-filter').with(target: 'dispatcher.00-namevar.inc.any', order: 50) }
          it { is_expected.to contain_concat__fragment('namevar-farm-filter').with(content: %r{^\s{2}/filter\s\{$}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-filter').with(content: %r{^\s{4}/0000\s\{\s/type}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-filter').with(content: %r{\s/type\s"deny"\s/url}) }
          it { is_expected.to contain_concat__fragment('namevar-farm-filter').with(content: %r{\s/url\s'\.\*'\s\}$}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-filter').with(content: %r{/method}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-filter').with(content: %r{/query}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-filter').with(content: %r{/protocol}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-filter').with(content: %r{/path}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-filter').with(content: %r{/selectors}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-filter').with(content: %r{/extension}) }
          it { is_expected.not_to contain_concat__fragment('namevar-farm-filter').with(content: %r{/suffix}) }
        end
        context 'simple filters' do
          let(:facts) { os_facts.merge(testname: 'simple-filters') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(target: 'dispatcher.50-customparams.inc.any', order: 50) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{^\s{2}/filter\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{^\s{4}/0000\s\{\s/type}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/type\s"deny"\s/method}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/method\s"\(POST\|GET\)"\s/query}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/query\s"\[.\]\*"\s/protocol}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/protocol\s"https\?"\s/path}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/path\s"/content/test/\.\*"\s/selectors}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/selectors\s"\(1\|tidy\)"\s/extension}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/extension\s"\(css\|js\|html\)"\s/suffix}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/suffix\s"/some/path/\.\*"\s\}$}) }
          it { is_expected.not_to contain_concat__fragment('customparams-farm-filter').with(content: %r{/url}) }
        end
        context 'regex filters' do
          let(:facts) { os_facts.merge(testname: 'regex-filters') }
          let(:title) { 'customparams' }

          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(target: 'dispatcher.50-customparams.inc.any', order: 50) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{^\s{2}/filter\s\{$}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{^\s{4}/0000\s\{\s/type}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/type\s"allow"\s/method}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/method\s'\(POST\|GET\)'\s/query}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/query\s'\[.\]\*'\s/protocol}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/protocol\s'https\?'\s/path}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/path\s'/content/test/\.\*'\s/selectors}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/selectors\s'\(1\|tidy\)'\s/extension}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/extension\s'\(css\|js\|html\)'\s/suffix}) }
          it { is_expected.to contain_concat__fragment('customparams-farm-filter').with(content: %r{\s/suffix\s'/some/path/\.\*'\s\}$}) }
          it { is_expected.not_to contain_concat__fragment('customparams-farm-filter').with(content: %r{/url}) }
        end
        context 'multiple filters' do
          let(:facts) { os_facts.merge(testname: 'multiple-filters') }
          let(:title) { 'multiplefilters' }

          it { is_expected.to contain_concat('dispatcher.50-multiplefilters.inc.any') }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-header').with(target: 'dispatcher.50-multiplefilters.inc.any') }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-clientheaders').with(target: 'dispatcher.50-multiplefilters.inc.any') }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-virtualhosts').with(target: 'dispatcher.50-multiplefilters.inc.any') }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-renders').with(target: 'dispatcher.50-multiplefilters.inc.any') }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(target: 'dispatcher.50-multiplefilters.inc.any', order: 50) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{^\s{2}/filter\s\{$}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{^\s{4}/0000\s\{\s/type\s"deny"\s/url\s'\.\*'\s\}$}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{^\s{4}/0001\s\{\s/type\s"allow"\s/method}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/method\s'\(POST\|GET\)'\s/query}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/query\s'\[.\]\*'\s/protocol}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/protocol\s'https\?'\s/path}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/path\s'/content/test/\.\*'\s/selectors}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/selectors\s'\(1\|tidy\)'\s/extension}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/extension\s'\(css\|js\|html\)'\s/suffix}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/suffix\s'/some/path/\.\*'\s\}$}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{^\s{4}/0002\s\{\s/type\s"deny"\s/method}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/method\s"\(POST\|GET\)"\s/query}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/query\s"\[.\]\*"\s/protocol}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/protocol\s"https\?"\s/path}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/path\s"/content/test/\.\*"\s/selectors}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/selectors\s"\(1\|tidy\)"\s/extension}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/extension\s"\(css\|js\|html\)"\s/suffix}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-filter').with(content: %r{\s/suffix\s"/some/path/\.\*"\s\}$}) }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-cache').with(target: 'dispatcher.50-multiplefilters.inc.any') }
          it { is_expected.to contain_concat__fragment('multiplefilters-farm-footer').with(target: 'dispatcher.50-multiplefilters.inc.any') }
        end
        context 'secure' do
          let(:facts) { os_facts.merge(testname: 'secure') }
          let(:title) { 'secure' }

          it { is_expected.to contain_concat('dispatcher.00-secure.inc.any') }
          it { is_expected.to contain_concat__fragment('secure-farm-filter').with(target: 'dispatcher.00-secure.inc.any', order: 50) }
          it { is_expected.to contain_concat__fragment('secure-farm-filter').with(content: %r{^\s{2}/filter\s\{$}) }
          it { is_expected.to contain_concat__fragment('secure-farm-filter').with(content: %r{^\s{4}/0000\s\{\s/type\s"deny"\s/url\s'\.\*'\s\}$}) }
          it do
            is_expected.to contain_concat__fragment('secure-farm-filter')
                .with(content: %r{^\s{4}/0001\s\{\s/type\s"allow"\s})
                .with(content: %r{"allow"\s/path\s"/content/\*"\s/extension})
                .with(content: %r{/extension\s'\(css\|eot\|gif\|ico\|jpeg\|jpg\|js\|gif\|pdf\|png\|svg\|swf\|ttf\|woff\|woff2\|html\)'\s\}})
          end
          it { is_expected.to contain_concat__fragment('secure-farm-filter').with(content: %r{^\s{4}/0002\s\{\s/type\s"deny"\s/url\s"/crx/\*"\s\}$}) }
          it { is_expected.to contain_concat__fragment('secure-farm-filter').with(content: %r{^\s{4}/0003\s\{\s/type\s"deny"\s/url\s"/system/\*"\s\}$}) }
          it { is_expected.to contain_concat__fragment('secure-farm-filter').with(content: %r{^\s{4}/0004\s\{\s/type\s"deny"\s/url\s"/apps/\*"\s\}$}) }
          it do
            is_expected.to contain_concat__fragment('secure-farm-filter')
                .with(content: %r{^\s{4}/0005\s\{\s/type\s"deny"\s})
                .with(content: %r{"deny"\s/selectors\s'\(feed\|rss\|pages\|languages\|blueprint\|infinity\|tidy\|sysview\|docview\|query\|\[0-9-\]\+\|jcr:content\)'})
                .with(content: %r{jcr:content\)'\s/extension\s'\(json\|xml\|html\|feed\)'\s\}})
          end
          it { is_expected.to contain_concat__fragment('secure-farm-filter').with(content: %r{^\s{4}/0006\s\{\s/type\s"deny"\s/method\s"GET"\s/query\s"debug=\*"\s\}$}) }
          it { is_expected.to contain_concat__fragment('secure-farm-filter').with(content: %r{^\s{4}/0007\s\{\s/type\s"deny"\s/method\s"GET"\s/query\s"wcmmode=\*"\s\}$}) }
          it { is_expected.to contain_concat__fragment('secure-farm-filter').with(content: %r{^\s{4}/0008\s\{\s/type\s"deny"\s/extension\s"jsp"\s\}$}) }
        end
      end
    end
  end
end
