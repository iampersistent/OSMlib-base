$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects')
require 'test/unit'

class TestNode < Test::Unit::TestCase

    def test_create
        node = OSM::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5)
        assert_kind_of OSM::Node, node
        assert_equal 17, node.id
        assert_equal 'somebody', node.user
        assert_equal '2007-02-20T10:29:49+00:00', node.timestamp
        assert_equal '#<OSM::Node id="17" user="somebody" timestamp="2007-02-20T10:29:49+00:00" lon="8.5" lat="47.5">', node.to_s

        assert_kind_of Hash, node.tags
        assert node.tags.empty?
        assert_nil node.tags['foo']

        hash = {:id => 17, :user => 'somebody', :timestamp => '2007-02-20T10:29:49+00:00', :lon => '8.5', :lat => '47.5'}
        assert_equal hash, node.attributes
    end

    def test_init_id
        node1 = OSM::Node.new
        node2 = OSM::Node.new
        node3 = OSM::Node.new(4)
        node4 = OSM::Node.new(-3)
        assert node1.id < 0
        assert node2.id < 0
        assert_not_equal node1.id, node2.id
        assert_equal 4, node3.id
        assert_equal -3, node4.id
    end

    def test_set_id
        node = OSM::Node.new
        assert_raise NotImplementedError do
            node.id = 1
        end
    end

    def test_set_user
        node = OSM::Node.new
        assert_nil node.user
        node.user = 'me'
        assert_equal 'me', node.user
    end

    def test_set_timestamp
        node = OSM::Node.new
        assert_nil node.timestamp
        assert_raise ArgumentError do
            node.timestamp = 'xxx'
        end
        node.timestamp = '2007-06-17T16:02:34+01:00'
        assert_equal '2007-06-17T16:02:34+01:00', node.timestamp
    end

    def test_tags1
        node = OSM::Node.new
        assert node.tags.empty?
        assert ! node.is_tagged?

        node.tags['tourism'] = 'hotel'
        assert ! node.tags.empty?
        assert node.is_tagged?

        assert_equal 'hotel', node.tags['tourism']
        assert_equal 'hotel', node['tourism']
        assert_equal 'hotel', node.tourism
        assert_nil node.tags['doesnt_exist']

        node['name'] = 'Hotel Alfredo'
        assert_equal 'Hotel Alfredo', node['name']

        assert_equal 2, node.tags.size
    end

    def test_tag2
        node = OSM::Node.new
        node.add_tags('amenity' => 'fuel', 'name' => 'ESSO')

        assert_equal 'fuel', node.tags['amenity']
        assert_equal 'ESSO', node.tags['name']
        assert_equal 'ESSO', node.name

        assert_equal 2, node.tags.size
    end

    def test_method_missing
        node = OSM::Node.new
        assert_equal 'foo', node.bar = 'foo'
        assert_equal 'foo', node.bar
        assert ! node.bar?
        assert_raise ArgumentError do
            node.call(:bar=, 'x', 'y')
        end
        assert_raise ArgumentError do
            node.call(:bar?, 'x')
        end
        assert_raise ArgumentError do
            node.call(:bar, 'x')
        end
    end

    def test_tag_boolean
        node = OSM::Node.new
        node.add_tags('true1' => 'true', 'true2' => 'yes', 'true3' => '1', 'false1' => 'x', 'false2' => '0')

        assert node.true1?
        assert node.true2?
        assert node.true3?
        assert ! node.false1?
        assert ! node.false2?
    end

    def test_id_type
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
        assert_nil node.lat
        node.lat = '123.45'
        assert_equal '123.45', node.lat
        node.lat = 123.45
        assert_equal '123.45', node.lat
    end

    def test_lon
        node = OSM::Node.new(123)
        assert_raise ArgumentError do
            node.lon = Hash.new
        end
        assert_nil node.lon
        node.lon = '123.45'
        assert_equal '123.45', node.lon
        node.lon = 123.45
        assert_equal '123.45', node.lon
    end

    def test_magic_add_hash
        node = OSM::Node.new
        node << { 'a' => 'b' } << { 'c' => 'd' }
        assert_equal 'b', node.tags['a']
        assert_equal 'd', node.tags['c']
    end

    def test_magic_add_tags
        node = OSM::Node.new
        tags = OSM::Tags.new
        tags['a'] = 'b'
        node << tags
        assert_equal 'b', node.tags['a']
    end

    def test_magic_add_array
        node = OSM::Node.new
        node << [{'a' => 'b'}, {'c' => 'd'}]
        assert_equal 'b', node.tags['a']
        assert_equal 'd', node.tags['c']
    end

end
