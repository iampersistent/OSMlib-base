$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects')
require 'test/unit'

class TestOSMObject < Test::Unit::TestCase

    def test_init
        assert_raise ArgumentError do
            OSM::OSMObject.new()
        end
        assert_raise ArgumentError do
            OSM::OSMObject.new(17)
        end
        assert_raise NotImplementedError do
            OSM::OSMObject.new(17, 'user', '2000-01-01T00:00:00Z')
        end
    end

end
