class UsersController < ApplicationController
  before_filter :ensure_login_params_exist, only: :create

  def create
    user = User.find_by_email(params[:user][:email])
    return render status: 200, json: { error: "Invalid Credentials" } if user.blank?
    return render status: 200, json: { error: "Please confirm your email address to continue" } unless user.confirmed?
    if user &&  user.valid_password?(params[:user][:password])
      sign_in(:user, user)
      return render status: 200, json: user.as_json
    end
    return render status: 200, json: { error: "Invalid Credentials" }
  end

  def get_users
    users = User.sales_staff_users(current_user)
    render status: 200, json: User.get_json_staff_dropdown(users)
  end

  def check_email
    user = User.find_by_email(params[:email])
    if user.present?
      render status: 200, json: {data: true}
    else
      render status: 200, json: {data: false}
    end
  end

  def email_confirmation
    user = User.confirm_by_token(params[:confirmation_token])
    if user.errors.blank?
      return render status: 200, json: {data: true}
    else
      return render status: 200, json: { error: user.errors.full_messages.first }
    end
  end

  def logout
    Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
    render status: 200, json: { message: "Logged Out Successfully" }
  end

  private
    def ensure_login_params_exist
      return if !params[:user][:email].blank? and !params[:user][:password].blank?
      render status: 422, json: { error: "Missing Login params"}
    end
end