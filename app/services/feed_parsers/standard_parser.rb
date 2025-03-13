module FeedParsers
  class StandardParser
    def self.can_parse?(url)
      true # Fallback parser
    end
    
    def self.parse(xml_content, feed_url)
      begin
        feed = Feedjira.parse(xml_content)
      rescue => e
        # If Feedjira fails, try with Nokogiri
        doc = Nokogiri::XML(xml_content)
        
        # Create a basic feed structure
        feed = OpenStruct.new(
          title: doc.at_xpath('//channel/title')&.text || doc.at_xpath('//feed/title')&.text || 'Unknown Feed',
          description: doc.at_xpath('//channel/description')&.text || doc.at_xpath('//feed/subtitle')&.text || '',
          entries: []
        )
        
        # Parse items (RSS or Atom)
        items = doc.xpath('//item') # RSS
        items = doc.xpath('//entry') if items.empty? # Atom
        
        items.each do |item_node|
          is_atom = item_node.name == 'entry'
          
          if is_atom
            entry = OpenStruct.new(
              title: item_node.at_xpath('./title')&.text || 'Untitled',
              content: item_node.at_xpath('./content')&.text || '',
              summary: item_node.at_xpath('./summary')&.text || '',
              url: item_node.at_xpath('./link[@rel="alternate"]')&.attr('href') || '',
              published: parse_date(item_node.at_xpath('./published')&.text || item_node.at_xpath('./updated')&.text),
              entry_id: item_node.at_xpath('./id')&.text || SecureRandom.uuid,
              author: item_node.at_xpath('./author/name')&.text || ''
            )
          else
            entry = OpenStruct.new(
              title: item_node.at_xpath('./title')&.text || 'Untitled',
              content: item_node.at_xpath('./description')&.text || '',
              summary: item_node.at_xpath('./description')&.text || '',
              url: item_node.at_xpath('./link')&.text || '',
              published: parse_date(item_node.at_xpath('./pubDate')&.text),
              entry_id: item_node.at_xpath('./guid')&.text || SecureRandom.uuid,
              author: item_node.at_xpath('./author')&.text || item_node.at_xpath('./dc:creator')&.text || ''
            )
            
            # Get enclosure info
            enclosure = item_node.at_xpath('./enclosure')
            if enclosure
              entry.enclosure_url = enclosure['url']
              entry.enclosure_type = enclosure['type']
            end
          end
          
          feed.entries << entry
        end
      end
      
      # Basic feed information
      result = {
        title: feed.title,
        description: feed.description,
        url: feed_url,
        items: []
      }
      
      # Process each entry
      feed.entries.each do |entry|
        # Determine content type
        is_video = false
        is_audio = false
        audio_url = nil
        youtube_id = nil
        
        # Check for enclosures (podcasts, etc)
        if entry.respond_to?(:enclosure_url) && entry.enclosure_url.present?
          enclosure_type = entry.respond_to?(:enclosure_type) ? entry.enclosure_type.to_s : ''
          
          if enclosure_type.include?('audio')
            is_audio = true
            audio_url = entry.enclosure_url
          elsif enclosure_type.include?('video')
            is_video = true
          end
        end
        
        # Check for YouTube videos in the content
        if entry.respond_to?(:content) && entry.content.present?
          youtube_match = entry.content.match(/youtube\.com\/embed\/([^"&?\/\s]+)/)
          if youtube_match
            is_video = true
            youtube_id = youtube_match[1]
          end
        end
        
        # Create item hash
        item = {
          title: entry.title,
          description: entry.respond_to?(:content) ? entry.content : entry.summary,
          link: entry.respond_to?(:url) ? entry.url : nil,
          published_at: entry.respond_to?(:published) ? entry.published : Time.current,
          guid: entry.respond_to?(:entry_id) ? entry.entry_id : SecureRandom.uuid,
          author: entry.respond_to?(:author) ? entry.author : nil,
          is_video: is_video,
          is_audio: is_audio,
          audio_url: audio_url,
          youtube_id: youtube_id,
          enclosure_type: entry.respond_to?(:enclosure_type) ? entry.enclosure_type : nil
        }
        
        result[:items] << item
      end
      
      result
    end
    
    private
    
    def self.parse_date(date_str)
      return Time.current unless date_str.present?
      
      begin
        Time.parse(date_str)
      rescue ArgumentError, TypeError
        Time.current
      end
    end
  end
end 