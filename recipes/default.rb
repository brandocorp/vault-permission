#
# Cookbook Name:: vault-permission
# Recipe:: default
#
# Copyright (C) 2014
#
#
#

#
# @example Add the current client to the secrets::test_module vault
#
# vault_permission 'Add current node to vault permissions' do
#   client_name node.name
#   vault_name  'secrets'
#   vault_item  'test_module'
#   admin_name  'vault-permission'
#   admin_key   '/tmp/vagrant-chef-4/validation.pem'
# end
#
# vault = ChefVault::Item.load('secrets', 'test_module')
# Chef::Log.info vault['secret_key']
#

chef_gem 'chef-vault'
require 'chef-vault'

