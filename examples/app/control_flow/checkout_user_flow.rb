class CheckoutUserFlow < ControlFlow::Base 
  
  define_flow :free_service do
    # This is run inside the before filter
    
    #steps :organization, ...
    add_step :service
    add_step :organization
    add_step :account
    add_step :profile
    add_step :completed_free
  end
  
  
  define_flow :paid_service do
    # This is run inside the before filter
    add_step :service, :organization, :payment, :profile, :completed_paid
  end
  
  define_steps do
    
    # When a state is entered conditions must be met for a state to be active
    
    # :is_complete
    # is_complete returns true if condition matches
    # used in combination with depends_on in other steps.
    
    # :validates
    # These conditions must be met for this state to be valid
    
    
    step :service do
      value do
        order_url
      end
      
      is_complete do
        current_user.service
      end
    end
    
    # These are eq to classes
    step :organization do
      value do
        organizations_url
      end
      
      depends_on :service
    end
    
    step :account do
      value do
        accounts_url
      end
      
      depends_on :service

      is_complete do
        current_account && current_customer.account == current_account
      end
    end
    
    step :profile do
      value do
        profiles_url
      end     
      
      depends_on :account
    end
    
    step :payment do
      value do
        payments_url
      end
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
    
    step :completed_free do
      value do
        free_completed_url
      end
      
      depends_on :account, :organization

      validates do
        current_account.service
      end
    end
    
    step :completed_paid do
      value do
        paid_completed_url
      end
      depends_on :payment
    end
     
  end
  
end