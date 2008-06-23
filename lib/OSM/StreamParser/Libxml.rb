# Contains the OSM::StreamParser and OSM::Callbacks classes using LibXML.

require 'rubygems'
begin
    require 'xml/libxml'
rescue LoadError
    require 'libxml'
end

# Namespace for modules and classes related to the OpenStreetMap project.
module OSM

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
    class Callbacks < CallbacksBase

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

    end

    # Stream parser for OpenStreetMap XML files.
    class StreamParser < StreamParserBase

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
            super(options)

            @parser = XML::SaxParser.new
            if @filename.nil?
                @parser.string = @string
            else
                @parser.filename = @filename
            end
            @parser.callbacks = @callbacks
        end

    end

end

