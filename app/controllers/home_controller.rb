class HomeController < ApplicationController
  include ApplicationHelper
  before_filter :get_current_user
  skip_before_filter :authenticate_user!, :only => :logged_out
  
  def home
  end

  def logged_out
  end

  private
  def get_current_user
    @current_user = current_user
  end
end
