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
dispatcher_version = '4.3.3'
dispatcher_file    = "dispatcher-#{dispatcher_target}-#{dispatcher_version}.so"
dispatcher_tarfile = "dispatcher-#{dispatcher_target}-linux-x86_64-#{dispatcher_version}.tar.gz"
dispatcher_src     = "http://download.macromedia.com/dispatcher/download/#{dispatcher_tarfile}"
inventory_hash     = inventory_hash_from_inventory_file
node_config        = facts_from_node(inventory_hash, ENV['TARGET_HOST'])
platform           = node_config.dig('platform')

case platform
when %r{(centos|oracle|scientific)}
  vhost_path = '/etc/httpd/conf.d'
  service   = 'httpd'
when %r{(debian|ubuntu)}
  mod_path  = '/usr/lib/apache2/modules'
  conf_path = '/etc/apache2/mods-enabled'
  log_path  = '/var/log/apache2'
else
  raise 'Unknown platform.'
end

describe 'dispatcher' do
  context 'vhost fragment' do
    describe 'is idempotent' do
      let(:pp) do
        <<~PUPPETCODE
          $dir = '/tmp/dispatcher'
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
          include apache
          class { 'dispatcher' :
            module_file => "$dir/#{dispatcher_file}",
            vhosts      => ["default"],
            require     => Archive['#{dispatcher_tarfile}'],
            log_level   => 'trace',
          }
          dispatcher::farm { 'default' :
            renderers => [{ hostname => 'localhost', port => 4503 }],
            virtualhosts => ['*'],      
            filters   => [
              { 'allow' => false, 'rank' => 1, 'url' => { 'regex' => true, 'pattern' => '.*' }},
              { 'allow' => true, 'rank' => 2, 'path' => { 'regex' => false, 'pattern' => '/content/*' }, 'extension' => { 'regex' => false, 'pattern' => 'html' }}
            ],
            cache     => {
              docroot         => '/var/www/html',
              rules           => [{ 'rank' => 1, 'glob' => '*.html', 'allow' => true }],
              allowed_clients => [{ 'rank' => 1, 'glob' => '*.*.*.*', 'allow' => false }],
            },
          }
        PUPPETCODE
      end

      it { expect(idempotent_apply(pp)).to be_truthy }
    end
    describe service(service) do
      it { is_expected.to be_running }
    end
    describe file("#{vhost_path}/15-default.conf") do
      its(:content) { is_expected.to match %r{<IfModule disp_apache2.c>$} }
      its(:content) { is_expected.to match %r{SetHandler dispatcher-handler$} }
      its(:content) { is_expected.to match %r{</IfModule>$} }
    end
    describe 'vhost loaded' do
      it 'should block request' do
        run_shell('curl -s -o /dev/null -w "%{http_code}" http://localhost/not/allowed') do |r|
          expect(r.stdout).to match %r{404}
        end
      end
      it 'should allow request' do
        run_shell('curl -s -o /dev/null -w "%{http_code}" http://localhost/content/allowed.html') do |r|
          expect(r.stdout).to match %r{502}
        end
      end
    end
  end
end
