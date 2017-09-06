class NotesController < ApplicationController
  before_action :set_note, only: [:show, :update]
  before_action :set_delete_all_note, only: [:delete_all]

  def index
    if params[:search_text].present?
      notes = Note.search_box(params[:search_text],current_user.id).with_active.get_json_notes
    else
      notes = Note.search(params,current_user.id).with_active.get_json_notes
    end
    render status: 200, json: notes.as_json
  end

  def show
    render status: 200, json: @note.get_json_note_index.as_json   
  end

  def create
    note = Note.new(note_params)
    note.sales_user_id = current_user.id
    if note.save
      render status: 200, json: { note_id: note.id}
    else
      render status: 200, json: { message: note.errors.full_messages.first }
    end
  end    

  def update
    if @note.update_attributes(note_params)
      render status: 200, json: { note_id: @note.id}
    else
      render status: 200, json: { message: @note.errors.full_messages.first }
    end
  end

  def delete_all
    @note_ids.each do |id|
      note = Note.find(id.to_i)
      note.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  private
    def set_note
      @note = Note.find(params[:id])
    end

    def set_delete_all_note
      @note_ids = JSON.parse(params[:ids])
    end

    def note_params
      params.require(:note).permit(:id, :subject, :decription, :contact_id, :customer_id, :created_by_id, :updated_by_id, :created_at, :updated_at)
    end
end