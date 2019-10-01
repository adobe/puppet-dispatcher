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

require 'spec_helper_acceptance'
require 'serverspec'
require 'puppet_litmus'
include PuppetLitmus

dispatcher_target  = 'apache2.4'
dispatcher_version = '4.3.2'
dispatcher_file    = "dispatcher-#{dispatcher_target}-#{dispatcher_version}.so"
dispatcher_tarfile = "dispatcher-#{dispatcher_target}-linux-x86_64-ssl-#{dispatcher_version}.tar.gz"
dispatcher_src     = "http://download.macromedia.com/dispatcher/download/#{dispatcher_tarfile}"
inventory_hash     = inventory_hash_from_inventory_file
node_config        = facts_from_node(inventory_hash, ENV['TARGET_HOST'])
platform           = node_config.dig('platform')

case platform
when %r{(centos|oracle|scientific)}
  mod_path  = '/etc/httpd/modules'
  conf_path = '/etc/httpd/conf.modules.d'
  log_path  = '/var/log/httpd'
  service   = 'httpd'
when %r{(debian|ubuntu)}
  mod_path  = '/usr/lib/apache2/modules'
  conf_path = '/etc/apache2/mods-enabled'
  log_path  = '/var/log/apache2'
else
  raise 'Unknown platform.'
end

