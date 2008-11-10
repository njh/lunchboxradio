#--
# =============================================================================
# Copyright (c) 2006 Pau Garcia i Quiles (pgquiles@elpauer.org)
# All rights reserved.
#
# This library may be used only as allowed by either the Ruby license (or, by
# association with the Ruby license, the GPL). See the "doc" subdirectory of
# the XSPF distribution for the texts of these licenses.
# -----------------------------------------------------------------------------
# XSPF for Ruby website : http://xspf.rubyforge.org
# =============================================================================
#++

require 'rexml/document'

# :main: USAGE

module MetaGen #:nodoc:

  # define the method
  def self.add_method(klass, meth_name, body, meth_rdoc)
    code = <<-CODE
    # #{meth_rdoc}
    def #{meth_name.downcase}
      @#{meth_name}
    end
    
    def #{meth_name.downcase}=(value)
      @#{meth_name.downcase} = value
    end

    private
    def parse_#{meth_name.downcase}
      begin
        #{body}
      rescue NoMethodError
        return nil
      end
    end
    CODE
    
    klass.module_eval(code)
 
    # hook to write klass + name attrib to a file
    if $META_RDOC
      open($META_RDOC, 'a+') do |f|
        f.puts("class #{klass}\n #{code}\n end")
      end
    end
    
  end

  # output in different formats
  # FIXME Only works in parse mode, not in generation mode. 
  #def self.add_output_format(klass, format, meth_rdoc)
  #  xslt_path = "'#{File.join( File.dirname(__FILE__), %Q{xspf2#{format}.xsl} )}'"
  #  code = <<-CODE
  #    # #{meth_rdoc}
  #    def to_#{format}
  #      xslt = XML::XSLT.new
  #      xslt.xml = self.to_xml
  #      xslt.xsl = REXML::Document.new( File.new( #{xslt_path} ) )
  #      xslt.serve
  #    end
  #  CODE
  #  
  #  klass.module_eval(code)
  ## 
  #  if $META_RDOC
  #    open($META_RDOC, 'a+') do |f|
  #      f.puts("class #{klass}\n #{code}\n end")
  #    end
  #  end
#
  #end
  
end

class XSPF

  attr_reader :xspf

  #:stopdoc:
  ATTRIBUTES = %w{ version encoding }
  VERSION_RDOC = 'Version for the XML document or _nil_ if not defined'
  ENCODING_RDOC = 'Encoding of the XML document or _nil_ if not defined'
  
  OUTPUT_FORMATS = %w{ m3u html smil rdf soundblox }
  M3U_RDOC = 'Creates a .m3u playlist from the XSPF document. This method makes use of the official XSPF to M3U XSLT transformation by Lucas Gonze.'
  HTML_RDOC = 'Outputs the playlist as an HTML page. This method makes use of the official XSPF to HTML XSLT transformation by Lucas Gonze.'
  SMIL_RDOC = 'Creates a .smil playlist from the XSPF document. This method makes use of the official XSPF to SMIL XSLT transformation by Lucas Gonze.'
  SOUNDBLOX_RDOC = 'Creates a SoundBlox playlist from the XSPF document. This method makes use of the official XSPF to SoundBlox XSLT tranformation by Lucas Gonze.'
  RDF_RDOC = 'Creates a RDF feed from the XSPF document. This method makes use of the XSPF to RDF XSLT transformation by Libby Miller.'

  ATTRIBUTES.each do |attrib|
    MetaGen.add_method(self, attrib, "@xspf.#{attrib}", eval(attrib.upcase + '_RDOC').to_s )
  end

  #OUTPUT_FORMATS.each do |format|
  #  MetaGen.add_output_format(self, format, eval(format.upcase + '_RDOC').to_s )
  #end

  #:startdoc:
  
  # Creates a XSPF object from a file or string (parse mode) or from a hash or nil (generation mode).
  #
  # Possible keys in the hash: :version, :encoding
  def initialize(source = nil)
    if ( source.nil? || source.instance_of?(Hash) ) then
        @version = if source.nil? || !source.has_key?(:version)
                     '1.0'
                   else
                     source[:version]
                   end
        @encoding = if source.nil? || !source.has_key?(:encoding)
                      'UTF-8'
                    else
                      source[:encoding]
                    end
        @playlist = nil
        @playlist = if !source.nil? && source.has_key?(:playlist) then
                        if source[:playlist].instance_of?(XSPF::Playlist)
                            source[:playlist]
                        else
                          raise(TypeError, 'You must pass a file/string (parsing mode) or a hash/nothing (generator mode) as argument to XSPF#new')
                        end
                    end

    elsif ( source.instance_of?(File) || source.instance_of?(String) ) then
        @xspf = REXML::Document.new(source)
        ATTRIBUTES.each do |attrib|
          eval('@' + attrib + '= parse_' + attrib)
        end

        @playlist = XSPF::Playlist.new(self)
        
    else
      raise(TypeError, 'You must pass a file/string (parsing mode) or a hash/nothing (generator mode) as argument to XSPF#new')
    end
  end

  # A XSPF::Playlist object
  def playlist
    @playlist
  end

  def playlist=(value)
    raise(TypeError, 'The playlist must be an instance of XSPF::Playlist') unless value.instance_of?(XSPF::Playlist)
    @playlist = value
  end

  # Exports the XSPF object to XML
  def to_xml
    xml = REXML::Document.new
    xml << REXML::XMLDecl.new(@version, @encoding)
    xml << REXML::Document.new(@playlist.to_xml) unless @playlist.nil?
    xml.to_s
  end

  # The <playlist> section of the XSPF document (outputs XML code). This method is only used while parsing.
  protected
  def playlist_xml
    @xspf.root
  end

