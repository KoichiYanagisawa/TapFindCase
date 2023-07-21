# frozen_string_literal: true

require 'selenium-webdriver'

require_relative 'info_scraper'
require_relative 'image_scraper'

# スクレイピングを行うクラス
class Main
  attr_reader :driver, :options
  attr_accessor :wait, :urls

  def initialize
    setup_user_agents
    setup_options
    setup_driver
    @wait = Selenium::WebDriver::Wait.new(timeout: 20)
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

  def scraping
    @info_scraper.get_item_info(@wait, @driver)
  end
end

main = Main.new
main.scraping
