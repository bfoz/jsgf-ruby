require 'strscan'

module JSGF
    class Tokenizer
	TOKENS = {
	    /grammar/				=> :GRAMMAR,
	    /#JSGF/				=> :HEADER,
	    /import/				=> :IMPORT,
	    /public/				=> :PUBLIC,
	    /\{(\\.|[^\}]+)*\}/			=> :TAG,
	    /[^ \t\n;=|*+<>\(\)\[\]{}*\/]+/	=> :TOKEN,
	    %r{/\d*(\.\d+)?/}			=> :WEIGHT,
	}

	# @param io [IO]    the {::IO} stream to read from
	def initialize(io)
	    io = io.read unless io.is_a?(String)
	    @scanner = StringScanner.new(io)
	end

	def next_token
	    return if @scanner.eos?

	    @scanner.skip(/\s+/)	# Skip all leading whitespace
	    @scanner.skip(%r{//.*\n})	# Skip single-line comments

	    # Skip C-style comments
	    if @scanner.scan(%r{/\*})
		# Look for the end of the block, and skip any trailing whitespace
		@scanner.skip_until(%r{\*/\s*})
	    end

	    TOKENS.each do |(pattern, token)|
		text = @scanner.scan(pattern)
		return [token, text] if text
	    end
	    x = @scanner.getch
	    [x, x] unless x.nil?
	end
    end
end
