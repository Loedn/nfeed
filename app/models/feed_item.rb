class FeedItem < ApplicationRecord
  belongs_to :feed
  
  validates :title, presence: true
  validates :link, presence: true
  
  scope :recent, -> { order(published_at: :desc) }
  
  # Content type methods
  def content_type
    if is_video?
      'video'
    elsif is_audio?
      'audio'
    else
      'text'
    end
  end
  
  def is_video?
    is_video || link.present? && (link =~ /youtube\.com|youtu\.be|vimeo\.com/).present?
  end
  
  def is_audio?
    is_audio || 
      (enclosure_type.present? && enclosure_type.start_with?('audio/')) ||
      (link.present? && link =~ /\.mp3$|\.m4a$|\.wav$|\.ogg$|\.opus$|podcast|anchor\.fm/)
  end
  
  def youtube_id
    return nil unless is_video?
    
    regex = %r{
      (?:youtube(?:-nocookie)?\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)
      ([^"&?/\s]{11})
    }x
    
    match = regex.match(link)
    match[1] if match
  end
  
  def audio_url
    return enclosure_url if enclosure_url.present? && enclosure_type.present? && enclosure_type.start_with?('audio/')
    return link if link =~ /\.mp3$|\.m4a$|\.wav$|\.ogg$|\.opus$/
    nil
  end
end 