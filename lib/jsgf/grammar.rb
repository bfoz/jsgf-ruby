require_relative 'atom'
require_relative 'optional'

module JSGF
    class Grammar
	attr_reader :character_encoding
	attr_reader :locale
	attr_reader :grammar_name
	attr_reader :private_rules
	attr_reader :public_rules
	attr_reader :version

	# @param rules	[Hash]	the rules to search
	# @return [Array<Hash,Hash>]	the set of root and non-root rules from the given set of rules
	def self.roots(rules)
	    # Descend through the rule trees to see if they reference each other.
	    #  Root rules aren't referenced by any other rule.
	    names = rules.flat_map {|(name,rule)| find_rule_names(rule)}.compact.uniq
	    left, right = rules.partition {|name, rule| names.include?(name) }
	    [Hash[right], Hash[left]]
	end

	# Expand the given rule and collect any references to other rules
	# @param rule	[Array]	the right-hand-side of the rule to expand
	# @return [Array]   an array of referenced rule names
	def self.find_rule_names(rule)
	    case rule
		when Alternation, Array, Optional
		    rule.flat_map {|a| find_rule_names(a) }
		when Atom then rule.reference ? rule.atom : []
		else
		    raise StandardError, "Unkown atom #{rule.class}: #{rule}"
	    end
	end

	def initialize(name:nil, character_encoding:nil, locale:nil, private_rules:{}, public_rules:{}, rules:nil, version:nil)
	    raise ArgumentError, "Grammar requires a name" unless name
	    @character_encoding = character_encoding
	    @locale = locale
	    @grammar_name = name
	    @version = version

	    if rules and !rules.empty?
		@public_rules, @private_rules = ::JSGF::Grammar.roots(rules)
	    else
		@private_rules = private_rules
		@public_rules = public_rules
	    end
	end

	# @!attribute roots
	#   @return [Hash]  the set of public rules that comprise the roots of the {Grammar} tree
	def roots
	    r = self.class.roots(public_rules).first
	    r.empty? ? nil : r
	end

	# @!attribute rules
	#   @return [Hash]  Returns a {Hash} of the public and private rules, keyed by rule name
	def rules
	    @public_rules.merge(@private_rules)
	end

	# @!attribute version
	#   @return [String]  the JSGF specification version
	def version
	    @version || 'V1.0'
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

	# Write the {Grammar} to a file or an {IO} stream
	# @param file	[String,IO] a filename, or an IO stream, to write to
	def write(file)
	    if file.is_a?(String)
		File.write(file, self.to_s)
	    else
		file.write(self.to_s)
	    end
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
		when Atom then atom.to_s
		when Optional then '[' + atom.elements.map {|a| unparse_atom(a, nested:nested)}.join(' | ') + ']'
		else
		    weight = (atom[:weight] != 1.0) ? "/#{atom[:weight]}/" : nil
		    if atom[:name]
			[weight, '<' + atom[:name] + '>'].compact.join(' ')
		    end
	    end
	end
    end
end
