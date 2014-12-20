class Chef
  class Resource
    class VaultPermission < Chef::Resource
      provides :vault_permission, :on_platforms => :all

      def initialize(name, run_context=nil)
        super
        @action = :add
        @allowed_actions.push(:add, :remove)
        @vault_name = name
        @vault_item = nil
        @admin_name = nil
        @admin_key  = nil
        @resource_name = :vault_permission
        @provider = Chef::Provider::VaultPermission
      end

      def client_name(arg=nil)
        set_or_return(
          :client_name,
          arg,
          :kind_of => [ String ]
        )
      end

      def vault_name(arg=nil)
        set_or_return(
          :vault_name,
          arg,
          :kind_of => [ String ]
        )
      end

      def vault_item(arg=nil)
        set_or_return(
          :vault_item,
          arg,
          :kind_of => [ String ]
        )
      end

      def admin_name(arg=nil)
        set_or_return(
          :admin_client,
          arg,
          :kind_of => [ String ]
        )
      end

      def admin_key(arg=nil)
        set_or_return(
          :admin_client_key,
          arg,
          :kind_of => [ String ]
        )
      end

      def after_created
        Array(@action).each do |action|
          self.run_action(action)
        end
      end
    end
  end
end
