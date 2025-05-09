class AddLinksToBanners < ActiveRecord::Migration[7.1]
  def change
    add_column :banners, :desktop_links, :string
    add_column :banners, :mobile_links, :string
  end
end
