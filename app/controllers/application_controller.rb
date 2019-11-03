class ApplicationController < ActionController::Base
  protected  
    def current_user_session
      @current_user_session ||= UserSession.find
    end

    def current_user
      @current_user ||= current_user_session && current_user_session.user
    end  
end
