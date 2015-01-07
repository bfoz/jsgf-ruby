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
	grammar.rules['rule'][:atoms].size.must_equal 1
    end

    it 'must parse a rule with multiple atoms' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one two;').parse
	grammar.rules.size.must_equal 1
	grammar.rules.keys.must_equal ['rule']
	grammar.rules['rule'][:atoms].size.must_equal 2
    end

    it 'must parse a rule with multiple grouped atoms' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=(one two);').parse
	grammar.rules.size.must_equal 1
	grammar.rules.keys.must_equal ['rule']
	grammar.rules['rule'][:atoms].size.must_equal 2
    end

    describe 'when parsing an alternation' do
	it 'must parse a rule with an alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one | two;').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'][:atoms].size.must_equal 1

	    alternation = grammar.rules['rule'][:atoms].first
	    alternation.must_be_kind_of JSGF::Alternation
	    alternation.size.must_equal 2
	end
	
	it 'must parse a rule with a bigger alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one | two | three;').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'][:atoms].size.must_equal 1

	    alternation = grammar.rules['rule'][:atoms].first
	    alternation.must_be_kind_of JSGF::Alternation
	    alternation.size.must_equal 3
	    alternation.elements[0][:atom].must_equal 'one'
	    alternation.elements[1][:atom].must_equal 'two'
	    alternation.elements[2][:atom].must_equal 'three'
	end

	it 'must parse a weighted alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>= /0.5/ one | /0.25/ two | /0.25/ three;').parse
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'][:atoms].size.must_equal 1

	    alternation = grammar.rules['rule'][:atoms].first
	    alternation.must_be_kind_of JSGF::Alternation
	    alternation.size.must_equal 3
	    alternation.weights.must_equal [0.5, 0.25, 0.25]
	    alternation.elements[0][:atom].must_equal 'one'
	end

	it 'must parse a grouped alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=(one | two | three);').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'][:atoms].size.must_equal 1
	    grammar.rules['rule'][:atoms].first.must_be_kind_of JSGF::Alternation
	    grammar.rules['rule'][:atoms].first.size.must_equal 3
	end
    end

    describe 'when parsing optionals' do
	it 'must parse an optional group of a single atom' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=[one];').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'][:atoms].size.must_equal 1
	end

	it 'must parse an optional alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=[one | two];').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'][:atoms].size.must_equal 1

	    rule = grammar.rules['rule'][:atoms]
	    rule.first.must_be_kind_of JSGF::Alternation
	    rule.first.optional.must_equal true
	end

	it 'must parse a multi-atom optional alternation' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one two [three | four];').parse
	    grammar.rules.size.must_equal 1
	    grammar.rules.keys.must_equal ['rule']
	    grammar.rules['rule'][:atoms].size.must_equal 3

	    rule = grammar.rules['rule'][:atoms]
	    rule.size.must_equal 3
	end
    end
end
