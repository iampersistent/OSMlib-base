$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'StreamParser.rb')
require 'test/unit'
require 'rexml/document'
require 'rubygems'
require 'builder'

class TestParser < OSM::StreamParser

    include Test::Unit::Assertions

    def node(node)
        assert_kind_of OSM::Node, node
    end

    def way(way)
    end

    def relation(relation)
    end

end

class ParserTest < Test::Unit::TestCase

    def setup
        @parser = TestParser.new('test/test.osm')
    end

    def test_create
        assert_kind_of OSM::StreamParser, @parser
        @parser.parse
    end

end
