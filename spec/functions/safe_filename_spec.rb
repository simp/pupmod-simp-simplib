require 'spec_helper'

shared_examples 'simplib::safe_filename()' do |input, return_value|
  it { is_expected.to run.with_params(input).and_return(return_value) }
end

describe 'simplib::safe_filename' do
  context 'with an already safe filename' do
    it_behaves_like 'simplib::safe_filename()', 'test_filename', 'test_filename'
  end

  context 'with unsafe filenames' do
    test_hash = {
      'foo/bar' => 'foo__bar',
      'foo/bar*baz' => 'foo__bar__baz',
      'foo/bar*baz|foo' => 'foo__bar__baz__foo',
      'foo/bar*baz|foo?bar' => 'foo__bar__baz__foo__bar',
      'foo/bar*baz|foo?bar<baz' => 'foo__bar__baz__foo__bar__baz',
      'foo/bar*baz|foo?bar<baz>foo' => 'foo__bar__baz__foo__bar__baz__foo',
      'foo/bar*baz|foo?bar<baz>foo\bar' => 'foo__bar__baz__foo__bar__baz__foo__bar',
    }

    test_hash.each_pair do |input, output|
      it_behaves_like 'simplib::safe_filename()', input, output
    end
  end

  context 'with a custom pattern and replacement' do
    it { is_expected.to run.with_params('foo@bar', '@', '___').and_return('foo___bar') }
  end
end
