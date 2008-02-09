$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'API.rb')
require 'test/unit'

require 'net/http'

# This is a mock class that pretends to be a Net::HTTPResponse. It is called from some of the
# tests to fake the network interaction with the server.
class MockHTTPResponse

    attr_reader :code, :body

    def initialize(suffix)
        case suffix
            when 'node/1'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.5" generator="OpenStreetMap server">
  <node id="1" lat="48.1" lon="8.1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
</osm>
}
            when 'node/2'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.5" generator="OpenStreetMap server">
  <node id="1" lat="48.1" lon="8.1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
  <node id="2" lat="48.2" lon="8.2" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
</osm>
}
            when 'way/1'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.5" generator="OpenStreetMap server">
  <way id="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" user="u">
    <nd ref="1"/>
    <nd ref="2"/>
    <nd ref="3"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
</osm>
}
            when 'way/2'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.5" generator="OpenStreetMap server">
  <way id="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" user="u">
    <nd ref="1"/>
    <nd ref="2"/>
    <nd ref="3"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
  <way id="2" visible="true" timestamp="2007-06-03T20:02:39+01:00" user="u">
    <nd ref="4"/>
    <nd ref="5"/>
    <nd ref="6"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
</osm>
}
            when 'relation/1'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.5" generator="OpenStreetMap server">
  <relation id="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" user="u">
    <member type="way" ref="1" role=""/>
    <member type="way" ref="2" role=""/>
    <tag k="type" v="something"/>
  </relation>
</osm>
}
            when 'relation/2'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.5" generator="OpenStreetMap server">
  <relation id="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" user="u">
    <member type="way" ref="1" role=""/>
    <member type="way" ref="2" role=""/>
    <tag k="type" v="something"/>
  </relation>
  <relation id="2" visible="true" timestamp="2007-07-24T16:18:51+01:00" user="u">
    <member type="way" ref="3" role=""/>
    <member type="way" ref="4" role=""/>
    <tag k="type" v="something"/>
  </relation>
</osm>
}
            when /^(node|way|relation)\/404$/
                @code = 404
                @body = ''
            when /^(node|way|relation)\/410$/
                @code = 410
                @body = ''
            when /^(node|way|relation)\/500$/
                @code = 500
                @body = ''
            else
                raise ArgumentError.new("unknown parameter: '#{suffix}'")
        end
    end

end

class TestAPI < Test::Unit::TestCase

    def setup
        @api = OSM::API.new

        @mapi = OSM::API.new('http://mock/')
        def @mapi.get(suffix)
            MockHTTPResponse.new(suffix)
        end
    end

    def test_create_std
        assert_kind_of OSM::API, @api
        assert_equal 'http://www.openstreetmap.org/api/0.5/', @api.instance_variable_get(:@base_uri)
    end

    def test_create_uri
        api = OSM::API.new('http://localhost/')
        assert_kind_of OSM::API, api
        assert_equal 'http://localhost/', api.instance_variable_get(:@base_uri)
    end

    def test_get_object
        assert_raise ArgumentError do
            @mapi.get_object('foo', 1)
        end
    end

    # node

    def test_get_node_type_error
        assert_raise TypeError do
            @api.get_node('foo')
        end
        assert_raise TypeError do
            @api.get_node(-17)
        end
    end

    def test_get_node_200
        node = @mapi.get_node(1)
        assert_kind_of OSM::Node, node
        assert_equal 1, node.id
        assert_equal '48.1', node.lat
        assert_equal '8.1', node.lon
        assert_equal 'u', node.user
    end

    def test_get_node_too_many_objects
        assert_raise OSM::APITooManyObjects do
            @mapi.get_node(2)
        end
    end

    def test_get_node_404
        assert_raise OSM::APINotFound do
            @mapi.get_node(404)
        end
    end

    def test_get_node_410
        assert_raise OSM::APIGone do
            @mapi.get_node(410)
        end
    end

    def test_get_node_500
        assert_raise OSM::APIServerError do
            @mapi.get_node(500)
        end
    end

    # way

    def test_get_way_type_error
        assert_raise TypeError do
            @api.get_way('foo')
        end
        assert_raise TypeError do
            @api.get_way(-17)
        end
    end

    def test_get_way_200
        way = @mapi.get_way(1)
        assert_kind_of OSM::Way, way
        assert_equal 1, way.id
        assert_equal 'u', way.user
    end

    def test_get_way_404
        assert_raise OSM::APINotFound do
            @mapi.get_way(404)
        end
    end

    def test_get_way_410
        assert_raise OSM::APIGone do
            @mapi.get_way(410)
        end
    end

    def test_get_way_500
        assert_raise OSM::APIServerError do
            @mapi.get_way(500)
        end
    end

    # relation

    def test_get_relation_type_error
        assert_raise TypeError do
            @api.get_relation('foo')
        end
        assert_raise TypeError do
            @api.get_relation(-17)
        end
    end

    def test_get_relation_200
        relation = @mapi.get_relation(1)
        assert_kind_of OSM::Relation, relation
        assert_equal 1, relation.id
        assert_equal 'u', relation.user
    end

    def test_get_relation_404
        assert_raise OSM::APINotFound do
            @mapi.get_relation(404)
        end
    end

    def test_get_relation_410
        assert_raise OSM::APIGone do
            @mapi.get_relation(410)
        end
    end

    def test_get_relation_500
        assert_raise OSM::APIServerError do
            @mapi.get_relation(500)
        end
    end


end

