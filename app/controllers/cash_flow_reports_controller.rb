class CashFlowReportsController < ApplicationController
  def index
    months = []
    net_cash_flow = 0
    income = 0
    outcome = 0

    flow = []
    sales_flow = []
    cheque_register_flow = []

    outflow = []
    return_wizard_outflow = []
    cheque_register_outflow = []
    material_outflow = []

    months_range = 0..11
    months_range.to_a.reverse.each do |month_offset|
        start_date = month_offset.months.ago.beginning_of_month
        end_date = month_offset.months.ago.end_of_month
        
        # InFlow
        invoice = Invoice.where(:created_at => start_date..end_date).select(&:grand_total).map(&:grand_total).inject(&:+)
        invoice = 0 if invoice.blank? or invoice < 1
        cheque_register = ChequeRegister.where(:created_at => start_date..end_date).select(&:credit).map(&:credit).inject(&:+)
        cheque_register = 0 if cheque_register.blank? or cheque_register < 1

        sales_flow.append(invoice)
        cheque_register_flow.append(cheque_register)
        income += (invoice + cheque_register)
        flow.append(invoice + cheque_register)
       

        # OutFlow
        return_wizard = ReturnWizard.where(:created_at => start_date..end_date).select(&:original_amount).map(&:original_amount).inject(&:+)
        return_wizard = 0 if return_wizard.blank? or return_wizard < 1
        cheque_register = ChequeRegister.where(:created_at => start_date..end_date).select(&:debit).map(&:debit).inject(&:+)
        cheque_register = 0 if cheque_register.blank? or cheque_register < 1
        material = Material.where(:created_at => start_date..end_date).select(&:price).map(&:price).inject(&:+)
        material = 0 if material.blank? or material < 1

        return_wizard_outflow.append(return_wizard)
        cheque_register_outflow.append(cheque_register)
        material_outflow.append(material)
        outcome += (return_wizard + cheque_register + material)
        outflow.append(return_wizard + cheque_register + material)

        # InFlow + # OutFlow
        months.append(start_date.strftime('%b'))
    end
    months.append("Total")
    sales_flow.append(sales_flow.inject(:+))
    cheque_register_flow.append(cheque_register_flow.inject(:+))

    return_wizard_outflow.append(return_wizard_outflow.inject(:+))
    cheque_register_outflow.append(cheque_register_outflow.inject(:+))
    material_outflow.append(material_outflow.inject(:+))

    inflow_total = flow.inject(:+)
    outflow_total = outflow.inject(:+)
    
    net_cash_flow = income - outcome
    render status: 200, json: { outflow_total: outflow_total, inflow_total: inflow_total, months: months,flow: flow,sales_flow: sales_flow,
    	cheque_register_flow: cheque_register_flow, return_wizard_outflow: return_wizard_outflow,
    	cheque_register_outflow: cheque_register_outflow, material_outflow: material_outflow,
    	outflow: outflow ,net_cash_flow:net_cash_flow}
  end
end