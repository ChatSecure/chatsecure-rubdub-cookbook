#
# Cookbook Name:: chatsecure_rubdub
# Recipe:: default
#
# Copyright 2016, Chris Ballinger
#
# Licensed under the AGPLv3
#

owner = node['chatsecure_rubdub']['service_user']
group_id = node['chatsecure_rubdub']['service_group_id']

# Make git checkout and app directories
directory node['chatsecure_rubdub']['app_root'] do
  owner node['chatsecure_rubdub']['git_user']
  group group_id
  recursive true
  action :create
end

directory node['chatsecure_rubdub']['git_root'] do
  owner node['chatsecure_rubdub']['git_user']
  group group_id
  recursive true
  action :create
end

ssh_known_hosts_entry 'github.com'

# Git checkout to git_root
git node['chatsecure_rubdub']['git_root'] do
   repository node['chatsecure_rubdub']['git_url'] 
   revision node['chatsecure_rubdub']['git_rev']  
   action :sync
   user node['chatsecure_rubdub']['git_user']
   group group_id
end

# Git post-receive hook for git_root: Pull changes to app_root
template node['chatsecure_rubdub']['git_root'] + "/.git/hooks/post-receive" do
  source "post-receive.sh.erb"
  owner node['chatsecure_rubdub']['git_user']
  group group_id
  mode "770"
  variables({
    :app_root => node['chatsecure_rubdub']['app_root'],
  })
end

# Perform initial Git pull from git_root into app_root
git node['chatsecure_rubdub']['app_root'] do
  repository node['chatsecure_rubdub']['git_root']
  revision node['chatsecure_rubdub']['git_rev']  
  action :sync
  user node['chatsecure_rubdub']['git_user']
  group group_id
end

execute "set_app_permissions" do
  command "chmod -R 770 ."
  cwd node['chatsecure_rubdub']['app_root']
end

# Make configured src/index.js
template node['chatsecure_rubdub']['app_root'] + "/src/index.js" do
    source "index.js.erb"
    owner node['chatsecure_rubdub']['git_user']   
    group group_id   
    mode "770"
    variables({
      :bind_address => node['chatsecure_rubdub']['bind_address'],
      :domain => node['chatsecure_rubdub']['domain'],
    })
    action :create
end

=begin
nodejs_npm 'install package.json dependencies' do
  path node['chatsecure_rubdub']['app_root'] # Directory containing package.json
  json true
  #user 'root'
  user node['chatsecure_rubdub']['service_user'] 
end
=end

execute "npm install package.json" do
  command "npm install"
  cwd node['chatsecure_rubdub']['app_root'] + '/'
  user node['chatsecure_rubdub']['service_user']
  group group_id
  environment "HOME" => "/home/" + node['chatsecure_rubdub']['service_user']
end

log_path = node['chatsecure_rubdub']['log_dir'] + node['chatsecure_rubdub']['service_log']
# Upstart service config file
template "/etc/init/" + node['chatsecure_rubdub']['service_name'] + ".conf" do
    source "upstart.conf.erb"
    owner 'root' 
    group 'root'
    variables({
    :service_user => node['chatsecure_rubdub']['service_user'],
    :app_root => node['chatsecure_rubdub']['app_root'],
    :log_path => log_path,
    :service_name => node['chatsecure_rubdub']['service_name']
    })
end

# Make service log file
directory node['chatsecure_rubdub']['log_dir'] do
  owner node['chatsecure_rubdub']['service_user']
  group group_id
  recursive true
  action :create
end

# Register app as a service
service node['chatsecure_rubdub']['service_name'] do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end