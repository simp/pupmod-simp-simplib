require 'spec_helper'

describe 'simplib::proc_options' do
  context 'when facts.simplib__mountpoints./proc.options is not defined' do

    let(:facts){{}}

    it { is_expected.to run.and_return({}) }
  end

  context 'when facts.simplib__mountpoints does not include /proc' do
    let(:facts){{
      'simplib__mountpoints' =>{
        '/tmp' => {
          'options' => ['foo']
        }
      }
    }}

    it { is_expected.to run.and_return({}) }
  end

  context 'when facts.simplib__mountpoints./proc.options does not include hidepid' do
    let(:facts){{
      'simplib__mountpoints' =>{
        '/proc' => {
          'options' => ['foo']
        }
      }
    }}

    it { is_expected.to run.and_return({'foo' => nil}) }
  end

  context 'when facts.simplib__mountpoints./proc.options includes hidepid' do
    let(:facts){{
      'simplib__mountpoints' =>{
        '/proc' => {
          'options' => ["hidepid=#{hidepid_val}"]
        }
      }
    }}

    [0, 1, 2, 'foo'].each do |test_val|
      context "with hidepid=#{test_val}" do
        let(:hidepid_val){ test_val }

        it { is_expected.to run.and_return({'hidepid' => hidepid_val}) }
      end
    end
  end

  context 'when facts.simplib__mountpoints./proc.options includes gid' do
    let(:facts){{
      'simplib__mountpoints' =>{
        '/proc' => {
          'options' => ["gid=#{gid_val}"]
        }
      }
    }}

    [885, 234, 111, 'foo'].each do |test_val|
      context "with gid=#{test_val}" do
        let(:gid_val){ test_val }

        it { is_expected.to run.and_return({'gid' => gid_val}) }
      end
    end
  end

  context 'when facts.simplib__mountpoints./proc.options includes hidepid and gid' do
    let(:facts){{
      'simplib__mountpoints' =>{
        '/proc' => {
          'options' => [
            "hidepid=#{hidepid_val}",
            "gid=#{gid_val}"
          ]
        }
      }
    }}

    [885, 234, 111, 'foo'].each do |test_gid_val|
      [0, 1, 2, 'foo'].each do |test_hidepid_val|
        context "with hidepid=#{test_hidepid_val} and gid=#{test_gid_val}" do
          let(:hidepid_val){ test_hidepid_val }
          let(:gid_val){ test_gid_val }

          it { is_expected.to run.and_return({'hidepid' => hidepid_val, 'gid' => gid_val}) }
        end
      end
    end
  end
end
