class FeedsController < ApplicationController
  before_action :set_collection
  before_action :set_feed, only: [:show, :edit, :update, :destroy, :refresh, :content]
  
  def index
    @feeds = @collection.feeds
  end
  
  def show
    respond_to do |format|
      format.html
      format.rss { render xml: @feed.to_rss.to_s }
    end
  end
  
  def new
    @feed = @collection.feeds.build
  end
  
  def create
    @feed = @collection.feeds.build(feed_params)
    
    if @feed.save
      # Try to fetch feed content immediately
      FeedFetcher.fetch(@feed) if params[:fetch_now]
      redirect_to collection_feed_path(@collection, @feed), notice: 'Feed was successfully created.'
    else
      # Add more detailed error messages
      flash.now[:alert] = "Failed to create feed: #{@feed.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @feed.update(feed_params)
      redirect_to collection_feed_path(@collection, @feed), notice: 'Feed was successfully updated.'
    else
      render :edit
    end
  end
  
  def destroy
    @feed.destroy
    redirect_to collection_feeds_path(@collection), notice: 'Feed was successfully destroyed.'
  end
  
  def refresh
    if FeedFetcher.fetch(@feed)
      redirect_to collection_feed_path(@collection, @feed), notice: 'Feed was successfully refreshed.'
    else
      redirect_to collection_feed_path(@collection, @feed), alert: "Failed to refresh feed: #{@feed.fetch_error}"
    end
  end
  
  def content
    @items = @feed.feed_items.recent.limit(params[:limit] ? params[:limit].to_i : 10)
  end
  
  def fetch_raw
    @feed = @collection.feeds.find(params[:id])
    
    begin
      @raw_content = FeedFetcher.fetch_content(@feed.url)
      
      if @raw_content
        # Store the raw content in a temporary session variable
        session[:raw_feed_content] = @raw_content
        redirect_to debug_collection_feed_path(@collection, @feed), notice: "Raw feed content fetched successfully"
      else
        redirect_to debug_collection_feed_path(@collection, @feed), alert: "Failed to fetch content from URL"
      end
    rescue => e
      redirect_to debug_collection_feed_path(@collection, @feed), alert: "Error fetching raw content: #{e.message}"
    end
  end
  
  def debug
    @feed = @collection.feeds.find(params[:id])
    @raw_content = session[:raw_feed_content]
    @debug_info = {}
    
    begin
      content = FeedFetcher.fetch_content(@feed.url)
      if content
        doc = Nokogiri::XML(content)
        @debug_info[:feed_type] = if doc.at_css('rss') 
                                    'RSS'
                                  elsif doc.at_css('feed')
                                    'Atom'
                                  else
                                    'Unknown'
                                  end
        @debug_info[:items_count] = doc.css('item, entry').count
        @debug_info[:sample_item] = doc.at_css('item, entry')&.to_s
      else
        @debug_info[:error] = "Could not fetch content from URL"
      end
    rescue => e
      @debug_info[:error] = e.message
      @debug_info[:backtrace] = e.backtrace.first(5)
    end
    
    render :debug
  end
  
  private
  
  def set_collection
    @collection = Collection.find(params[:collection_id])
  end
  
  def set_feed
    @feed = @collection.feeds.find(params[:id])
  end
  
  def feed_params
    params.require(:feed).permit(:title, :url, :description)
  end
end 