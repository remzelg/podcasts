require 'open-uri'
require 'curb'

class ItunesFeedWorker
  include Sidekiq::Worker

  ALPHABET = ('A'..'Z').to_a + ["*"]
  BASE_URL = "https://itunes.apple.com/us/genre/podcasts-"
  CATEGORIES =  {
    # mt = media type. 2 indicates podcasts
    arts:                         "#{BASE_URL}arts/id1301?mt=2",
    business:                     "#{BASE_URL}business/id1321?mt=2",
    comedy:                       "#{BASE_URL}comedy/id1303?mt=2",
    education:                    "#{BASE_URL}education/id1304?mt=2",
    games_and_hobbies:            "#{BASE_URL}games-hobbies/id1323?mt=2",
    government_and_organizations: "#{BASE_URL}government-organizations/id1325?mt=2",
    health:                       "#{BASE_URL}health/id1307?mt=2",
    kids_and_family:              "#{BASE_URL}kids-family/id1305?mt=2",
    music:                        "#{BASE_URL}music/id1310?mt=2",
    news_and_politics:            "#{BASE_URL}news-politics/id1311?mt=2",
    religion_and_spirituality:    "#{BASE_URL}religion-spirituality/id1314?mt=2",
    science_and_medicine:         "#{BASE_URL}science-medicine/id1315?mt=2",
    society_and_culture:          "#{BASE_URL}society-culture/id1324?mt=2",
    sports_and_recreation:        "#{BASE_URL}sports-recreation/id1316?mt=2",
    tv_and_film:                  "#{BASE_URL}tv-film/id1309?mt=2",
    technology:                   "#{BASE_URL}technology/id1318?mt=2"
  }

  def perform
    import_categories
    find_feeds
  end

private
  def import_categories
    CATEGORIES.each do |k, v|
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
