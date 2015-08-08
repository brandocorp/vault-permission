#
# Cookbook Name:: vault-permission
# Recipe:: default
#
# Copyright (C) 2014

chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault'
