$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects')
require 'test/unit'
require 'rubygems'
require 'geo_ruby'

class TestGeometry < Test::Unit::TestCase

    def setup
        @db = OSM::Database.new
    end

    def test_node_geometry
        node = OSM::Node.new(1, nil, nil, 10.4, 40.3)
        assert_kind_of GeoRuby::SimpleFeatures::Point, node.geometry
        assert_equal 10.4, node.geometry.lon
        assert_equal 40.3, node.geometry.lat
        assert_equal 10.4, node.point.lon
        assert_equal 40.3, node.point.lat
    end

    def test_node_geometry_nil
        node = OSM::Node.new(1)
        assert_raise OSM::GeometryError do
            node.geometry
        end
    end

    def test_node_shape
        node = OSM::Node.new(1, nil, nil, 10.4, 40.3)
        attrs = {'a' => 'b', 'c' => 'd'}
        shape = node.shape(node.point, attrs)
        assert_kind_of GeoRuby::Shp4r::ShpRecord, shape
        assert_equal attrs, shape.data
        assert_kind_of GeoRuby::SimpleFeatures::Point, shape.geometry
        assert_equal node.geometry, shape.geometry
    end

    def test_way_geometry_nil
        way = OSM::Way.new(1)
        assert_raise OSM::GeometryError do
            way.linestring
        end
        assert_raise OSM::GeometryError do
            way.polygon
        end
        assert_raise OSM::GeometryError do
            way.geometry
        end

    end

    def test_way_geometry_fail
        way = OSM::Way.new(1)
        way.nodes << OSM::Node.new.id << OSM::Node.new.id << OSM::Node.new.id
        assert_raise OSM::NoDatabaseError do
            way.linestring
        end
        assert_raise OSM::NoDatabaseError do
            way.polygon
        end
        assert_raise OSM::NoDatabaseError do
            way.geometry
        end
    end

    def test_way_geometry
        @db << (way = OSM::Way.new(1))
        @db << (node1 = OSM::Node.new(nil, nil, nil, 0, 0))
        @db << (node2 = OSM::Node.new(nil, nil, nil, 0, 10))
        @db << (node3 = OSM::Node.new(nil, nil, nil, 10, 10))

        assert_raise OSM::GeometryError do
            way.linestring
        end
        assert_raise OSM::GeometryError do
            way.polygon
        end
        assert_raise OSM::GeometryError do
            way.geometry
        end

        way.nodes << node1.id

        assert_raise OSM::GeometryError do
            way.linestring
        end
        assert_raise OSM::GeometryError do
            way.polygon
        end
        assert_raise OSM::GeometryError do
            way.geometry
        end

        way.nodes << node2.id

        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.linestring
        assert_raise OSM::GeometryError do
            way.polygon
        end
        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.geometry

        way.nodes << node3.id

        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.linestring
        assert_raise OSM::NotClosedError do
            way.polygon
        end
        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.geometry

        way.nodes << node1.id
        assert_kind_of GeoRuby::SimpleFeatures::Polygon, way.polygon

    end

    def test_relation_geometry
        rel = OSM::Relation.new
        assert_raise OSM::NoGeometryError do
            rel.geometry
        end
    end

end
