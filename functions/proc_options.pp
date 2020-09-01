# Returns a Hash of the mount options for `/proc`
#
# Will return an empty Hash if '/proc' is not found so that calls to `dig()`
# work without issue.
#
# @return [Hash]
#
function simplib::proc_options {
  Hash(
    pick($facts.dig('simplib__mountpoints', '/proc', 'options'), []).map |$opt| {
      split($opt, '=').map |$part| { strip($part) }
    }.map |$opt_arr| {
      $key = $opt_arr[0]
      $value = $opt_arr[1]

      if $value and $value =~ /\A\d+\Z/ {
        [$key, Integer($value)]
      }
      else {
        [$key, $value]
      }
    }
  )
}
