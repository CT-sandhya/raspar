require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'raspar'

class Leguide
  include Raspar

  SHIPPING_PROC = Proc.new{|text, ele| text.split(':').last.strip}
  DATA_PROC = Proc.new{|text, ele| Nokogiri::HTML.parse(text).text.split(':').last.strip}

  domain 'http://www.leguide.com'

  #External attrs
  attr :name, '.block_bpu_feature .p b'
  attr :specifications, '#page2', :eval => :build_specification

  collection :product, '.offers_list li' do
    attr :alt_name,       '.gopt.offer.t'
    attr :image,          '.lg_photo img', :attr => 'src'
    attr :price,          '.price .euro.gopt'
    attr :orignal_price,  '.price .barre'
    attr :desc,           '.gopt.description,.info .description'
    attr :vendor,         '.name a'
    attr :availability,   '.av', :attr => 'data-value', :eval => DATA_PROC
    attr :delivery_time,  '.dv', :attr => 'data-value', :eval => DATA_PROC
    attr :shipping_price, '.delivery.gopt', :eval => SHIPPING_PROC
  end

  #For External attr define class method because it evalute only once for all object in sigle html doc.
  def build_specification(val, ele)
    attrs = {}
    ele.search('li').each do |li|
      attrs[li.search('.title').first.content] =  li.search('.value').first.content
    end
    attrs
  end

  #For normal attr use instance method 
  def parse_price(val, ele)
    val.gsub(/[ ,]/, ' ' => '', ',' => '.')
  end

end

url = 'http://www.leguide.com/sb/bp/5010500/hotpoint_ariston/ECO9F_149_FRS/55743410.htm'
url = 'http://www.leguide.com/electromenager.htm'
p ARGV[0] || url
#page = open(ARGV[0] || url).read().gsub(/[[:cntrl:]@]/, '')
page = open(ARGV[0] || url).read()

Raspar.parse(url, page).each do |o|
  pp o
  p "*"*40  
end
