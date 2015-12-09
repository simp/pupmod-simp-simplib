Facter.add('simp_enabled') do
  setcode do
    retval = false
    class_file = %x{puppet config print classfile}.strip
    retval = true if IO.readlines(class_file).grep(/^simp$/).any?

    retval
  end
end
