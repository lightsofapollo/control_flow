class CheckoutUserFlow
  class CompleteStep < CheckoutUserFlow::Step
    
    depends_on :step => [:account, :organization]
    
    validates do
      current_account.service
    end
        
  end
end