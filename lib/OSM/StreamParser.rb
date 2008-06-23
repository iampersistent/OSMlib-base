
require 'OSM/objects'
require 'OSM/Database'

# Namespace for modules and classes related to the OpenStreetMap project.
module OSM

    # This exception is raised by OSM::StreamParser when the OSM file
    # has an unknown version.
    class VersionError < StandardError
    end

end

require "OSM/StreamParser/#{OSM::XMLPARSER}"

module OSM

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

end

