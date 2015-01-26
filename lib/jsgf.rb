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
end
