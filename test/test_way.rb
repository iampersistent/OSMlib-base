$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects.rb')
require 'test/unit'

class WayTest < Test::Unit::TestCase

    def setup
        @way1 = OSM::Way.new(123, 'somebody', '2007-02-20T10:29:49+00:00')
        @way2 = OSM::Way.new(1111, 'somebodyelse', '2007-04-20T10:29:49+00:00')
    end

    def test_create
        assert_kind_of OSM::Way, @way1
        assert_equal 123, @way1.id
        assert_equal 'somebody', @way1.user
        assert_equal '2007-02-20T10:29:49+00:00', @way1.timestamp
        assert_kind_of Hash, @way1.tags
        assert @way1.tags.empty?
        assert_nil @way1.tags['foo']
    end

    def test_tags
        assert @way1.tags.empty?

        @way1.tags['highway'] = 'residential'
        assert_equal 'residential', @way1.tags['highway']
        assert_nil @way1.tags['doesnt_exist']
        assert ! @way1.tags.empty?

        @way2.add_tags('amenity' => 'fuel', 'name' => 'ESSO')
        assert_equal 'fuel', @way2.tags['amenity']
        assert_equal 'ESSO', @way2.tags['name']
        assert_equal 'ESSO', @way2.name
        assert_nil @way2.tags['doesnt_exist']
    end

    def test_init
        assert_raise ArgumentError do
            way = OSM::Way.new()
        end
        way = OSM::Way.new(4)
        assert 4, way.id
        assert_nil way.user

        way.user = 'me'
        assert_equal 'me', way.user

        assert_nil way.timestamp
        assert_raise ArgumentError do
            way.timestamp = 'xxx'
        end
        way.timestamp = '2007-06-17T16:02:34+01:00'
        assert_equal '2007-06-17T16:02:34+01:00', way.timestamp
    end

    def test_id
        assert_kind_of OSM::Way, OSM::Way.new('123')
        assert_kind_of OSM::Way, OSM::Way.new(123)
        assert_raise ArgumentError do
            OSM::Way.new('foo')
        end
        assert_raise ArgumentError do
            OSM::Way.new('123x')
        end
        assert_raise ArgumentError do
            OSM::Way.new(123.3)
        end
        assert_raise ArgumentError do
            OSM::Way.new(Hash.new)
        end
    end
end
