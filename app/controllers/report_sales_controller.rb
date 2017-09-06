class ReportSalesController < ApplicationController

  def index
      filter = ['Etsy','Amazon','eBay','Shopify']
      @orders = SalesOrder.where("sales_orders.sales_user_id = ?",current_user.id)
      @orders = @orders.order('COALESCE(create_timestamp, sales_orders.created_at) DESC')
      if params[:filter].present?
        @orders = @orders.joins(:account => :marketplace).where('marketplaces.name = ?', params[:filter])
      else
        @orders = @orders.joins(:account => :marketplace).where('marketplaces.name IN (?)', filter)
      end

      search = search.where('', params[:created_at].to_date) if params[:created_at].present?      
      @orders = @orders.where('DATE(sales_orders.create_timestamp) > ?', Date.parse(params[:start_date])) if Date.parse(params[:start_date]) rescue false
      @orders = @orders.where('DATE(sales_orders.create_timestamp) < ?', Date.parse(params[:end_date])) if Date.parse(params[:end_date]) rescue false
      @groups = @orders.group_by { |o|
        case params[:group]
          when 'Month'
            o.create_timestamp.to_date.strftime("%B %Y")
          when 'Year'
            o.create_timestamp.to_date.strftime("Year %Y")
          else # blank => :day
            o.create_timestamp.to_date.strftime("%B %d, %Y")
        end
      }.map { |g, orders|
        {
          :title => g,
          :count => orders.length,
          :revenue => orders.select(&:grand_total).map(&:grand_total).inject(&:+),
          :avg_order => orders.select(&:grand_total).map(&:grand_total).inject(&:+) / orders.length,
          #:net => orders.map(&:net_profit).inject(&:+),
        }
      }

    title = @groups.map {|g| g[:title] }
    count = @groups.map {|g| g[:count].to_i }
    revenue = @groups.map {|g| g[:revenue].to_f }
    count_heading = count.inject(0){|sum,x| sum + x }
    revenue_heading = revenue.inject(0){|sum,x| sum + x }

    render status: 200, json: {revenue_heading:revenue_heading, count_heading:count_heading,title:title,count:count,revenue:revenue}.as_json
  end
end