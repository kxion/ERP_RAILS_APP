class Invoice < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :buyer
  belongs_to :account
  belongs_to :order_shipping_detail
  belongs_to :contact, class_name: "Contact", foreign_key: "contact_user_id"
  belongs_to :customer, class_name: "Customer", foreign_key: "customer_user_id"
  
  #Has Many Relationship
  has_many :sales_order_items, :dependent => :destroy
  has_many :ledger_entries
  has_many :return_wizards
  
  #Html Form Nested Attributes
  accepts_nested_attributes_for :buyer
  accepts_nested_attributes_for :order_shipping_detail

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }

  #After Create Call Function
  after_create :create_ledger_entry

  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("invoices.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("name LIKE :search OR status LIKE :search
              ", search: "%#{search_text}%")
      end
    else
      search = search.where("grand_total :search OR uid :search", search: "%#{search_text}%")
    end
    return search
  end

  def self.search(params,current_user_id,is_paid)
    search = where("invoices.sales_user_id = ?",current_user_id)
    search = search.where('invoices.id = ?',params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('invoices.uid = ?',params[:uid]) if params[:uid].present?
    search = search.where('invoices.name = ?',params[:name]) if params[:name].present?
    search = search.where('invoices.grand_total = ?',params[:grand_total]) if params[:grand_total].present?
    search = search.where('invoices.customer_user_id = ?',params[:customer_user_id]) if params[:customer_user_id].present?
    search = search.where('invoices.status = ?',params[:status]) if params[:status].present?
    search = search.where('DATE(invoices.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('DATE(invoices.create_timestamp) = ?', params[:create_timestamp].to_date) if params[:create_timestamp].present?
    return search
  end

  def get_json_invoices
    create_timestamp = self.create_timestamp.present? ? self.create_timestamp.strftime('%d %B, %Y') : self.create_timestamp
    is_deleted = self.is_active ? 'NO' : 'YES'
    as_json(only: [:id,:uid,:name,:grand_total,:status,:subtotal,
      :tax,:is_active])
    .merge({code:"INV-#{self.id.to_s.rjust(4, '0')}",
      customer: self.customer.try(:user).try(:full_name),
      created_at:self.created_at.strftime('%d %B, %Y'),
      create_timestamp: create_timestamp,
      order_code:"SO-#{self.sales_order_id.to_s.rjust(4, '0')}",
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      is_deleted: is_deleted,
    })
  end 

  def self.get_json_invoices
    sales_orders_list =[]
    Invoice.all.each do |sales_order|
      sales_orders_list << sales_order.get_json_invoices
    end
    return sales_orders_list
  end

  def get_json_invoice_show
    create_timestamp = self.create_timestamp.present? ? self.create_timestamp.strftime('%d %B, %Y') : self.create_timestamp
    update_timestamp = self.update_timestamp.present? ? self.update_timestamp.strftime('%d %B, %Y') : self.update_timestamp
    cancelled_at = self.cancelled_at.present? ? self.cancelled_at.strftime('%d %B, %Y') : self.cancelled_at
    paid_at = self.paid_at.present? ? self.paid_at.strftime('%d %B, %Y') : self.paid_at
    refunded_at = self.refunded_at.present? ? self.refunded_at.strftime('%d %B, %Y') : self.refunded_at
    shipped_at = self.shipped_at.present? ? self.shipped_at.strftime('%d %B, %Y') : self.shipped_at

    as_json(only: [:id,:uid,:name,:status,:cancel_reason,:payment_method,:subtotal,
      :tax,:discount,:grand_total,:buyer_id,:shipped,:marketplace_fee,:processing_fee,
      :profit_share_deductions, :net, :acquisition_cost,:is_active])
    .merge({code:"INV-#{self.id.to_s.rjust(4, '0')}",
      customer: self.customer.try(:user).try(:full_name),
      contact: self.contact.try(:user).try(:full_name),
      create_timestamp: create_timestamp,
      update_timestamp: update_timestamp,
      cancelled_at: cancelled_at,
      paid_at: paid_at,
      refunded_at: refunded_at,
      buyer_name: self.buyer.try(:name),
      buyer_email: self.buyer.try(:email),
      buyer_phone_number: self.buyer.try(:phone_number),
      shipping_name: self.order_shipping_detail.try(:name),
      shipping_price: self.order_shipping_detail.try(:price),
      shipping_address_line_1: self.order_shipping_detail.try(:address_line_1),
      shipping_city: self.order_shipping_detail.try(:city),
      shipping_state: self.order_shipping_detail.try(:state),
      shipping_country: self.order_shipping_detail.try(:country),
      shipping_postal_code: self.order_shipping_detail.try(:postal_code),
      shipping_phone: self.order_shipping_detail.try(:phone),
      shipping_tracking_code: self.order_shipping_detail.try(:tracking_code),
      shipping_notes: self.order_shipping_detail.try(:notes),
      shipped_at: shipped_at,
      items: SalesOrderItem.get_json_sales_order_items(false,self.sales_order_items),
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      order_code:"SO-#{self.sales_order_id.to_s.rjust(4, '0')}",
    })
  end

  def get_json_invoice_edit
    as_json(only: [:id,:customer_user_id,:contact_user_id,:sales_order_id,:name,:subtotal,
      :tax,:grand_total,:account_id,:uid,:buyer_id,:order_shipping_detail_id,
      :payment_status,:paid_at,:refunded_at,:shipped,:shipped_at,:cancelled,
      :cancelled_at,:cancel_reason,:notes,:payment_method,:create_timestamp,
      :update_timestamp,:discount,:marketplace_fee,:processing_fee,:status,
      :profit_share_deductions, :net, :acquisition_cost])
    .merge({code:"INV-#{self.id.to_s.rjust(4, '0')}",
      order_shipping_detail_attributes:{
        id:self.order_shipping_detail.try(:id),
        price:self.order_shipping_detail.try(:price),
        name:self.order_shipping_detail.try(:name),
        phone:self.order_shipping_detail.try(:phone),
        city:self.order_shipping_detail.try(:city),
        state:self.order_shipping_detail.try(:state),
        country:self.order_shipping_detail.try(:country),
        postal_code:self.order_shipping_detail.try(:postal_code),
        address_line_1:self.order_shipping_detail.try(:address_line_1),
        address_line_2:self.order_shipping_detail.try(:address_line_2),
        carrier:self.order_shipping_detail.try(:carrier),
        tracking_code:self.order_shipping_detail.try(:tracking_code),
        tracking_url:self.order_shipping_detail.try(:tracking_url),
        notes:self.order_shipping_detail.try(:notes),
        available_carriers:self.order_shipping_detail.try(:available_carriers),
        buyer_id:self.order_shipping_detail.try(:buyer_id),
        real_price:self.order_shipping_detail.try(:real_price),
      },
      buyer_attributes:{
        id:self.buyer.try(:id),
        email:self.buyer.try(:email),
        uid:self.buyer.try(:uid),
        name:self.buyer.try(:name),
        phone_number:self.buyer.try(:phone_number),
      },
    })
  end

  def self.sales_sales_order_invoices(current_user)
    where("invoices.sales_user_id = ? AND invoices.is_active = ?",current_user.id,true)
  end

  def self.get_json_sales_order_invoices_dropdown(sales_order_invoices)
    list = []
    sales_order_invoices.each do |sales_order_invoice|
      list << as_json(only: [])
        .merge({name:sales_order_invoice.name,
          invoice_id:sales_order_invoice.id,
        })
    end
    return list
  end
  private
    def create_ledger_entry
      acc_account = AccAccount.find_by_default_type("CreateInvoice") 
      LedgerEntry.create(subject:"Created By Receivables Invoice",customer_id:self.customer_user_id,acc_account_id:acc_account.id,invoice_id:self.id,amount:self.grand_total,sales_user_id:self.sales_user_id)
    end

end