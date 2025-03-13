class PagesController < ApplicationController
    def home
        @collections = Collection.all
        @recent_items = FeedItem.includes(:feed => :collection)
                               .order(published_at: :desc)
                               .limit(20)
    end
end
