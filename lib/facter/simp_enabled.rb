Facter.add('simp_enabled') do
  setcode do
    retval = false
    class_file = %x{puppet config print classfile}.strip
    retval = true if not IO.readlines(class_file).find{ |i| i =~ /^simp$/}.nil?

    retval
  end
end
