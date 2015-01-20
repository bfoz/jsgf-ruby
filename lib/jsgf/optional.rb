module JSGF
    class Optional
	include Enumerable

	attr_reader :elements

	def initialize(*args)
	    @elements = args
	end

	# @group Enumerable
	def each(*args, &block)
	    elements.each(*args, &block)
	end
	# @endgroup

	def optional
	    true
	end
    end
end
