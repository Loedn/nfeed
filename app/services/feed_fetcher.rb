require 'rss'
require 'open-uri'
require 'nokogiri'

class FeedFetcher
  def self.fetch(feed)
    begin
      feed.update(status: 'fetching')
      
      content = URI.open(feed.url).read
      puts "--------------------------------content: #{content}"
      
      # Try different parsing approaches
      items = []
      
      begin
        # Try standard RSS parser first
        rss = RSS::Parser.parse(content, false)
        puts "--------------------------------rss: #{rss}"
        
        if rss.is_a?(RSS::Rss)
          # Handle RSS 2.0 or 1.0
          rss.items.each do |item|
            puts "--------------------------------item: #{item}"
            items << {
              "title" => item.title,
              "link" => item.respond_to?(:link) ? item.link : item.guid.content,
              "description" => item.description,
              "published_at" => (item.respond_to?(:pubDate) ? item.pubDate : item.date)&.to_s,
              "is_video" => !!(item.respond_to?(:link) ? item.link =~ /youtube\.com|youtu\.be/)
            }
          end
        elsif rss.is_a?(RSS::Atom::Feed)
          # Handle Atom
          rss.entries.each do |entry|
            items << {
              "title" => entry.title.content,
              "link" => entry.link.href,
              "description" => entry.content&.content || entry.summary&.content,
              "published_at" => entry.published&.to_s || entry.updated&.to_s,
              "is_video" => !!(entry.link.href =~ /youtube\.com|youtu\.be/)
            }
          end
        end
      rescue => e
        puts "RSS Parser error: #{e.message}, trying Nokogiri fallback"
        
        # Fallback to Nokogiri for more flexible parsing
        doc = Nokogiri::XML(content)
        
        # Try RSS format
        doc.css('item').each do |item|
          items << {
            "title" => item.at_css('title')&.content,
            "link" => item.at_css('link')&.content,
            "description" => item.at_css('description')&.content,
            "published_at" => item.at_css('pubDate')&.content,
            "is_video" => !!(item.at_css('link')&.content =~ /youtube\.com|youtu\.be/)
          }
        end
        
        # Try Atom format if no items found
        if items.empty?
          doc.css('entry').each do |entry|
            items << {
              "title" => entry.at_css('title')&.content,
              "link" => entry.at_css('link')&.attr('href'),
              "description" => entry.at_css('content')&.content || entry.at_css('summary')&.content,
              "published_at" => entry.at_css('published')&.content || entry.at_css('updated')&.content,
              "is_video" => !!(entry.at_css('link')&.attr('href') =~ /youtube\.com|youtu\.be/)
            }
          end
        end
      end
      
      feed.update(
        items: items,
        last_fetched_at: Time.current,
        status: 'success',
        fetch_error: nil
      )
      
      return true
    rescue => e
      puts "Feed fetcher error: #{e.message}"
      feed.update(
        status: 'error',
        fetch_error: e.message
      )
      
      return false
    end
  end
end 