require 'spec_helper'

describe 'simplib::module_metadata::os_blacklisted' do
  context 'on a supported, but blacklisted, OS' do
    let(:module_metadata) { scope.function_load_module_metadata(['simplib']) }

    let(:facts) do
      {
        os: {
          'name' => 'Ubuntu',
          'release' => {
            'major' => '14',
            'full' => '14.999',
          },
        },
      }
    end

    context 'with no version matching' do
      context 'with a match' do
        it 'returns true' do
          is_expected.to run.with_params(module_metadata, ['Banana', 'Ubuntu', 'Chicken']).and_return(true)
        end
      end

      context 'without a match' do
        it 'returns false' do
          is_expected.to run.with_params(module_metadata, ['Banana', 'Ubuntwo', 'Chicken']).and_return(false)
        end
      end
    end

    context 'with full version matching' do
      context 'with a match' do
        it 'returns true' do
          is_expected.to run.with_params(
            module_metadata,
            ['Banana', { 'Ubuntu' => '14.999' }, { 'Chicken' => ['14.999', '15.1'] }],
            { 'release_match' => 'full' },
          ).and_return(true)
        end

        context 'without a match' do
          it 'returns false' do
            is_expected.to run.with_params(
              module_metadata,
              ['Banana', { 'Ubuntu' => '14.888' }, { 'Chicken' => ['14.999', '15.1'] }],
              { 'release_match' => 'full' },
            ).and_return(false)
          end
        end
      end
    end

    context 'with major version matching' do
      context 'with a match' do
        it 'returns true' do
          is_expected.to run.with_params(
            module_metadata,
            ['Banana', { 'Ubuntu' => '14.999' }, { 'Chicken' => ['14.999', '15.1'] }],
            { 'release_match' => 'major' },
          ).and_return(true)
        end
      end

      context 'without a match' do
        it 'returns false' do
          is_expected.to run.with_params(
            module_metadata,
            ['Banana', { 'Ubuntu' => '13.999' }, { 'Chicken' => ['14.999', '15.1'] }],
            { 'release_match' => 'major' },
          ).and_return(false)
        end
      end
    end
  end
end
