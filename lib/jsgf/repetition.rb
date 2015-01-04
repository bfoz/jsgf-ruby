module JSGF
    class Repetition
	# @param atom [Hash]	the atom to repeat
	# @param minimum_count	[Number]	the minimum repetition count (0 or 1)
	def initialize(atom, minimum_count)
	    @atom = atom
	    @count = minimum_count
	end
    end
end
