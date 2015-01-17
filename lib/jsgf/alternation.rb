module JSGF
    class Alternation
	include Enumerable

	attr_reader :elements
	attr_accessor :optional
	attr_reader :tags

	def initialize(*args)
	    @elements = args
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

	def size
	    @elements.size
	end

	def weights
	    @elements.map {|a| a[:weight]}
	end
    end
end
