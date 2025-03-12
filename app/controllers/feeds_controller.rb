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
      redirect_to collection_feed_path(@collection, @feed), notice: 'Feed was successfully created.'
    else
      render :new
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
    @items = @feed.display_items(params[:limit] ? params[:limit].to_i : 10)
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