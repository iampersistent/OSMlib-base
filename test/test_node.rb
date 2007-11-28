$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects.rb')
require 'test/unit'

class NodeTest < Test::Unit::TestCase

    def setup
        @node1 = OSM::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5)
        @node2 = OSM::Node.new(25, 'somebodyelse', '2007-03-20T00:00:00+00:00')
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
    end

    def test_tags
        assert @node1.tags.empty?

        @node1.tags['highway'] = 'residential'
        assert_equal 'residential', @node1.tags['highway']
        assert_nil @node1.tags['doesnt_exist']
        assert ! @node1.tags.empty?

        @node2.add_tags('amenity' => 'fuel', 'name' => 'ESSO')
        assert_equal 'fuel', @node2.tags['amenity']
        assert_equal 'ESSO', @node2.tags['name']
        assert_equal 'ESSO', @node2.name
        assert_nil @node2.tags['doesnt_exist']
    end

    def test_init
        assert_raise ArgumentError do
            node = OSM::Node.new()
        end
        node = OSM::Node.new(4)
        assert 4, node.id
        assert_nil node.user

        node.user = 'me'
        assert_equal 'me', node.user

        assert_nil node.timestamp
        assert_raise ArgumentError do
            node.timestamp = 'xxx'
        end
        node.timestamp = '2007-06-17T16:02:34+01:00'
        assert_equal '2007-06-17T16:02:34+01:00', node.timestamp
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
