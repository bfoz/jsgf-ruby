require 'minitest/autorun'
require 'jsgf/parser'

describe JSGF::Grammar do
    it 'must require a grammar name' do
	-> { JSGF::Grammar.new }.must_raise ArgumentError
    end

    it 'must have a default version' do
	JSGF::Grammar.new(name:'test').version.must_equal 'V1.0'
	JSGF::Grammar.new(name:'test').to_s.must_equal "#JSGF V1.0;\ngrammar test;"
    end

    describe 'roots' do
	it 'must not have roots without public rules' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; <rule>=one | two | three;').parse
	    grammar.roots.must_equal nil
	end

	it 'must have one root for one public rule' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule>=one | two | three;').parse
	    grammar.roots.size.must_equal 1
	    grammar.roots['rule'].must_be_kind_of Array
	end

	it 'must have two roots for two public rules' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule1>=one | two | three; public <rule2>=four five;').parse
	    grammar.roots.size.must_equal 2
	    grammar.roots['rule1'].must_be_kind_of Array
	    grammar.roots['rule2'].must_be_kind_of Array
	end
    end

    it 'must unparse a header' do
	grammar = JSGF::Parser.new('#JSGF; grammar header_grammar;').parse
	grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;"
    end

    it 'must unparse a header with a version' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;').parse
	grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;"
    end

    it 'must unparse a header with a version and a character encoding' do
	grammar = JSGF::Parser.new('#JSGF V1.0 ENCODING; grammar header_grammar;').parse
	grammar.to_s.must_equal "#JSGF V1.0 ENCODING;\ngrammar header_grammar;"
    end

    it 'must unparse a simple rule' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one;').parse
	grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;\n<rule> = one;"
    end

    it 'must unparse a public rule' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;public <rule>=one;').parse
	grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;\npublic <rule> = one;"
    end

    it 'must unparse a multi-atom rule' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one two;').parse
	grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;\n<rule> = one two;"
    end

    it 'must unparse a multi-atom optional' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=[one two];').parse
	grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;\n<rule> = [one two];"
    end

    it 'must unparse an alternation' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=one | two;').parse
	grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;\n<rule> = one | two;"
    end

    it 'must unparse an optional alternation' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=[one | two];').parse
	grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;\n<rule> = [one | two];"
    end

    it 'must unparse an alternation with a nested group' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=(one two) | three;').parse
	grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;\n<rule> = (one two) | three;"
    end

    describe 'when unparsing rule references' do
	it 'must unparse a rule reference' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>=(one <rule2>) | three; <rule2>=two;').parse
	    grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;\n<rule> = (one <rule2>) | three;\n<rule2> = two;"
	end

	it 'must unparse a weighted rule reference' do
	    grammar = JSGF::Parser.new('#JSGF V1.0; grammar header_grammar;<rule>= /0.5/ one | /0.5/ <rule2>; <rule2>=two;').parse
	    grammar.to_s.must_equal "#JSGF V1.0;\ngrammar header_grammar;\n<rule> = /0.5/ one | /0.5/ <rule2>;\n<rule2> = two;"
	end
    end
end
