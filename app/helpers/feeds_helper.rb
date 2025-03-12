module FeedsHelper
  def youtube_video_id(url)
    return nil unless url.present?
    
    # Match YouTube URL patterns
    regex = %r{
      (?:youtube(?:-nocookie)?\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)
      ([^"&?/\s]{11})
    }x
    
    match = regex.match(url)
    match[1] if match
  end
  
  def embed_youtube_video(url, width: 560, height: 315)
    video_id = youtube_video_id(url)
    return nil unless video_id
    
    content_tag(:div, class: 'youtube-video-container') do
      content_tag(:iframe, '', 
        width: width,
        height: height,
        src: "https://www.youtube.com/embed/#{video_id}",
        frameborder: 0,
        allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
        allowfullscreen: true
      )
    end
  end
  
  def process_feed_content(item)
    content = sanitize(item["description"])
    
    # Check if the item link is a YouTube video
    if youtube_video_id(item["link"])
      content = embed_youtube_video(item["link"]) + content_tag(:div, content, class: 'feed-text-content')
    end
    
    content
  end
end 