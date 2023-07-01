# frozen_string_literal: true

require 'selenium-webdriver'

# Scraperというクラスを作成
class Scraper
  attr_reader :driver, :options

  # 初期化メソッドを定義
  def initialize
    setup_user_agents # UserAgentのリストを作成
    setup_options # オプションを設定
    setup_driver # ドライバをセットアップ
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
  def search_item(url, items)
    retry_count = 0 # リトライカウンタを0で初期化
    begin
      puts "今から商品詳細ページのURLを取得します。リトライ回数は#{retry_count}回目です。"
      @driver.get(url) # 指定したURLにアクセス
      @driver.find_element(:id, 'query').send_keys(items, :enter) # 検索欄にアイテム名を入力してEnterキーを押す
      sleep(5) # 2秒待つ
      loop do # 次のページが存在する限りループ
        puts get_urls('.p-item_visual.is-biggerlinkBigger.s-biggerlinkHover_alpha') # 検索結果からアイテムのURLを取得
        break unless go_to_next_page # 次のページが存在しない場合、ループを抜ける
        sleep(5) # 2秒待つ
      end
    rescue StandardError => e # エラーが発生した場合
      puts "Error: #{e.message}" # エラーメッセージを出力
      retry_count += 1 # リトライカウンタを増やす
      retry if retry_count <= 3 # リトライカウンタが3以下であれば、再度試みる
      puts '検索が3回失敗しました' # 3回試しても失敗した場合、失敗メッセージを出力
    end
  end

  # 検索結果からアイテムのURLを取得するメソッドを定義
  def get_urls(class_name)
    urls = [] # URLを格納する配列を作成
    elements = @driver.find_elements(:css, class_name) # 検索結果の要素を取得
    elements.each do |element| # 要素を1つずつ取り出す
      urls << element.attribute('href') # 要素のhref属性を取得して配列に格納
    end
    urls # 配列を返す
  end

  # 次のページに遷移するメソッドを定義
  def go_to_next_page
    next_page_element = @driver.find_element(:css, '.p-pager_btn.p-pager_btn_next a') # 次のページへのリンクを取得
    next_page_element.click # リンクをクリックして次のページに移動
  rescue Selenium::WebDriver::Error::NoSuchElementError # リンクが存在しない場合
    false # falseを返す
  else
    true # リンクが存在する場合、trueを返す
  end
end

# Scraperのインスタンスを作成し、アイテムを検索
url = 'https://kakaku.com/'
items = 'iPhone ケース'
scraper = Scraper.new
scraper.search_item(url, items)
