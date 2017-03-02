# vim: set expandtab ts=2 sw=2:
def gen_random_pass(length,complexity,complex_only)

  length = length.to_i
  if length.eql?(0)
    length = @default_password_length
  elsif length < 8
    length = 8
  end

  passwd = ''
  begin
    Timeout::timeout(30) do
      default_charlist = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      specific_charlist = nil
      case complexity
      when 1
        specific_charlist = ['@','%','-','_','+','=','~']
      when 2
        specific_charlist = (' '..'/').to_a + ('['..'`').to_a + ('{'..'~').to_a
      else
      end
      unless specific_charlist == nil
        if complex_only == true
          charlists = [
            specific_charlist
          ]
        else
          charlists = [
            default_charlist,
            specific_charlist
          ]
        end

      else
        charlists = [
          default_charlist
        ]
      end

      charlists.each do |charlist|
        (length/charlists.length).ceil.times { |i|
          passwd += charlist[rand(charlist.size-1)]
        }
      end

      passwd = passwd[0..(length-1)]
    end
  rescue Timeout::Error
    raise Puppet::ParseError, "passgen timed out for #{@id}!"
  end

  return passwd
end

def passgen(id, hash = nil)
  @crypt_map = {
    'md5'     => '1',
    'sha256'  => '5',
    'sha512'  => '6'
  }
  defaults = {
    'return_current' => false,
    'last'           => false,
    'length'         => @default_password_length,
    'hash'           => false,
    'complexity'     => 0,
    'complex_only'   => false,
  }
  options = {}
  defaults.each do |key, value|
    if (hash.key?(key))
      options[key] = hash[key]
    else
      options[key] = value
    end
  end
  password_path = "/passgen/#{id}/password"
  salt_path = "/passgen/#{id}/salt"
  complexity = options["complexity"];
  length = options["length"];
  complex_only = options["complex_only"];
  # Only generate the password once, for every attempt to update
  if (options.key?("password"))
    pass = options["password"]
  else
    pass = gen_random_pass(length, complexity, complex_only)
  end
  if (options.key?("salt"))
    salt = options["salt"]
  else
    salt = gen_random_pass(16, 0, complex_only)
  end
  salt = gen_random_pass(16,0,complex_only)
  successful_put = false
  (0...30).each do |round|
    stored_pass = call_function("libkv::atomic_get", {"key" => password_path})
    if (stored_pass["value"] == nil)
      retval = attempt_put = call_function("libkv::atomic_put", { "key" => password_path, "value" => pass, "previous" => stored_pass})
    else
      unless (stored_pass["value"].length == length)
        retval = attempt_put = call_function("libkv::atomic_put", { "key" => password_path, "value" => pass, "previous" => stored_pass})
      else
        retval = true
        pass = stored_pass["value"]
      end
    end
    if (retval == true)
      successful_put = true
      break
    end
  end
  if (successful_put == false)
  end

  empty = call_function("libkv::empty_value", {})
  attempt_put = call_function("libkv::atomic_put", { "key" => salt_path, "value" => salt, "previous" => empty})
  salt = call_function("libkv::get", {"key" => salt_path})
  if options["hash"]
    return pass.crypt("$#{@crypt_map[options['hash']]}$#{salt}")
  else
    return pass
  end
end
