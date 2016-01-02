require_relative 'rule'

module JSGF
    class Alternation
	include Enumerable

	attr_reader :elements

	# @!attribute
	#   @return [Bool]  Sometimes an {Alternation} is optional
	attr_accessor :optional
	alias optional? optional

	attr_reader :tags

	def initialize(*args)
	    @elements = args.map do |a|
		case a
		    when String then Rule.parse_atom(a)
		    when Symbol then JSGF::Atom.new(a.to_s, reference:true)
		    else
			a
		end
	    end

	    @optional = false
	    @tags = []
	end

	# @group Enumerable
	def each(*args, &block)
	    elements.each(*args, &block)
	end
	# @endgroup

	def push(*args)
	    @elements.push *args
	end

	# @group Attributes
	def size
	    @elements.size
	end

	def weights
	    @elements.map {|a| a.respond_to?(:weight) ? a.weight : a[:weight]}
	end
	# @endgroup
    end
end
