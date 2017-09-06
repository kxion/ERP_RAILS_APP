class Contact < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :user
  belongs_to :customer

  #Has Many Relationship
  has_many :notes
  has_many :sales_orders, dependent: :destroy
   
  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }

  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  #Constants
  SALUTATION = %w(Mr. Ms. Mrs. Prof. Dr.)

  def self.search_box(search_text,current_user_id)
    search = where("contacts.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("phone_mobile LIKE :search OR primary_country LIKE :search
                OR designation LIKE :search ", search: "%#{search_text}%")
      end
    else
      search = search.where("id :search", search: "%#{search_text}%")
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("contacts.sales_user_id = ?",current_user_id)
    if params[:code].present? 
      code = params[:code].split("-CON")
      if code.last.present?
        code = code.last.gsub(/\D/,'')
        search = search.where('contacts.id = ?', code)
      end
    end
    search = search.joins(:user).where("lower(users.first_name) LIKE ?" ,"%#{params[:first_name].downcase}%") if params[:first_name].present?
    search = search.joins(:user).where("lower(users.middle_name) LIKE ?" ,"%#{params[:middle_name].downcase}%") if params[:middle_name].present?
    search = search.joins(:user).where("lower(users.last_name) LIKE ?" ,"%#{params[:last_name].downcase}%") if params[:last_name].present?
    search = search.where('contacts.phone_mobile = ?', params[:mobile]) if params[:mobile].present?
    search = search.where('(contacts.primary_country = ?) OR( contacts.alternative_country = ?)', params[:primary_country],params[:primary_country]) if params[:primary_country].present?
    search = search.where('contacts.designation = ?', params[:designation]) if params[:designation].present?
    search = search.where('contacts.customer_id = ?', params[:customer_id]) if params[:customer_id].present?
    search = search.where('DATE(contacts.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    return search
  end

  def self.sales_contacts(current_user)
    where("contacts.sales_user_id = ? AND contacts.is_active = ?",current_user.id,true)
  end

  def get_json_contact_show
    as_json(only: [:id,:salutation,:phone_mobile,:phone_work,:designation,:department,
      :decription, :primary_street, :primary_city, :primary_state, :primary_country,
      :primary_postal_code, :alternative_street, :alternative_city, :alternative_state,
      :alternative_country, :alternative_postal_code ])
    .merge({
      code:"CUS#{self.customer_id.to_s.rjust(4, '0')}-CON#{self.id.to_s.rjust(4, '0')}",
      first_name:self.user.first_name,
      last_name:self.user.last_name,
      middle_name:self.user.middle_name,
      customer:self.customer.try(:user).try(:full_name),
      email:self.user.email,
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      notes:Note.with_active.get_json_notes(false,self.notes),
      })
  end  

  def get_json_contact_index
    as_json(only: [:id,:phone_mobile,:primary_country,:designation])
    .merge({
      code:"CUS#{self.customer_id.to_s.rjust(4, '0')}-CON#{self.id.to_s.rjust(4, '0')}",
      customer:self.customer.try(:user).try(:full_name),
      name:self.user.full_name,
      created_at:self.created_at.strftime('%d %B, %Y'),
      })
  end 
       
  def self.get_json_contacts(is_contacts_index=true, contacts=[])
    contacts = all if is_contacts_index.present?
    contacts_list =[]
    contacts.each do |contact|
      contacts_list << contact.get_json_contact_index
    end
    return contacts_list
  end

  def get_json_contact_edit
    as_json(only: [])
    .merge({
      id: self.user.id,
      email: self.user.email,
      first_name: self.user.first_name,
      middle_name: self.user.middle_name,
      last_name: self.user.last_name,
      contact_attributes:{
        id: self.id,
        customer_id: self.customer.try(:id),
        salutation: self.salutation,
        phone_mobile: self.phone_mobile,
        phone_work: self.phone_work,
        designation: self.designation,
        department: self.department,
        primary_street: self.primary_street,
        primary_city: self.primary_city,
        primary_state: self.primary_state,
        primary_country: self.primary_country,
        primary_postal_code: self.primary_postal_code,
        alternative_street: self.alternative_street,
        alternative_city: self.alternative_city,
        alternative_state: self.alternative_state,
        alternative_country: self.alternative_country,
        alternative_postal_code: self.alternative_postal_code,
        decription: self.decription,
      }
    })
  end 
end