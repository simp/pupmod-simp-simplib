# Turn a hash into a options string, for use in a shell command
#
# @example simplib::hash_to_opts({'key' => 'value'})
#   returns ``--key=value``
# @example simplib::hash_to_opts({'key' => ['lo',7,false]})
#   returns ``--key=lo,7,false``
# @example simplib::hash_to_opts({'key' => Undef })
#   returns ```--key``
# @example simplib::hash_to_opts({'f' => '/tmp/file'}, {'connector' => ' ', 'prefix' => '-'})
#   returns ``-f /tmp/file``
#
# @param input Input hash, with Strings as keys and either a String, Array,
#   Numeric, Boolean, or Undef as a value.
#
# @param opts Options hash. It only takes 3 keys, none of them required:
#   * ``connector``: String that joins each key and value pair. Defaults to '='
#   * ``prefix``: String that prefixes each key value pair. Defaults to '--'
#   * ``array_delimiter``: When a value is an array, the string that is used to
#     deliminate each item. Defaults to ','
#
# @return [String]
#
function simplib::hash_to_opts (
  Hash[String,Variant[Array,String,Numeric,Boolean,Undef]] $input,
  Struct[{
    Optional[connector]       => String[1],
    Optional[prefix]          => String[1],
    Optional[array_delimiter] => String[1],
  }] $opts = {}
) {
  $connector       = pick($opts['connector'],       '=')
  $prefix          = pick($opts['prefix'],          '--')
  $array_delimiter = pick($opts['array_delimiter'], ',')

  $out = $input.map |$key, $val| {
    case $val {
      Undef:   { "${prefix}${key}" }
      Array:   { "${prefix}${key}${connector}${val.join($array_delimiter).shellquote}" }
      default: { "${prefix}${key}${connector}${String($val).shellquote}" }
    }
  }
  $out.join(' ')
}
