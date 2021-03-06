require 'nokogiri'
require 'open-uri'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "shopify_apps.db"
)
# Custom AR models
require './category.rb'
require './application_link.rb'

def parse_app_links(doc)
  doc.css('.ui-app-card a').map do |app_card|
    app_link = app_card['href']
    query_index = app_link.index("?")
    app_link.slice(0..(query_index ? query_index - 1 : -1))
  end
end

def get_app_links(url)
  begin
    p "Parsing url #{url}"
    file = URI.open(url)
    doc = Nokogiri::HTML(file)
    parse_app_links(doc)
  rescue OpenURI::HTTPError => e
    p "Error while parsing #{e.message}"
    return false
  end
end

def save_application_link(url)
  existing_item = ApplicationLink.find_by_url(url)
  # upsert wasn't working on the server for some reason
  if existing_item
    existing_item.last_seen_in_category = Time.now
    existing_item.save!
  else
    item = ApplicationLink.new({url: url, last_seen_in_category: Time.now})
    item.save!
  end
end

def scrape_next_category
  category = Category.order(last_scraped_at: :asc).first
  category.last_page_scraped += 1
  category.last_scraped_at = Time.now
  category.save!
  
  app_links = get_app_links(category.url + "?page=#{category.last_page_scraped}")
  if app_links
    app_links.each { |link| save_application_link(link) }
  else
    # in case of an error reset last_page_scraped, to start from the beginning
    category.last_page_scraped = 0
    category.save!
  end
end

scrape_next_category
