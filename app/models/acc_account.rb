class AccAccount < ActiveRecord::Base

  #Has Many Relationship
  has_many :ledger_entries

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("acc_accounts.sales_user_id = ?",current_user_id)
    puts search
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("acc_code LIKE :search
          OR name LIKE :search OR acc_type LIKE :search OR description LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("id = ?", search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    acc_type = JSON.parse(params[:acc_type]) if params[:acc_type].present?
    search = where("acc_accounts.sales_user_id = ?",current_user_id)
    search = search.where("acc_accounts.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('acc_accounts.acc_code = ?',params[:acc_code]) if params[:acc_code].present?
    search = search.where('acc_accounts.name = ?',params[:name]) if params[:name].present?
    search = search.where('acc_accounts.acc_type IN (?)',acc_type) if acc_type.present?
    search = search.where('DATE(acc_accounts.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('acc_accounts.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_acc_account
    as_json(only: [:id,:acc_code,:name,:acc_type,:description])
    .merge({
      code:"ACC#{self.id.to_s.rjust(4, '0')}",
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
    })
  end 

  def self.get_json_acc_accounts
    acc_accounts_list =[]
    all.each do |acc_account|
      acc_accounts_list << acc_account.get_json_acc_account
    end
    return acc_accounts_list
  end

  def self.sales_acc_accounts(current_user)
    where("acc_accounts.sales_user_id = ? AND acc_accounts.is_active = ?",current_user.id,true)
  end

  def self.get_json_acc_accounts_dropdown(acc_accounts)
    list = []
    acc_accounts.each do |acc_account|
      list << as_json(only: [])
      .merge({name:acc_account.name,
        acc_account_id:acc_account.id,
      })
    end
    return list
  end
end
