#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::legacy::common_settings' do
  it "returns legacy passgen's common settings" do
    # creates vardir for this example block
    subject # rubocop:disable RSpec/NamedSubject
    expected = {
      'keydir'    => File.join(Puppet.settings[:vardir], 'simp', 'environments', scope.lookupvar('::environment'), 'simp_autofiles', 'gen_passwd'),
      'user'      => Etc.getpwuid(Process.uid).name,
      'group'     => Etc.getgrgid(Process.gid).name,
      'dir_mode'  => 0o750,
      'file_mode' => 0o640,
    }

    is_expected.to run.and_return(expected)
  end
end
