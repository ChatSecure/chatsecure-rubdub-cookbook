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

# Setup certbot
certbot_name = 'certbot-auto'
remote_file '/usr/local/bin/certbot-auto' do
  source 'https://dl.eff.org/certbot-auto'
  mode '0755'
  action :create_if_missing
end

execute "use certbot to generate certificate" do
	command "certbot-auto certonly --standalone -n --agree-tos --email chris@chatsecure.org -d pubsub.chatsecure.org --keep"
end

fix_permissions = "cp /etc/letsencrypt/live/pubsub.chatsecure.org/fullchain.pem #{node['chatsecure_rubdub']['tls_cert_path']} && cp /etc/letsencrypt/live/pubsub.chatsecure.org/privkey.pem #{node['chatsecure_rubdub']['tls_key_path']} && chown -R #{node['chatsecure_rubdub']['service_user']}:#{group_id} #{node['chatsecure_rubdub']['tls_dir']} && chmod 755 -R #{node['chatsecure_rubdub']['tls_dir']}"

execute "fix cert permissions" do
	command fix_permissions
end

cron_command = "certbot renew --standalone -n --post-hook \"#{fix_permissions} && service #{node['chatsecure_rubdub']['service_name']} restart\""

cron_d 'update-certificate' do
	predefined_value '@daily'
	command cron_command
end

execute "Install Node 6 LTS PPA" do
	command "curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -"
	command "sudo apt-get upgrade nodejs -y"
end

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
    :service_name => node['chatsecure_rubdub']['service_name'],
    :port => node['chatsecure_rubdub']['port'],
    :bind_address => node['chatsecure_rubdub']['bind_address'],
    :domain => node['chatsecure_rubdub']['domain'],
    :tls_key_path => node['chatsecure_rubdub']['tls_key_path'],
    :tls_cert_path => node['chatsecure_rubdub']['tls_cert_path']
    })
end

# Make service log file
directory node['chatsecure_rubdub']['log_dir'] do
  owner node['chatsecure_rubdub']['service_user']
  group group_id
  recursive true
  action :create
end

file log_path do
  mode '770'
  owner node['chatsecure_rubdub']['service_user']
  group group_id
  action [:create_if_missing, :touch]
end

# Register app as a service
service node['chatsecure_rubdub']['service_name'] do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end