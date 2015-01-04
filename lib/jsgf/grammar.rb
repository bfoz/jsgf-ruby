module JSGF
    class Grammar
	attr_reader :character_encoding
	attr_reader :locale
	attr_reader :private_rules
	attr_reader :public_rules
	attr_reader :version

	def initialize(character_encoding:nil, locale:nil, private_rules:{}, public_rules:{}, version:nil)
	    @character_encoding = character_encoding
	    @locale = locale
	    @private_rules = private_rules
	    @public_rules = public_rules
	    @version = version
	end

	# @!attribute rules
	#   @return [Hash]  Returns a {Hash} of the public and private rules, keyed by rule name
	def rules
	    @public_rules.merge(@private_rules)
	end
    end
end
