#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::simpkv::root_dir' do
  it "should return passgen's root directory in simpkv" do
    is_expected.to run.and_return('gen_passwd')
  end
end
