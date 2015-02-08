require 'minitest/autorun'
require 'jsgf/parser'

describe JSGF::Parser do
    describe 'when parsing the header' do
	it 'must parse the version' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;').parse
	    grammar.version.must_equal 'V1.0'
	end

	it 'must parse the character encoding' do
	    grammar = JSGF::Parser.new('#JSGF V1.0 CHARSET; grammar header_grammar;').parse
	    grammar.version.must_equal 'V1.0'
	    grammar.character_encoding.must_equal 'CHARSET'
	end

	it 'must parse the locale' do
	    grammar = JSGF::Parser.new('#JSGF V1.0 CHARSET locale; grammar header_grammar;').parse
	    grammar.version.must_equal 'V1.0'
	    grammar.character_encoding.must_equal 'CHARSET'
	    grammar.locale.must_equal 'locale'
	end
    end

    it 'must parse a rule with a single atom' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one;').parse
	grammar.rules.size.must_equal 1
	grammar.rules.keys.must_equal ['rule']
	grammar.rules['rule'].size.must_equal 1
    end

    it 'must parse a rule with multiple atoms' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one two;').parse
	grammar.rules.size.must_equal 1
	grammar.rules.keys.must_equal ['rule']
	grammar.rules['rule'].size.must_equal 2
    end

    it 'must parse a rule with multiple grouped atoms' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=(one two);').parse
	grammar.rules.size.must_equal 1
	grammar.rules.keys.must_equal ['rule']
	grammar.rules['rule'].size.must_equal 2
    end

    describe 'when parsing an alternation' do
	it 'must parse a rule with an alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one | two;').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'].size.must_equal 1

	    alternation = grammar.rules['rule'].first
	    alternation.must_be_kind_of JSGF::Alternation
	    alternation.size.must_equal 2
	end

	it 'must parse a rule with a bigger alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one | two | three;').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'].size.must_equal 1

	    alternation = grammar.rules['rule'].first
	    alternation.must_be_kind_of JSGF::Alternation
	    alternation.size.must_equal 3
	    alternation.elements[0].must_equal Atom.new('one')
	    alternation.elements[1].must_equal Atom.new('two')
	    alternation.elements[2].must_equal Atom.new('three')
	end

	it 'must parse a weighted alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>= /0.5/ one | /0.25/ two | /0.25/ three;').parse
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'].size.must_equal 1

	    alternation = grammar.rules['rule'].first
	    alternation.must_be_kind_of JSGF::Alternation
	    alternation.size.must_equal 3
	    alternation.weights.must_equal [0.5, 0.25, 0.25]
	    alternation.elements[0].must_equal Atom.new('one', weight:0.5)
	    alternation.elements[1].must_equal Atom.new('two', weight:0.25)
	    alternation.elements[2].must_equal Atom.new('three', weight:0.25)
	end

	it 'must parse a grouped alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=(one | two | three);').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'].size.must_equal 1
	    grammar.rules['rule'].first.must_be_kind_of JSGF::Alternation
	    grammar.rules['rule'].first.size.must_equal 3
	end
    end

    describe 'when parsing optionals' do
	it 'must parse an optional group of a single atom' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=[one];').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'].size.must_equal 1
	end

	it 'must parse an optional alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=[one | two];').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'].size.must_equal 1

	    rule = grammar.rules['rule']
	    rule.first.must_be_kind_of JSGF::Alternation
	    rule.first.optional.must_equal true
	end

	it 'must parse a multi-atom optional alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one two [three | four];').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'].size.must_equal 3

	    rule = grammar.rules['rule']
	    rule.size.must_equal 3
	end
    end

    describe 'when parsing rule references' do
	it 'must parse a rule reference' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=<rule1>;<rule1>=one;').parse
	    grammar.rules.size.must_equal 2
	    grammar.rules.keys.must_equal ['rule', 'rule1']
	    grammar.rules['rule'].must_equal [{name:'rule1', weight:1.0, tags:[]}]
	    grammar.rules['rule1'].must_equal [Atom.new('one')]
	end

	it 'must parse a weighted rule reference' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>= /0.5/ <rule1> | /0.5/ two; <rule1>=one;').parse
	    grammar.rules.size.must_equal 2
	    grammar.rules.keys.must_equal ['rule', 'rule1']

	    grammar.rules['rule'].size.must_equal 1
	    grammar.rules['rule'].first.must_be_kind_of JSGF::Alternation
	    grammar.rules['rule'].first.elements.must_equal [{name:'rule1', weight:0.5, tags:[]}, Atom.new('two', weight:0.5)]

	    grammar.rules['rule1'].must_equal [Atom.new('one')]
	end
    end
end
