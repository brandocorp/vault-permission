class Chef
  class VaultValidator

    attr_reader :node

    def initialize(node, vault)
      @node = node
      configure(vault)
    end

    def configure(vault)
      # Load the vault item
      vault   = ChefVault::Item.load('secrets', vault)
      # Skip this if we're already allowed
      unless vault.keys.clients.include?(node.name)
        Chef::Log.info ("Adding #{node.name} to vault: #{vault}")
        clients = vault.keys

        # Build a client object which represents the current node running chef-client
        client = ChefVault::ChefPatch::ApiClient.load(node.name)

        # Add the node to the vault, and save the change
        clients.add(client, vault.secret, "clients")
        clients.save
      end
    end
  end
end
