class CheckoutUserFlow < ControlFlow::Base 
  
  define_flow :free_service do
    # This is run inside the before filter
    
    #steps :organization, ...
    step :service
    step :organization
    step :account
    step :profile
    step :completed_free
  end
  
  
  define_flow :paid_service do
    # This is run inside the before filter
    steps :service, :organization, :payment, :profile, :completed_paid
  end
  
  define_steps do
    
    # When a state is entered conditions must be met for a state to be active
    
    # :is_complete
    # is_complete returns true if condition matches
    # used in combination with depends_on in other steps.
    
    # :validates
    # These conditions must be met for this state to be valid
    
    
    service do
      is_complete do
        current_user.service
      end
    end
    
    # These are eq to classes
    organization do
      depends_on :service
    end
    
    account do
      depends_on :service

      is_complete do
        current_account && current_customer.account == current_account
      end
    end
    
    profile do
      depends_on :account
    end
    
    payment do
      depends_on :organization, :account
      
      is_complete do
        if(current_account)
          # Same id
          if(current_account.service === current_customer.service)
            true
          end
        end
        false
      end
      
    end
    
    completed_free do
      depends_on :account, :organization

      validates do
        current_account.service
      end
    end
    
    completed_paid do
      depends_on :payment
    end
     
  end
  
end