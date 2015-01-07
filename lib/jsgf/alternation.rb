module JSGF
    class Alternation
	attr_reader :elements
	attr_accessor :optional
	attr_reader :tags

	def initialize(*args)
	    @elements = args
	    @optional = false
	    @tags = []
	end

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
