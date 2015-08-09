# vault-permission

Use a validator client to provide new nodes with access to a chef-vault.

# Usage

This cookbook was designed with two scenarios in mind.

1. Giving a new node access to a Vault or Vaults during its initial chef run.

2. Testing of a cookbook which may require access to a Vault.


## New Nodes

When bootstrapping a new node, some assumptions are made. The first assumption
is that the node still has access to the validator pem. The second assumption is
that the validator client has been made an administrator of all required vaults.

> Note: The `Vagrantfile` included [here](https://github.com/brandocorp/vault-permission/blob/master/Vagrantfile) was used to validate functionality against an active Chef Server. 


### Setup

One way to achieve this is by
[including](https://github.com/Nordstrom/chef-vault#kniferb) the validator as
an admin in your `knife.rb` config.

#### Example:

```ruby
knife[:vault_admins] = ['validator']
```

Once the validator has been made an admin, you can provide the new node with
access, by using the `vault_permission` resource. As an example, suppose we need
to give the node access to the `development` item in the `passwords` vault.
First, create the vault if it doesn't already exist.

```shell
knife vault create passwords development '{"admin": "password"}' -A brandocorp-validator -m client
```

With the validator as an admin of the vault, we then add the following in our
recipe code.

#### Example:

```ruby
vault_permission "Adding #{node.name} to vault[passwords::development]" do
  client_name Chef::Config[:node_name]
  client_key  Chef::Config[:client_key]
  vault_name  'passwords'
  vault_item  'development'
  admin_name  'brandocorp-validator'
  admin_key   '/etc/chef/brandocorp-validator.pem'
  only_if { ::File.exist? '/etc/chef/brandocorp-validator.pem' }
end
```

## Testing

If you want to test access to a vault in your cookbook, it can be tricky for the
same reasons. Since the test kitchen node is not truly a node on a Chef Server,
it's hard to have a vault ready to go with access provided to your kitchen node.

Luckily, test kitchen uses a common validator for all runs, and this can be used
in conjunction with Chef Vault to provide your kitchen node with access to the
vault.

### Setup

Start by creating some fixture data.

##### knife.rb

```shell
$ mkdir -p ./test/fixtures/{.chef,clients,data_bags}
$ cat > ./test/fixtures/.chef/knife.rb <<-EOS
node_name         'test-kitchen'
client_key        'test-kitchen.pem'
cookbook_path File.expand_path("../../cookbooks", __FILE__)
local_mode true
EOS
```

##### test-kitchen.pem

```shell
$ cat > ./test/fixtures/.chef/test-kitchen.pem <<-EOS
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA0sOY9tHvVtLZ6xmVmH8d8LrRrNcWOXbrvvCrai+T3GtRvRSL
hksLrpOpD0L9EHM6NdThNF/eGA9Oq+UKAe6yXR0hwsKuxKXqQ8SEmlhZZ9GiuggD
B/zYD3ItB6SGpdkRe7kQqTChQyrIXqbRkJqxoTXLyeJDF0sCyTdp3L8IZCUWodM8
oV9TlQBJHYtG1gLUwIi8kcMVEoCn2Q8ltCj0/ftnwhTtwO52RkWA0uYOLGVayHsL
SCFfx+ACWPU/oWCwW5/KBqb3veTv0aEg/nh0QsFzRLoTx6SRFI5dT2Nf8iiJe4WC
UG8WKEB2G8QPnxsxfOPYDBdTJ4CXEi2e+z41VQIDAQABAoIBAALhqbW2KQ+G0nPk
ZacwFbi01SkHx8YBWjfCEpXhEKRy0ytCnKW5YO+CFU2gHNWcva7+uhV9OgwaKXkw
KHLeUJH1VADVqI4Htqw2g5mYm6BPvWnNsjzpuAp+BR+VoEGkNhj67r9hatMAQr0I
itTvSH5rvd2EumYXIHKfz1K1SegUk1u1EL1RcMzRmZe4gDb6eNBs9Sg4im4ybTG6
pPIytA8vBQVWhjuAR2Tm+wZHiy0Az6Vu7c2mS07FSX6FO4E8SxWf8idaK9ijMGSq
FvIS04mrY6XCPUPUC4qm1qNnhDPpOr7CpI2OO98SqGanStS5NFlSFXeXPpM280/u
fZUA0AECgYEA+x7QUnffDrt7LK2cX6wbvn4mRnFxet7bJjrfWIHf+Rm0URikaNma
h0/wNKpKBwIH+eHK/LslgzcplrqPytGGHLOG97Gyo5tGAzyLHUWBmsNkRksY2sPL
uHq6pYWJNkqhnWGnIbmqCr0EWih82x/y4qxbJYpYqXMrit0wVf7yAgkCgYEA1twI
gFaXqesetTPoEHSQSgC8S4D5/NkdriUXCYb06REcvo9IpFMuiOkVUYNN5d3MDNTP
IdBicfmvfNELvBtXDomEUD8ls1UuoTIXRNGZ0VsZXu7OErXCK0JKNNyqRmOwcvYL
JRqLfnlei5Ndo1lu286yL74c5rdTLs/nI2p4e+0CgYB079ZmcLeILrmfBoFI8+Y/
gJLmPrFvXBOE6+lRV7kqUFPtZ6I3yQzyccETZTDvrnx0WjaiFavUPH27WMjY01S2
TMtO0Iq1MPsbSrglO1as8MvjB9ldFcvp7gy4Q0Sv6XT0yqJ/S+vo8Df0m+H4UBpU
f5o6EwBSd/UQxwtZIE0lsQKBgQCswfjX8Eg8KL/lJNpIOOE3j4XXE9ptksmJl2sB
jxDnQYoiMqVO808saHVquC/vTrpd6tKtNpehWwjeTFuqITWLi8jmmQ+gNTKsC9Gn
1Pxf2Gb67PqnEpwQGln+TRtgQ5HBrdHiQIi+5am+gnw89pDrjjO5rZwhanAo6KPJ
1zcPNQKBgQDxFu8v4frDmRNCVaZS4f1B6wTrcMrnibIDlnzrK9GG6Hz1U7dDv8s8
Nf4UmeMzDXjlPWZVOvS5+9HKJPdPj7/onv8B2m18+lcgTTDJBkza7R1mjL1Cje/Z
KcVGsryKN6cjE7yCDasnA7R2rVBV/7NWeJV77bmzT5O//rW4yIfUIg==
-----END RSA PRIVATE KEY-----
EOS
```

##### test-kitchen.pub

```shell
$ cat > ./test/fixtures/.chef/test-kitchen.pub <<-EOS
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0sOY9tHvVtLZ6xmVmH8d
8LrRrNcWOXbrvvCrai+T3GtRvRSLhksLrpOpD0L9EHM6NdThNF/eGA9Oq+UKAe6y
XR0hwsKuxKXqQ8SEmlhZZ9GiuggDB/zYD3ItB6SGpdkRe7kQqTChQyrIXqbRkJqx
oTXLyeJDF0sCyTdp3L8IZCUWodM8oV9TlQBJHYtG1gLUwIi8kcMVEoCn2Q8ltCj0
/ftnwhTtwO52RkWA0uYOLGVayHsLSCFfx+ACWPU/oWCwW5/KBqb3veTv0aEg/nh0
QsFzRLoTx6SRFI5dT2Nf8iiJe4WCUG8WKEB2G8QPnxsxfOPYDBdTJ4CXEi2e+z41
VQIDAQAB
-----END PUBLIC KEY-----
EOS
```

##### test-kitchen.json

```shell
$ cat > ./test/fixtures/clients/test-kitchen.json <<-EOS
{
  "name": "test-kitchen",
  "public_key": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0sOY9tHvVtLZ6xmVmH8d\n8LrRrNcWOXbrvvCrai+T3GtRvRSLhksLrpOpD0L9EHM6NdThNF/eGA9Oq+UKAe6y\nXR0hwsKuxKXqQ8SEmlhZZ9GiuggDB/zYD3ItB6SGpdkRe7kQqTChQyrIXqbRkJqx\noTXLyeJDF0sCyTdp3L8IZCUWodM8oV9TlQBJHYtG1gLUwIi8kcMVEoCn2Q8ltCj0\n/ftnwhTtwO52RkWA0uYOLGVayHsLSCFfx+ACWPU/oWCwW5/KBqb3veTv0aEg/nh0\nQsFzRLoTx6SRFI5dT2Nf8iiJe4WCUG8WKEB2G8QPnxsxfOPYDBdTJ4CXEi2e+z41\nVQIDAQAB\n-----END PUBLIC KEY-----",
  "validator": false,
  "admin": true,
  "json_class": "Chef::ApiClient",
  "chef_type": "client"
}
EOS
```

##### Client List

With the above files in place, and inside the `test/fixtures` directory, you
should be able to run the following command.

```shell
$ cd ./test/fixtures
$ knife client list
test-kitchen
```

##### Create a Vault

Create the development vault item in the passwords vault.

```shell
$ knife vault create passwords development '{"admin": "password"}' -A test-kitchen
$ ls ./data_bags/passwords/
development.json      development_keys.json
```

View the content of the vault after creating it.

```shell
$ knife vault show passwords development
admin: password
id:    development
```

##### Accessing the Vault

You should then be able to access the Vault from your node using the `vault_permission` resource as described above.

```ruby
# grant permissions
vault_permission "Adding #{node.name} to vault[passwords::development]" do
  client_name Chef::Config[:node_name]
  client_key  Chef::Config[:client_key]
  vault_name  'passwords'
  vault_item  'development'
  admin_name  'test-kitchen'
  admin_key   '/tmp/kitchen/validator.pem'
end

# test our access
vault = ChefVault::Item.load('passwords', 'development')
log vault['admin']
```