end

class XSPF::Playlist < XSPF

  attr_reader :playlist

  #:stopdoc:
  ATTRIBUTES = %w{ xmlns version }
  ELEMENTS = %w{ title creator annotation info location identifier image date license attribution extension }
  ATTRIBUTE_AND_ELEMENT = %w{ link meta }
  ATTRIBUTION_CHILD_ELEMENTS = %w{ location identifier }
  EXTENSION_CHILD_ELEMENTS = %w{ application content }
  
  XMLNS_RDOC = 'The XML namespace. It must be http://xspf.org/ns/0/ for a valid XSPF document.'
  XMLNS_DEFAULT = 'http://xspf.org/ns/0/'
  VERSION_RDOC = 'The XSPF version. It may be 0 or 1, although 1 is strongly advised.'
  VERSION_DEFAULT = '1'
  TITLE_RDOC = 'A human-readable title for the playlist. xspf:playlist elements MAY contain exactly one.'
  CREATOR_RDOC = 'Human-readable name of the entity (author, authors, group, company, etc) that authored the playlist. XSPF::Playlist objects MAY contain exactly one.'
  ANNOTATION_RDOC = 'A human-readable comment on the playlist. This is character data, not HTML, and it may not contain markup. XSPF::Playlist objects elements MAY contain exactly one.'
  INFO_RDOC = 'URL of a web page to find out more about this playlist. Likely to be homepage of the author, and would be used to find out more about the author and to find more playlists by the author. XSPF::Playlist objects MAY contain exactly one.'
  LOCATION_RDOC = 'Source URL for this playlist. XSPF::Playlist objects MAY contain exactly one.'
  IDENTIFIER_RDOC = 'Canonical ID for this playlist. Likely to be a hash or other location-independent name. MUST be a legal URN. XSPF::Playlist objects MAY contain exactly one.'
  IMAGE_RDOC = 'URL of an image to display if XSPF::Playlist#image return nil. XSPF::Playlist objects MAY contain exactly one.'
  DATE_RDOC = 'Creation date (not last-modified date) of the playlist, formatted as a XML schema dateTime. XSPF::Playlist objects MAY contain exactly one.'
  LICENSE_RDOC = 'URL of a resource that describes the license under which this playlist was released. XSPF::Playlist objects MAY contain zero or one license element.'
  ATTRIBUTION_RDOC = 'An ordered list of URIs. The purpose is to satisfy licenses allowing modification but requiring attribution. If you modify such a playlist, move its XSPF::Playlist#location or XSPF::Playlist#identifier element to the top of the items in the XSPF::Playlist#attribution element. XSPF::Playlist objects MAY contain exactly one attribution element. Please note that currently XSPF for Ruby does not parse the contents of XSPF::Playlist#attribution.'
  EXTENSION_RDOC = 'The extension element allows non-XSPF XML to be included in XSPF documents without breaking XSPF validation. The purpose is to allow nested XML, which the meta and link elements do not. XSPF::Playlist objects MAY contain zero or more extension elements but currently XSPF for Ruby returns only the first one.'
  LINK_REL_RDOC = 'The link element allows non-XSPF web resources to be included in XSPF documents without breaking XSPF validation. A valid _link_ element has a _rel_ attribute and a _content_ element, obtained with XSPF::Playlist#link_rel and XSPF::Playlist#link_content respectively. XSPF::Playlist objects MAY contain zero or more link elements, but currently XSPF for Ruby returns only the first one.'
  LINK_CONTENT_RDOC = 'The link element allows non-XSPF web resources to be included in XSPF documents without breaking XSPF validation. A valid _link_ element has a _rel_ attribute and a _content_ element, obtained with XSPF::Playlist#link_rel and XSPF::Playlist#link_content respectively. XSPF::Playlist objects MAY contain zero or more meta elements, but currently XSPF for Ruby returns only the first one.'
  META_REL_RDOC = 'The meta element allows non-XSPF metadata to be included in XSPF documents without breaking XSPF validation. A valid _meta_ element has a _rel_ attribute and a _content_ element, obtained with XSPF::Playlist#meta_rel and XSPF::Playlist#meta_content respectively. XSPF::Playlist objects MAY contain zero or more meta elements, but currently XSPF for Ruby returns only the first one.'
  META_CONTENT_RDOC = 'The meta element allows non-XSPF metadata to be included in XSPF documents without breaking XSPF validation. A valid _meta_ element has a _rel_ attribute and a _content_ element, obtained with XSPF::Playlist#meta_rel and XSPF::Playlist#meta_content respectively. XSPF::Playlist objects MAY contain zero or more meta elements, but currently XSPF for Ruby returns only the first one.'
  
