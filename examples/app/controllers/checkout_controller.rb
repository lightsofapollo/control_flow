class CheckoutController < ApplicationController
  
  self.current_step = :payment
  
  before_filter do
    # get current flow (:free_service, :paid_service)
    
    #initialize control flow in context of controller
    @user_flow = CheckoutUserFlow.new(self) 
    
    @user_flow.enter_flow(current_flow)
    @user_flow.enter_step(current_step)
    
    unless(@user_flow.valid?)
      redirect_to @user_flow.last_valid_step.value
    end
  end
  
  def create
    if(resource.save)
      #...
      redirect_to @user_flow.next_state.value
    end
  end
  
end