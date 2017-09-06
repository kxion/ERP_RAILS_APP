class KnowledgeBasesController < ApplicationController
  before_action :set_knowledge_base, only: [:show, :update]
  before_action :set_delete_all_knowledge_base, only: [:delete_all]

  def index
    if params[:search_text].present?
      knowledge_bases = KnowledgeBase.search_box(params[:search_text],current_user.id).with_active.get_json_knowledge_bases
    else
      knowledge_bases = KnowledgeBase.search(params,current_user.id).with_active.get_json_knowledge_bases
    end
    render status: 200, json: knowledge_bases.as_json
  end

  def show
    render status: 200, json: @knowledge_base.get_json_knowledge_base.as_json 
  end

  def create
    knowledge_base = KnowledgeBase.new(knowledge_base_params)
    knowledge_base.sales_user_id = current_user.id
    if knowledge_base.save
      render status: 200, json: { knowledge_base_id: knowledge_base.id}
    else
      render status: 200, json: { message: knowledge_base.errors.full_messages.first }
    end
  end 

  def update
    if @knowledge_base.update_attributes(knowledge_base_params)
      render status: 200, json: { knowledge_base_id: @knowledge_base.id}
    else
      render status: 200, json: { message: @knowledge_base.errors.full_messages.first }
    end
  end

  def delete_all
    @knowledge_base_ids.each do |id|
      knowledge_base = KnowledgeBase.find(id.to_i)
      knowledge_base.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_knowledge_bases
    knowledge_bases = KnowledgeBase.sales_knowledge_bases(current_user)
    render status: 200, json: KnowledgeBase.get_json_knowledge_bases_dropdown(knowledge_bases)
  end

  private
    def set_knowledge_base
      @knowledge_base = KnowledgeBase.find(params[:id])
    end

    def set_delete_all_knowledge_base
      @knowledge_base_ids = JSON.parse(params[:ids])
    end

    def knowledge_base_params
      params.require(:knowledge_base).permit(:id, :title, :kb_category_id, :status, :revision,
      :body, :resolution, :author_id, :approver_id)
    end
end