# Contains the OSM::StreamParser and OSM::Callbacks classes.

require 'rubygems'
begin
    require 'xml/libxml'
rescue LoadError
    require 'libxml'
end

require 'OSM/objects'
require 'OSM/Database'

# Namespace for modules and classes related to the OpenStreetMap project.
module OSM

    # This exception is raised by OSM::StreamParser when the OSM file
    # has an unknown version.
    class VersionError < StandardError
    end

    # Implements the callbacks called by OSM::StreamParser while parsing the OSM
    # XML file.
    #
    # To create your own behaviour, create a subclass of this class and (re)define
    # the following methods:
    #
    #   node(node) - see below
    #   way(way) - see below
    #   relation(relation) - see below
    #
    #   start_document() - called once at start of document
    #   end_document() - called once at end of document
    #
    #   result() - see below
    #
    class Callbacks

        include XML::SaxParser::Callbacks

        # the OSM::Database used to store objects in
        attr_accessor :db

        def on_start_document   # :nodoc:
            start_document if respond_to?(:start_document)
        end

        def on_end_document     # :nodoc:
            end_document if respond_to?(:end_document)
        end

        def on_start_element(name, attr_hash)   # :nodoc:
            case name
                when 'osm'      then _start_osm(attr_hash)
                when 'node'     then _start_node(attr_hash)
                when 'way'      then _start_way(attr_hash)
                when 'relation' then _start_relation(attr_hash)
                when 'tag'      then _tag(attr_hash)
                when 'nd'       then _nd(attr_hash)
                when 'member'   then _member(attr_hash)
            end
        end

        def on_end_element(name)    # :nodoc:
            case name
                when 'node'     then _end_node()
                when 'way'      then _end_way()
                when 'relation' then _end_relation()
            end
        end

        # Overwrite this in a derived class. The default behaviour is to do nothing
        # but to store all node objects in a OSM::Database if one was supplied when
        # creating the OSM::StreamParser object.
        def node(node)
            true
        end

        # Overwrite this in a derived class. The default behaviour is to do nothing
        # but to store all way objects in a OSM::Database if one was supplied when
        # creating the OSM::StreamParser object.
        def way(way)
            true
        end

        # Overwrite this in a derived class. The default behaviour is to do nothing
        # but to store all relation objects in a OSM::Database if one was supplied when
        # creating the OSM::StreamParser object.
        def relation(relation)
            true
        end

        # Overwrite this in a derived class. Whatever this method returns will be
        # returned from the OSM::StreamParser#parse method.
        def result
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
            @db << @context if node(@context) && ! @db.nil?
        end

        def _start_way(attr_hash)
            @context = OSM::Way.new(attr_hash['id'], attr_hash['user'], attr_hash['timestamp'])
        end

        def _end_way()
            @db << @context if way(@context) && ! @db.nil?
        end

        def _start_relation(attr_hash)
            @context = OSM::Relation.new(attr_hash['id'], attr_hash['user'], attr_hash['timestamp'])
        end

        def _end_relation()
            @db << @context if relation(@context) && ! @db.nil?
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

    # This callback class for OSM::StreamParser collects all objects found in the XML in
    # an array and the OSM::StreamParser#parse method returns this array.
    #
    #   cb = OSM::ObjectListCallbacks.new
    #   parser = OSM::StreamParser.new(:filename => 'filename.osm', :callbacks => cb)
    #   objects = parser.parse
    #
    class ObjectListCallbacks < Callbacks

        def start_document
            @list = []
        end

        def node(node)
            @list << node
        end

        def way(way)
            @list << way
        end

        def relation(relation)
            @list << relation
        end

        def result
            @list
        end

    end

    # Stream parser for OpenStreetMap XML files.
    class StreamParser

        # Create new StreamParser object. Only argument is a hash.
        #
        # call-seq: OSM::StreamParser.new(:filename => 'filename.osm')
        #           OSM::StreamParser.new(:string => '...')
        #
        # The hash keys:
        #   :filename  => name of XML file
        #   :string    => XML string
        #   :db        => an OSM::Database object
        #   :callbacks => an OSM::Callbacks object (or more likely from a derived class)
        #                 if none was given a new OSM:Callbacks object is created
        #
        # You can only use :filename or :string, not both.
        def initialize(options)
            @filename = options[:filename]
            @string = options[:string]
            @db = options[:db]
            @context = nil

            if (@filename.nil? && @string.nil?) || ((!@filename.nil?) && (!@string.nil?))
                raise ArgumentError.new('need either :filename or :string argument')
            end

            @callbacks = options[:callbacks].nil? ? OSM::Callbacks.new : options[:callbacks]
            @callbacks.db = @db

            @sax_parser = XML::SaxParser.new
            if @filename.nil?
                @sax_parser.string = @string
            else
                @sax_parser.filename = @filename
            end
            @sax_parser.callbacks = @callbacks
        end

        # Run the parser. Return value is the return value of the OSM::Callbacks#result method.
        def parse
            @sax_parser.parse
            @callbacks.result
        end

    end

end

