module JSGF
    class Rule < Array
	# Convert a string containing a single atom into an {Atom} or a rule reference
	# @param atom	[String]	the text to parse
	def self.parse_atom(atom)
	    case atom
		when /\<(.*)\>/, /:(.*)/ then {name:$1, weight:1.0, tags:[]}
		else
		    Atom.new(atom)
	    end
	end
    end
end
