class JSGF::Parser

token GRAMMAR HEADER IMPORT PUBLIC TAG TOKEN WEIGHT

rule

grammar: header
	| header rule_list
	| header import_header rule_list
	;

header: jsgf_header grammar_header;

jsgf_header: HEADER ';'
	| HEADER TOKEN ';' { @version = val[1]; }
	| HEADER TOKEN TOKEN ';' { @version = val[1]; @charset = val[2]; }
	| HEADER TOKEN TOKEN TOKEN ';' { @version = val[1]; @charset = val[2]; @locale = val[3]; }
	;

grammar_header: GRAMMAR TOKEN ';' { @grammar_name = val[1] };

import_header: import_statement | import_header import_statement;

import_statement: IMPORT rule_name ';';

rule_list: rule | rule_list rule;

rule_name: '<' TOKEN '>' { result = val[1] }

rule: rule_name '=' alternate_list ';'		    { define_rule(val[0], :private, *(val[2..-2])) }
	| PUBLIC rule_name '=' alternate_list ';'   { define_rule(val[1], :public, val[3]) }
	;

alternate_list: rule_expansion		    { result = val.first }
	| alternate_list '|' rule_expansion { result = define_alternation(*val) }
	;

rule_expansion: tagged_rule_item		{ result = val.first }
	| rule_expansion tagged_rule_item	{ result = val }
	;

tagged_rule_item: rule_item
	| tagged_rule_item TAG { val[0][:tags].push(val[1]); result = val[0] }
	;

rule_item: rule_atom | weighted_item;

weighted_item: WEIGHT rule_atom { val[1][:weight] = val.first[1..-2].to_f; result = val[1] }

rule_group: '(' alternate_list ')'	{ result = val[1] };
rule_optional: '[' alternate_list ']'	{ result = define_optional(val[1]) };

rule_atom: TOKEN { result = define_atom(val.first) }
	| rule_name
	| rule_group
	| rule_optional
	| rule_atom '*' { result = JSGF::Repetition.new(val[0], 0) }
	| rule_atom '+' { result = JSGF::Repetition.new(val[0], 1) }
	;

---- header

require_relative 'alternation'
require_relative 'grammar'
require_relative 'optional'
require_relative 'repetition'

---- inner

attr_reader :grammar_name
attr_reader :handler

def initialize(tokenizer)
    @private_rules = {}
    @public_rules = {}
    tokenizer = JSGF::Tokenizer.new(tokenizer) if tokenizer.is_a?(String)
    @tokenizer = tokenizer
    super()
end

def define_alternation(*args)
    if args.first.is_a?(JSGF::Alternation)
	args.first.push *(args.drop(2))
	args.first
    else
	JSGF::Alternation.new(*(args.each_slice(2).map {|a,b| a}))
    end
end

def define_optional(*args)
    if args.first.respond_to?(:optional)
	args.first.optional = true
	args.first
    else
	JSGF::Optional.new(*args)
    end
end

def define_atom(atom, weight=1.0, tags=[])
   {atom:atom, weight:weight, tags:[]}
end

def define_rule(name, visibility=:private, *args)
    r = {name:name, visibility:visibility, atoms:args}
    if visibility == :private
	@private_rules[name] = r
    else
	@public_rules[name] = r
    end
    r
end

def next_token
    @tokenizer.next_token
end

def parse
    do_parse
    JSGF::Grammar.new(	character_encoding:@charset,
			locale:@locale,
			private_rules:@private_rules,
			public_rules:@public_rules,
			version:@version)
end