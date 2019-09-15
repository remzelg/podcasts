require 'open-uri'

class ItunesFeedWorker
  include Sidekiq::Worker

  ALPHABET = ('A'..'Z').to_a + ["*"]
  CATEGORIES = YAML.load_file(Rails.root.join('config/itunes_categories.yml'))

  def perform
    import_categories
    find_feeds
  end

private
  def import_categories
    CATEGORIES.each do |k, v|
      # TODO: Call worker with name of category and the url. Run each category import separately
      CSV.open("db/categories/" + k.to_s + ".csv", "wb") do |csv|
        ALPHABET.each do |letter|
          alphabet_page_url = "#{v}&letter=#{letter}"
          alphabet_page_html = Nokogiri::HTML(open(alphabet_page_url))
          # Count number of pages. Ignore link to next page.
          page_count = alphabet_page_html.xpath("//*[@id='selectedgenre']/ul[2]/li/a[not(contains(@class, 'paginate-more'))]").size
          # Always assume at least one page. If there is only one page, the above calculation is incorrect and returns 0.
          paginate_count = page_count > 0 ? page_count : 1
          (1..paginate_count).each do |i|
            url = alphabet_page_url+"&page=#{i}"
            puts "#{k}, #{url}"
            csv << [url]
          end
        end
      end
    end
  end

  def find_feeds
    CATEGORIES.each do |k, v|
      # TODO: Call worker with name of category and the url. Run each category import separately
      CSV.foreach("db/categories/#{k.to_s}.csv") do |row|
        url = row[0]
        # TODO: Remove rescue statement when this is finished testing
        doc = Nokogiri::HTML(open(url)) rescue break
        puts "Fetching podcasts from #{url}"
        podcasts = doc.xpath('//*[@id="selectedcontent"]/div/ul/li/a')

        podcasts.each do |podcast|
          itunes_url = podcast["href"]
          itunes_title = podcast.text
          itunes_id = itunes_url.split("/id").last
          podcast_url = "https://itunes.apple.com/lookup?id=#{itunes_id}&entity=podcast"
          puts "import #{podcast_url}"
          metadata = open(podcast_url){ |f| f.read }
          rss_url = JSON.parse(metadata)["results"].first["feedUrl"]
          Feed.where(
            itunes_url: itunes_url,
            itunes_title: itunes_title,
            rss_url: rss_url
          ).first_or_create
        end
      end
    end
  end
end
