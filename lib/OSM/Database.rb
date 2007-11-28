
require 'OSM/objects.rb'

module OSM

    # An OSM database. It holds nodes, ways and relations in memory.
    class Database

        attr_accessor :version

        # Create an empty database.
        def initialize
            clear
        end

        # Delete all nodes, ways and relations from the database.
        # You should call this before deleting a database to break
        # internal loop references.
        def clear
            @nodes     = Hash.new
            @ways      = Hash.new
            @relations = Hash.new
        end

        # Add a Node to the database.
        def add_node(node)
            @nodes[node.id.to_i] = node
            node.db = self
        end

        # Add a Way to the database.
        def add_way(way)
            @ways[way.id.to_i] = way
            way.db = self
        end

        # Add a Relation to the database.
        def add_relation(relation)
            @relations[relation.id.to_i] = relation
            relation.db = self
        end

        # Get node from db with given ID. Returns nil if there is no node
        # with this ID.
        def get_node(id)
            @nodes[id.to_i]
        end

        # Get way from db with given ID. Returns nil if there is no way
        # with this ID.
        def get_way(id)
            @ways[id.to_i]
        end

        # Get relation from db with given ID. Returns nil if there is no relation
        # with this ID.
        def get_relation(id)
            @relations[id.to_i]
        end

        # Add an object (Node, Way, or Relation) to the database.
        #
        # call-seq: db << object -> db
        #
        def <<(object)
            case object
                when OSM::Node     then add_node(object)
                when OSM::Way      then add_way(object)
                when OSM::Relation then add_relation(object)
                else raise ArgumentError.new('Can only add objects of classes OSM::Node, OSM::Way, or OSM::Relation')
            end
            self
        end

    end

end
