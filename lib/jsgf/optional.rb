module JSGF
    class Optional
	attr_reader :elements

	def initialize(*args)
	    @elements = args
	end

	def optional
	    true
	end
    end
end
