require 'minitest/autorun'
require 'jsgf/parser'

describe JSGF::Optional do
    it 'must be enumerable' do
	optional = JSGF::Optional.new('one', 'two', 'three')
	optional.all? {|a| a}
    end

    it 'must be mappable' do
	optional = JSGF::Optional.new('one', 'two', 'three')
	i = 0
	optional.map {|a| i = i + 1 }.must_equal [1,2,3]
    end
end
