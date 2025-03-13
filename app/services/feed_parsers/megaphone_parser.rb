module FeedParsers
  class MegaphoneParser
    def self.can_parse?(url)
      url.include?('feeds.megaphone.fm')
    end
    
    def self.parse(xml_content, feed_url)
      begin
        # Try to parse with Feedjira first
        feed = Feedjira.parse(xml_content)
      rescue => e
        # If Feedjira fails, try with Nokogiri
        doc = Nokogiri::XML(xml_content)
        
        # Create a basic feed structure
        feed = OpenStruct.new(
          title: doc.at_xpath('//channel/title')&.text || 'Unknown Podcast',
          description: doc.at_xpath('//channel/description')&.text || '',
          itunes_summary: doc.at_xpath('//channel/itunes:summary')&.text || '',
          entries: []
        )
        
        # Parse items
        doc.xpath('//item').each do |item_node|
          entry = OpenStruct.new(
            title: item_node.at_xpath('./title')&.text || 'Untitled Episode',
            summary: item_node.at_xpath('./description')&.text || '',
            content: nil,
            itunes_summary: item_node.at_xpath('./itunes:summary')&.text || '',
            url: item_node.at_xpath('./link')&.text || '',
            link: item_node.at_xpath('./link')&.text || '',
            published: parse_date(item_node.at_xpath('./pubDate')&.text),
            entry_id: item_node.at_xpath('./guid')&.text || SecureRandom.uuid,
            id: item_node.at_xpath('./guid')&.text || SecureRandom.uuid,
            itunes_author: item_node.at_xpath('./itunes:author')&.text || '',
            itunes_duration: item_node.at_xpath('./itunes:duration')&.text || ''
          )
          
          # Get enclosure info
          enclosure = item_node.at_xpath('./enclosure')
          if enclosure
            entry.enclosure_url = enclosure['url']
            entry.enclosure_type = enclosure['type']
          end
          
          feed.entries << entry
        end
      end
      
      # Basic feed information
      result = {
        title: feed.title,
        description: feed.description || feed.itunes_summary,
        url: feed_url,
        items: []
      }
      
      # Process each entry/episode
      feed.entries.each do |entry|
        # Extract audio URL from enclosure
        audio_url = entry.respond_to?(:enclosure_url) && entry.enclosure_url.present? ? entry.enclosure_url : nil
        
        # Create item hash
        item = {
          title: entry.title,
          description: entry.respond_to?(:summary) ? entry.summary : nil,
          link: entry.respond_to?(:url) ? entry.url : nil,
          published_at: entry.respond_to?(:published) ? entry.published : Time.current,
          guid: entry.respond_to?(:entry_id) ? entry.entry_id : SecureRandom.uuid,
          author: entry.respond_to?(:itunes_author) ? entry.itunes_author : nil,
          is_audio: audio_url.present?,
          audio_url: audio_url,
          enclosure_type: entry.respond_to?(:enclosure_type) ? entry.enclosure_type : 'audio/mpeg'
        }
        
        # Add duration if available
        item[:duration] = entry.itunes_duration if entry.respond_to?(:itunes_duration)
        
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