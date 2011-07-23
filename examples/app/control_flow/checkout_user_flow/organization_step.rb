class CheckoutUserFlow
  class OrganizationStep < CheckoutUserFlow::Step
    
      depends_on :step => :service
    
  end
end