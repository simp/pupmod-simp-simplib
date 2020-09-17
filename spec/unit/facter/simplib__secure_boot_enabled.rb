# frozen_string_literal: true

require 'spec_helper'

describe 'simplib__secure_boot_enabled' do
  before :each do
    Facter.clear
    Facter.stubs(:value).with(:kernel).returns('Linux')
  end

  context 'without SecureBoot files in /sys/firmware/efi/efivars' do
    it do
      Dir.stubs(:glob).with('/sys/firmware/efi/efivars/SecureBoot-*').returns([])

      expect(Facter.fact('simplib__secure_boot_enabled').value).to match(false)
    end
  end

  context 'with a SecureBoot file in /sys/firmware/efi/efivars' do
    before :each do
      @sb_tempfile = Tempfile.new('simplib__secure_boot_enabled')
      @sm_tempfile = Tempfile.new('simplib__secure_boot_enabled')

      Dir.stubs(:glob).with('/sys/firmware/efi/efivars/SecureBoot-*').returns([@sb_tempfile.path])
      Dir.stubs(:glob).with('/sys/firmware/efi/efivars/SetupMode-*').returns([@sm_tempfile.path])
    end

    after :each do
      File.unlink(@sb_tempfile) if File.exist?(@sb_tempfile)
      File.unlink(@sm_tempfile) if File.exist?(@sm_tempfile)
    end

    context 'with SecureBoot enabled' do
      before :each do
        File.open(@sb_tempfile, 'wb') do |fh|
          fh.write('1234')
          fh.write([1].pack('C'))
        end
      end

      context 'with SetupMode disabled' do
        before :each do
          File.open(@sm_tempfile, 'w') do |fh|
            fh.write('1234')
            fh.write([0].pack('C'))
          end
        end

        it do
          expect(Facter.fact('simplib__secure_boot_enabled').value).to match(true)
        end
      end

      context 'with SetupMode enabled' do
        before :each do
          File.open(@sm_tempfile, 'w') do |fh|
            fh.write('1234')
            fh.write([1].pack('C'))
          end
        end

        it do
          expect(Facter.fact('simplib__secure_boot_enabled').value).to match(false)
        end
      end
    end

    context 'with SecureBoot disabled' do
      before :each do
        File.open(@sb_tempfile, 'w') do |fh|
          fh.write('1234')
          fh.write([0].pack('C'))
        end
      end

      context 'with SetupMode disabled' do
        before :each do
          File.open(@sm_tempfile, 'w') do |fh|
            fh.write('1234')
            fh.write([0].pack('C'))
          end
        end

        it do
          expect(Facter.fact('simplib__secure_boot_enabled').value).to match(false)
        end
      end

      context 'with SetupMode enabled' do
        before :each do
          File.open(@sm_tempfile, 'w') do |fh|
            fh.write('1234')
            fh.write([1].pack('C'))
          end
        end

        it do
          expect(Facter.fact('simplib__secure_boot_enabled').value).to match(false)
        end
      end
    end
  end
end
