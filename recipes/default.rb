#
# Cookbook Name:: postfix-dkim
# Recipe:: default
#
# Copyright 2011, Room 118 Solutions, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.default['postfix']['main']['milter_default_action'] = 'accept'
node.default['postfix']['main']['milter_protocol']       = 2
node.default['postfix']['main']['smtpd_milters']         = node['postfix_dkim']['postfix_milter_socket']
node.default['postfix']['main']['non_smtpd_milters']     = node['postfix_dkim']['postfix_milter_socket']

include_recipe 'postfix'

package 'opendkim'
package 'opendkim-tools' # For opendkim-genkey

template "/etc/opendkim.conf" do
  source "opendkim.conf.erb"
  mode 0755
  variables(
    domain:       node['postfix_dkim']['domain'],
    keyfile:      node['postfix_dkim']['keyfile'],
    selector:     node['postfix_dkim']['selector'],
    socket:       node['postfix_dkim']['socket']
  )
end

directory File.dirname(node['postfix_dkim']['keyfile']) do
  mode 0755
end

bash "generate and install key" do
  cwd File.dirname(node['postfix_dkim']['keyfile'])
  code <<-EOH
    opendkim-genkey #{node['postfix_dkim']['testmode'] ? '-t' : ''} -s #{node['postfix_dkim']['selector']} -d #{node['postfix_dkim']['domain']}
    mv "#{node['postfix_dkim']['selector']}.private" #{File.basename node['postfix_dkim']['keyfile']}
  EOH
  not_if { File.exist? node['postfix_dkim']['keyfile'] }
end

file node['postfix_dkim']['keyfile'] do
  owner 'opendkim'
  mode '0600'
end

# opendkim 2.11+ (first shipped with Ubuntu 18) changed the service and config
# files, moving settings from the service file to the config file. We
# previously "fixed" that by restoring an old service file to work with the
# old config file. Now we've updated the config file so we can use the updated
# service file. If it looks like the existing service file is our old "fixed"
# version, "update" it to match the upstream service file.

execute 'reload-systemd' do
  command 'systemctl daemon-reload'

  action :nothing
end

cookbook_file '/lib/systemd/system/opendkim.service' do
  owner 'root'
  group 'root'
  mode '0644'

  only_if { ::File.read('/lib/systemd/system/opendkim.service').match(/EnvironmentFile=-\/etc\/default\/opendkim/) }

  notifies :run, 'execute[reload-systemd]', :immediately
end

service "opendkim" do
  action :start
end
