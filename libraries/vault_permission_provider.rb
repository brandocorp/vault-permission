class Chef
  class Provider
    class VaultPermission < Chef::Provider
      attr_reader :vault

      def whyrun_supported?
        true
      end

      def load_current_resource
      end

      def action_add
        as_vault_admin do
          converge_by("add #{@new_resource.client_name} to vault[#{@new_resource.vault_name}::#{@new_resource.vault_item}]") do
            add_vault_permission unless vault_clients.include?(@new_resource.client_name)
          end
        end
      end

      def action_remove
        as_vault_admin do
          converge_by("removing #{@new_resource.client_name} from vault #{@new_resource.vault_name}::#{@new_resource.vault_item}") do
            remove_vault_permission if vault_clients.include?(@new_resource.client_name)
          end
        end
      end

      def client
        @client ||= generate_client_object
      end

      def generate_client_object
        client = ChefVault::ChefPatch::ApiClient.load(@new_resource.client_name)
        client.name(@new_resource.client_name) unless client.name == @new_resource.client_name
        client.public_key(local_client_key.public_key.to_pem) if client.public_key.nil?
        client
      rescue Net::HTTPServerException
        local_client
      end

      def local_client
        client = Chef::ApiClient.new
        client.name(@new_resource.client_name)
        client.public_key(local_client_key.public_key.to_pem)
        client
      end

      def local_client_key
        OpenSSL::PKey::RSA.new(::File.read(@new_resource.client_key))
      end

      def vault
        @vault ||= ChefVault::Item.load(
          @new_resource.vault_name,
          @new_resource.vault_item
        )
      end

      def vault_clients
        vault.keys.clients
      end

      private

      def as_vault_admin
        Chef::Config[:node_name]  = @new_resource.admin_name
        Chef::Config[:client_key] = @new_resource.admin_key
        yield
        Chef::Config[:node_name]  = @new_resource.client_name
        Chef::Config[:client_key] = @new_resource.client_key
      end

      def add_vault_permission
        vault.keys.add(client, vault.secret, 'clients')
        vault.keys.save
      end

      def remove_vault_permission
        vault.keys.delete(client, 'clients')
        vault.keys.save
      end
    end
  end
end