# FIXME Currently we only return the first "link"
# FIXME Currently we only return the first "meta"
# FIXME Currently we only return the first "extension"
# TODO Parse "attribution"
# TODO Parse "extension"

  # Returns the value of the attribute or nil if the attribute is not present
  ATTRIBUTES.each do |attrib|
    MetaGen.add_method( self, attrib, "@playlist.root.attributes['#{attrib}']", eval(attrib.upcase + '_RDOC').to_s )
  end

  ELEMENTS.each do |element|
    MetaGen.add_method( self, element, "@playlist.elements['#{element}'].text", eval(element.upcase + '_RDOC').to_s )
  end

  ATTRIBUTE_AND_ELEMENT.each do |ae|
    MetaGen.add_method( self, "#{ae}_content", "@playlist.elements['#{ae}'].text", eval(ae.upcase + '_CONTENT_RDOC').to_s )
    MetaGen.add_method( self, "#{ae}_rel", "@playlist.elements['#{ae}'].attributes['rel']", eval(ae.upcase + '_REL_RDOC').to_s )
  end

  #:startdoc:
  
  # Creates a XSPF::Playlist from a XSPF document (parse mode) or from a hash of values (generation mode)
  #
  # Possible keys in the hash: :xmlns, :version, :title, :creator, :annotation, :info, :location, :identifier, :image, :date, :license, :attribution, :extension, :link_rel, :link_content, :meta_rel, :meta_content
  def initialize(source = nil)

    if ( source.instance_of?(Hash) || source.nil? ) then

      ATTRIBUTES.each do |attrib|
        add_instance_variable(source, attrib)
      end

      ELEMENTS.each do |element|
        add_instance_variable(source, element)
      end

      ATTRIBUTE_AND_ELEMENT.each do |ae|
        add_instance_variable(source, "#{ae}_content" )
        add_instance_variable(source, "#{ae}_rel" )
      end

      @tracklist = if ( !source.nil? && source.has_key?(:tracklist) && source[:tracklist].instance_of?(XSPF::Tracklist) )
                      source[:tracklist]
                    else
                      nil
                    end

    elsif source.instance_of?(XSPF) then

      @playlist = source.playlist_xml

      ATTRIBUTES.each do |attrib|
        eval('@' + attrib.downcase + '= parse_' + attrib.downcase)
      end
  
      ELEMENTS.each do |element|
        eval('@' + element.downcase + '= parse_' + element.downcase)
      end

      ATTRIBUTE_AND_ELEMENT.each do |ae|
        eval('@' + ae.downcase + '_content = parse_' + ae.downcase + '_content')
        eval('@' + ae.downcase + '_rel = parse_' + ae.downcase + '_rel')
      end

      @tracklist = XSPF::Tracklist.new(self)

    else
      raise(TypeError, 'You must pass a XSPF object (parsing mode) or a hash (generator mode) as argument to XSPF::Playlist#new')
    end
    
  end

  # A XSPF::Tracklist object
  def tracklist
    @tracklist
  end

  def tracklist=(value)
    raise(TypeError, 'The tracklist must be an instance of XSPF::Tracklist') unless value.instance_of?(XSPF::Tracklist)
    @tracklist = value
  end

  alias :<< :tracklist=

  # Exports the XSPF::Playlist to XML (only the <playlist> section)
  def to_xml
  
    xml = REXML::Element.new('playlist')

    ATTRIBUTES.each do |attrib|
      # TODO Sure there is a nicer way to do evaluate this condition...
      unless eval('@' + attrib.downcase + '.nil?')
        xml.attributes[attrib] = eval('@' + attrib.downcase)
      end 
    end
    
    ELEMENTS.each do |element|
      # TODO Sure there is a nicer way to do evaluate this condition...
      unless eval('@' + element.downcase + '.nil?')
        el = REXML::Element.new(element)
        el.add_text( eval('@' + element.downcase) )
        xml.add_element(el)
      end 
    end

    ATTRIBUTE_AND_ELEMENT.each do |ae|
      # TODO Sure there is a nicer way to do evaluate this condition...
      unless eval('@' + ae.downcase + '_rel.nil? && @'+ ae.downcase + '_content.nil?')
        el = REXML::Element.new(ae.downcase)
        el.add_attribute('rel', eval('@' + ae.downcase + '_rel') )
        el.add_text( eval('@' + ae.downcase + '_content') )
        xml.add_element(el)
      end 
    end

    xml << REXML::Document.new(@tracklist.to_xml)
    
    xml.to_s
  
  end
  
  # The <trackList> section of the XSPF document (outputs XML code). This method is only used while parsing.
  protected
  def tracklist_xml  
    @playlist.elements['trackList']
  end

  private
  def add_instance_variable(hash, var)

    if !hash.nil? && hash.has_key?(var.downcase.to_sym)
      eval('@' + var.downcase + ' = \'' + hash[var.downcase.to_sym] + '\'')
    else
      eval('@' + var.downcase + ' = defined?(' + var.upcase + '_DEFAULT) ? ' + var.upcase + '_DEFAULT : nil')
    end

  end

