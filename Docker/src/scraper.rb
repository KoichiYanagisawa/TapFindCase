# frozen_string_literal: true

require 'selenium-webdriver'
require 'set'

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
    @item_info = [] # 商品情報を格納する配列を作成
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

# アイテムの詳細ページから情報を取得するメソッドを定義
def get_item_info
  @urls.each_with_index do |url, index| # Setの中身を1つずつ取り出す
    retry_count = 0
    begin
      # 現在の処理を5/89のように表示する
      puts "現在の処理: #{index + 1}/#{@urls.length}"
      item_info = {} # 商品情報を格納するハッシュを作成
      @driver.get(url) # 指定したURLにアクセス
      sleep(3) # 3秒待つ
      item_info[:name] = @wait.until { @driver.find_element(:xpath, '//div[@id="titleBox"]/div[1]/h2[@itemprop="name"]').text } # 商品名を取得
      item_info[:maker] = @wait.until { @driver.find_element(:xpath, '//*[@id="relateList"]/li/a').text } # メーカー名を取得
      item_info[:url] = @wait.until { @driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/div[3]/span/a').attribute('href') } # 商品URLを取得
      item_info[:price] = @wait.until { @driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/p/span[@class="priceTxt"]').text } # 価格を取得
      @item_info << item_info # item_infoをitem_info配列に追加
    rescue StandardError => e
      puts "get_item_info: #{e.message}"
      retry_count += 1
      retry if retry_count <= 3
      puts "URL #{url} に対するリトライが3回失敗しました"
    end
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
end

# Scraperのインスタンスを作成し、アイテムを検索
# url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec103=24,25,26,28,29,30,31,32,33,34,35,36,37,38'
url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec103=34'
scraper = Scraper.new
scraper.search_item(url)
scraper.get_item_info
scraper.item_info.each do |item_info|
  puts item_info[:name]
  puts item_info[:maker]
  puts item_info[:url]
  puts item_info[:price]
end
