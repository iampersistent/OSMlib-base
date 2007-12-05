#  OSM/StreamParser.rb

require 'rubygems'
require 'xml/libxml'

require 'OSM/objects'
require 'OSM/Database'

# Namespace for modules and classes related to the OpenStreetMap project.
module OSM

    # This exception is raised when the OSM file has the wrong version.
    class VersionError < Exception
    end

    # Stream parser for OpenStreetMap .osm files.
    class StreamParser

        def initialize(filename, db=nil)
            @context = nil
            @db = db

            @sax_parser = XML::SaxParser.new
            @sax_parser.filename = filename

            @sax_parser.on_start_document { start_document if respond_to?(:start_document) }
            @sax_parser.on_end_document { end_document if respond_to?(:end_document) }

            @sax_parser.on_start_element { |name, attr_hash|
                case name
                    when 'osm'      then _start_osm(attr_hash)
                    when 'node'     then _start_node(attr_hash)
                    when 'way'      then _start_way(attr_hash)
                    when 'relation' then _start_relation(attr_hash)
                    when 'tag'      then _tag(attr_hash)
                    when 'nd'       then _nd(attr_hash)
                    when 'member'   then _member(attr_hash)
                end
            }

            @sax_parser.on_end_element { |name|
                case name
                    when 'node'     then _end_node()
                    when 'way'      then _end_way()
                    when 'relation' then _end_relation()
                end
            }
        end

        # Run the parser
        def parse
            @sax_parser.parse
        end

        private

        def _start_osm(attr_hash)
            if attr_hash['version'] != '0.5'
                raise OSM::VersionError, 'OSM::StreamParser only understands OSM file version 0.5'
            end
        end

        def _start_node(attr_hash)
            @context = OSM::Node.new(attr_hash['id'], attr_hash['user'], attr_hash['timestamp'], attr_hash['lon'], attr_hash['lat'])
        end

        def _end_node()
            if respond_to?(:node)
                @db << @context if node(@context) && ! @db.nil?
            end
        end

        def _start_way(attr_hash)
            @context = OSM::Way.new(attr_hash['id'], attr_hash['user'], attr_hash['timestamp'])
        end

        def _end_way()
            if respond_to?(:way)
                @db << @context if way(@context) && ! @db.nil?
            end
        end

        def _start_relation(attr_hash)
            @context = OSM::Relation.new(attr_hash['id'], attr_hash['user'], attr_hash['timestamp'])
        end

        def _end_relation()
            if respond_to?(:relation)
                @db << @context if relation(@context) && ! @db.nil?
            end
        end

        def _nd(attr_hash)
            @context.nodes << attr_hash['ref']
        end

        def _tag(attr_hash)
            if respond_to?(:tag)
                return unless tag(@context, attr_hash['k'], attr_value['v'])
            end
            @context.add_tags( attr_hash['k'] => attr_hash['v'] )
        end

        def _member(attr_hash)
            new_member = OSM::Member.new(attr_hash['type'], attr_hash['ref'], attr_hash['role'])
            if respond_to?(:member)
                return unless member(@context, new_member)
            end
            @context.members << new_member
        end

    end

end

