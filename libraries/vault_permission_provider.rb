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
        return unless have_admin_authority?
        configure_as_admin(@new_resource.admin_name, @new_resource.admin_key)
        load_vault(new_resource.vault_name, new_resource.vault_item)

        if vault_clients.include? @new_resource.client_name
          return
        else
          converge_by("add #{@new_resource.client_name} to vault #{@new_resource.vault_name}::#{@new_resource.vault_item}") do
            add_vault_permission(@new_resource.client_name, vault)
          end
        end
      end

      def action_remove
        return unless have_admin_authority?
        configure_as_admin(@new_resource.admin_name, @new_resource.admin_key)
        load_vault(new_resource.vault_name, new_resource.vault_item)

        if vault_clients.include? @new_resource.client_name
          converge_by("removing #{@new_resource.client_name} from vault #{@new_resource.vault_name}::#{@new_resource.vault_item}") do
            remove_vault_permission(@new_resource.client_name, vault)
          end
        else
          return
        end
      end

      def vault_clients
        vault.keys.clients
      end

      private

      def have_admin_authority?
        admin_name? && admin_key?
      end

      def admin_name?
        # Validate an admin client was provided
        ! @new_resource.admin_name.nil?
      end

      def admin_key?
        !@new_resource.admin_key.nil? && ::File.exists?(@new_resource.admin_key)
      end

      def load_vault(name, item)
        @vault = ChefVault::Item.load(name, item)
      end

      # This part is questionable. I'd like some feedback on the potential issues
      # switching the node/client might have
      def configure_as_admin(name, key)
        Chef::Config[:node_name] = name
        Chef::Config[:client_key] = key
      end

      def add_vault_permission(client, vault)
        client = ChefVault::ChefPatch::ApiClient.load(client)
        vault.keys.add(client, vault.secret, "clients")
        vault.keys.save
      end

      def remove_vault_permission(client, vault)
        client = ChefVault::ChefPatch::ApiClient.load(client)
        vault.keys.delete(client, "clients")
        vault.keys.save
      end

    end
  end
end
