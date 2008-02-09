$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'Database.rb')
require 'test/unit'

class TestDatabase < Test::Unit::TestCase

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

        assert_equal 2, @db.nodes.size
        assert_equal 1, @db.ways.size
        assert_equal 1, @db.relations.size

        @db.clear
        assert_equal 0, @db.nodes.size
        assert_equal 0, @db.ways.size
        assert_equal 0, @db.relations.size

        assert_nil node.db
        assert_nil node1.db
        assert_nil way.db
        assert_nil relation.db
    end

    def test_adding_multiple
        @db << OSM::Node.new(1) << OSM::Node.new(2) << OSM::Way.new(3)
        assert_kind_of OSM::Node, @db.get_node(1)
        assert_kind_of OSM::Node, @db.get_node(2)
        assert_kind_of OSM::Way,  @db.get_way(3)
    end

    def test_adding_unknown_object
        assert_raise ArgumentError do
            @db << Hash.new
        end
    end

    def test_overwrite_node
        node1 = OSM::Node.new(89)
        @db.add_node(node1)
        assert_equal @db, node1.db
        node2 = OSM::Node.new(89)
        @db.add_node(node2)
        assert_equal @db, node2.db
        assert_nil node1.db
    end

    def test_overwrite_way
        way1 = OSM::Way.new(89)
        @db.add_way(way1)
        assert_equal @db, way1.db
        way2 = OSM::Way.new(89)
        @db.add_way(way2)
        assert_equal @db, way2.db
        assert_nil way1.db
    end

    def test_overwrite_relation
        relation1 = OSM::Relation.new(89)
        @db.add_relation(relation1)
        assert_equal @db, relation1.db
        relation2 = OSM::Relation.new(89)
        @db.add_relation(relation2)
        assert_equal @db, relation2.db
        assert_nil relation1.db
    end

    def test_way_node_objects
        way = OSM::Way.new
        assert_raise OSM::NoDatabaseError do
            way.node_objects
        end
        @db << way
        assert_equal [], way.node_objects
        node = OSM::Node.new(19)
        way.nodes << node.id
        @db << node
        assert_equal 19, way.nodes[0] 
        assert_equal [node], way.node_objects
    end

end
