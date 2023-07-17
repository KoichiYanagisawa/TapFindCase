class ChangeEcSiteUrlInProducts < ActiveRecord::Migration[7.0]
  def up
    change_column :products, :ec_site_url, :string, limit: 500
  end

  def down
    change_column :products, :ec_site_url, :string, limit: 255
  end
end
