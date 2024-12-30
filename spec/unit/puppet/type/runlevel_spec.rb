#!/usr/bin/env rspec

require 'spec_helper'

runlevel_type = Puppet::Type.type(:runlevel)

describe runlevel_type do
  let(:catalog) { Puppet::Resource::Catalog.new }

  before(:each) do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Puppet::Type::Runlevel).to receive(:catalog).and_return(catalog)
    # rubocop:enable RSpec/AnyInstance
  end

  context 'when setting parameters' do
    let(:valid_names) do
      {
        '1' => '1',
        '2'          => '2',
        '3'          => '3',
        '4'          => '4',
        '5'          => '5',
        'rescue'     => '1',
        'multi-user' => '3',
        'graphical'  => '5',
      }
    end

    let(:invalid_names) { [ 'foo', '0', 'graphical.target' ] }

    context ':name' do
      it 'accepts valid values' do
        valid_names.each_pair do |key, value|
          resource = runlevel_type.new(name: key)
          expect(resource[:name]).to eq(value)
        end
      end

      it 'rejects invalid values' do
        invalid_names.each do |value|
          expect { runlevel_type.new(name: value) }.to raise_error(%r{Invalid value})
        end
      end
    end

    context ':level' do
      it 'accepts valid values' do
        valid_names.each_pair do |_key, value|
          resource = runlevel_type.new(
            name: '5',
            level: value,
          )

          expect(resource[:level]).to eq(value)
        end
      end

      it 'rejects invalid values' do
        invalid_names.each do |value|
          expect {
            runlevel_type.new(
              name: '5',
              level: value,
            )
          }.to raise_error(%r{Invalid value})
        end
      end
    end

    context ':transition_timeout' do
      let(:valid_values) { [ '0', '100', '1000000' ] }

      let(:invalid_values) { [ 'bob', '-1' ] }

      it 'accepts valid values' do
        valid_values.each do |value|
          resource = runlevel_type.new(
            name: '5',
            transition_timeout: value,
          )

          expect(resource[:transition_timeout]).to eq(value.to_i)
        end
      end

      it 'rejects invalid values' do
        invalid_values.each do |value|
          expect {
            runlevel_type.new(
              name: '5',
              transition_timeout: value,
            )
          }.to raise_error(%r{Invalid value})
        end
      end
    end

    context 'persist' do
      let(:valid_values) { [ 'true', 'false', true, false ] }

      it 'accepts valid values' do
        valid_values.each do |value|
          resource = runlevel_type.new(
            name: '5',
            persist: value,
          )

          expect(resource[:persist]).to eq(value.to_s.to_sym)
        end
      end
    end
  end
end
