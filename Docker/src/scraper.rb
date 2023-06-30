# frozen_string_literal: true

# selenium-webdriverを使う準備
require 'selenium-webdriver'


options = Selenium::WebDriver::Chrome::Options.new

options.add_argument('--headless') # ヘッドレスモードを有効にする
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

driver = Selenium::WebDriver.for :chrome, options: options


# # タイムアウトを設定
# driver.manage.timeouts.implicit_wait = 10

# # リトライ回数を設定
# driver.manage.timeouts.page_load = 5
# googleのトップページを開く
driver.navigate.to 'https://www.google.com/'

# ページのタイトルを取得して表示
puts driver.title
