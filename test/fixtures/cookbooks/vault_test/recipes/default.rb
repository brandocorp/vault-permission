include_recipe 'vault-permission::default'

chef_gem 'pry' do
  compile_time true
end

ruby_block 'Test Vault Permissions' do
  block do
    begin
      vault = ChefVault::Item.load('secrets', 'test')
      Chef::Log.info "secret_key = #{vault['secret_key']}"
    rescue ChefVault::Exceptions::SecretDecryption
      Chef::Log.warn "Vault can not be decrypted by this client, yet!"
    end
  end
end

vault_permission 'Add current node to vault permissions' do
  client_name Chef::Config[:node_name]
  client_key Chef::Config[:client_key]
  vault_name 'secrets'
  vault_item 'test'
  admin_name node['vault_permission']['admin_name']
  admin_key  node['vault_permission']['admin_key']
  action :add
end

ruby_block 'Decrypt the Vault' do
  block do
    vault = ChefVault::Item.load('secrets', 'test')
    puts "secret_key = #{vault['secret_key']}"
  end
end
