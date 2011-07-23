class CheckoutUserFlow
  class PaymentStep < CheckoutUserFlow::Step
    
    depends_on :step => [:account, :organization]
        
  end
end