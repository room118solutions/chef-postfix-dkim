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
    autorestart:  (node['postfix_dkim']['autorestart'] ? 'yes' : 'no'),
    send_headers: node['postfix_dkim']['sender_headers']
  )
end

template "/etc/default/opendkim" do
  source "opendkim.erb"
  mode 0755
  variables(
    socket: node['postfix_dkim']['socket']
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

service "opendkim" do
  action :start
end

service "postfix" do
  action :restart
end