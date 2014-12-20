include_recipe "vault-permission::default"

vault_permission 'Add current node to vault permissions' do
  client_name node.name
  vault_name  'secrets'
  vault_item  'test'
  admin_name  'test-kitchen'
  admin_key   '/tmp/kitchen/validation.pem'
end

vault = ChefVault::Item.load('secrets', 'test')
Chef::Log.info vault['secret_key']

vault_permission 'secrets' do
  client_name node.name
  vault_item  'test'
  admin_name  'test-kitchen'
  admin_key   '/tmp/kitchen/validation.pem'
  action      :remove
end

