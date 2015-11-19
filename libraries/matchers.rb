if defined?(ChefSpec)
  def add_vault_permission(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :vault_permission,
      :create,
      resource_name
    )
  end

  def remove_vault_permission(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :vault_permission,
      :remove,
      resource_name
    )
  end
end
