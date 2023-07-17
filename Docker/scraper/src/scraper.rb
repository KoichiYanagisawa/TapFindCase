# frozen_string_literal: true

require 'selenium-webdriver'
require 'set'
require 'active_record'
require 'mysql2'
require 'yaml'
require 'dotenv/load'
require 'erb'
require 'net/http'
require 'uri'

db_config = YAML.safe_load(ERB.new(File.read('./config/database.yml')).result, aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])

# 機種名のクラス
class Model < ActiveRecord::Base
  has_many :product_models
  has_many :products, through: :product_models
end

# 商品と機種名の中間テーブルのクラス
class ProductModel < ActiveRecord::Base
  belongs_to :product
  belongs_to :model
end

# 写真の保存先を管理するクラス
class Image < ActiveRecord::Base
  belongs_to :product
  validates :image_url, :thumbnail_url, presence: true
end

# 商品のクラス
class Product < ActiveRecord::Base
  has_many :product_models
  has_many :models, through: :product_models
  has_many :images
  validates :name, :maker, :price, :ec_site_url, presence: true
end

# スクレイピングを行うクラス
class Scraper
  attr_reader :driver, :options
  attr_accessor :item_info

  def initialize
    setup_user_agents
    setup_options
    setup_driver
    @wait = Selenium::WebDriver::Wait.new(timeout: 20)
    @urls = Set.new
  end

  def setup_user_agents
    @user_agents = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5.1 Safari/605.1.1',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.58'
    ]
  end

  def setup_options
    @options = Selenium::WebDriver::Chrome::Options.new
    @options.add_argument('--headless')
    @options.add_argument('--no-sandbox')
    @options.add_argument('--disable-dev-shm-usage')
    @options.add_argument('--disable-gpu')
    @options.add_argument("--user-agent=#{@user_agents.sample}")
  end

  # ドライバをセットアップするメソッドを定義
  def setup_driver
    @driver = Selenium::WebDriver.for :chrome, options: @options # オプションをセットしてChromeを起動
    @driver.manage.timeouts.implicit_wait = 20 # タイムアウトを設定
    @driver.manage.timeouts.page_load = 20 # ページロードのタイムアウトを設定
  end

  # アイテムを検索するメソッドを定義
  def search_item(url)
    retry_count = 0 # リトライカウンタを0で初期化
    begin
      puts "今から商品詳細ページのURLを取得します。リトライ回数は#{retry_count}回目です。"
      @driver.get(url) # 指定したURLにアクセス
      loop do # 次のページが存在する限りループ
        sleep(3) # 3秒待つ
        get_urls('//a[@class="ckitanker"]') # 検索結果からアイテムのURLを取得する
        break unless go_to_next_page # 次のページが存在しない場合、ループを抜ける
        retry_count = 0 # リトライカウンタを0に戻す
      end
    rescue StandardError => e # エラーが発生した場合
      puts "search_item: #{e.message}" # エラーメッセージを出力
      retry_count += 1 # リトライカウンタを増やす
      retry if retry_count <= 3 # リトライカウンタが3以下であれば、再度試みる
      puts '検索が3回失敗しました' # 3回試しても失敗した場合、失敗メッセージを出力
    end
  end

  # 検索結果からアイテムのURLを取得するメソッドを定義
  def get_urls(xpath)
    elements = @wait.until { @driver.find_elements(:xpath, xpath) } # 検索結果の要素を取得
    elements.each do |element| # 要素を1つずつ取り出す
      @urls.add(element.attribute('href')) # SetにURLを追加（重複は自動的に除外される）
    end
    puts "現在のURL取得数:#{@urls.size}"
  rescue Selenium::WebDriver::Error::TimeOutError => e
    puts "get_urls: #{e.message}"
  end

  # 次のページに遷移するメソッドを定義
  def go_to_next_page
    next_page_element = @wait.until { @driver.find_element(:xpath, '//a/img[@class="pageNextOn"]') } # 次のページへのリンクを取得
    next_page_element.click # リンクをクリックして次のページに移動
  rescue Selenium::WebDriver::Error::TimeoutError # リンクが存在しない場合
    puts 'go_to_next_page:次のページが見つかりませんでした' # メッセージを出力
    false # falseを返す
  else
    true # リンクが存在する場合、trueを返す
  end

  def get_item_info
    @urls.each_with_index do |url, index|
      retry_on_error do
        puts "現在の処理: #{index + 1}/#{@urls.length}"
        @driver.get(url)
        sleep(3)
        item_info = extract_item_info
        item_info[:models] = extract_models
        item_info[:image_url], item_info[:thumbnail_url] = get_item_images(@driver.current_url)
        store_data_to_db(item_info)
      end
    end
  end

  def extract_item_info
    item_info = {}
    raw_name = @wait.until { @driver.find_element(:xpath, '//div[@id="titleBox"]/div[1]/h2[@itemprop="name"]').text }
    name, color = split_name_and_color(raw_name)
    item_info[:name] = name
    item_info[:color] = color
    item_info[:maker] = @wait.until { @driver.find_element(:xpath, '//*[@id="relateList"]/li/a').text }
    item_info[:ec_site_url] = decode_url(@wait.until { @driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/div[3]/span/a').attribute('href') })
    item_info[:price] = @wait.until { @driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/p/span[@class="priceTxt"]').text }
    item_info
  end

  def split_name_and_color(item_name)
    color = item_name.match(/\[(.*?)\]/)
    name = item_name.gsub(/\[(.*?)\]/, '').strip
    color = color[1] if color
    return name, color
  end

  def decode_url(url)
    uri = URI.parse(url)
    params = CGI.parse(uri.query)
    URI.decode_www_form_component(params['Url'][0])
  end

  def extract_models
    model_info_text = @wait.until { @driver.find_element(:xpath, '//div[@id="specBox"]/p').text }
    models = model_info_text.match(/対応機種：(iPhone .+)/)[1].split(/\/|\s\/\s/)
    models.map do |model|
      model = model.gsub(/(\s第)(\d+)(世代)/, '(第\2世代)')  # 既存の正規表現
      model = model.gsub(/SE2/, 'SE(第2世代)')  # 新しい正規表現: SE2 を SE(第2世代) に変換
      model = model.gsub(/SE3/, 'SE(第3世代)')  # 新しい正規表現: SE3 を SE(第3世代) に変換
      model = "iPhone #{model}" unless model.include?("iPhone")
      model.strip
    end
  end

  # 商品IDを取得する
  def get_item_id(url)
    url.match(/https:\/\/kakaku\.com\/item\/(K\d+)\//)[1]
  end

  # 画像一覧ページのURLを生成する
  def generate_image_list_url(item_id)
    "https://kakaku.com/item/#{item_id}/images/"
  end

  # サムネイル要素を取得する
  def get_thumbnail_elements
    @wait.until { @driver.find_elements(:xpath, '//div[@class="zoomimgList"]//img') }
  end

  # 大きな画像のURLを取得する
  def get_large_image_url
    @wait.until { @driver.find_element(:xpath, '//img[@class="zoomimg"]').attribute('src') }
  end

  # ローカルに画像を保存する
  def save_image(image_url, filename, is_thumbnail = false)
    file_path = nil
    uri = URI(image_url)
    directory = is_thumbnail ? "/root/src/thumbnails" : "/root/src/images"
    file_path = "#{directory}/#{filename}.jpg"

    retry_on_error do
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri

        http.request request do |response|
          open file_path, "wb" do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
    end

    file_path
  end

  # 商品画像を取得する
  def get_item_images(url)
    puts "商品画像を取得します: #{url}"

    retry_on_error do
      item_id = get_item_id(url)
      image_list_url = generate_image_list_url(item_id)

      @driver.get(image_list_url)
      sleep(3)

      thumbnail_elements = get_thumbnail_elements
      thumbnail_file_paths = []
      image_file_paths = []

      thumbnail_elements.each_with_index do |thumbnail_element, i|
        # サムネイルを保存
        thumbnail_url = thumbnail_element.attribute('src')
        thumbnail_file_path = save_image(thumbnail_url, "#{item_id}_thumbnail_#{i}", true)
        thumbnail_file_paths << thumbnail_file_path

        # サムネイルをクリックして大きい画像を表示
        thumbnail_element.click
        sleep(3)

        # 大きな画像を保存
        image_url = get_large_image_url
        image_file_path = save_image(image_url, "#{item_id}_large_#{i}")
        image_file_paths << image_file_path
      end

      [image_file_paths, thumbnail_file_paths]
    end
  end

  def store_data_to_db(item_info)
    ActiveRecord::Base.transaction do
      product = update_or_create_product(item_info)
      item_info[:models].each do |model_name|
        model = Model.find_or_create_by!(model: model_name)
        ProductModel.find_or_create_by!(product: product, model: model)
      end
      update_or_create_image(item_info, product.id)
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "store_data_to_db: #{e.message}"
  end

  def update_or_create_product(item_info)
    product = Product.find_or_initialize_by(name: item_info[:name], maker: item_info[:maker], color: item_info[:color])
    product.assign_attributes(
      ec_site_url: item_info[:ec_site_url],
      price: item_info[:price],
      checked_at: Time.now
    )
    product.save! if product.new_record? || product.changed?
    product
  end

  def update_or_create_image(item_info, product_id)
    image = Image.find_or_initialize_by(product_id: product_id)
    image.assign_attributes(
      image_url: item_info[:image_url],
      thumbnail_url: item_info[:thumbnail_url]
    )
    image.save! if image.new_record? || image.changed?
  end

  def retry_on_error
    retry_count = 0
    begin
      yield
    rescue StandardError => e
      puts "Error: #{e.message}"
      retry_count += 1
      retry if retry_count <= 3
      puts 'リトライが3回失敗しました'
    end
  end

  # 一定期間確認がなかったデータを削除するメソッドを定義
  def delete_unchecked_data
    Product.where('checked_at < ?', 1.week.ago).destroy_all
  end
end

# Scraperのインスタンスを作成し、アイテムを検索
# url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec103=24,25,26,28,29,30,31,32,33,34,35,36,37,38'
# url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec103=34'
url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec102=1&pdf_Spec103=31,32,34,35,36'
scraper = Scraper.new
scraper.search_item(url)
scraper.get_item_info
scraper.delete_unchecked_data
