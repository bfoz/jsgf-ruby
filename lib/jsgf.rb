require_relative 'jsgf/builder'
require_relative 'jsgf/parser'
require_relative 'jsgf/tokenizer'

=begin
A parser for JSGF files.

http://www.w3.org/TR/jsgf/
http://en.wikipedia.org/wiki/JSGF

http://en.wikipedia.org/wiki/JSGF

@example
    grammar = JSGF.read(filename)
=end
module JSGF
    # @param filename	[String]    the file to parse
    # @return [Grammar]	the resulting {Grammar}
    def self.read(filename)
	tokenzier = JSGF::Tokenizer.new(File.read(filename))
	JSGF::Parser.new(tokenzier).parse
    end

    # @return [Grammar] a new {Grammar} built from the block argument
    def self.grammar(name=nil, &block)
	Builder.build(name, &block)
    end
end
