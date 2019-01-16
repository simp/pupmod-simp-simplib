require 'spec_helper'

# This just gives us a hook so that we can call the function later on
describe 'simplib::stages', type: :class do

  let(:pre_condition) {%(
    define mydef::test (
      $attribute = simplib::dlookup('mydef::test', 'attribute', $title, { 'default_value' => 'lucille2' })
    ){
      notify { "$title says": message => $attribute }
    }

    mydef::test { 'gob': }
    mydef::test { 'tobias': }
    mydef::test { 'michael': attribute => 'bananastand' }
  )}

  let(:gob){catalogue.resource('Mydef::Test[gob]')}
  let(:tobias){catalogue.resource('Mydef::Test[tobias]')}
  let(:michael){catalogue.resource('Mydef::Test[michael]')}

  it { is_expected.to compile.with_all_deps }

  context 'no overrides' do
    it { expect(gob[:attribute]).to eq('lucille2') }
    it { expect(tobias[:attribute]).to eq('lucille2') }
    it { expect(michael[:attribute]).to eq('bananastand') }
  end

  context 'overrides' do
    let(:facts){{
      :cache_bust => Time.now.to_s,
      :hieradata => 'simplib_dlookup_overrides'
    }}

    let(:hieradata){ 'simplib_dlookup_overrides' }
    let(:hiera_data){{
      'Define[mydef::test]::attribute' => 'illusions',
      'foo::bar' => 'baz'
    }}

    context 'with global overrides' do
      it { expect(gob[:attribute]).to eq('illusions') }
    end
    context 'with specific overrides' do
      it { expect(tobias[:attribute]).to eq('blueman') }
    end
    context 'with a static value' do
      it { expect(michael[:attribute]).to eq('bananastand') }
    end
  end
end
