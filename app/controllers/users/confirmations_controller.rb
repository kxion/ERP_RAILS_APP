class Users::ConfirmationsController < Devise::ConfirmationsController
  protect_from_forgery with: :exception
  respond_to :html, :json
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    begin
      super
    rescue Exception => e
      puts e
    end
    if Rails.env.development?
      redirect_to "http://localhost:3000/"
    else
      redirect_to "https://erp-clarabyte.herokuapp.com/"
    end
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
