class Chef
  class Resource
    class VaultPermission < Chef::Resource::LWRPBase

      identity_attr :client_name

      resource_name :vault_permission

      actions :add, :remove
      default_action :add

      attribute :client_name,
        kind_of: String,
        default: Chef::Config[:node_name]

      attribute :client_key,
        kind_of: String,
        default: Chef::Config[:client_key]

      attribute :vault_name,
        kind_of: String,
        required: true,
        default: nil

      attribute :vault_item,
        kind_of: String,
        required: true,
        default: nil

      attribute :admin_name,
        kind_of: String,
        default: nil

      attribute :admin_key,
        kind_of: String,
        required: true,
        default: nil

      # def after_created
      #   Array(@action).each do |action|
      #     run_action(action)
      #   end
      # end
    end
  end
end
