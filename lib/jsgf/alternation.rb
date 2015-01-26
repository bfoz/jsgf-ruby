module JSGF
    class Alternation
	include Enumerable

	attr_reader :elements
	attr_accessor :optional
	attr_reader :tags

	def initialize(*args)
	    @elements = args.map do |a|
		case a
		    when String
			case a
			    when /\<(.*)\>/, /:(.*)/ then {name:$1, weight:1.0, tags:[]}
			    else
				{atom:a, weight:1.0, tags:[]}
			end
		    when Symbol then {name:a.to_s, weight:1.0, tags:[]}
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

	def size
	    @elements.size
	end

	def weights
	    @elements.map {|a| a[:weight]}
	end
    end
end
