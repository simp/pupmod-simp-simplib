require 'spec_helper'

describe 'simplib::os_bugfixes' do
  context 'supported operating systems' do
    on_supported_os.each do |os, __facts|
      puts "       ^^^    os:      '#{os}'"
      puts "       @@@ facts:      '#{__facts.fetch(:operatingsystemmajrelease)}'"
      
      ### Temporary debugging junk: add `PRY1=x PRY2=x` in front of your rspec
      ### run to drop down to each pry point.
      ### 
      require 'pry'; binding.pry if ENV['PRY1']

      let(:facts) do
        puts "       @@@    os:      '#{os}'"
        puts "       @@@ facts:      '#{__facts.fetch(:operatingsystemmajrelease)}'"
        require 'pry'; binding.pry if ENV['PRY2']
        __facts
      end

      context  "on #{os}" do
        context 'base' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('simplib::os_bugfixes') }
        end

        context 'bugfix1049656' do
          let(:params) {{ :include_bugfix1049656 => true }}

          it do
            _facts = facts_hash(nodename('foo'))
            puts "       === facts:      '#{facts.fetch(:operatingsystemmajrelease)}'"
            puts "       === facts_hash: '#{_facts.fetch('operatingsystemmajrelease')}'"
            require 'pry'; binding.pry if ENV['PRY3']

            #### using the facts_hash:
            ###if (_facts.fetch('osfamily') == 'RedHat') && (_facts.fetch('operatingsystemmajrelease').to_s == '7')
            if (facts.fetch(:osfamily) == 'RedHat') && (facts.fetch(:operatingsystemmajrelease) == 7) 
              is_expected.to contain_file('/etc/init.d/bugfix1049656').with_ensure('file')
            else
              require 'pry'; binding.pry if ENV['PRY4']
              ### TIP: a notify called 'xxx' is in the catalogue.  It records what the
              ###      value of `::operatingsystemmajrelease` was at compile time.
              ### 
              ### From pry, use:
              ### 
              ###  catalogue.instance_variable_get('@in_to')
              ### 
              ### And look for Notify[xxx]
              ### 
              is_expected.to contain_file('/etc/init.d/bugfix1049656').with_ensure('absent')
            end
          end

          it do
            ###_facts = facts_hash(nodename('foo'))
            #### using the facts_hash:
            ###if (_facts.fetch('osfamily') == 'RedHat') && (_facts.fetch('operatingsystemmajrelease').to_s == '7')
            if (facts.fetch(:osfamily) == 'RedHat') && (facts.fetch(:operatingsystemmajrelease) == 7) 
              is_expected.to contain_service('bugfix1049656').with_enable(true)
            else
              is_expected.to contain_service('bugfix1049656').with_enable(false)
            end
          end

        end
      end
    end
  end
end

