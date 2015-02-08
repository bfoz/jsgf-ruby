module JSGF
    class Atom
	# @!attribute atom
	#   @return [String]  the atom of the {Atom}
	attr_accessor :atom

	# @!attribute weight
	#   @return [Number]  the {Atom}'s weight, when part of an {Alternation}. Defaults to 1.0.
	attr_accessor :weight

	# @!attribute tags
	#   @return [Array]  the collection of tags to be stored with the {Atom}
	attr_accessor :tags

	# @param atom	[String]    the atom of the {Atom}
	# @param weight	[Number]    the weight to be used when part of an {Alternation}. Valid values are 0..1.0.
	# @param tags	[Array]	    any tags to be stored with the {Atom}
	def initialize(atom, *tags, weight:nil)
	    @atom = atom
	    @tags = tags
	    @weight = (weight && (weight != 1.0)) ? weight : nil
	end

	def eql?(other)
	    @atom.eql?(other.atom) && @tags.eql?(other.tags) && @weight.eql?(other.weight)
	end
	alias == eql?

	# Stringify in a manner suitable for output to a JSGF file
	def to_s
	    [(weight && (weight != 1.0)) ? "/#{weight}/" : nil, atom, *tags].compact.join(' ')
	end
    end
end
