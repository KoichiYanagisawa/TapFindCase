# frozen_string_literal: true

require 'selenium-webdriver'

require_relative 'url_scraper'
require_relative 'info_scraper'
require_relative 'image_scraper'
require_relative 'db_manager'

# スクレイピングを行うクラス
class Main
  attr_reader :driver, :options
  attr_accessor :wait, :urls

  def initialize
    setup_user_agents
    setup_options
    setup_driver
    @wait = Selenium::WebDriver::Wait.new(timeout: 20)
    @url_scraper = URLScraper.new
    @info_scraper = InfoScraper.new
    @image_scraper = ImageScraper.new
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

  def setup_driver
    @driver = Selenium::WebDriver.for :chrome, options: @options
    @driver.manage.timeouts.implicit_wait = 20
    @driver.manage.timeouts.page_load = 20
  end

  def scraping(url)
    @url_scraper.search_item(@wait, @driver, url)
    @info_scraper.get_item_info(@wait, @driver, @url_scraper.urls)
    DbManager.delete_unchecked_data
  end
end

# Scraperのインスタンスを作成し、アイテムを検索
# url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec103=24,25,26,28,29,30,31,32,33,34,35,36,37,38'
# url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec102=1&pdf_Spec103=31,32,34,35,36'
url = 'https://kakaku.com/keitai/mobilephone-accessories/itemlist.aspx?pdf_Spec103=34'
main = Main.new
main.scraping(url)
