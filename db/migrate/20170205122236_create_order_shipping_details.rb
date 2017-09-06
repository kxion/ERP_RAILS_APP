class CreateOrderShippingDetails < ActiveRecord::Migration
  def change
    create_table :order_shipping_details do |t|
      t.decimal :price, :precision => 16, :scale => 4
      t.string :name
      t.string :phone
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.string :address_line_1
      t.string :address_line_2
      t.string :carrier
      t.string :tracking_code
      t.string :tracking_url
      t.text :notes
      t.text :available_carriers
      t.integer :buyer_id
      t.decimal :real_price, :precision => 16, :scale => 2

      t.timestamps null: false
    end
  end
end
