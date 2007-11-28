
# Namespace for modules and classes related to the OpenStreetMap project.
module OSM

    # This is a virtual parent class for the OSM objects Node, Way and Relation.
    class OSMObject

        # Unique ID
        attr_reader :id

        # The user who last edited this object (as read from file, it is not updated by operations to this object)
        attr_accessor :user

        # Last change of this object (as read from file, it is not updated by operations to this object)
        attr_reader :timestamp

        # A Hash of tags
        attr_reader :tags

        # The database this object is in
        attr_accessor :db

        def initialize(id, user=nil, timestamp=nil) #:nodoc:
            raise NotImplementedError.new('OSMObject is a virtual base class for the Node, Way, and Relation classes') if self.class == OSM::OSMObject

            @id = _check_id(id)
            @user = user
            @timestamp = _check_timestamp(timestamp) unless timestamp.nil?
            @db = nil
            @tags = Hash.new
        end

        # Set timestamp for this object.
        def timestamp=(timestamp)
            @timestamp = _check_timestamp(timestamp)
        end

        # Add one or more tags to this object.
        #
        # call-seq: add_tags(Hash) -> OSMObject
        #
        def add_tags(new_tags)
            new_tags.each do |k, v|
                self.tags[k.to_s] = v
            end
            self
        end

        # Has this object any tags?
        def is_tagged?
            ! @tags.empty?
        end

        # Return geometry of this feature.
        #
        # call-seq: geometry() -> GeoRuby::SimpleFeatures::Geometry
        def geometry
            @feature
        end

        def shape(fields)
            f = Hash.new
            fields.each do |key, value|
                f[key.to_s] = value
            end
            GeoRuby::Shp4r::ShpRecord.new(geometry, f)
        end

        # All other methods are mapped so its easy to access tags: For instance obj.name
        # is the same as obj.tags['name']. This works for getting and setting tags.
        def method_missing(method, *args)
            if method.to_s.slice(-1, 1) == '='
                if args.size != 1
                    raise ArgumentError.new("wrong number of arguments (#{args.size} for 1)")
                end
                tags[method.to_s.chop] = args[0]
            else
                if args.size > 0
                    raise ArgumentError.new("wrong number of arguments (#{args.size} for 0)")
                end
                tags[method.to_s]
            end
        end
 
        private

        def _check_id(id)
            if id.kind_of?(Integer)
                return id
            elsif id.kind_of?(String)
                raise ArgumentError, "ID must be an integer" unless id =~ /^[0-9]+$/
                return id.to_i
            else
                raise ArgumentError, "ID must be integer or string with integer"
            end
        end

        def _check_timestamp(timestamp)
            if timestamp !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}[+-][0-9]{2}:[0-9]{2}$/
                raise ArgumentError, "Timestamp is in wrong format (must be 'yyyy-mm-ddThh:mm:ss[+-]mm:ss')"
            end
            timestamp
        end

        def _check_lon(lon)
            if lon.kind_of?(Numeric)
                return lon.to_s
            elsif lon.kind_of?(String)
                return lon
            else
                raise ArgumentError, "'lon' must be number or string containing number"
            end
        end

        def _check_lat(lat)
            if lat.kind_of?(Numeric)
                return lat.to_s
            elsif lat.kind_of?(String)
                return lat
            else
                raise ArgumentError, "'lat' must be number or string containing number"
            end
        end

    end

    # OpenStreetMap Node.
    class Node < OSMObject

        # Longitude in decimal degrees
        attr_reader :lon
        
        # Latitude in decimal degrees
        attr_reader :lat

        # Create new Node object.
        def initialize(id, user=nil, timestamp=nil, lon=nil, lat=nil)
            @lon = _check_lon(lon) unless lon.nil?
            @lat = _check_lat(lat) unless lat.nil?
            super(id, user, timestamp)
        end

        # Set longitude.
        def lon=(lon)
            @lon = _check_lon(lon)
        end

        # Set latitude.
        def lat=(lat)
            @lat = _check_lat(lat)
        end

        # Return string version of this Node object.
        # 
        # call-seq: to_s -> String
        #
        def to_s
            "#<OSM::Node id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\" lon=\"#{@lon}\" lat=\"#{@lat}\">"
        end

    end

    # OpenStreetMap Way.
    class Way < OSMObject

        # Array of node IDs in this way.
        attr_reader :nodes

        # Create new Way object.
        def initialize(id, user=nil, timestamp=nil, nodes=[])
            @nodes = nodes
            super(id, user, timestamp)
        end

        # Return string version of this Way object.
        # 
        # call-seq: to_s -> String
        #
        def to_s
            "#<OSM::Way id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\">"
        end

    end

    # OpenStreetMap Relation.
    class Relation < OSMObject

        # Array of Member objects
        attr_reader :members

        # Create new Relation object.
        def initialize(id, user=nil, timestamp=nil, members=[])
            @members = members
            super(id, user, timestamp)
        end

        # Add one or more members to this relation.
        #
        # call-seq: relation << [member1, member2, ...] -> Relation
        #
        def <<(*new_members)
            @members.push(*new_members)
            self
        end

        # Return string version of this Relation object.
        # 
        # call-seq: to_s -> String
        #
        def to_s
            "#<OSM::Relation id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\">"
        end

    end

    # A member of an OpenStreetMap Relation.
    class Member

        # Role this member has in the relationship
        attr_accessor :role

        # Type of referenced object (can be 'node', 'way', or 'relation')
        attr_reader :type

        # ID of referenced object
        attr_reader :ref

        # Create a new Member object. Type can be one of 'node', 'way' or 'relation'. Ref is the
        # ID of the corresponding Node, Way, or Relation. Role is a freeform string and can be empty.
        def initialize(type, ref, role='')
            if type !~ /^(node|way|relation)$/
                raise ArgumentError.new("type must be 'node', 'way', or 'relation'")
            end
            if ref.to_s !~ /^[0-9]+$/
                raise ArgumentError
            end
            @type = type
            @ref  = ref.to_i
            @role = role
        end

    end

end

