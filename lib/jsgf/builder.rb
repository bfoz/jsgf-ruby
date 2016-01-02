require_relative 'alternation'
require_relative 'grammar'

module JSGF
    class Builder
	def initialize
	    @rules = {}
	end

	# Convenience method for instantiating a builder and then building a {Grammar}
	# @param name [String]	the name of the new {Grammar}
	# @return [Grammar] a new {Grammar} built from the block argument
	def self.build(name=nil, &block)
	    self.new.build(name, &block)
	end

	# @param name [String]	the name of the new {Grammar}
	# @return [Grammar] a new {Grammar} built from the block argument
	def build(name=nil, &block)
	    @name = name || 'DSL'
	    instance_eval(&block) if block_given?
	    Grammar.new(name:@name, rules:@rules)
	end

	# Set the name attribute from the DSL block
	def name(arg)
	    @name = arg
	end

	# Create a new rule using the provided name and string
	#   By default, all new rules are private, unless they're root rules
	# @example
	#   rule rule1: 'This is a rule'
	#   rule rule2: ['one', 'two']
	#   rule rule3: 'This is not :rule2'
	# @return [JSGF::Grammar]
	def rule(**options)
	    options.each do |name, v|
		@rules[name.to_s] = case v
		    when Array	then Rule.new [Alternation.new(*v)]
		    when Symbol	then Rule.new [Rule.parse_atom(v.to_s).tap {|a| a.reference=true}]
		    else
			stack = nil
			v.split(' ').map do |a|
			    if stack
				if a == ']'
				    next if stack.empty?

				    if stack.length == 1
					stack.first.optional = true
					stack.first
				    else
					Optional.new(*stack)
				    end.tap do
					stack = nil
				    end
				else
				    stack.push(Rule.parse_atom(a))
				    next
				end
			    elsif a == '['
				stack = []
				next
			    else
				Rule.parse_atom(a)
			    end
			end.compact
		end
	    end
	end
    end
end
