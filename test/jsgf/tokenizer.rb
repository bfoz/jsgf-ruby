require 'minitest/autorun'
require 'jsgf/tokenizer'

describe JSGF::Tokenizer do
    it 'must pass individual characters' do
	JSGF::Tokenizer.new(';').next_token.must_equal [';', ';']
    end

    it 'must recognize the grammar keyword' do
	JSGF::Tokenizer.new('grammar').next_token.must_equal [:GRAMMAR, 'grammar']
    end

    it 'must skip leading whitespace' do
	JSGF::Tokenizer.new('   grammar').next_token.must_equal [:GRAMMAR, 'grammar']
    end

    it 'must recognize the header string' do
	JSGF::Tokenizer.new('#JSGF').next_token.must_equal [:HEADER, '#JSGF']
    end

    it 'must recognize the public keyword' do
	JSGF::Tokenizer.new('public').next_token.must_equal [:PUBLIC, 'public']
    end

    it 'must recognize a tag block ' do
	JSGF::Tokenizer.new('{ some stuff }').next_token.must_equal [:TAG, '{ some stuff }']
    end

    it 'must recognize a weight' do
	JSGF::Tokenizer.new('/0.5/').next_token.must_equal [:WEIGHT, '/0.5/']
    end

    it 'must recognize a token' do
	JSGF::Tokenizer.new(' some_token ').next_token.must_equal [:TOKEN, 'some_token']
    end

    describe 'when given comments' do
	it 'must skip C-style comments' do
	    JSGF::Tokenizer.new(' /* a comment */ some_token ').next_token.must_equal [:TOKEN, 'some_token']
	end

	it 'must skip multi-line C-style comments' do
	    JSGF::Tokenizer.new(" /* a\nmulti-line\ncomment */ some_token ").next_token.must_equal [:TOKEN, 'some_token']
	end

	it 'must skip single-line C++ comments' do
	    JSGF::Tokenizer.new(' some_token // a comment ').next_token.must_equal [:TOKEN, 'some_token']
	end

	it 'must skip single-line C++ comments at the beginning of a line' do
	    JSGF::Tokenizer.new(" some_token // \n//a comment ").next_token.must_equal [:TOKEN, 'some_token']
	end
    end
end
