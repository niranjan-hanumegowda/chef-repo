#
# Cookbook Name:: graylog2
# Recipe:: default
#
# Copyright 2014, Custom, Inc.
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
# 

# Create user and group
#
group node.graylog2[:user] do
  action   :create
  system   true
end

user node.graylog2[:user] do
  comment  "graylog2 User"
  home     node.graylog2[:home]
  shell    "/bin/bash"
  gid      node.graylog2[:user]
  supports :manage_home => false
  action   :create
  system   true
end

# FIX: Work around the fact that Chef creates the directory even for `manage_home: false`
bash "remove the graylog2 user home" do
  user     'root'
  code     "rm -rf  #{node.graylog2[:home]}"
  not_if   "test -L #{node.graylog2[:home]}"
  only_if  "test -d #{node.graylog2[:home]}"
end
