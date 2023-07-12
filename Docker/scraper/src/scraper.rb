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

# database.ymlを読み込む設定
db_config = YAML.load(ERB.new(File.read('./config/database.yml')).result, aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])

# ModelのActiveRecordモデルを定義します
class Model < ActiveRecord::Base
  has_many :product_models
  has_many :products, through: :product_models
end

# ProductModelのActiveRecordモデルを定義します
class ProductModel < ActiveRecord::Base
  belongs_to :product
  belongs_to :model
end

# ImageのActiveRecordモデルを定義します
class Image < ActiveRecord::Base
  belongs_to :product
  validates :image_url, :thumbnail_url, presence: true
end

# ProductのActiveRecordモデルを更新します
class Product < ActiveRecord::Base
  has_many :product_models
  has_many :models, through: :product_models
  has_many :images
  validates :name, :maker, :price, :ec_site_url, presence: true
end

# Scraperというクラスを作成
class Scraper
  attr_reader :driver, :options
  attr_accessor :item_info

  # 初期化メソッドを定義
  def initialize
    setup_user_agents # UserAgentのリストを作成
    setup_options # オプションを設定
    setup_driver # ドライバをセットアップ
    @wait = Selenium::WebDriver::Wait.new(timeout: 20) # 明示的に待ち時間を設定
    @urls = Set.new # 商品詳細ページのURLを格納するSetを作成
  end

  # UserAgentのリストを作成するメソッドを定義
  def setup_user_agents
    @user_agents = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5.1 Safari/605.1.1',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.58'
    ]
  end

  # オプションを設定するメソッドを定義
  def setup_options
    @options = Selenium::WebDriver::Chrome::Options.new # インスタンスを作成
    @options.add_argument('--headless') # ヘッドレスモードで実行
    @options.add_argument('--no-sandbox') # サンドボックスを無効にする
    @options.add_argument('--disable-dev-shm-usage') # メモリファイルの場所を指定する
    @options.add_argument('--disable-gpu') # GPUを使わない
    @options.add_argument("--user-agent=#{@user_agents.sample}") # UserAgentをランダムに指定
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

  # アイテムの詳細ページから情報を取得するメソッドを定義
  def get_item_info
    @urls.each_with_index do |url, index| # Setの中身を1つずつ取り出す
      retry_count = 0
      begin
        # 現在の処理の進捗を表示する
        puts "現在の処理: #{index + 1}/#{@urls.length}"
        item_info = {} # 商品情報を格納するハッシュを作成
        @driver.get(url) # 指定したURLにアクセス
        sleep(3) # 3秒待つ
        item_info[:name] = @wait.until { @driver.find_element(:xpath, '//div[@id="titleBox"]/div[1]/h2[@itemprop="name"]').text } # 商品名を取得
        item_info[:maker] = @wait.until { @driver.find_element(:xpath, '//*[@id="relateList"]/li/a').text } # メーカー名を取得
        item_info[:ec_site_url] = @wait.until { @driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/div[3]/span/a').attribute('href') } # 商品URLを取得
        uri = URI.parse(@wait.until { @driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/div[3]/span/a').attribute('href') })
        params = CGI.parse(uri.query)
        item_info[:ec_site_url] = URI.decode_www_form_component(params['Url'][0])
        item_info[:price] = @wait.until { @driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/p/span[@class="priceTxt"]').text } # 価格を取得
        item_info[:image_url], item_info[:thumbnail_url] = get_item_images(@driver.current_url) # 商品画像とサムネイル画像のURLを取得
        @driver.get(url) # 指定したURLにアクセス
        sleep(3) # 3秒待つ
        model_info_text = @wait.until { @driver.find_element(:xpath, '//div[@id="specBox"]/p').text }
        models = model_info_text.match(/対応機種：(iPhone .+)/)[1].split(/\/|\s\/\s/) # "対応機種："の後の文字列を取得し、スラッシュ('/')またはスペース+スラッシュ+スペース(' / ')で分割
        models.each do |model|
          model = model.gsub(/(\s第)(\d+)(世代)/, '(第\2世代)') # " 第X世代" を "第X世代" に統一
          model = "iPhone #{model}" unless model.include?("iPhone") # "iPhone"が含まれていない場合は、"iPhone"を追加
          item_info[:model] = model.strip # モデル名を取得（前後の空白を削除）
          puts "モデル名:#{item_info[:model]}"
          store_data_to_db(item_info) # 商品データをデータベースに保存
        end

        # 今のURLを取得して、商品画像を取得する
        # get_item_images(@driver.current_url)

      rescue StandardError => e
        puts "get_item_info: #{e.message}"
        retry_count += 1
        retry if retry_count <= 3
        puts "URL #{url} に対するリトライが3回失敗しました"
      end
    end
  end

  # 商品画像を取得するメソッドを定義
  def get_item_images(url)
    puts "商品画像を取得します: #{url}"
    retry_count = 0
    image_file_paths = []
    thumbnail_file_paths = []

    begin
      # 商品IDを取得
      item_id = url.match(/https:\/\/kakaku\.com\/item\/(K\d+)\//)[1]

      # 画像一覧ページのURLを作成
      image_list_url = "https://kakaku.com/item/#{item_id}/images/"

      # 画像一覧ページにアクセス
      @driver.get(image_list_url)
      sleep(3) # 3秒待つ

      # 小さい画像の要素を取得
      thumbnail_elements = @wait.until { @driver.find_elements(:xpath, '//div[@class="zoomimgList"]//img') }

      # 小さい画像の要素の数だけループ
      thumbnail_elements.each_with_index do |thumbnail_element, i|
        # 小さい画像のURLを取得
        thumbnail_url = thumbnail_element.attribute('src')

        # 小さい画像を保存
        thumbnail_file_path = save_image(thumbnail_url, "#{item_id}_thumbnail_#{i}", true)
        thumbnail_file_paths << thumbnail_file_path

        # 小さい画像をクリックして大きい画像を表示
        thumbnail_element.click
        sleep(3) # 3秒待つ

        # 大きい画像のURLを取得
        image_url = @wait.until { @driver.find_element(:xpath, '//img[@class="zoomimg"]').attribute('src') }

        # 大きい画像を保存
        image_file_path = save_image(image_url, "#{item_id}_large_#{i}")
        image_file_paths << image_file_path
      end

    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "URL #{url} に対する画像取得が終了しました"
    rescue StandardError => e
      puts "get_item_images: #{e.message}"
      retry_count += 1
      retry if retry_count <= 3
      puts "URL #{url} に対する画像取得が3回失敗しました"
    end

    return image_file_paths, thumbnail_file_paths
  end

  # 画像を保存するメソッドを定義
  def save_image(image_url, filename, is_thumbnail = false)
    file_path = nil

    begin
      uri = URI(image_url)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri

        http.request request do |response|
          # 保存するディレクトリを指定
          directory = is_thumbnail ? "/root/src/thumbnail" : "/root/src/images"
          file_path = "#{directory}/#{filename}.jpg"
          open file_path, "wb" do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end

    rescue => e
      puts "get_item_images: #{e.message}"
    end

    return file_path
  end

  # 商品データを重複なく保存するメソッドを定義
  def store_data_to_db(item_info)
    puts "商品名:#{item_info[:name]}をDBに保存します"

    ActiveRecord::Base.transaction do
      product = Product.find_or_initialize_by(name: item_info[:name], maker: item_info[:maker])

      # URL, 価格が異なる場合、または新規のレコードである場合、データを更新する
      if product.new_record? || product.ec_site_url != item_info[:ec_site_url] || product.price != item_info[:price]
        product.attributes = {
          ec_site_url: item_info[:ec_site_url],
          price: item_info[:price],
          checked_at: Time.now # 商品を確認した日時を更新
        }
        product.save!
      end

      # productが正常に作成または更新された場合のみ、modelとの関連付けを行う
      model = Model.find_or_create_by!(model: item_info[:model])
      ProductModel.find_or_create_by!(product: product, model: model)

      # 画像データをimagesテーブルに保存
      # 商品画像とサムネイル画像が異なる場合、または新規のレコードである場合、データを更新する
      image = Image.find_or_initialize_by(product_id: product.id)
      if image.new_record? || image.image_url != item_info[:image_url] || image.thumbnail_url != item_info[:thumbnail_url]
        image.attributes = {
          image_url: item_info[:image_url],
          thumbnail_url: item_info[:thumbnail_url]
        }
        image.save!
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "store_data_to_db: #{e.message}"
  end

  # 一定期間確認がなかったデータを削除するメソッドを定義
  def delete_unchecked_data
    Product.where('checked_at < ?', 1.week.ago).destroy_all
  end
end

# Scraperのインスタンスを作成し、アイテムを検索
# url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec103=24,25,26,28,29,30,31,32,33,34,35,36,37,38'
url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec103=34'
scraper = Scraper.new
scraper.search_item(url)
scraper.get_item_info
scraper.delete_unchecked_data
