class Account < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :user
  belongs_to :marketplace

  #Has Many Relationship
  has_many :sale_events
  has_many :sales_orders

  #Validations
  validates :user_id, :title, :marketplace_id, presence: true

  #Object Serialize
  serialize :state
  serialize :relisting_pricing

  #Html Form Nested Attributes
  accepts_nested_attributes_for :sale_events, :allow_destroy => true

  def get_json_account
    as_json(only: [:id,:title,:user_id,:marketplace_id,:auto_renew,:relisting_pricing,
      :state,:is_connected])
    .merge({
      sale_events_attributes: self.sale_events.get_json_sale_events
    })
  end 

  def state
    @state ||= HashWithCallbacks.new(self[:state] || {}, :changed => -> (changed_values) {
      self.update_attribute(:state, @state.to_h)
    })
  end

  def integration
    @integration ||= Integrations.by_uid(marketplace.api_uid).new(state)
  end
end