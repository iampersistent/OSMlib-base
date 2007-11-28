$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects.rb')
require 'test/unit'

class MiscTest < Test::Unit::TestCase

    def setup
        @node = OSM::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00')
        @way = OSM::Way.new(17, 'somebodyelse', '2007-03-20T00:00:00+00:00')
    end

    def test_different
    end

end
