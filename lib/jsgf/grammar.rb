module JSGF
    class Grammar
	attr_reader :character_encoding
	attr_reader :locale
	attr_reader :grammar_name
	attr_reader :private_rules
	attr_reader :public_rules
	attr_reader :version

	def initialize(name:nil, character_encoding:nil, locale:nil, private_rules:{}, public_rules:{}, version:nil)
	    raise ArgumentError, "Grammar requires a name" unless name
	    @character_encoding = character_encoding
	    @locale = locale
	    @grammar_name = name
	    @private_rules = private_rules
	    @public_rules = public_rules
	    @version = version
	end

	# @!attribute rules
	#   @return [Hash]  Returns a {Hash} of the public and private rules, keyed by rule name
	def rules
	    @public_rules.merge(@private_rules)
	end

	def to_s
	    private_rule_array = @private_rules.map do |(name, rule)|
		atoms = rule.map {|a| unparse_atom(a) }.join(' ')
		"<#{name}> = #{atoms};"
	    end
	    public_rule_array = @public_rules.map do |(name, rule)|
		atoms = rule.map {|a| unparse_atom(a) }.join(' ')
		"public <#{name}> = #{atoms};"
	    end

	    [header, grammar_header, *public_rule_array, *private_rule_array].join("\n")
	end

    private
	# Generate the grammar name header line
	def grammar_header
	    "grammar #{grammar_name};"
	end

	# Generate the JSGF header line
	def header
	    ['#JSGF', version, character_encoding, locale].compact.join(' ') + ';'
	end

	def unparse_atom(atom, nested:false)
	    case atom
		when Array
		    s = atom.map {|a| unparse_atom(a, nested:nested)}.join(' ')
		    nested ? ('(' + s + ')') : s
		when Alternation
		    s = atom.elements.map {|a| unparse_atom(a, nested:true)}.join(' | ')
		    atom.optional ? ('[' + s + ']') : s
		when Optional then '[' + atom.elements.map {|a| unparse_atom(a, nested:nested)}.join(' | ') + ']'
		else
		    weight = (atom[:weight] != 1.0) ? "/#{atom[:weight]}/" : nil
		    if atom[:name]
			[weight, '<' + atom[:name] + '>'].compact.join(' ')
		    else
			[weight, atom[:atom], *atom[:tags]].compact.join(' ')
		    end
	    end
	end
    end
end
