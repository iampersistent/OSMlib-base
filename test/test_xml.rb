$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects')
require 'test/unit'
require 'rexml/document'
require 'rubygems'
require 'builder'

# In this file we test the to_xml methods of all the different objects.
class TestXml < Test::Unit::TestCase

    def setup
        @out = ''
        @doc = Builder::XmlMarkup.new(:target => @out)
    end

    # <tag k="foo" v="bar"/>
    def test_tags
        tags = OSM::Tags.new
        tags['foo'] = 'bar'
        tags.to_xml(@doc)

        rexml = REXML::Document.new(@out)
        element = REXML::XPath.first(rexml, '/tag')
        assert_kind_of REXML::Element, element
        assert_equal 'tag', element.name
        assert_equal 'foo', REXML::XPath.first(rexml, '/tag/@k').value
        assert_equal 'bar', REXML::XPath.first(rexml, '/tag/@v').value
    end

    # <node id="-1"/>
    def test_node_empty
        node = OSM::Node.new
        node.to_xml(@doc)

        rexml = REXML::Document.new(@out)
        element = REXML::XPath.first(rexml, '/node')
        assert_kind_of REXML::Element, element
        assert_equal 'node', element.name
        assert_equal node.id.to_s, REXML::XPath.first(rexml, '/node/@id').value
    end

    # <node id="45" user="user" timestamp="2007-12-12T01:01:01Z" lon="10.0" lat="20.0"/>
    def test_node_with_data
        node = OSM::Node.new(45, 'user', '2007-12-12T01:01:01Z', 10.0, 20.0)
        node.to_xml(@doc)

        rexml = REXML::Document.new(@out)
        element = REXML::XPath.first(rexml, '/node')
        assert_kind_of REXML::Element, element
        assert_equal 'node', element.name
        assert_equal '45', REXML::XPath.first(rexml, '/node/@id').value
        assert_equal 'user', REXML::XPath.first(rexml, '/node/@user').value
        assert_equal '2007-12-12T01:01:01Z', REXML::XPath.first(rexml, '/node/@timestamp').value
        assert_equal '10.0', REXML::XPath.first(rexml, '/node/@lon').value
        assert_equal '20.0', REXML::XPath.first(rexml, '/node/@lat').value
    end

    # <node id="-1">
    #   <tag k="tourism" v="hotel"/>
    #   <tag k="name" v="Grand Hotel"/>
    # </node>
    def test_node_with_tags
        node = OSM::Node.new
        node.add_tags('tourism' => 'hotel', 'name' => 'Grand Hotel')
        node.to_xml(@doc)

        rexml = REXML::Document.new(@out)
        element = REXML::XPath.first(rexml, '/node')
        assert_kind_of REXML::Element, element
        assert_equal 'node', element.name
        assert_equal node.id.to_s, REXML::XPath.first(rexml, '/node/@id').value

        keys = []
        REXML::XPath.each(rexml, '/node/tag') do |element|
            assert_kind_of REXML::Element, element
            assert_equal 'tag', element.name

            key   = REXML::XPath.first(element, '@k').value
            value = REXML::XPath.first(element, '@v').value
            keys << key

            case key
                when 'tourism'
                    assert_equal 'hotel', value
                when 'name'
                    assert_equal 'Grand Hotel', value
                else
                    raise ScriptError
            end
        end
        assert_equal ['name', 'tourism'], keys.sort
    end

    # <way id="4" user="foo" timestamp="2000-01-01T00:00:00Z">
    #   <nd ref="42/>
    #   <nd ref="43/>
    #   <tag k="highway" v="residential"/>
    #   <tag k="name" v="Harbour Street"/>
    # </way>
    def test_way
        way = OSM::Way.new(4, 'foo', '2000-01-01T00:00:00Z')
        way.add_tags('highway' => 'residential', 'name' => 'Harbour Street')
        way << OSM::Node.new(42)
        way << OSM::Node.new(43)
        way.to_xml(@doc)

        rexml = REXML::Document.new(@out)
        element = REXML::XPath.first(rexml, '/way')
        assert_kind_of REXML::Element, element
        assert_equal 'way', element.name
        assert_equal 'nd', REXML::XPath.first(rexml, '/way/[1]').name
        assert_equal 'tag', REXML::XPath.first(rexml, '/way/[3]').name
        assert_equal '4', REXML::XPath.first(rexml, '/way/@id').value

        keys = []
        REXML::XPath.each(rexml, '/way/tag') do |element|
            assert_kind_of REXML::Element, element
            assert_equal 'tag', element.name

            key   = REXML::XPath.first(element, '@k').value
            value = REXML::XPath.first(element, '@v').value
            keys << key

            case key
                when 'highway'
                    assert_equal 'residential', value
                when 'name'
                    assert_equal 'Harbour Street', value
                else
                    raise ScriptError
            end
        end
        assert_equal ['highway', 'name'], keys.sort

        refs = []
        REXML::XPath.each(rexml, '/way/nd') do |element|
            assert_kind_of REXML::Element, element
            assert_equal 'nd', element.name
            refs << REXML::XPath.first(element, '@ref').value
        end
        assert_equal ['42', '43'], refs.sort
    end

    # <member type="node" ref="18" role="foo"/>
    def test_member
        member = OSM::Member.new('node', 18, 'foo')
        member.to_xml(@doc)

        rexml = REXML::Document.new(@out)
        element = REXML::XPath.first(rexml, '/member')
        assert_kind_of REXML::Element, element
        assert_equal 'member', element.name
        assert_equal 'node', REXML::XPath.first(rexml, '/member/@type').value
        assert_equal '18',   REXML::XPath.first(rexml, '/member/@ref').value
        assert_equal 'foo',  REXML::XPath.first(rexml, '/member/@role').value
    end

    # <relation id="16" user="relator" timestamp="2000-01-01T00:00:00Z">
    #   <member type="way" ref="123" role="foo"/>
    # </relation>
    def test_relation
        relation = OSM::Relation.new(16, 'relator', '2000-01-01T00:00:00Z')
        relation.members << OSM::Member.new('way', 123, 'foo')
        relation.to_xml(@doc)

        rexml = REXML::Document.new(@out)
        element = REXML::XPath.first(rexml, '/relation')
        assert_kind_of REXML::Element, element
        assert_equal 'relation', element.name

        member = REXML::XPath.first(element, './[1]')
        assert_kind_of REXML::Element, member
        assert_equal 'member', member.name

        assert_equal 'way', REXML::XPath.first(element, 'member/@type').value
        assert_equal '123', REXML::XPath.first(element, 'member/@ref').value
        assert_equal 'foo', REXML::XPath.first(element, 'member/@role').value
    end

    # <osm version="0.6" generator="test">
    #   <node id="-1"/>
    #   <way id="-2"/>
    #   <relation id="-3"/>
    # </osm>
    def test_database
        db = OSM::Database.new
        db << OSM::Node.new
        db << OSM::Way.new
        db << OSM::Relation.new
        db.to_xml(@doc, 'test')

        rexml = REXML::Document.new(@out)
        element = REXML::XPath.first(rexml, '/osm')
        assert_kind_of REXML::Element, element
        assert_equal 'osm', element.name

        assert_equal '0.6',  REXML::XPath.first(element, '/osm/@version').value
        assert_equal 'test', REXML::XPath.first(element, '/osm/@generator').value

        assert_equal 'node',     REXML::XPath.first(element, '/osm/[1]').name
        assert_equal 'way',      REXML::XPath.first(element, '/osm/[2]').name
        assert_equal 'relation', REXML::XPath.first(element, '/osm/[3]').name
    end

end
