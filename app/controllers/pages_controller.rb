class PagesController < ApplicationController
    def home
        @collections_by_category = Collection.all.grouped_by_category
        
        # Get recent items but group by title/link to avoid duplicates
        items = FeedItem.includes(feed: :collection)
                       .order(published_at: :desc)
                       .limit(100)  # Get more items initially to account for duplicates
        
        # Group items by a combination of title and link
        grouped_items = items.group_by { |item| [item.title.downcase, item.link] }
        
        # For each group, keep the first item but collect all sources
        @recent_items = grouped_items.map do |_, items_group|
          primary_item = items_group.first
          primary_item.instance_variable_set(:@all_sources, items_group.map(&:feed).uniq)
          primary_item
        end.first(20)  # Limit to 20 unique items
    end
end
