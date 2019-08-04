require 'rest-client'
require 'csv'
require 'pry'
require 'nokogiri'
@url = "https://www.homelegance.com"
@categories
@sub_categories
@product_urls = []

def get_categories
  req = RestClient.get(@url)
  noko = Nokogiri::HTML(req)
  @categories = noko.xpath('//*[@id="menuholder"]/ul').children.children.select { |s| s.name == "a"}.map {|m| {name: m.text.strip, url: m.attributes["href"].value}}
  @sub_categories = noko.css("li.mainNav ul li a").map {|m| {name: m.text.strip, url: @url + m.attributes["href"].value[0..-2] + "?count=-1&pageNo=1"}}
end

def get_products(category, url)
  products = []
  req = RestClient.get(url)
  noko = Nokogiri::HTML(req)
  products = noko.css(".product_list-a a").map {|e| e.attributes["href"].value}
  products = products + noko.css(".product_list-b a").map {|e| e.attributes["href"].value}
  @product_urls += products.uniq
end

def get_product(url)
  req = RestClient.get(url)
  noko = Nokogiri::HTML(req)
  images = noko.css(".cloud-zoom-gallery").map{|e| @url + e.attributes["href"].value}
  desc = noko.xpath("/html/body/div[2]/div/div[9]").text.strip
  product_items = noko.css("#master_model_table tr")[1..-1].map {|e| {number: e.children[1].children[1].text, description: e.children[3].text, dimensions: e.children[5].text.strip}}
  name = get_number(noko.css(".share span").text, url.split("_")[1].split("/")[0])
  [name, images, desc, product_items.count]
end

def get_number(number, category)
  if category == "bedroomcollections"
    if number =~/Collection/
      return number.split(" ").first + "-1*4"
    end
  end
end
print get_product "https://www.homelegance.com/bedroom_bedroomcollections/1600Bedroom.htm"
