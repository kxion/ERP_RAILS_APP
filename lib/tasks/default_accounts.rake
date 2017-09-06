namespace :default_accounts do
  task create: :environment do
  	User.where(role:"Sales").each do |user|
  		AccAccount.create(acc_code:"1001",name:"Receivables",acc_type:"Profit/Loss",description:"Amount received through Invoices",sales_user_id: user.id,default_type:"CreateInvoice")
  		AccAccount.create(acc_code:"1002",name:"Payables",acc_type:"Profit/Loss",description:"Amount Payed to customers like Cheque and Returns",sales_user_id: user.id,default_type:"CreateReturnWizard")
  	end
  end
end
