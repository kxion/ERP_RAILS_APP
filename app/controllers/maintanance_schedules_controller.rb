class MaintananceSchedulesController < ApplicationController

  before_action :set_maintanance_schedule, only: [:show, :update]
  before_action :set_delete_all_maintanance_schedule, only: [:delete_all]

  def index
    if params[:search_text].present?
      maintanance_schedules = MaintananceSchedule.search_box(params[:search_text],current_user.id).with_active.get_json_maintanance_schedules
    else
      maintanance_schedules = MaintananceSchedule.search(params,current_user.id).with_active.get_json_maintanance_schedules
    end
    render status: 200, json: maintanance_schedules.as_json
  end

  def show
    render status: 200, json: @maintanance_schedule.get_json_maintanance_schedule.as_json   
  end

  def create
    maintanance_schedule = MaintananceSchedule.new(maintanance_schedule_params)
    maintanance_schedule.sales_user_id = current_user.id
    if maintanance_schedule.save
      render status: 200, json: { maintanance_schedule_id: maintanance_schedule.id }
    else
      render status: 200, json: { message: maintanance_schedule.errors.full_messages.first }
    end
  end 

  def update
    if @maintanance_schedule.update_attributes(maintanance_schedule_params)
      render status: 200, json: { maintanance_schedule_id: @maintanance_schedule.id }
    else
      render status: 200, json: { message: @maintanance_schedule.errors.full_messages.first }
    end
  end

  def delete_all
    @maintanance_schedule_ids.each do |id|
      maintanance_schedule = MaintananceSchedule.find(id.to_i)
      maintanance_schedule.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_maintanance_schedules
    maintanance_schedules = MaintananceSchedule.sales_maintanance_schedules(current_user)
    render status: 200, json: MaintananceSchedule.get_json_maintanance_schedules_dropdown(maintanance_schedules)
  end

  private
    def set_maintanance_schedule
      @maintanance_schedule = MaintananceSchedule.find(params[:id])
    end

    def set_delete_all_maintanance_schedule
      @maintanance_schedule_ids = JSON.parse(params[:ids])
    end

    def maintanance_schedule_params
      params.require(:maintanance).permit(:id,:subject,:schedule_date,:asset_id,:status,:description)
    end
end