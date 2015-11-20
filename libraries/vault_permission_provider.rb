class Chef
  class Provider
    class VaultPermission < Chef::Provider::LWRPBase
      attr_reader :vault

      provides :vault_permission

      use_inline_resources

      def whyrun_supported?
        true
      end

      def load_current_resource
      end

      action :add do
        as_vault_admin do
          converge_by("add #{client_name} to #{vault_name}/#{vault_item}") do
            Chef::Log.debug "add permissions as #{Chef::Config['node_name']}"
            add_vault_permission
          end unless vault_clients.include?(client_name)
        end
      end

      action :remove do
        as_vault_admin do
          converge_by("remove #{client_name} from #{vault_name}/#{vault_item}") do
            Chef::Log.debug "remove permissions as #{Chef::Config['node_name']}"
            remove_vault_permission
          end if vault_clients.include?(client_name)
        end
      end

      def client
        generate_client_object
      end

      def generate_client_object
        remote_client
      rescue Net::HTTPServerException
        Chef::Log.debug "Using local client"
        local_client
      end

      def remote_client
        client = ChefVault::ChefPatch::ApiClient.load(client_name)
        client.name(client_name) unless client.name == client_name
        client.public_key(local_client_key.public_key.to_pem) if client.public_key.nil?
        client
      end

      def local_client
        client = Chef::ApiClient.new
        client.name(client_name)
        client.public_key(local_client_key.public_key.to_pem)
        client
      end

      def local_client_key
        OpenSSL::PKey::RSA.new(::File.read(client_key))
      end

      def client_name
        @new_resource.client_name
      end

      def client_key
        @new_resource.client_key
      end

      def admin_name
        @new_resource.admin_name
      end

      def admin_key
        @new_resource.admin_key
      end

      def vault_name
        @new_resource.vault_name
      end

      def vault_item
        @new_resource.vault_item
      end

      def vault
        @vault ||= ChefVault::Item.load(vault_name, vault_item)
      end

      def vault_clients
        vault.keys.clients
      end

      private

      def as_vault_admin
        Chef::Log.debug "Assuming Admin Role: #{admin_name}"
        assume_admin_role
        load_vault
        yield
        Chef::Log.debug "Assuming Client Role: #{client_name}"
        assume_client_role
      end

      def assume_client_role
        Chef::Config[:node_name]  = client_name
        Chef::Config[:client_key] = client_key
      end

      def assume_admin_role
        Chef::Config[:node_name]  = admin_name
        Chef::Config[:client_key] = admin_key
      end

      def load_vault
        @vault = ChefVault::Item.load(vault_name, vault_item)
      end

      def add_vault_permission
        Chef::Log.debug "#{vault.raw_data}"
        vault.keys.add(client, vault.secret, 'clients')
        Chef::Log.debug vault.raw_data
        vault.keys.save
        # vault.clients(client, :add)
      end

      def remove_vault_permission
        Chef::Log.debug vault.to_json
        vault.keys.delete(client_name, 'clients')
        Chef::Log.debug vault.to_json
        vault.keys.save
        # vault.clients(client, :remove)
      end
    end
  end
end
