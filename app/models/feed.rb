class Feed < ApplicationRecord
  belongs_to :collection
  
  validates :title, presence: true
  validates :url, presence: true, url: true
  
  # Manual JSON serialization/deserialization
  def items
    return [] if self[:items].blank?
    begin
      JSON.parse(self[:items])
    rescue JSON::ParserError
      []
    end
  end
  
  def items=(value)
    self[:items] = value.is_a?(String) ? value : value.to_json
  end
  
  # Set default empty array for items
  after_initialize :set_default_items, if: :new_record?
  
  def set_default_items
    self[:items] = '[]' if self[:items].nil?
  end
  
  def to_rss
    RSS::Maker.make("2.0") do |maker|
      maker.channel.title = title
      maker.channel.description = description
      maker.channel.link = url
      maker.channel.language = "en"
      maker.channel.copyright = "Copyright #{Date.today.year}"
      maker.channel.lastBuildDate = updated_at
      
      # Add items if you have them stored
      if items.present?
        items.each do |item|
          maker.items.new_item do |i|
            i.title = item["title"]
            i.link = item["link"]
            i.description = item["description"]
            i.pubDate = item["published_at"]
          end
        end
      end
    end
  end
  
  def fetch_content
    FeedFetcher.fetch(self)
  end
  
  def display_items(limit = 10)
    items.take(limit)
  end
end 