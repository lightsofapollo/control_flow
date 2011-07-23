class CheckoutUserFlow
  class ProfileStep < CheckoutUserFlow::Step
    
    depends_on :step => :account
        
  end
end