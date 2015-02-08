require 'minitest/autorun'
require 'jsgf/atom'

describe JSGF::Atom do
    Atom = JSGF::Atom

    it 'must have a word' do
	Atom.new('test').atom.must_equal 'test'
    end

    it 'must not have a weight until given a weight' do
	Atom.new('test').weight.must_equal nil
    end

    it 'must stringify a word' do
	Atom.new('test').to_s.must_equal 'test'
    end

    it 'must stringify a weight' do
	Atom.new('test', weight:0.5).to_s.must_equal '/0.5/ test'
    end

    it 'must not stringify a nil weight' do
	Atom.new('test').to_s.must_equal 'test'
    end

    it 'must not stringify a default weight' do
	Atom.new('test', weight:1.0).to_s.must_equal 'test'
	Atom.new('test', weight:1).to_s.must_equal 'test'
    end
end
