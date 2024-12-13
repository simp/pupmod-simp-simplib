require 'spec_helper'

describe 'simplib::module_metadata::os_supported' do
  context 'on a supported OS' do
    facts = {
      os: {
        'name' => 'Ubuntu',
        'release' => {
          'major' => '14',
          'full'  => '14.999'
        }
      }
    }

    let(:facts) { facts }

    let(:module_metadata) do
      {
        'name' => 'test-module',
     'version' => '0.0.1',
     'operatingsystem_support' => [
       {
         'operatingsystem'        => 'Aardvark',
         'operatingsystemrelease' => [ '14.999' ]
       },
       {
         'operatingsystem'        => 'Ubuntu',
         'operatingsystemrelease' => [ '14.999' ]
       },
       {
         'operatingsystem'        => 'Banana',
         'operatingsystemrelease' => [ '1.2', '2.3' ]
       },
     ]
      }
    end

    context 'with no version matching' do
      context 'with a match' do
        it 'returns true' do
          is_expected.to run.with_params(module_metadata).and_return(true)
        end
      end

      context 'without a match' do
        let(:module_metadata) do
          {
            'name' => 'test-module',
         'version' => '0.0.1',
         'operatingsystem_support' => [
           {
             'operatingsystem'        => 'Aardvark',
             'operatingsystemrelease' => [ '14.999' ]
           },
           {
             'operatingsystem'        => 'Banana',
             'operatingsystemrelease' => [ '15.123' ]
           },
         ]
          }
        end

        it 'returns false' do
          is_expected.to run.with_params(module_metadata).and_return(false)
        end
      end
    end

    context 'with full version matching' do
      context 'with a match' do
        it 'returns true' do
          is_expected.to run.with_params(
            module_metadata,
            { 'release_match' => 'full' },
          ).and_return(true)
        end

        context 'without a match' do
          let(:module_metadata) do
            {
              'name' => 'test-module',
           'version' => '0.0.1',
           'operatingsystem_support' => [
             {
               'operatingsystem'        => 'Aardvark',
               'operatingsystemrelease' => [ '14.999' ]
             },
             {
               'operatingsystem'        => 'Ubuntu',
               'operatingsystemrelease' => [ '14.111' ]
             },
             {
               'operatingsystem'        => 'Banana',
               'operatingsystemrelease' => [ '1.2', '2.3' ]
             },
           ]
            }
          end

          it 'returns false' do
            is_expected.to run.with_params(
              module_metadata,
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
            { 'release_match' => 'major' },
          ).and_return(true)
        end
      end

      context 'without a match' do
        let(:module_metadata) do
          {
            'name' => 'test-module',
         'version' => '0.0.1',
         'operatingsystem_support' => [
           {
             'operatingsystem'        => 'Aardvark',
             'operatingsystemrelease' => [ '14.999' ]
           },
           {
             'operatingsystem'        => 'Ubuntu',
             'operatingsystemrelease' => [ '15.999' ]
           },
           {
             'operatingsystem'        => 'Banana',
             'operatingsystemrelease' => [ '1.2', '2.3' ]
           },
         ]
          }
        end

        it 'returns false' do
          is_expected.to run.with_params(
            module_metadata,
            { 'release_match' => 'major' },
          ).and_return(false)
        end
      end
    end
  end
end
