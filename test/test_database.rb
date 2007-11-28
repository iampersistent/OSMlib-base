$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'Database.rb')
require 'test/unit'

class DatabaseTest < Test::Unit::TestCase

    def setup
        @db = OSM::Database.new
    end

    def test_create
        assert_kind_of OSM::Database, @db
        @db.version = '0.5'
        assert_equal '0.5', @db.version
    end

    def test_adding
        node = OSM::Node.new(1)
        @db.add_node(node)
        assert_equal node, @db.get_node(1)
        assert_equal @db, node.db

        way = OSM::Way.new(17)
        @db.add_way(way)
        assert_equal way, @db.get_way(17)
        assert_equal @db, way.db

        relation = OSM::Relation.new(21)
        @db.add_relation(relation)
        assert_equal relation, @db.get_relation(21)
        assert_equal @db, relation.db

        node1 = OSM::Node.new(42)
        @db << node1
        assert_equal node1, @db.get_node(42)
        assert_equal @db, node1.db
    end

    def test_adding_unknown_object
        assert_raise ArgumentError do
            @db << Hash.new
        end
    end

end
