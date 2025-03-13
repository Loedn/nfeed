require 'open-uri'
require 'nokogiri'
require 'net/http'

class FeedFetcher
  def self.fetch(feed)
    begin
      feed.update(status: 'fetching')
      
      # Fetch content with better error handling
      content = fetch_content(feed.url)
      return false unless content
      
      # Parse the feed
      doc = Nokogiri::XML(content)
      
      # Track new items for the return value
      new_items = []
      
      # Try to determine feed type
      if doc.at_css('rss, rdf, feed')
        # Process RSS/Atom items
        items = []
        
        # Try RSS format first (both RSS 2.0 and RSS 1.0)
        items = doc.css('item') if items.empty?
        
        # Try Atom format if no RSS items found
        items = doc.css('entry') if items.empty?
        
        items.each do |item_node|
          # Extract common fields with fallbacks
          item_data = extract_item_data(item_node)
          next unless item_data[:guid].present? && item_data[:title].present?
          
          # Check if this item already exists
          existing_item = feed.feed_items.find_by(guid: item_data[:guid])
          next if existing_item
          
          # Create new item with error handling
          begin
            new_item = feed.feed_items.create!(
              title: item_data[:title],
              link: item_data[:link],
              description: item_data[:description],
              published_at: item_data[:published_at],
              guid: item_data[:guid],
              is_video: item_data[:is_video],
              is_audio: item_data[:is_audio],
              author: item_data[:author],
              categories: item_data[:categories],
              enclosure_url: item_data[:enclosure_url],
              enclosure_type: item_data[:enclosure_type]
            )
            
            new_items << new_item
          rescue => e
            Rails.logger.error("Failed to create feed item: #{e.message}")
          end
        end
      end
      
      feed.update(
        last_fetched_at: Time.current,
        status: new_items.any? ? 'success' : 'no_new_items',
        fetch_error: nil
      )
      
      return true
    rescue => e
      Rails.logger.error("Feed fetcher error: #{e.message}")
      feed.update(
        status: 'error',
        fetch_error: e.message
      )
      
      return false
    end
  end
  
  private
  
  def self.fetch_content(url)
    begin
      URI.open(url, 'User-Agent' => 'Mozilla/5.0 (compatible; MyFeedReader/1.0)').read
    rescue OpenURI::HTTPError, SocketError, Errno::ECONNREFUSED, Timeout::Error => e
      Rails.logger.error("Failed to fetch feed content: #{e.message}")
      nil
    end
  end
  
  def self.extract_item_data(node)
    is_atom = node.name == 'entry'
    
    # Initialize with default values
    data = {
      title: nil,
      link: nil,
      description: nil,
      published_at: nil,
      guid: nil,
      is_video: false,
      is_audio: false,
      author: nil,
      categories: nil,
      enclosure_url: nil,
      enclosure_type: nil
    }
    
    if is_atom
      # Atom feed
      data[:title] = node.at_css('title')&.content
      data[:link] = node.at_css('link')&.attr('href')
      data[:description] = node.at_css('content')&.content || node.at_css('summary')&.content
      data[:published_at] = parse_date(node.at_css('published')&.content || node.at_css('updated')&.content)
      data[:guid] = node.at_css('id')&.content || data[:link]
      data[:author] = node.at_css('author name')&.content
      
      # Check for media content
      media_content = node.at_css('media|content')
      if media_content
        data[:enclosure_url] = media_content['url']
        data[:enclosure_type] = media_content['type']
      end
    else
      # RSS feed
      data[:title] = node.at_css('title')&.content
      data[:link] = node.at_css('link')&.content
      data[:description] = node.at_css('description')&.content
      data[:published_at] = parse_date(node.at_css('pubDate')&.content || node.at_css('dc|date')&.content)
      data[:guid] = node.at_css('guid')&.content || data[:link]
      data[:author] = node.at_css('author')&.content || node.at_css('dc|creator')&.content
      
      # Get enclosure info if available
      enclosure = node.at_css('enclosure')
      if enclosure
        data[:enclosure_url] = enclosure['url']
        data[:enclosure_type] = enclosure['type']
      end
      
      
      # Get categories
      categories = node.css('category').map(&:content)
      data[:categories] = categories.join(', ') if categories.any?
    end
    
    # Determine content type
    data[:is_video] = !!(data[:link] =~ /youtube\.com|youtu\.be|vimeo\.com/)
    data[:is_audio] ||= !!(data[:enclosure_type]&.start_with?('audio/') || 
                          data[:link] =~ /\.mp3$|\.m4a$|\.wav$|\.ogg$|\.opus$|podcast|anchor\.fm/)
    
    # Set default published date if none found
    data[:published_at] ||= Time.current
    
    data
  end
  
  def self.parse_date(date_str)
    return nil unless date_str.present?
    
    begin
      Time.parse(date_str)
    rescue ArgumentError, TypeError
      Time.current
    end
  end
end 