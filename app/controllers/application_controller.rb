class ApplicationController < ActionController::Base
  def index
    render component: 'App', prerender: false
  end

  protected  
    def current_user_session
      @current_user_session ||= UserSession.find
    end

    def current_user
      @current_user ||= current_user_session && current_user_session.user
    end  
end
