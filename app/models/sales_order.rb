class SalesOrder < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :buyer
  belongs_to :account
  belongs_to :order_shipping_detail
  belongs_to :contact, class_name: "Contact", foreign_key: "contact_user_id"
  belongs_to :customer, class_name: "Customer", foreign_key: "customer_user_id"

  #Has Many Relationship
  has_many :manufacturinga
  has_many :sales_order_items, :dependent => :destroy

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  scope :with_invoice_active, -> { where('is_invoice_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("sales_orders.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("payment_status LIKE :search OR name LIKE :search
              OR status LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("uid :search OR grand_total :search", search: "%#{search_text}%")
    end
    return search
  end

  def self.search(params,current_user_id,is_paid)
    search = where("sales_orders.sales_user_id = ?",current_user_id)
    search = where("sales_orders.payment_status = ?","paid") if is_paid
    search = where("sales_orders.sales_user_id = ?",current_user_id)
    search = search.where('sales_orders.id = ?',params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('sales_orders.uid = ?',params[:uid]) if params[:uid].present?
    search = search.where('sales_orders.name = ?',params[:name]) if params[:name].present?
    search = search.where('sales_orders.grand_total = ?',params[:grand_total]) if params[:grand_total].present?
    search = search.where('sales_orders.customer_user_id = ?',params[:customer_user_id]) if params[:customer_user_id].present?
    search = search.where('sales_orders.status = ?',params[:status]) if params[:status].present?
    search = search.where('DATE(sales_orders.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('DATE(sales_orders.create_timestamp) = ?', params[:create_timestamp].to_date) if params[:create_timestamp].present?
    return search
  end

  def get_json_sales_order_index
    create_timestamp = self.create_timestamp.present? ? self.create_timestamp.strftime('%d %B, %Y') : self.create_timestamp
    as_json(only: [:id,:uid,:name,:grand_total,:status])
    .merge({code:"SO-#{self.id.to_s.rjust(4, '0')}",
      customer: self.customer.try(:user).try(:full_name),
      created_at:self.created_at.strftime('%d %B, %Y'),
      create_timestamp: create_timestamp,
      is_active: self.is_active,
    })
  end 

  def self.get_json_sales_orders
    sales_orders_list =[]
    SalesOrder.all.each do |sales_order|
      sales_orders_list << sales_order.get_json_sales_order_index
    end
    return sales_orders_list
  end

  def get_json_sales_order_show
    create_timestamp = self.create_timestamp.present? ? self.create_timestamp.strftime('%d %B, %Y') : self.create_timestamp
    update_timestamp = self.update_timestamp.present? ? self.update_timestamp.strftime('%d %B, %Y') : self.update_timestamp
    cancelled_at = self.cancelled_at.present? ? self.cancelled_at.strftime('%d %B, %Y') : self.cancelled_at
    paid_at = self.paid_at.present? ? self.paid_at.strftime('%d %B, %Y') : self.paid_at
    refunded_at = self.refunded_at.present? ? self.refunded_at.strftime('%d %B, %Y') : self.refunded_at
    shipped_at = self.shipped_at.present? ? self.shipped_at.strftime('%d %B, %Y') : self.shipped_at

    as_json(only: [:id,:uid,:name,:status,:cancel_reason,:payment_method,:subtotal,
      :tax,:discount,:grand_total,:buyer_id,:shipped,:marketplace_fee,:processing_fee])
    .merge({code:"SO-#{self.id.to_s.rjust(4, '0')}",
      customer: self.customer.try(:user).try(:full_name),
      contact: self.contact.try(:user).try(:full_name),
      create_timestamp: create_timestamp,
      update_timestamp: update_timestamp,
      cancelled_at: cancelled_at,
      paid_at: paid_at,
      refunded_at: refunded_at,
      buyer_name: self.buyer.name,
      buyer_email: self.buyer.email,
      buyer_phone_number: self.buyer.phone_number,
      shipping_name: self.order_shipping_detail.name,
      shipping_price: self.order_shipping_detail.price,
      shipping_address_line_1: self.order_shipping_detail.address_line_1,
      shipping_city: self.order_shipping_detail.city,
      shipping_state: self.order_shipping_detail.state,
      shipping_country: self.order_shipping_detail.country,
      shipping_postal_code: self.order_shipping_detail.postal_code,
      shipping_phone: self.order_shipping_detail.phone,
      shipping_tracking_code: self.order_shipping_detail.tracking_code,
      shipping_notes: self.order_shipping_detail.notes,
      shipped_at: shipped_at,
      is_active: !self.is_active,
      items: SalesOrderItem.get_json_sales_order_items(false,self.sales_order_items),
      invoices: Invoice.where(sales_order_id:self.id).with_active.get_json_invoices
    })
  end

  def get_json_sales_order_edit
    as_json(only: [:id, :customer_user_id, :contact_user_id])
    .merge({code:"SO-#{self.id.to_s.rjust(4, '0')}"})
  end

  def create_invoice
    invoice_attributes = self.attributes
    buyer_attributes = self.buyer.attributes
    order_shipping_detail_attributes = self.order_shipping_detail.attributes
    buyer_attributes['id'] = nil
    order_shipping_detail_attributes['id'] = nil
    invoice_attributes['id'] = nil
    buyer = Buyer.create(buyer_attributes)
    order_shipping_detail = OrderShippingDetail.create(order_shipping_detail_attributes)
    invoice_attributes['buyer_id'] = buyer.id
    invoice_attributes['order_shipping_detail_id'] = order_shipping_detail.id
    invoice = Invoice.create(invoice_attributes)
    return invoice
  end


  def self.refresh_for_account(account, date_from = 127.days.ago.to_date, date_to = DateTime.now.to_date)
    return false unless account.integration.logged_in?
    orders = account.integration.get_orders(date_from.to_datetime, date_to.to_datetime)
    puts orders
    orders.each { |order|
      process_external_order(account, order.with_indifferent_access)
    }
  end


  def self.sales_sales_orders(current_user)
    where("sales_orders.sales_user_id = ? AND sales_orders.is_active = ?",current_user.id,true)
  end

  def self.get_json_sales_orders_dropdown(sales_orders)
    list = []
    sales_orders.each do |sales_order|
      list << as_json(only: [])
      .merge({name:"SO-#{sales_order.id.to_s.rjust(4, '0')}",
        sales_order_id:sales_order.id,
      })
    end
    return list
  end

    private
      def self.process_external_order(account, order)
        if order_entry = account.sales_orders.find_by(:uid => order[:id])
            # update order
            SalesOrder.transaction do
                # update/create Buyer record
                buyer = order_entry.buyer
                if (order[:buyer][:id] rescue false)
                    buyer = account.marketplace.buyers.find_or_initialize_by(:uid => order[:buyer][:id])
                    buyer.update_attributes!(order[:buyer].slice(:name, :email, :phone_number).select { |k, v| !v.blank? })
                end
                # update OrderShippingDetail record
                unless order[:shipping].blank?
                    if shipping_detail = order_entry.order_shipping_detail
                        order_entry.order_shipping_detail.update_attributes!(order[:shipping].merge(:buyer_id => buyer.try(:id)))
                    else
                        shipping_detail = OrderShippingDetail.create!(order[:shipping].merge(:buyer_id => buyer.try(:id)))
                    end
                end
                # update Order record
                order_entry.update_attributes({
                        :buyer_id => buyer.try(:id),
                        :order_shipping_detail_id => shipping_detail.try(:id),
                        :update_timestamp => order[:last_update_at],
                        :status => order[:custom_status]
                    }.merge({ 
                        :grand_total => order[:totals][:grandtotal],
                        :subtotal => order[:totals][:subtotal],
                        :discount => order[:totals][:discount],
                        :tax => order[:totals][:tax] 
                    }.select { |k, v| !v.blank? }
                    ).merge(order.slice(:payment_status,
                        :paid_at, :refunded_at,
                        :shipped, :shipped_at,
                        :cancelled, :cancelled_at, :cancel_reason,
                        :notes, :payment_method))
                    )
                # TODO: update OrderListing records?
            end
        else
            # create order
            SalesOrder.transaction do
                # create/update Buyer record
                if (order[:buyer][:id] rescue false)
                    buyer = account.marketplace.buyers.find_or_initialize_by(:uid => order[:buyer][:id])
                    buyer.update_attributes!(order[:buyer].slice(:name, :email, :phone_number).select { |k, v| !v.blank? })
                end
                # create OrderShippingDetail record
                shipping_detail = OrderShippingDetail.create!(order[:shipping].merge(:buyer_id => buyer.try(:id))) unless order[:shipping].blank?
                # create Order record
                order_entry = account.sales_orders.create!({
                        :sales_user_id => account.user.id,
                        :buyer_id => buyer.try(:id),
                        :order_shipping_detail_id => shipping_detail.try(:id),
                        :uid => order[:id],
                        :status => order[:custom_status],
                        :create_timestamp => order[:created_at],
                        :update_timestamp => order[:last_update_at],
                        :grand_total => order[:totals][:grandtotal],
                        :subtotal => order[:totals][:subtotal],
                        :discount => order[:totals][:discount],
                        :tax => order[:totals][:tax],
                    }.merge(order.slice(
                        :payment_status,
                        :paid_at, :refunded_at,
                        :shipped, :shipped_at,
                        :cancelled, :cancelled_at, :cancel_reason,
                        :notes, :payment_method))
                    )
                # create OrderListing records
                order[:items].each { |item|
                    next if item[:item_id].blank? || (item[:quantity].try(:to_i) || 0) == 0
                    # account_listing = account.account_listings.find_by(:uid => item[:item_id])
                    # if (item[:price].try(:to_i) || 0) <= 0
                      #   if account_listing
                      #         item[:price] = account_listing.price
                      #   else
                      #         next
                      #   end
                    # end
                    order_entry.sales_order_items.create!(:uid => item[:item_id], :quantity => item[:quantity], :item_price => item[:price])
                }
            end
        end
      end
end
