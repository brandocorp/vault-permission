require 'spec_helper'

describe 'vault-permission::default' do
  cached(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }

  it 'installs the chef-vault gem' do
    expect(chef_run).to install_chef_gem('chef-vault')
  end
end
