require 'minitest/autorun'
require 'jsgf/builder'

describe JSGF::Builder do
    it 'must set the name from inside the block' do
	grammar = JSGF::Builder.build do
	    name 'MyName'
	end
	grammar.grammar_name.must_equal 'MyName'
    end

    it 'must set the name from an argument' do
	grammar = JSGF::Builder.build 'MyName'
	grammar.grammar_name.must_equal 'MyName'
    end

    it 'must build a single-atom rule' do
	grammar = JSGF::Builder.new.build do
	    rule rule1: 'one'
	end

	grammar.rules.size.must_equal 1
	grammar.rules['rule1'].must_equal [JSGF::Atom.new('one')]
    end

    it 'must build a multi-atom rule' do
	grammar = JSGF::Builder.build {rule rule1: 'one two' }
	grammar.rules.size.must_equal 1
	grammar.rules['rule1'].must_equal [JSGF::Atom.new('one'), JSGF::Atom.new('two')]
    end

    it 'must build a rule with a rule reference as a Symbol' do
	grammar = JSGF::Builder.build do
	    rule rule1: :one
	    rule one: 'one'
	end

	grammar.rules.size.must_equal 2
	grammar.rules['rule1'].must_equal [JSGF::Atom.new('one', reference:true)]
    end

    it 'must build a rule with a JSGF-style rule reference embedded in a string' do
	grammar = JSGF::Builder.build do
	    rule rule1: '<one>'
	    rule one: 'one'
	end

	grammar.rules.size.must_equal 2
	grammar.rules['rule1'].must_equal [JSGF::Atom.new('one', reference:true)]
    end

    it 'must build a rule with a rule reference symbol embedded in a string' do
	grammar = JSGF::Builder.build do
	    rule rule1: ':one'
	    rule one: 'one'
	end

	grammar.rules.size.must_equal 2
	grammar.rules['rule1'].must_equal [JSGF::Atom.new('one', reference:true)]
    end

    describe 'alternation' do
	it 'must build an alternation from an array of atoms' do
	    grammar = JSGF::Builder.build do
		rule rule1: %w{one two}
	    end
	    grammar.rules.size.must_equal 1
	    grammar.rules['rule1'].first.must_be_kind_of JSGF::Alternation
	    grammar.rules['rule1'].first.elements.must_equal [JSGF::Atom.new('one'), JSGF::Atom.new('two')]
	end

	it 'must build an alternation from an array of rule reference symbols' do
	    grammar = JSGF::Builder.build do
		rule rule1: [:one, :two]
		rule one: 'one'
		rule two: 'two'
	    end

	    grammar.rules.size.must_equal 3
	    grammar.rules['rule1'].first.must_be_kind_of JSGF::Alternation
	    grammar.rules['rule1'].first.elements.must_equal [JSGF::Atom.new('one', reference:true), JSGF::Atom.new('two', reference:true)]
	end

	it 'must build an alternation from an array of strings containing embedded rule reference symbols' do
	    grammar = JSGF::Builder.build do
		rule rule1: %w[:one :two]
		rule one: 'one'
		rule two: 'two'
	    end

	    grammar.rules.size.must_equal 3
	    grammar.rules['rule1'].first.must_be_kind_of JSGF::Alternation
	    grammar.rules['rule1'].first.elements.must_equal [JSGF::Atom.new('one', reference:true), JSGF::Atom.new('two', reference:true)]
	end

	it 'must build an alternation from an array of strings containing embedded JSGF-style rule reference names' do
	    grammar = JSGF::Builder.build do
		rule rule1: %w[<one> <two>]
		rule one: 'one'
		rule two: 'two'
	    end

	    grammar.rules.size.must_equal 3
	    grammar.rules['rule1'].first.must_be_kind_of JSGF::Alternation
	    grammar.rules['rule1'].first.elements.must_equal [JSGF::Atom.new('one', reference:true), JSGF::Atom.new('two', reference:true)]
	end
    end

    describe 'optional' do
	it 'must parse a rule with an optional word' do
	    grammar = JSGF::Builder.build do
		rule rule1: "this [is] optional"
	    end

	    grammar.rules.size.must_equal 1
	    rule = grammar.rules['rule1']
	    rule.size.must_equal 3

	    rule.first.atom.must_equal 'this'
	    rule.first.wont_be :optional?

	    rule[1].atom.must_equal 'is'
	    rule[1].must_be :optional?

	    rule.last.atom.must_equal 'optional'
	    rule.last.wont_be :optional?
	end

	it 'must parse a rule with an optional reference' do
	    grammar = JSGF::Builder.build do
		rule rule1: "this [:is] optional"
	    end

	    grammar.rules.size.must_equal 1
	    rule = grammar.rules['rule1']
	    rule.size.must_equal 3

	    rule.first.atom.must_equal 'this'
	    rule.first.wont_be :optional?

	    rule[1].atom.must_equal 'is'
	    rule[1].must_be :optional?
	    rule[1].must_be :reference?

	    rule.last.atom.must_equal 'optional'
	    rule.last.wont_be :optional?
	end

	it 'must parse a rule with an optional word surrounded by whitespace' do
	    grammar = JSGF::Builder.build do
		rule rule1: "this [ is ] optional"
	    end

	    grammar.rules.size.must_equal 1
	    rule = grammar.rules['rule1']
	    rule.size.must_equal 3
	    rule.map(&:atom).must_equal ['this', 'is', 'optional']

	    rule.first.wont_be :optional?
	    rule[1].must_be :optional?
	    rule.last.wont_be :optional?
	end

	it 'must parse a rule with an optional reference surrounded by whitespace' do
	    grammar = JSGF::Builder.build do
		rule rule1: "this [ :is ] optional"
	    end

	    grammar.rules.size.must_equal 1
	    rule = grammar.rules['rule1']
	    rule.size.must_equal 3
	    rule.map(&:atom).must_equal ['this', 'is', 'optional']

	    rule.first.wont_be :optional?

	    rule[1].must_be :optional?
	    rule[1].must_be :reference?

	    rule.last.wont_be :optional?
	end

	it 'must parse a rule with an optional words surrounded by whitespace' do
	    grammar = JSGF::Builder.build do
		rule rule1: "this [ is optional ]"
	    end

	    grammar.rules.size.must_equal 1
	    rule = grammar.rules['rule1']
	    rule.size.must_equal 2

	    rule.first.atom.must_equal 'this'
	    rule.first.wont_be :optional?

	    rule[1].must_be_kind_of JSGF::Optional
	    rule[1].elements.map(&:atom).must_equal ['is', 'optional']
	end

	it 'must parse a rule with an optional references surrounded by whitespace' do
	    grammar = JSGF::Builder.build do
		rule rule1: "this [ :is :optional ]"
	    end

	    grammar.rules.size.must_equal 1
	    rule = grammar.rules['rule1']
	    rule.size.must_equal 2

	    rule.first.atom.must_equal 'this'
	    rule.first.wont_be :optional?

	    rule.last.must_be_kind_of JSGF::Optional
	    rule.last.elements.map(&:atom).must_equal ['is', 'optional']
	end
    end
end