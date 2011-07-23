class CheckoutUserFlow
  class AccountStep < CheckoutUserFlow::Step
    
    depends_on :step => :service
    
    is_complete do
      current_account && current_customer.account == current_account
    end
    
  end
end