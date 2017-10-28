class InventoryManagementController < ApplicationController
	def get_inventory_item
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@inventory_items = InventoryItem.all
			if @inventory_items.present?
				render :json=> {:inventory_items => @inventory_items, :status => true,:message => "Get Inventory Items!"}, :status=>200
			elsif @inventory_items.empty?
	     		render :json=> {:status => true,:message => "No data!"}, :status=>200
			end
		else
	    render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def create_inventory_item
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			if @user.is_admin?
				@inventory_item = InventoryItem.create(inventory_item_params)
				@inventory_item.save
				render :json=> {:status => true,:message => "Inventory Item created!"}, :status=>200
			else
     		render :json=> {:status => false,:message => "Current user not a admin User!"}, :status=>201
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def show_inventory_item
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@inventory_item = InventoryItem.find_by(id: params[:inventory_item_id])
			if @inventory_item.present?
				render :json=> {:inventory_item => @inventory_item, :status => true,:message => "Inventory Item!"}, :status=>200
			elsif @inventory_item.empty?
	     	render :json=> {:status => true,:message => "No data!"}, :status=>200
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def edit_inventory_item
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			if @user.is_admin?
				@inventory_item = InventoryItem.find_by(id: params[:inventory_item_id])
				@inventory_item.update_attributes(inventory_item_params)
				render :json=> {:status => true,:message => "Inventory Item Updated!"}, :status=>200
			else
     		render :json=> {:status => false,:message => "Current user not a admin User!"}, :status=>201
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def delete_inventory_item
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			if @user.is_admin?
				@inventory_item_ids = params[:inventory_item_id].to_a
				if @inventory_item_ids.present?
					@inventory_item_ids.each do |id|
						@inventory_item = InventoryItem.find(id)
						if @inventory_item.present?
							@inventory_item.delete
							render :json=> {:status => true,:message => "Inventory Item deleted!"}, :status=>200
						else
							render :json=> {:status => true,:message => "There is no Inventory Item!"}, :status=>200
						end
					end
				else
					render :json=> {:status => true,:message => "There is no Inventory Item!"}, :status=>200
				end
			else
     		render :json=> {:status => false,:message => "Current user not a admin User!"}, :status=>201
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def get_listing
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@listings = @user.try(:listings)
			if @listings.present?
				render :json=> {:listings => @listings, :status => true,:message => "Get Item Source!"}, :status=>200
			elsif @listings.empty?
	     	render :json=> {:status => true,:message => "No data!"}, :status=>200
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def create_listing
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@listing = @user.listings.create(listings_params)
			@listing.save
			render :json=> {:status => true,:message => "Listing created!"}, :status=>200
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def show_listing
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@listing = @user.try(:listings).find_by(id: params[:listing_id])
			if @listing.present?
				render :json=> {:listing => @listing, :status => true,:message => "Listing!"}, :status=>200
			elsif @listing.empty?
     		render :json=> {:status => true,:message => "No data!"}, :status=>200
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def edit_listing
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@listing = Listing.find_by(id: params[:listing_id])
			if @listing.present?
				@listing.update_attributes(listings_params)
				render :json=> {:status => true,:message => "Listing Updated!"}, :status=>200
			else
     		render :json=> {:status => true,:message => "No data!"}, :status=>200
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def delete_listing
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@listing_id = params[:listing_id].to_a
			if @listing_id.present?
				@listing_id.each do |id|
					@listing = Listing.find(id)
					if @listing.present?
						@listing.delete
						render :json=> {:status => true,:message => "Listing deleted!"}, :status=>200
					else
     				render :json=> {:status => true,:message => "No data!"}, :status=>200
					end
				end
			else
     		render :json=> {:status => true,:message => "No data!"}, :status=>200
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def get_item_source
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@item_sources = ItemSource.all
			if @item_sources.present?
				render :json=> {:item_sources => @item_sources, :status => true,:message => "Get Item Source!"}, :status=>200
			elsif @item_sources.empty?
		    render :json=> {:status => true,:message => "No data!"}, :status=>200
			end
    else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
    end
	end

	def create_item_source
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@user.is_admin?
			if @user.is_admin?
				@item_source = ItemSource.create(item_source_params)
				@item_source.save
				render :json=> {:status => true,:message => "Item Source created!"}, :status=>200
			else
     			render :json=> {:status => false,:message => "Current user not a admin User!"}, :status=>201
			end
		else
     		render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def show_item_source
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@item_source = ItemSource.find_by(id: params[:item_source_id])
			if @item_source.present?
				render :json=> {:status => true, :item_source => @item_source,:message => "Item Source created!"}, :status=>200
			else
     		render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
			end
		end
	end

	def edit_item_source
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			if @user.is_admin?
				@item_source = ItemSource.find_by(id: params[:item_source_id])
				@item_source.update_attributes(item_source_params)
				render :json=> {:status => true,:message => "Item Source Updated!"}, :status=>200
			else
     		render :json=> {:status => false,:message => "Current user not a admin User!"}, :status=>201
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def delete_item_source
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			if @user.is_admin?
				@item_source_id = params[:item_source_id].to_a
				if @item_source_id.present?
					@item_source_id.each do |id|
						@item_source = ItemSource.find(id)
						if @item_source.present?
							render :json=> {:status => true,:message => "Inventory Item deleted!"}, :status=>200
							@item_source.delete
						else
							render :json=> {:status => true,:message => "There is no Inventory Item"}, :status=>200
						end
					end
				else
					render :json=> {:status => true,:message => "There is no Inventory Item"}, :status=>200
				end
			else
     		render :json=> {:status => false,:message => "Current user not a admin User!"}, :status=>201
			end
		else
     	render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	def get_item_category
		if params[:user_id].present?
			@user = User.find_by(id: params[:user_id])
			@item_category = ItemCategory.all
			if @item_category.present?
				render :json=> {:item_categories => @item_category, :status => true,:message => "Get Item Category!"}, :status=>200
			elsif @item_category.empty?
		    render :json=> {:status => true,:message => "No data!"}, :status=>200
			end
		else
	    render :json=> {:status => false,:message => "Something Went Wrong!"}, :status=>201
		end
	end

	private

	def item_source_params
		params.require(:item_source).permit(:id , :name, :short_name, :profit_share_percent)
	end

	def listings_params
		params.require(:listing).permit(:id,  :user_id, :item_category_id, :title, :make, :model, :description, :shipping_preset_id, :publish_on, :cost)
	end

	def inventory_item_params
		params.require(:inventory_item).permit(:id, :icc, :serial, :make, :model, :item_category_id, :item_source_id, :status, :location, :notes, :acquisition_cost, :cached_profit_share_percent, :details, :archived, :check_value, :item_category_name, :listing_id)
	end
end
