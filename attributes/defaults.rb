#
# Cookbook Name:: chatsecure_rubdub
# Attributes:: default
#
# Copyright 2016, Chris Ballinger
#
# Licensed under the AGPLv3
#

# Chef repo
default['chatsecure_rubdub']['secret_databag_name'] = "secrets"
default['chatsecure_rubdub']['secret_item_name']    = "chatsecure_rubdub"

# TODO SSL
#default['chatsecure_rubdub']['ssl_databag_name']       = "ssl"
#default['chatsecure_rubdub']['ssl_databag_item_name']  = "ssl"
 
# System
default['chatsecure_rubdub']['app_root']            = "/var/www/RubDub"
default['chatsecure_rubdub']['git_root']            = "/var/git/chatsecure-rubdub.git"  # Checkout into this directory, then copy to app_root post-receive

default['chatsecure_rubdub']['service_user']        = "rubdub"
default['chatsecure_rubdub']['service_group_id']    = 500

default['chatsecure_rubdub']['service_name']        = "chatsecure-rubdub"

default['chatsecure_rubdub']['git_user']            = "git"
default['chatsecure_rubdub']['git_url']             = "git://github.com/ChatSecure/RubDub.git"
default['chatsecure_rubdub']['git_rev']             = "master"
default['chatsecure_rubdub']['log_dir']             = "/var/log/chatsecure_rubdub/"
default['chatsecure_rubdub']['service_log']         = "chatsecure_rubdub.log"
default['chatsecure_rubdub']['run_script']          = "run.sh"

# RubDub parameters
default['chatsecure_rubdub']['port']                = 5269
default['chatsecure_rubdub']['bind_address']        = "pubsub-test.chatsecure.org"
default['chatsecure_rubdub']['domain']              = "pubsub-test.chatsecure.org"
default['chatsecure_rubdub']['tls_dir']				= "/srv/ssl/"
default['chatsecure_rubdub']['tls_key_path']        = "/srv/ssl/pubsub.chatsecure.org.key" 
default['chatsecure_rubdub']['tls_cert_path']       = "/srv/ssl/pubsub.chatsecure.org.crt"
