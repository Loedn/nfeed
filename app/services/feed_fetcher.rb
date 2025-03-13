require 'open-uri'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'feedjira'

class FeedFetcher
  def self.fetch(feed)
    feed.update(status: 'fetching')
    
    begin
      xml_content = fetch_content(feed.url)
      
      if xml_content
        # Determine which parser to use
        parser = if FeedParsers::MegaphoneParser.can_parse?(feed.url)
                  FeedParsers::MegaphoneParser
                else
                  FeedParsers::StandardParser
                end
        
        # Parse the feed
        parsed_feed = parser.parse(xml_content, feed.url)
        
        # Update feed attributes
        feed.update(
          title: parsed_feed[:title],
          description: parsed_feed[:description],
          last_fetched_at: Time.current,
          status: 'success'
        )
        
        # Process feed items
        process_feed_items(feed, parsed_feed[:items])
        
        return true
      else
        feed.update(status: "error: Failed to fetch content")
        return false
      end
    rescue => e
      feed.update(status: "error: #{e.message}")
      return false
    end
  end
  
  def self.fetch_content(url)
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "FeedReader/1.0"
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', read_timeout: 30) do |http|
      http.request(request)
    end
    
    if response.is_a?(Net::HTTPSuccess)
      response.body
    else
      nil
    end
  rescue => e
    Rails.logger.error("Error fetching feed: #{e.message}")
    nil
  end
  
  private
  
  def self.process_feed_items(feed, items)
    items.each do |item_data|
      # Find existing item or create new one
      item = feed.feed_items.find_or_initialize_by(guid: item_data[:guid])
      
      # Update item attributes
      item.update(
        title: item_data[:title],
        description: item_data[:description],
        link: item_data[:link],
        published_at: item_data[:published_at],
        author: item_data[:author],
        is_audio: item_data[:is_audio] || false,
        is_video: item_data[:is_video] || false,
        audio_url: item_data[:audio_url],
        enclosure_type: item_data[:enclosure_type],
        youtube_id: item_data[:youtube_id],
        duration: item_data[:duration]
      )
    end
  end
end 