end

class XSPF::Tracklist < XSPF::Playlist

  attr_reader :tracklist

  # Creates a XSPF::Tracklist from a XSPF::Playlist (parse mode) or without parameters (generation mode)
  def initialize(playlist=nil)
    if (playlist.instance_of?(Hash) || playlist.nil?) then
      @tracklist = ''
      @tracks = []
    else
      @tracklist = playlist.tracklist_xml
      @tracks = @tracklist.elements.collect { |track| XSPF::Track.new(track) }
    end
  end

  # Returns an array XSPF::Track objects
  def tracks
    @tracks
  end

  # Adds a new XSPF::Track to the XSPF::Tracklist
  def <<(track)
    @tracks << track
  end

  # Exports the XSPF::Tracklist to XML (only the <trackList> section)
  def to_xml
    xml = REXML::Element.new('trackList')
    @tracks.each { |t| xml << REXML::Document.new(t.to_xml) }
    xml.to_s
  end

end

class XSPF::Track

  attr_reader :track

  #:stopdoc:
  ELEMENTS = %w{ location identifier title creator annotation info image album trackNum duration extension }
  ATTRIBUTE_AND_ELEMENT = %w{ link meta }
  
  LOCATION_RDOC = 'URL of resource to be rendered. Probably an audio resource, but MAY be any type of resource with a well-known duration, such as video, a SMIL document, or an XSPF document. The duration of the resource defined in this element defines the duration of rendering. XSPF::Track objects MAY contain zero or more location elements, but a user-agent MUST NOT render more than one of the named resources. Currently, XSPF for Ruby returns only the first location.'
  IDENTIFIER_RDOC = 'Canonical ID for this resource. Likely to be a hash or other location-independent name, such as a MusicBrainz identifier or isbn URN (if there existed isbn numbers for audio). MUST be a legal URN. XSPF::Track objects elements MAY contain zero or more identifier elements, but currently XSPF for Ruby returns only the first one.'
  TITLE_RDOC = 'Human-readable name of the track that authored the resource which defines the duration of track rendering. This value is primarily for fuzzy lookups, though a user-agent may display it. XSPF::Track objects MAY contain exactly one.'
  CREATOR_RDOC = 'Human-readable name of the entity (author, authors, group, company, etc) that authored the resource which defines the duration of track rendering. This value is primarily for fuzzy lookups, though a user-agent may display it. XSPF::Track objects MAY contain exactly one.'
  ANNOTATION_RDOC = 'A human-readable comment on the track. This is character data, not HTML, and it may not contain markup. XSPF::Track objects MAY contain exactly one.'
  INFO_RDOC = 'URL of a place where this resource can be bought or more info can be found.'
  IMAGE_RDOC = 'URL of an image to display for the duration of the track. XSPF::Track objects MAY contain exactly one.'
  ALBUM_RDOC = 'Human-readable name of the collection from which the resource which defines the duration of track rendering comes. For a song originally published as a part of a CD or LP, this would be the title of the original release. This value is primarily for fuzzy lookups, though a user-agent may display it. XSPF::Track objects MAY contain exactly one.'
  TRACKNUM_RDOC = 'Integer with value greater than zero giving the ordinal position of the media on the XSPF::Track#album. This value is primarily for fuzzy lookups, though a user-agent may display it. XSPF::Track objects MAY contain exactly one. It MUST be a valid XML Schema nonNegativeInteger.'
  DURATION_RDOC = 'The time to render a resource, in milliseconds. It MUST be a valid XML Schema nonNegativeInteger. This value is only a hint -- different XSPF generators will generate slightly different values. A user-agent MUST NOT use this value to determine the rendering duration, since the data will likely be low quality. XSPF::Track objects MAY contain exactly one duration element.'
  EXTENSION_RDOC = 'The extension element allows non-XSPF XML to be included in XSPF documents without breaking XSPF validation. The purpose is to allow nested XML, which the meta and link elements do not. XSPF::Track objects MAY contain zero or more extension elements, but currently XSPF for Ruby returns only the first one.'
  LINK_REL_RDOC = 'The link element allows non-XSPF web resources to be included in XSPF documents without breaking XSPF validation. A valid _link_ element has a _rel_ attribute and a _content_ element, obtained with XSPF::Track#link_rel and XSPF::Track#link_content respectively. XSPF::Track objects MAY contain zero or more link elements, but currently XSPF for Ruby returns only the first one.'
  LINK_CONTENT_RDOC = 'The link element allows non-XSPF web resources to be included in XSPF documents without breaking XSPF validation. A valid _link_ element has a _rel_ attribute and a _content_ element, obtained with XSPF::Track#link_rel and XSPF::Track#link_content respectively. XSPF::Track objects MAY contain zero or more meta elements, but currently XSPF for Ruby returns only the first one.'
  META_REL_RDOC = 'The meta element allows non-XSPF metadata to be included in XSPF documents without breaking XSPF validation. A valid _meta_ element has a _rel_ attribute and a _content_ element, obtained with XSPF::Track#meta_rel and XSPF::Track#meta_content respectively. XSPF::Track objects MAY contain zero or more meta elements, but currently XSPF for Ruby returns only the first one.'
  META_CONTENT_RDOC = 'The meta element allows non-XSPF metadata to be included in XSPF documents without breaking XSPF validation. A valid _meta_ element has a _rel_ attribute and a _content_ element, obtained with XSPF::Track#meta_rel and XSPF::Track#meta_content respectively. XSPF::Track objects MAY contain zero or more meta elements, but currently XSPF for Ruby returns only the first one.'

  ELEMENTS.each do |element|
    MetaGen.add_method( self, element, "@track.elements['#{element}'].text", eval(element.upcase + '_RDOC').to_s )
  end

  ATTRIBUTE_AND_ELEMENT.each do |ae|
    MetaGen.add_method( self, "#{ae}_content", "@track.elements['#{ae}'].text", eval(ae.upcase + '_CONTENT_RDOC').to_s )
    MetaGen.add_method( self, "#{ae}_rel", "@track.elements['#{ae}'].attributes['rel']", eval(ae.upcase + '_REL_RDOC').to_s )
  end

  # :startdoc:
  
  # Creates a XSPF::Track object from a <track> section of the XSPF document or from a hash of values
  #
  # Possible keys in the hash in generation mode: :location, :identifier, :title, :creator, :annotation, :info, :image, :album, :tracknum, :duration, :extension, :link_rel, :link_content, :meta_rel, :meta_content)
  def initialize(tr)
    
    if tr.instance_of?(Hash)

      ELEMENTS.each do |element|
        add_instance_variable(tr, element.downcase)
      end

      ATTRIBUTE_AND_ELEMENT.each do |ae|
        add_instance_variable(tr, "#{ae.downcase}_content" )
        add_instance_variable(tr, "#{ae.downcase}_rel" )
      end
      
    else
      @track = tr

      ELEMENTS.each do |element|
        eval('@' + element.downcase + '= parse_' + element.downcase)
      end

      ATTRIBUTE_AND_ELEMENT.each do |ae|
        eval('@' + ae.downcase + '_content = parse_' + ae.downcase + '_content')
        eval('@' + ae.downcase + '_rel = parse_' + ae.downcase + '_rel')
      end
    end
    
  end

  # Exports the XSPF::Track to XML (only the <track> section)
  def to_xml

    xml = REXML::Element.new('track')
    
    ELEMENTS.each do |element|
      # TODO Sure there is a nicer way to do evaluate this condition...
      unless eval('@' + element.downcase + '.nil?')
        el = REXML::Element.new(element)
        el.add_text( eval('@' + element.downcase) )
        xml.add_element(el)
      end 
    end

    ATTRIBUTE_AND_ELEMENT.each do |ae|
      # TODO Sure there is a nicer way to do evaluate this condition...
      unless eval('@' + ae.downcase + '_rel.nil? && @'+ ae.downcase + '_content.nil?')
        el = REXML::Element.new(ae.downcase)
        el.add_attribute('rel', eval('@' + ae.downcase + '_rel') )
        el.add_text( eval('@' + ae.downcase + '_content') )
        xml.add_element(el)
      end 
    end

    xml.to_s
    
  end
  
  private
  def add_instance_variable(hash, var)
    
    if hash.has_key?(var.downcase.to_sym)
      eval('@' + var.downcase + ' = \'' + hash[var.downcase.to_sym] + '\'')
    else
      eval('@' + var.downcase + ' = defined?(' + var.upcase + '_DEFAULT) ? ' + var.upcase + '_DEFAULT : nil')
    end
  
  end

end