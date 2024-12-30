require 'spec_helper'

describe 'simplib::params2hash' do
  let(:pre_condition) do
    <<~END
      class foo (
        $param1 = 'foo',
        $prune_me = 'bar',
        $array = ['one', 'two'],
        $hash = { 'key' => 'value' },
      ) {
        $random_var = 'should be ignored'

        notify { 'test': message => 'this is a test'}

        $_params = simplib::params2hash()

        notify { 'class_json': message => $_params.to_json }
      }

      include 'foo'

      define bar (
        $param1 = 'foo',
        $prune_me = 'bar',
        $array = ['one', 'two'],
        $hash = { 'key' => 'value' },
      ) {
        notify { 'test2': message => 'this is another test'}

        $_params = simplib::params2hash()

        notify { 'define_json': message => $_params.to_json }
      }

      bar { 'baz': }
    END
  end

  it do
    class_output = JSON.parse(catalogue.resource('Notify[class_json]')[:message])

    expect(class_output).to match(
      {
        'param1'   => 'foo',
        'prune_me' => 'bar',
        'array'    => ['one', 'two'],
        'hash'     => { 'key' => 'value' },
      },
    )

    define_output = JSON.parse(catalogue.resource('Notify[define_json]')[:message])

    expect(define_output).to match(
      {
        'name'     => 'baz',
        'param1'   => 'foo',
        'prune_me' => 'bar',
        'array'    => ['one', 'two'],
        'hash'     => { 'key' => 'value' },
      },
    )
  end

  context 'when pruning values' do
    let(:pre_condition) do
      <<~END
        class foo (
          $param1 = 'foo',
          $prune_me = 'bar',
          $array = ['one', 'two'],
          $hash = { 'key' => 'value' },
        ) {
          notify { 'test': message => 'this is a test'}

          $_params = simplib::params2hash(['prune_me'])

          notify { 'class_json': message => $_params.to_json }
        }

        include 'foo'

        define bar (
          $param1 = 'foo',
          $prune_me = 'bar',
          $array = ['one', 'two'],
          $hash = { 'key' => 'value' },
        ) {
          notify { 'test2': message => 'this is another test'}

          $_params = simplib::params2hash(['prune_me'])

          notify { 'define_json': message => $_params.to_json }
        }

        bar { 'baz': }
      END
    end

    it do
      class_output = JSON.parse(catalogue.resource('Notify[class_json]')[:message])

      expect(class_output).to match(
        {
          'param1'   => 'foo',
          'array'    => ['one', 'two'],
          'hash'     => { 'key' => 'value' },
        },
      )

      define_output = JSON.parse(catalogue.resource('Notify[define_json]')[:message])

      expect(define_output).to match(
        {
          'name'     => 'baz',
          'param1'   => 'foo',
          'array'    => ['one', 'two'],
          'hash'     => { 'key' => 'value' },
        },
      )
    end
  end
end
