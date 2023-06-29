# frozen_string_literal: true

# レスポンスをファイルのように扱うgem
require 'open-uri'

# スクレイピングに使うgem
require 'nokogiri'

# 出力を見やすくするためのgem
require 'csv'

# 取得するURLを指定(今回は)
domain = 'https://qiita.com'
query = '/search?q=ruby'
url = domain + query

# urlを開いて、resに格納
res = URI.open(url)
sleep(1)

# HTMLをパースする
body = res.read
charset = res.charset
html = Nokogiri::HTML.parse(body, nil, charset)

# 結果を格納する配列
results = []
html.css('.style-3f8mxy').each do |node|
  title = node.css('.style-1toxh2v a').text
  page = node.css('a.style-1lvpob1').attribute('href').value
  results << [title, domain + page]
end

results.each do |result|
  result_url = result[1]
  article = URI.open(result_url)
  sleep(1)
  article_body = article.read
  charset = article.charset
  article_html = Nokogiri::HTML.parse(article_body, nil, charset)
  puts "タイトル：#{result[0]}"
  puts "URL：#{result_url}"
  puts "お気に入り：#{article_html.css('.style-1vpukh3').text}"
  puts "ストック数：#{article_html.css('.style-1grh9bf').text}"
  puts '---------------------------------'
end
