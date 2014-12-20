chef_server_url   'http://127.0.0.1:8889'
node_name         'test-kitchen'
client_key        'test-kitchen.pem'
cookbook_path File.expand_path("../../cookbooks", __FILE__)
local_mode true
