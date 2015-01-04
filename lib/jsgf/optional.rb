module JSGF
    class Optional
	def initialize(*args)
	    @elements = args
	end

	def optional
	    true
	end
    end
end
