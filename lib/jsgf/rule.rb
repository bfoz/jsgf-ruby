module JSGF
    class Rule < Array
	# Convert a string containing a single atom into an {Atom} or a rule reference
	# @param atom	[String]	the text to parse
	def self.parse_atom(atom, optional:nil)
	    case atom
		# Parse optionals first to prevent the reference-regex from grabbing it first
		when /\[(.*)\]/		    then parse_atom($1, optional:true)
		when /\<(.*)\>/, /:(.*)/    then Atom.new($1, optional:optional, reference:true)
		else
		    Atom.new(atom, optional:optional)
	    end
	end
    end
end
