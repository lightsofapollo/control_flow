class CheckoutController < ApplicationController
  
  self.current_step = :payment
  
  before_filter do
    # get current flow (:free_service, :paid_service)
    @user_flow = CheckoutUserFlow.enter(current_flow)
    @user_flow.set_step(current_step)
    
    unless(@user_flow.valid?)
      @user_flow.goto_previous_valid_state
    end
  end
  
  def create
    if(resource.save)
      #...
      @user_flow.goto_next_state
    end
  end
  
end