class ReturnWizard < ActiveRecord::Base

  #Belongs To Relationship
  belongs_to :customer
  belongs_to :invoice

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }

  #After Create Call Function
  after_create :create_ledger_entry

  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("return_wizards.sales_user_id = ?",current_user_id)
    puts search
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("subject LIKE :search OR refund_type LIKE :search OR payment_type LIKE :search
        	OR status LIKE :search OR reason_for_return LIKE :search OR return_description LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("original_amount = ? OR shipping_charges = ? OR amount_to_be_refunded = ?", search_text, search_text, search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    status = JSON.parse(params[:status]) if params[:status].present?
    reason_for_return = JSON.parse(params[:reason_for_return]) if params[:reason_for_return].present?
    search = where("return_wizards.sales_user_id = ?",current_user_id)
    search = search.where("return_wizards.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('return_wizards.subject = ?',params[:subject]) if params[:subject].present?
    search = search.where('return_wizards.customer_id = ?',params[:customer_id]) if params[:customer_id].present?
    search = search.where('return_wizards.invoice_id = ?',params[:invoice_id]) if params[:invoice_id].present?
    search = search.where('return_wizards.original_amount = ?',params[:original_amount]) if params[:original_amount].present?
    search = search.where('return_wizards.shipping_charges = ?',params[:shipping_charges]) if params[:shipping_charges].present?
    search = search.where('return_wizards.amount_to_be_refunded = ?',params[:amount_to_be_refunded]) if params[:amount_to_be_refunded].present?
    search = search.where('return_wizards.refund_type = ?',params[:refund_type]) if params[:refund_type].present?
    search = search.where('return_wizards.payment_type = ?',params[:payment_type]) if params[:payment_type].present?
    search = search.where('return_wizards.status IN (?)',status) if status.present?
    search = search.where('return_wizards.reason_for_return IN (?)',reason_for_return) if reason_for_return.present?
    search = search.where('DATE(return_wizards.date_paid) = ?', params[:date_paid].to_date) if params[:date_paid].present?
    search = search.where('DATE(return_wizards.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('return_wizards.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_return_wizard
    date_paid = self.date_paid.present? ? self.date_paid.strftime('%d %B, %Y') : ""
    as_json(only: [:id,:subject, :invoice_id, :customer_id, :original_amount,
    	:shipping_charges, :amount_to_be_refunded, :refund_type, :payment_type, :status, :reason_for_return, :return_description])
    .merge({
      code:"RW#{self.id.to_s.rjust(4, '0')}",
      customer: self.customer.try(:user).try(:full_name),
      date_paid: date_paid,
      invoice: self.invoice.try(:name),
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
    })
  end 

  def self.get_json_return_wizards
    return_wizards_list =[]
    all.each do |return_wizard|
      return_wizards_list << return_wizard.get_json_return_wizard
    end
    return return_wizards_list
  end

  def self.sales_return_wizards(current_user)
    where("return_wizards.sales_user_id = ? AND return_wizards.is_active = ?",current_user.id,true)
  end

  def self.get_json_return_wizards_dropdown(return_wizards)
    list = []
    return_wizards.each do |return_wizard|
      list << as_json(only: [])
      .merge({name:return_wizard.subject,
        return_wizard_id:return_wizard.id,
      })
    end
    return list
  end
  private
    def create_ledger_entry
      acc_account = AccAccount.find_by_default_type("CreateReturnWizard") 
      LedgerEntry.create(subject:"Created By Payables Return Wizard",customer_id:self.customer_id,acc_account_id:acc_account.id,invoice_id:self.invoice_id,amount:self.amount_to_be_refunded,sales_user_id:self.sales_user_id)
    end
end