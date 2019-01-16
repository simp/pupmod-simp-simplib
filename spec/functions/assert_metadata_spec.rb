require 'spec_helper'

describe 'simplib::assert_metadata' do
  context 'on a supported OS' do
    facts = {
      :os => {
        'name' => 'Ubuntu',
        'release' => {
          'major' => '14',
          'full' => '14.04'
        }
      }
    }

    context 'with no version matching' do
      let(:facts) { facts }

      it { is_expected.to run.with_params('stdlib') }
    end

    context 'with full version matching' do
      let(:facts) { facts }

      it { is_expected.to run.with_params('stdlib', { 'os' => { 'options' => { 'release_match' => 'full' } } } ) }
    end

    context 'with major version matching' do
      let(:facts) { facts }

      it { is_expected.to run.with_params('stdlib', { 'os' => { 'options' => { 'release_match' => 'major' } } } ) }
    end
  end

  context 'on a supported OS with an unsupported full version' do
    facts = {
      :os => {
        'name' => 'Ubuntu',
        'release' => {
          'major' => '14',
          'full' => '14.999'
        }
      }
    }

    context 'with no version matching' do
      let(:facts) { facts }

      it { is_expected.to run.with_params('stdlib') }
    end

    context 'with full version matching' do
      let(:facts) { facts }

        it {
          expect {
            is_expected.to run.with_params('stdlib', { 'os' => { 'options' => { 'release_match' => 'full' } } } )
          }.to raise_error(/OS.*is not supported/)
        }
    end

    context 'when disabled' do
      let(:facts) { facts }

      it { is_expected.to run.with_params('stdlib', { 'enable' => false, 'os' => { 'options' => { 'release_match' => 'full' } } } ) }
    end
  end

  context 'on a supported OS with an unsupported major version' do
    facts = {
      :os => {
        'name' => 'Ubuntu',
        'release' => {
          'major' => '1',
          'full' => '1.01'
        }
      }
    }

    context 'with no version matching' do
      let(:facts) { facts }

      it { is_expected.to run.with_params('stdlib') }
    end

    context 'with major version matching' do
      let(:facts) { facts }

      it {
        expect {
            is_expected.to run.with_params('stdlib', { 'os' => { 'options' => { 'release_match' => 'major' } } } )
        }.to raise_error(/OS.*is not supported/)
      }
    end
  end

  context 'on an unsupported OS' do
    facts = {
      :os => {
        'name' => 'Bob'
      }
    }

    context 'with no version matching' do
      let(:facts) { facts }

      it {
        expect {
          is_expected.to run.with_params('stdlib')
        }.to raise_error(/OS.*is not supported/)
      }
    end
  end
end
# vim: set expandtab ts=2 sw=2:
