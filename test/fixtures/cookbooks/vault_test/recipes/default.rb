include_recipe 'vault-permission::default'

chef_gem 'pry' do
  compile_time true
end

vault_permission 'Add current node to vault permissions' do
  client_name Chef::Config[:node_name]
  client_key Chef::Config[:client_key]
  vault_name 'secrets'
  vault_item 'test'
  admin_name node['vault_permission']['admin_name']
  admin_key  node['vault_permission']['admin_key']
end

vault = ChefVault::Item.load('secrets', 'test')
log "secret_key = #{vault['secret_key']}"
