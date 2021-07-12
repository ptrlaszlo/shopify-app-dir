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
require './application_snapshot.rb'

def parse_app_details(doc)
  attributes = {}

  attributes["name"] = doc.css('.ui-app-store-hero__header__app-name')&.first&.content

  doc.css('.reviews-summary__rating-breakdown').each do |rating|
    number_of_stars = rating.css('.ui-star-rating').first["data-rating"]
    number_of_ratings = rating.css('.reviews-summary__review-count a')&.first&.content&.delete_prefix("(")&.delete_suffix(")")

    attributes[number_of_stars] = number_of_ratings || "0"
  end

  categories = doc.css('.ui-app-store-hero__container .ui-app-store-hero__kicker a').map do |category|
    category["href"].delete_prefix("/browse/")
  end

  attributes["categories"] = categories

  attributes
end

def get_app_details(url)
  begin
    p "Parsing url #{url}"
    file = URI.open(url)
    doc = Nokogiri::HTML(file)
    parse_app_details(doc)
  rescue OpenURI::HTTPError => e
    p "Error while parsing #{e.message}"
    return false
  end
end

def save_app_snapshot(app_link, app_details)
  app = ApplicationSnapshot.new({
    application_link: app_link,
    name: app_details["name"],
    one_star: app_details["1"],
    two_stars: app_details["2"],
    three_stars: app_details["3"],
    four_stars: app_details["4"],
    five_stars: app_details["5"],
    categories: Category.where(name: app_details["categories"])
  })
  app.save!
end

def scrape_next_app
  app_link = ApplicationLink.order(last_scraped_at: :asc).first
  app_link.last_scraped_at = Time.now
  app_link.save!

  app_details = get_app_details(app_link.url)
  if app_details
    save_app_snapshot(app_link, app_details)
  end
end

scrape_next_app
