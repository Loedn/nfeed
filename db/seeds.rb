# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create collections with categories
[
  { name: "Linux", category: "Technology" },
  { name: "Crypto", category: "Finance" },
  { name: "News", category: "Technology" },
  { name: "Software Development", category: "Technology" },
  { name: "Security", category: "Technology" },
  { name: "Entertainment", category: "Technology" },
  { name: "SEO", category: "Technology" },
  { name: "Gaming", category: "Video Games" },
  { name: "Food", category: "Food" },
  { name: "Travel", category: "Travel" }
].each do |collection_data|
  Collection.find_or_create_by!(name: collection_data[:name]) do |collection|
    collection.category = collection_data[:category]
  end
end

# Crypto Feeds
crypto_collection = Collection.find_by(name: "Crypto")
crypto_feeds = [
  { title: "Ethereum News - CT", url: "https://cointelegraph.com/rss/tag/ethereum" },
  { title: "Altcoin News - CT", url: "https://cointelegraph.com/rss/tag/altcoin" },
  { title: "Bitcoin News - CT", url: "https://cointelegraph.com/rss/tag/bitcoin" },
  { title: "Monero News - CT", url: "https://cointelegraph.com/rss/tag/monero" },
  { title: "Blockchain News - CT", url: "https://cointelegraph.com/rss/tag/blockchain" },
  { title: "Regulation News - CT", url: "https://cointelegraph.com/rss/tag/regulation" },
  { title: "0xResearch", url: "https://feeds.megaphone.fm/0xresearch" },
  { title: "empire", url: "https://feeds.megaphone.fm/empire" },
  { title: "thebreakdown", url: "https://feeds.megaphone.fm/thebreakdown" },
  { title: "1000x", url: "https://feeds.megaphone.fm/1000x" },
  { title: "bellcurve", url: "https://feeds.megaphone.fm/bellcurve" },
  { title: "supplyshock", url: "https://feeds.megaphone.fm/supplyshock" },
  { title: "lightspeed", url: "https://feeds.megaphone.fm/lightspeed" },
  { title: "forwardguidance", url: "https://feeds.megaphone.fm/forwardguidance" },
  { title: "expansion", url: "https://feeds.megaphone.fm/expansion" },   


]

crypto_feeds.each do |feed_data|
  crypto_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
    feed.url = feed_data[:url]
  end
end

# Linux Feeds
linux_collection = Collection.find_by(name: "Linux")
linux_feeds = [
  { title: "Linux Foundation", url: "https://www.linuxfoundation.org/blog/rss.xml" },
  { title: "Phoronix", url: "https://www.phoronix.com/rss.php" },
  { title: "Gaming on Linux", url: "https://www.gamingonlinux.com/article_rss.php" },
  { title: "r/Linux", url: "https://www.reddit.com/r/linux/top.rss" },
  { title: "DistroWatch", url: "https://distrowatch.com/news/dw.xml" },
  { title: "It's FOSS", url: "https://itsfoss.com/feed/" },
  { title: "OMG Ubuntu", url: "https://www.omgubuntu.co.uk/feed" },
  { title: "cyberciti.com", url: "https://www.cyberciti.com/feed/" },
  { title: "tecmint.com", url: "https://www.tecmint.com/feed/" },
  { title: "linuxhint.com", url: "https://linuxhint.com/feed/" },
  { title: "UbuntuhandbookNewsTutorialsHowtosForUbuntuLinux", url: "http://feeds.feedburner.com/UbuntuhandbookNewsTutorialsHowtosForUbuntuLinux" },
  { title: "tecadmin.net", url: "https://tecadmin.net/feed/" },
  { title: "rosehosting.com", url: "https://www.rosehosting.com/blog/feed/" },
  { title: "linuxhandbook.com", url: "https://linuxhandbook.com/rss/" },
  { title: "linuxconfig.org", url: "https://linuxconfig.org/feed" }
]

linux_feeds.each do |feed_data|
  linux_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
    feed.url = feed_data[:url]
  end
end


# News Feeds
news_collection = Collection.find_by(name: "News")
news_feeds = [
  { title: "Mashable", url: "https://mashable.com/feeds/rss/all" },
  { title: "TechCrunch", url: "https://techcrunch.com/feed/" },
  { title: "The Verge", url: "https://www.theverge.com/rss/frontpage" }
]

news_feeds.each do |feed_data|
  news_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
    feed.url = feed_data[:url]
  end
end

# Software Development Feeds
software_collection = Collection.find_by(name: "Software Development")
software_feeds = [
  { title: "Ruby Weekly", url: "https://rubyweekly.com/rss" },
  { title: "JavaScript Weekly", url: "https://javascriptweekly.com/rss" },
  { title: "Python Weekly", url: "https://pythonweekly.com/rss" },
  { title: "phppot", url: "https://phppot.com/feed/" },
  { title: "css-tricks", url: "https://css-tricks.com/feed/" },
  { title: "dev.to", url: "https://dev.to/feed" },
  { title: "code.tutsplus", url: "https://code.tutsplus.com/posts.atom" }
]

