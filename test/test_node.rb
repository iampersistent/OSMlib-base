$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects.rb')
require 'test/unit'

class NodeTest < Test::Unit::TestCase

    def setup
        @node1 = OSM::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5)
        @node2 = OSM::Node.new(25, 'somebodyelse', '2007-03-20T00:00:00Z')
    end

    def test_create
        assert_kind_of OSM::Node, @node1
        assert_equal 17, @node1.id
        assert_equal 'somebody', @node1.user
        assert_equal '2007-02-20T10:29:49+00:00', @node1.timestamp
        assert_equal '#<OSM::Node id="17" user="somebody" timestamp="2007-02-20T10:29:49+00:00" lon="8.5" lat="47.5">', @node1.to_s

        assert_kind_of Hash, @node1.tags
        assert @node1.tags.empty?
        assert_nil @node1.tags['foo']

        hash = {:id => 17, :user => 'somebody', :timestamp => '2007-02-20T10:29:49+00:00', :lon => '8.5', :lat => '47.5'}
        assert_equal hash, @node1.attributes
        hash = {:id => 25, :user => 'somebodyelse', :timestamp => '2007-03-20T00:00:00Z'}
        assert_equal hash, @node2.attributes
    end

    def test_tags
        assert @node1.tags.empty?

        @node1.tags['tourism'] = 'hotel'
        assert_equal 'hotel', @node1.tags['tourism']
        assert_equal 'hotel', @node1['tourism']
        assert_nil @node1.tags['doesnt_exist']
        assert ! @node1.tags.empty?

        @node1['name'] = 'Hotel Alfredo'
        assert_equal 'Hotel Alfredo', @node1['name']

        @node2.add_tags('amenity' => 'fuel', 'name' => 'ESSO')
        assert_equal 'fuel', @node2.tags['amenity']
        assert_equal 'ESSO', @node2.tags['name']
        assert_equal 'ESSO', @node2.name
        assert_nil @node2.tags['doesnt_exist']
    end

    def test_init
        node1 = OSM::Node.new
        node2 = OSM::Node.new
        node3 = OSM::Node.new(4)
        assert node1.id < 0
        assert node2.id < 0
        assert_not_equal node1.id, node2.id
        assert_equal 4, node3.id
        assert_nil node1.user

        node1.user = 'me'
        assert_equal 'me', node1.user

        assert_nil node1.timestamp
        assert_raise ArgumentError do
            node1.timestamp = 'xxx'
        end
        node1.timestamp = '2007-06-17T16:02:34+01:00'
        assert_equal '2007-06-17T16:02:34+01:00', node1.timestamp
    end

    def test_id
        assert_kind_of OSM::Node, OSM::Node.new('123')
        assert_kind_of OSM::Node, OSM::Node.new(123)
        assert_raise ArgumentError do
            OSM::Node.new('foo')
        end
        assert_raise ArgumentError do
            OSM::Node.new('123x')
        end
        assert_raise ArgumentError do
            OSM::Node.new(123.3)
        end
        assert_raise ArgumentError do
            OSM::Node.new(Hash.new)
        end
    end

    def test_lat
        node = OSM::Node.new(123)
        assert_raise ArgumentError do
            node.lat = Hash.new
        end
        node.lat = '123.45'
        assert_equal '123.45', node.lat
        node.lat = 123.45
        assert_equal '123.45', node.lat
    end

end