describe 'dispatcher' do
  context 'secure settings' do
    describe 'is idempotent' do
      let(:pp) do
        <<~PUPPETCODE
          $dir = '/tmp/dispatcher-ssl'
          file { $dir :
            ensure => directory
          }
          archive { '#{dispatcher_tarfile}' :
            path         => "$dir/#{dispatcher_tarfile}",
            source       => "#{dispatcher_src}",
            extract      => true,
            extract_path => $dir,
            creates      => "$dir/#{dispatcher_file}",
            require      => File[$dir],
          }
          class { 'apache' :
            default_ssl_vhost => true,
          }
          class { 'dispatcher' :
            module_file => "$dir/#{dispatcher_file}",
            require     => Archive['#{dispatcher_tarfile}']
          }
          dispatcher::farm { 'default' :
            renderers => [{ hostname => 'localhost', port => 4503 }],
            filters   => [{ 'allow' => true, 'rank' => 1, 'path' => { 'regex' => false, 'pattern' => '/content/*' }}],
            cache     => {
              docroot         => '/var/www/html',
              rules           => [{ 'rank' => 1, 'glob' => '*.html', 'allow' => true }],
              allowed_clients => [{ 'rank' => 1, 'glob' => '127.0.0.1', 'allow' => true }],
            },
            secure    => true,
          }
        PUPPETCODE
      end

      it { expect(idempotent_apply(pp)).to be_truthy }
    end
    describe service(service) do
      it { is_expected.to be_running }
    end
    describe file("#{conf_path}/dispatcher.load") do
      it { is_expected.to be_file }
    end
    describe file("#{mod_path}/#{dispatcher_file}") do
      it { is_expected.to be_file }
    end
    describe file("#{mod_path}/mod_dispatcher.so") do
      it { is_expected.to be_symlink }
    end
    describe file("#{conf_path}/dispatcher.farms.any") do
      it { is_expected.to be_file }
    end
    describe file("#{conf_path}/dispatcher.conf") do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match %r{DispatcherConfig.*#{conf_path}/dispatcher.farms.any} }
      its(:content) { is_expected.to match %r{DispatcherLog.*#{log_path}/dispatcher.log} }
      its(:content) { is_expected.to match %r{DispatcherLogLevel.*warn} }
      its(:content) { is_expected.to match %r{DispatcherDeclineRoot.*On} }
      its(:content) { is_expected.to match %r{DispatcherUseProcessedURL.*On} }
      its(:content) { is_expected.to match %r{DispatcherPassError.*0} }
      its(:content) { is_expected.not_to match %r{DispatcherKeepAliveTimeout} }
      its(:content) { is_expected.not_to match %r{DispatcherNoCanonURL} }
    end
    describe file("#{conf_path}/dispatcher.00-default.inc.any") do
      it { is_expected.to be_file }
      describe 'file header' do
        its(:content) { is_expected.to match %r{^/default\s\{$} }
      end
      describe 'clientheaders' do
        its(:content) { is_expected.not_to match %r{/clientheaders\s\{} }
      end
      describe 'virtualhosts' do
        its(:content) { is_expected.to match %r{^\s{2}/virtualhosts\s\{$} }
        its(:content) { is_expected.to match %r{^\s{4}"default"$} }
      end
      describe 'sessionmanagement' do
        its(:content) { is_expected.not_to match %r{/sessionmanagement\s\{} }
      end
      describe 'renders' do
        its(:content) { is_expected.to match %r{^\s{2}/renders\s\{$} }
        its(:content) { is_expected.to match %r{^\s{4}/renderer0\s\{$} }
        its(:content) { is_expected.to match %r{^\s{6}/hostname "localhost"$} }
        its(:content) { is_expected.to match %r{^\s{6}/port "4503"$} }
        its(:content) { is_expected.to match %r{^\s{6}/secure "1"$} }
        its(:content) { is_expected.not_to match %r{/timeout} }
        its(:content) { is_expected.not_to match %r{/receive_timeout} }
        its(:content) { is_expected.not_to match %r{/ipv4} }
        its(:content) { is_expected.not_to match %r{/always-resolve} }
      end
      describe 'filters' do
        its(:content) { is_expected.to match %r{^\s{2}/filter\s\{$} }
        its(:content) { is_expected.to match %r{^\s{4}/0000\s\{\s/type\s"deny"\s/url\s'\.\*'\s\}$} }
        its(:content) { is_expected.to match %r{^\s{4}/0001\s\{\s/type\s"allow"\s/path\s"/content/\*"\s\}$} }
        its(:content) { is_expected.to match %r{^\s{4}/0002\s\{\s/type\s"deny"\s/url\s"/crx/\*"\s\}$} }
        its(:content) { is_expected.to match %r{^\s{4}/0003\s\{\s/type\s"deny"\s/url\s"/system/\*"\s\}$} }
        its(:content) { is_expected.to match %r{^\s{4}/0004\s\{\s/type\s"deny"\s/url\s"/apps/\*"\s\}$} }
        its(:content) { is_expected.to match %r{^\s{4}/0005\s\{\s/type\s"deny"\s/selectors} }
        its(:content) { is_expected.to match %r{\s/selectors\s'\(feed\|rss\|pages\|languages\|blueprint\|infinity\|tidy\|sysview\|docview\|query\|\[0-9-\]\+\|jcr:content\)'} }
        its(:content) { is_expected.to match %r{jcr:content\)'\s/extension\s'\(json\|xml\|html\|feed\)'\s\}} }
        its(:content) { is_expected.to match %r{^\s{4}/0006\s\{\s/type\s"deny"\s/method\s"GET"\s/query\s"debug=\*"\s\}$} }
        its(:content) { is_expected.to match %r{^\s{4}/0007\s\{\s/type\s"deny"\s/method\s"GET"\s/query\s"wcmmode=\*"\s\}$} }
        its(:content) { is_expected.to match %r{^\s{4}/0008\s\{\s/type\s"deny"\s/extension\s"jsp"\s\}$} }
      end
      describe 'vanity_urls' do
        its(:content) { is_expected.not_to match %r{/vanity_urls\s\{} }
      end
      describe 'propagateSyndPost' do
        its(:content) { is_expected.not_to match %r{/propagateSyndPost\s\{} }
      end
      describe 'cache' do
        its(:content) { is_expected.to match %r{^\s{2}/cache\s\{$} }
        its(:content) { is_expected.to match %r{^\s{4}/docroot\s"/var/www/html"$} }
        its(:content) { is_expected.to match %r{\s{4}/rules\s\{$} }
        its(:content) { is_expected.to match %r{\s{6}/0000 \{ /type "allow" /glob "\*\.html" \}$} }
        its(:content) { is_expected.to match %r{\s{4}/allowedClients\s\{$} }
        its(:content) { is_expected.to match %r{\s{6}/0000\s\{\s/type\s"deny"\s/glob\s"\*"\s\}$} }
        its(:content) { is_expected.to match %r{\s{6}/0001\s\{\s/type\s"allow"\s/glob\s"127\.0\.0\.1"\s\}$} }
        its(:content) { is_expected.not_to match %r{/statfile} }
        its(:content) { is_expected.not_to match %r{/serveStaleOnError} }
        its(:content) { is_expected.not_to match %r{/allowAuthorized} }
        its(:content) { is_expected.not_to match %r{/statfileslevel} }
        its(:content) { is_expected.not_to match %r{/invalidate} }
        its(:content) { is_expected.not_to match %r{/invalidateHandler} }
        its(:content) { is_expected.not_to match %r{/ignoreUrlParams} }
        its(:content) { is_expected.not_to match %r{/headers} }
        its(:content) { is_expected.not_to match %r{/mode} }
        its(:content) { is_expected.not_to match %r{/gracePeriod} }
        its(:content) { is_expected.not_to match %r{/enableTTL} }
      end
      describe 'auth_checker' do
        its(:content) { is_expected.not_to match %r{/auth_checker\s\{} }
      end
      describe 'statistics' do
        its(:content) { is_expected.not_to match %r{/statistics\s\{} }
      end
      describe 'health_check' do
        its(:content) { is_expected.not_to match %r{/health_check\s\{} }
      end
      describe 'retryDelay' do
        its(:content) { is_expected.not_to match %r{/retryDelay\s\{} }
      end
      describe 'numberOfRetries' do
        its(:content) { is_expected.not_to match %r{/numberOfRetries\s\{} }
      end
      describe 'unavailablePenalty' do
        its(:content) { is_expected.not_to match %r{/unavailablePenalty\s\{} }
      end
      describe 'failover' do
        its(:content) { is_expected.not_to match %r{/failover\s\{} }
      end
      describe 'file footer' do
        its(:content) { is_expected.to match %r{^\}$} }
      end
    end
  end
end
