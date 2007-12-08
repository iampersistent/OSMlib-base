# Contains classes for OpenStreetMap objects: OSM::OSMObject (virtual parent class), OSM::Node, OSM::Way, OSM::Relation, OSM::Member

# Namespace for modules and classes related to the OpenStreetMap project.
module OSM

    # This is a virtual parent class for the OSM objects Node, Way and Relation.
    class OSMObject

        # To give out unique IDs to the objects we keep a counter that gets decreased every time we use it. See
        # the #_next_id method.
        @@id = 0

        # Unique ID
        attr_reader :id

        # The user who last edited this object (as read from file, it is not updated by operations to this object)
        attr_accessor :user

        # Last change of this object (as read from file, it is not updated by operations to this object)
        attr_reader :timestamp

        # Tags for this object
        attr_reader :tags

        # The OSM::Database this object is in (if any)
        attr_accessor :db

        def initialize(id, user, timestamp) #:nodoc:
            raise NotImplementedError.new('OSMObject is a virtual base class for the Node, Way, and Relation classes') if self.class == OSM::OSMObject

            @id = id.nil? ? _next_id : _check_id(id)
            @user = user
            @timestamp = _check_timestamp(timestamp) unless timestamp.nil?
            @db = nil
            @tags = Tags.new
        end

        # Create an error when somebody tries to set the ID. (We need this here because otherwise method_missing will be called.)
        def id=(id) # :nodoc:
            raise NotImplementedError.new('id can not be changed once the object was created')
        end

        # Set timestamp for this object.
        def timestamp=(timestamp)
            @timestamp = _check_timestamp(timestamp)
        end

        # The list of attributes for this object
        def attribute_list # :nodoc:
            [:id, :user, :timestamp]
        end

        # Returns a hash of all non-nil attributes of this object.
        #
        # Keys of this hash are <tt>:id</tt>, <tt>:user</tt>, and <tt>:timestamp</tt>. For a Node also <tt>:lon</tt> and <tt>:lat</tt>.
        #
        # call-seq: attributes -> Hash
        #
        def attributes
            attrs = Hash.new
            attribute_list.each do |attribute|
                value = self.send(attribute)
                attrs[attribute] = value unless value.nil?
            end
            attrs
        end

        # Get tag value
        def [](key)
            tags[key]
        end

        # Set tag
        def []=(key, value)
            tags[key] = value
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
        #
        # call-seq: is_tagged?
        #
        def is_tagged?
            ! @tags.empty?
        end

        # Return geometry of this feature.
        #
        # call-seq: geometry -> GeoRuby::SimpleFeatures::Geometry
        #
        def geometry # XXX needs rewriting
            @feature
        end

        # Create a new GeoRuby::Shp4r::ShpRecord with the geometry of this object and
        # the given attributes.
        #
        # attributes:: Hash with attributes
        #
        # call-seq: shape(attributes) -> GeoRuby::Shp4r::ShpRecord
        #
        # Example:
        #   node = Node(nil, nil, nil, 7.84, 54.34)
        #   node.shape(:type => 'Pharmacy', :name => 'Hyde Park Pharmacy')
        #
        def shape(attributes)
            fields = Hash.new
            attributes.each do |key, value|
                fields[key.to_s] = value
            end
            GeoRuby::Shp4r::ShpRecord.new(geometry, fields)
        end

        # All other methods are mapped so its easy to access tags: For instance obj.name
        # is the same as obj.tags['name']. This works for getting and setting tags.
        #
        #   node = OSM::Node.new
        #   node.add_tags( 'highway' => 'residential', 'name' => 'Main Street' )
        #   node.highway                   #=> 'residential'
        #   node.highway = 'unclassified'  #=> 'unclassified'
        #   node.name                      #=> 'Main Street'
        #
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

        # Return next free ID
        def _next_id
            @@id -= 1
            @@id
        end

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
            if timestamp !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|([+-][0-9]{2}:[0-9]{2}))$/
                raise ArgumentError, "Timestamp is in wrong format (must be 'yyyy-mm-ddThh:mm:ss(Z|[+-]mm:ss)')"
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
        #
        # If +id+ is +nil+ a new unique negative ID will be allocated.
        def initialize(id=nil, user=nil, timestamp=nil, lon=nil, lat=nil)
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

        # List of attributes for a Node
        def attribute_list
            [:id, :user, :timestamp, :lon, :lat]
        end

        # Return string version of this node.
        # 
        # call-seq: to_s -> String
        #
        def to_s
            "#<OSM::Node id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\" lon=\"#{@lon}\" lat=\"#{@lat}\">"
        end

        # Return XML for this node. This method uses the XML Builder library. The only parameter is the builder object.
        def to_xml(xml)
            xml.node(attributes) do |xml|
                tags.to_xml(xml)
            end
        end

    end

    # OpenStreetMap Way.
    class Way < OSMObject

        # Array of node IDs in this way.
        attr_reader :nodes

        # Create new Way object.
        #
        # If +id+ is +nil+ a new unique negative ID will be allocated.
        def initialize(id=nil, user=nil, timestamp=nil, nodes=[])
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

        # Return XML for this way. This method uses the Builder library. The only parameter ist the builder object.
        def to_xml(xml)
            xml.way(attributes) do |xml|
                nodes.each do |node|
                    xml.nd(:ref => node.id)
                end
                tags.to_xml(xml)
            end
        end

    end

    # OpenStreetMap Relation.
    class Relation < OSMObject

        # Array of Member objects
        attr_reader :members

        # Create new Relation object.
        #
        # If +id+ is +nil+ a new unique negative ID will be allocated.
        def initialize(id=nil, user=nil, timestamp=nil, members=[])
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

        # This method is here to overwrite the shape method in the parent class.
        def shape(attributes) # :nodoc:
            raise NoMethodError.new("Relations don't have a shape, so you can't call Relation#shape")
        end

        # Return string version of this Relation object.
        # 
        # call-seq: to_s -> String
        #
        def to_s
            "#<OSM::Relation id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\">"
        end

        # Return XML for this relation. This method uses the Builder library. The only parameter ist the builder object.
        def to_xml(xml)
            xml.relation(attributes) do |xml|
                members.each do |member|
                    member.to_xml(xml)
                end
                tags.to_xml(xml)
            end
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

        # Return XML for this way. This method uses the Builder library. The only parameter ist the builder object.
        def to_xml(xml)
            xml.member(:type => type, :ref => ref, :role => role)
        end

    end

    # A collection of OSM tags which can be attached to a Node, Way, or Relation. It is a subclass of Hash.
    class Tags < Hash

        # Return XML for these tags. This method uses the Builder library. The only parameter ist the builder object.
        def to_xml(xml)
            each do |key, value|
                xml.tag(:k => key, :v => value)
            end
        end

    end

end

