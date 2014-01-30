#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Copyright 2014, Gap, Inc.
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
[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

Erubis::Context.send(:include, Extensions::Templates)

mongodb = "mongodb-#{node.mongodb[:version]}"

include_recipe "ark"

# Create user and group
#
group node.mongodb[:user] do
  action :create
  system true
end

user node.mongodb[:user] do
  comment "mongodb User"
  home    "#{node.mongodb[:dir]}/mongodb"
  shell   "/bin/bash"
  gid     node.mongodb[:user]
  supports :manage_home => false
  action  :create
  system true
end

# FIX: Work around the fact that Chef creates the directory even for `manage_home: false`
bash "remove the mongodb user home" do
  user    'root'
  code    "rm -rf  #{node.mongodb[:dir]}/mongodb"

  not_if  "test -L #{node.mongodb[:dir]}/mongodb"
  only_if "test -d #{node.mongodb[:dir]}/mongodb"
end


# Create service
#
template "/etc/init.d/mongod" do
  source "mongod.init.erb"
  owner 'root' and mode 0755
end

service "mongod" do
  supports :status => true, :restart => true
  action [ :enable ]
end

# Download, extract, symlink the mongodb libraries and binaries
#
ark_prefix_root = node.mongodb[:dir] || node.ark[:prefix_root]
ark_prefix_home = node.mongodb[:dir] || node.ark[:prefix_home]

ark "mongodb" do
  url   node.mongodb[:download_url]
  owner node.mongodb[:user]
  group node.mongodb[:user]
  version node.mongodb[:version]
  has_binaries ['bin/mongod', 'bin/mongo', 'bin/mongos']
  checksum node.mongodb[:checksum]
  prefix_root   ark_prefix_root
  prefix_home   ark_prefix_home

  notifies :start,   'service[mongod]'
  notifies :restart, 'service[mongod]' unless node.mongodb[:skip_restart]

  not_if do
    link   = "#{node.mongodb[:dir]}/mongodb"
    target = "#{node.mongodb[:dir]}/mongodb-#{node.mongodb[:version]}"
    binary = "#{target}/bin/mongod"

    ::File.directory?(link) && ::File.symlink?(link) && ::File.readlink(link) == target && ::File.exists?(binary)
  end
end

link "/usr/bin/mongod" do
  to "#{node.mongodb[:dir]}/mongodb/bin/mongo"
end

# Increase open file and memory limits
#
bash "enable user limits" do
  user 'root'

  code <<-END.gsub(/^    /, '')
    echo 'session    required   pam_limits.so' >> /etc/pam.d/su
  END

  not_if { ::File.read("/etc/pam.d/su").match(/^session    required   pam_limits\.so/) }
end

log "increase limits for the mongodb user"

file "/etc/security/limits.d/10-mongodb.conf" do
  content <<-END.gsub(/^    /, '')
    #{node.mongodb.fetch(:user, "mongod")}     -    nofile    #{node.mongodb[:limits][:nofile]}
    #{node.mongodb.fetch(:user, "mongod")}     -    memlock   #{node.mongodb[:limits][:memlock]}
  END
end

template "/etc/sysconfig/mongod" do
  source  'mongod.sysconfig.erb'
  owner 'root'
  group 'root'
  mode '0644'

  notifies :start,   'service[mongod]'
  notifies :restart, 'service[mongod]' unless node.mongodb[:skip_restart]
end

template "/etc/mongod.conf" do
  source  'mongod.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'

  notifies :start,   'service[mongod]'
  notifies :restart, 'service[mongod]' unless node.mongodb[:skip_restart]
end
