# encoding: utf-8
require "sinatra/base"
require "nokogiri"
require "open-uri"
require "jbuilder"

class BusNow < Sinatra::Base
  BASE_URL = "http://www.urbs.curitiba.pr.gov.br/horario-de-onibus/"

  get "/api/schedules/:code" do |code|
    content_type :json
    result = crawl_page "#{code}"
    render result
  end

  get "/api/schedules/:code/:type" do |code, type|
    content_type :json
    result = crawl_page "#{code}/#{type}"
    render result
  end

  private
  def crawl_page(url)
    items = []
    result = []
    page = Nokogiri::HTML.parse(open(BASE_URL + url), nil, "UTF-8")
    name = page.css("h2.left.schedule")[0].content
    page.css("div.bg-white.round-bl-60.width96.margin-medium-top.clearfix").each do |line|
      station = line.css("h3.schedule")[0].content
      type = line.css("p.grey.margin0")[0].content.match("([^-]+$)")[0].strip
      schedules = line.css("ul > li").map { |s| s.content }
      items << { :station => station, :type => type, :schedules => schedules }
    end
    result << { :name => name, :items => items }
  end

  private
  def render(result)
    Jbuilder.encode do |json|
      json.name result[0][:name]
      json.items result[0][:items] do |item|
        json.station item[:station]
        json.type item[:type]
        json.schedules item[:schedules]
      end
    end
  end
end