software_feeds.each do |feed_data|
  software_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
    feed.url = feed_data[:url]
  end
end

# Security Feeds
security_collection = Collection.find_by(name: "Security")
security_feeds = [
  { title: "TheHackersNews", url: "https://feeds.feedburner.com/TheHackersNews" },
  { title: "bleepingcomputer.com", url: "https://www.bleepingcomputer.com/feed/" },
  { title: "nakedsecurity.sophos.com", url: "https://nakedsecurity.sophos.com/feed" },
  { title: "threatpost.com", url: "https://threatpost.com/feed" },
  { title: "www.malwarebytes.com/blog/feed/index.xml", url: "https://www.malwarebytes.com/blog/feed/index.xml" }
]

security_feeds.each do |feed_data|
  security_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
    feed.url = feed_data[:url]
  end
end

# Entertainment Feeds
entertainment_collection = Collection.find_by(name: "Entertainment")
entertainment_feeds = [
  { title: "The Verge", url: "https://www.theverge.com/rss/frontpage" },
  { title: "Mashable", url: "https://mashable.com/feeds/rss/all" },
  { title: "TechCrunch", url: "https://techcrunch.com/feed/" },
  { title: "Gizmodo", url: "https://gizmodo.com/rss" },
  { title: "Wired", url: "https://www.wired.com/feed/category/science/top/rss" },
  { title: "Ars Technica", url: "https://arstechnica.com/rss.xml" },
  { title: "The Guardian", url: "https://www.theguardian.com/world/rss" },
  { title: "The New York Times", url: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml" },    
  { title: "The Washington Post", url: "https://rss.washingtonpost.com/rss/world" },
  { title: "The Wall Street Journal", url: "https://rss.wsj.com/feeds/sections/world" },
  { title: "The Los Angeles Times", url: "https://rss.latimes.com/rss/world" },
  { title: "The New York Post", url: "https://rss.nypost.com/world" },
  { title: "The Daily Mail", url: "https://rss.dailymail.co.uk/world" },
  { title: "The Independent", url: "https://rss.independent.co.uk/world" }, 
  { title: "The Times", url: "https://rss.times.co.uk/world" },
  { title: "The Daily Telegraph", url: "https://rss.telegraph.co.uk/world" },
  { title: "The Daily Express", url: "https://rss.express.co.uk/world" },
  { title: "The Daily Mirror", url: "https://rss.mirror.co.uk/world" },
  { title: "The Daily Star", url: "https://rss.dailystar.co.uk/world" },    
  { title: "The Daily Mail", url: "https://rss.dailymail.co.uk/world" },
  { title: "The Independent", url: "https://rss.independent.co.uk/world" },
  { title: "The Sun", url: "https://rss.thesun.co.uk/world" }
]

entertainment_feeds.each do |feed_data|
  entertainment_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
    feed.url = feed_data[:url]
  end
end

# SEO Feeds
seo_collection = Collection.find_by(name: "SEO")
seo_feeds = [
  { title: "Search Engine Journal", url: "https://www.searchenginejournal.com/feed/" },
  { title: "ahrefs.com", url: "https://ahrefs.com/blog/feed/" },
  { title: "www.semrush.com/blog/feed/", url: "https://www.semrush.com/blog/feed/" }
]

seo_feeds.each do |feed_data|
  seo_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
    feed.url = feed_data[:url]
  end
end

# Gaming Feeds
gaming_collection = Collection.find_by(name: "Gaming")
gaming_feeds = [
  { title: "GameSpot", url: "https://www.gamespot.com/feeds/rss/all" },
  { title: "Polygon", url: "https://www.polygon.com/rss/index.xml" },
  { title: "Destructoid", url: "https://www.destructoid.com/rss.php" },
  { title: "Kotaku", url: "https://feeds.kottke.org/main" },
  { title: "Joystiq", url: "https://www.joystiq.com/feeds/rss/all" },
  { title: "Game Informer", url: "https://www.gameinformer.com/rss" },
]

gaming_feeds.each do |feed_data|
  gaming_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
    feed.url = feed_data[:url]
  end
end

# Food Feeds
food_collection = Collection.find_by(name: "Food")
food_feeds = [
  { title: "Eater", url: "https://feeds.eater.com/rss/the-takeout" },
  { title: "Serious Eats", url: "https://feeds.seriouseats.com/rss/index.xml" },
  ]

food_feeds.each do |feed_data|
  food_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
    feed.url = feed_data[:url]
  end
end

# Travel Feeds
# travel_collection = Collection.find_by(name: "Travel")
# travel_feeds = [
#   { title: "Lonely Planet", url: "https://feeds.simplecast.com/X5000000" },
#   { title: "National Geographic Travel", url: "https://feeds.simplecast.com/X5000000" },
# ]

# travel_feeds.each do |feed_data|
#   travel_collection.feeds.find_or_create_by!(title: feed_data[:title]) do |feed|
#     feed.url = feed_data[:url]
#   end
# end

Feed.all.each do |feed|
  FeedFetcher.fetch(feed)
end