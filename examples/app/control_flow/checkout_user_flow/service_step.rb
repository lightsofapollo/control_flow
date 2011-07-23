class CheckoutUserFlow
  class ServiceStep < CheckoutUserFlow::Step
    
    
    is_complete do
      current_user.service
    end
    
  end
end