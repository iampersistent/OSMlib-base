$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects.rb')
require 'test/unit'

class OsmObjectTest < Test::Unit::TestCase

    def test_init
        assert_raise ArgumentError do
            OSM::OSMObject.new()
        end
        assert_raise NotImplementedError do
            OSM::OSMObject.new(17)
        end
    end

end
