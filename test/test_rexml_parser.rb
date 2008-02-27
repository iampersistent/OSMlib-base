$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'StreamParserREXML.rb')
require 'test/unit'
#require 'rexml/document'
require 'rubygems'
require 'builder'

class CallbacksREXMLForTests < OSM::CallbacksREXML

    include Test::Unit::Assertions

    def node(node)
        assert_kind_of OSM::Node, node
    end

    def way(way)
    end

    def relation(relation)
    end

end

class TestParserREXML < Test::Unit::TestCase

    def test_create_fail
        assert_raise ArgumentError do
            OSM::StreamParserREXML.new
        end
        assert_raise ArgumentError do
            OSM::StreamParserREXML.new(:filename => 'foo', :string => 'bar')
        end
    end

    def test_create_with_file
        parser = OSM::StreamParserREXML.new(:filename => 'test/test.osm', :callbacks => CallbacksREXMLForTests.new)
        assert_kind_of OSM::StreamParserREXML, parser
        parser.parse
    end

    def test_create_with_string
        parser = OSM::StreamParserREXML.new(:callbacks => CallbacksREXMLForTests.new, :string => %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.5" generator="OpenStreetMap server">
  <node id="17905203" lat="48.9614113" lon="8.3046066" user="test" visible="true" timestamp="2007-04-09T22:16:39+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
</osm>
        })
        assert_kind_of OSM::StreamParserREXML, parser
        parser.parse
    end

end
