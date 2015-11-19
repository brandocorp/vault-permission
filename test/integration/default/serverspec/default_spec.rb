require 'spec_helper'

describe file('/tmp/kitchen/data_bags/secrets/test_keys.json') do
  it { is_expected.to be_file }
  its(:content) { is_expected.not_to match(/default-(ubuntu|centos)-\d+/) }
end
