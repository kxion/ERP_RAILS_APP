class TimeclocksController < ApplicationController
  before_action :set_timeclock, only: [:show, :update]
  before_action :set_delete_all_timeclock, only: [:delete_all]

  def index
    if params[:search_text].present?
      timeclocks = Timeclock.search_box(params[:search_text],current_user.id).with_active.get_json_timeclocks
    else
      timeclocks = Timeclock.search(params,current_user.id).with_active.get_json_timeclocks
    end
    render status: 200, json: timeclocks.as_json
  end

  def show
    render status: 200, json: @timeclock.get_json_timeclock.as_json    
  end

  def create
    timeclock = Timeclock.new(timeclock_params)
    timeclock.sales_user_id = current_user.id
    if timeclock.save
      render status: 200, json: { timeclock_id: timeclock.id}
    else
      render status: 200, json: { message: timeclock.errors.full_messages.first }
    end
  end 

  def update
    if @timeclock.update_attributes(timeclock_params)
      render status: 200, json: { timeclock_id: @timeclock.id}
    else
      render status: 200, json: { message: @timeclock.errors.full_messages.first }
    end
  end

  def delete_all
    @timeclock_ids.each do |id|
      timeclock = Timeclock.find(id.to_i)
      timeclock.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  private
    def set_timeclock
      @timeclock = Timeclock.find(params[:id])
    end

    def set_delete_all_timeclock
      @timeclock_ids = JSON.parse(params[:ids])
    end

    def timeclock_params
      params.require(:timeclock).permit(:id,:subject, :employee_id, :in_time,
       :out_time)
    end
end