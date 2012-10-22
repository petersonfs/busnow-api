# encoding: utf-8
require "sinatra/base"
require "nokogiri"
require "open-uri"
require "jbuilder"

class BusaoCwb < Sinatra::Base
  BASE_URL = "http://www.urbs.curitiba.pr.gov.br/horario-de-onibus/"

  get "/api/schedules/:code.json" do |code|
    content_type :json
    items = []

    page = Nokogiri::HTML.parse(open(BASE_URL + "#{code}"), BASE_URL, "UTF-8")
    name = page.css("h2.left.schedule")[0].content
    page.css("div.bg-white.round-bl-60.width96.margin-medium-top.clearfix").each do |line|
      station = line.css("h3.schedule")[0].content
      type = line.css("p.grey.margin0")[0].content.match("([^-]+$)")[0].strip
      schedules = line.css("li.bold").map { |s| s.content }
      items << { :station => station, :type => type, :schedules => schedules }
    end

    Jbuilder.encode do |json|
      json.name name
      json.items items do |item|
        json.station item[:station]
        json.type item[:type]
        json.schedules item[:schedules]
      end
    end
  end
end