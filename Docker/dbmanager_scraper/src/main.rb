# frozen_string_literal: true

require_relative 'db_manager'

# スクレイピングを行うクラス
class Main
  def initialize
    @db_manager = DbManager.new
  end

  def start
    @db_manager.store_data_to_s3
  end
end
main = Main.new
main.start
