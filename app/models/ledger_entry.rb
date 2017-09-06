class LedgerEntry < ActiveRecord::Base

  #Belongs To Relationship
  belongs_to :customer
  belongs_to :acc_account
  belongs_to :invoice

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("ledger_entries.sales_user_id = ?",current_user_id)
    puts search
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("subject LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("id = ?", search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("ledger_entries.sales_user_id = ?",current_user_id)
    search = search.where("ledger_entries.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('ledger_entries.subject = ?',params[:subject]) if params[:subject].present?
    search = search.where('ledger_entries.customer_id = ?',params[:customer_id]) if params[:customer_id].present?
    search = search.where('ledger_entries.acc_account_id = ?',params[:acc_account_id]) if params[:acc_account_id].present?
    search = search.where('ledger_entries.invoice_id = ?',params[:invoice_id]) if params[:invoice_id].present?
    search = search.where('ledger_entries.amount = ?',params[:amount]) if params[:amount].present?
    search = search.where('DATE(ledger_entries.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('ledger_entries.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_ledger_entry
    as_json(only: [:id,:subject, :customer_id, :acc_account_id, :invoice_id, :amount])
    .merge({
      code:"LDE#{self.id.to_s.rjust(4, '0')}",
      customer: self.customer.try(:user).try(:full_name),
      acc_account: self.acc_account.try(:name),
      invoice: self.invoice.try(:name),
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
    })
  end 

  def self.get_json_ledger_entries
    ledger_entries_list =[]
    all.each do |ledger_entry|
      ledger_entries_list << ledger_entry.get_json_ledger_entry
    end
    return ledger_entries_list
  end

  def self.sales_ledger_entries(current_user)
    where("ledger_entries.sales_user_id = ? AND ledger_entries.is_active = ?",current_user.id,true)
  end

  def self.get_json_ledger_entries_dropdown(ledger_entries)
    list = []
    ledger_entries.each do |ledger_entry|
      list << as_json(only: [])
      .merge({name:ledger_entry.subject,
        ledger_entry_id:ledger_entry.id,
      })
    end
    return list
  end

end
