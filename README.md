JSGF
====

[![Build Status](https://travis-ci.org/bfoz/jsgf-ruby.png)](https://travis-ci.org/bfoz/jsgf-ruby)
[![Gem Version](https://badge.fury.io/rb/jsgf.svg)](http://badge.fury.io/rb/jsgf)

For all of your [Java Speech Grammar Format](http://www.w3.org/TR/jsgf/) parsing needs.

Usage
-----

Reading an existing JSGF file is as simple as...

```ruby
require 'jsgf'

grammar = JSGF.read('example.gram')
```

Writing to a file is similarly simple.

```ruby
grammar.write('my_grammar.gram')
```

You can also write to an IO stream.

```ruby
File.open('my_grammar.gram', 'w') do |f|
    grammar.write(f)
end
```

### Grammar DSL

The JSGF gem includes a simple DSL for generating new grammars. The syntax follows the
the [JSGF](http://www.w3.org/TR/jsgf/) syntax, but with a few differences.

- Rule names can be either Symbols or Strings (they're converted to Strings internally)
- Rules can be referenced using symbols in addition to the angle-bracket syntax used by JSGF.
- Alternations are created using arrays
- Rules are private by default, however the root rules are automatically made public

```ruby
grammar = JSGF.grammar 'Turtle' do
    rule quit: 'quit'                       # 'quit' and 'move' are public because
    rule move: 'go :direction :distance'    #   they are the roots of the grammar tree

    rule direction: %w{forward backward}
    rule distance: %w{one two three four five six seven eight nine ten}
end
```

Atoms can be made optional using the JSGF square-bracket syntax...

```ruby
grammar = JSGF.grammar 'PoliteTurtle' do
    rule move: '[please] go :direction :distance'
    ...
end
```

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'jsgf'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jsgf

License
-------

Copyright 2015 Brandon Fosdick <bfoz@bfoz.net> and released under the BSD license.
