module JSGF
    class Atom
	# @!attribute atom
	#   @return [String]  the atom of the {Atom}
	attr_accessor :atom

	# @!attribute
	#   @return [Bool]  Sometimes an {Atom} is optional
	attr_accessor :optional
	alias optional? optional

	# @!attribute reference
	#   @return [Bool]  The {Atom} is a reference to a {Rule}
	attr_accessor :reference
	alias reference? reference

	# @!attribute weight
	#   @return [Number]  the {Atom}'s weight, when part of an {Alternation}. Defaults to 1.0.
	attr_accessor :weight

	# @!attribute tags
	#   @return [Array]  the collection of tags to be stored with the {Atom}
	attr_accessor :tags

	# @param atom	[String]    the atom of the {Atom}
	# @param weight	[Number]    the weight to be used when part of an {Alternation}. Valid values are 0..1.0.
	# @param tags	[Array]	    any tags to be stored with the {Atom}
	def initialize(atom, *tags, weight:nil, optional:nil, reference:nil)
	    @atom = atom
	    @optional = optional
	    @reference = reference
	    @tags = tags
	    @weight = (weight && (weight != 1.0)) ? weight : nil
	end

	def eql?(other)
	    @atom.eql?(other.atom) && @tags.eql?(other.tags) && @weight.eql?(other.weight)
	end
	alias == eql?

	# Stringify in a manner suitable for output to a JSGF file
	def to_s
	    s = [(weight && (weight != 1.0)) ? "/#{weight}/" : nil, reference? ? '<'+atom+'>' : atom, *tags].compact.join(' ')
	    s = '[' + s + ']' if optional?
	    s
	end
    end
end
