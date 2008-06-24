$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects')
require 'test/unit'

class TestMembers < Test::Unit::TestCase

    def test_node
        member = OSM::Member.new('node', 17, 'foo')
        assert_equal 'node', member.type
        assert_equal 17, member.ref
        assert_equal 'foo', member.role
    end

    def test_way
        member = OSM::Member.new('way', 17)
        assert_equal 'way', member.type
        assert_equal 17, member.ref
        assert_equal '', member.role
    end

    def test_relation
        member = OSM::Member.new('relation', 17, 'foo')
        assert_equal 'relation', member.type
        assert_equal 17, member.ref
        assert_equal 'foo', member.role
    end

    def test_fail
        assert_raise ArgumentError do
            OSM::Member.new('unknown', 17, 'foo')
        end
    end

end
