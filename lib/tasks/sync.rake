namespace :sync do
  task feeds: [:environment] do
    Feed.all.each do |feed|
      url = feed.url
      xml = HTTParty.get(url).body
      content = Feedjira.parse(xml)
      content.entries.each do |entry|
        local_entry = feed.episodes.where(title: entry.title).first_or_initialize
        local_entry.update_attributes(content: entry.content, author: entry.author, url: entry.url, published: entry.published)
        p "Synced Entry - #{entry.title}"
      end
      p "Synced Feed - #{feed.name}"
    end
  end
end
