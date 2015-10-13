# _Description_
#
# Return true if the clvmd is running.
#
Facter.add("has_clustering") do
    setcode do
        retval = false

	result = %x{/sbin/service clvmd status 2> /dev/null}

	# result = "" if clvmd is not present
	if (result !~ /stopped/) && (result !~ //) then
          retval = true
        end

        retval
    end
end
