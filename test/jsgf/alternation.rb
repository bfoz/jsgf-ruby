require 'minitest/autorun'
require 'jsgf/parser'

describe JSGF::Alternation do
    it 'must convert string arguments into atoms' do
	alternation = JSGF::Alternation.new('one', 'two', 'three')
	alternation.elements.must_equal [Atom.new('one'), Atom.new('two'), Atom.new('three')]
    end

    it 'must be enumerable' do
	alternation = JSGF::Alternation.new('one', 'two', 'three')
	alternation.all? {|a| a}
    end

    it 'must be mappable' do
	alternation = JSGF::Alternation.new('one', 'two', 'three')
	i = 0
	alternation.map {|a| i = i + 1 }.must_equal [1,2,3]
    end
end
