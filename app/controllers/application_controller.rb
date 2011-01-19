# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :set_last_request_at 
  if User.first == nil
    User.create!(:user_name=>'admin',:email=>'admin@example.com',:first_name=>'The',:last_name=>'Admin')
    User.first.attempt_set_password(:password=>'password',:password_confirmation=>'password')
  end
    
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to home_url
  end
  
  def current_user_or_can?(permissions = nil,obj = nil)
    the_id = obj ? obj.user_id : params[:id].to_i
    permissions = [permissions] if !permissions.nil? && permissions.class != Array
    if (the_id == current_user.id) || (!permissions || (permissions.any? {|p| current_user_can?(p)} ) )
      true
    else
      respond_to do |format|
        flash[:notice] = :not_allowed
        format.html { redirect_to( home_url) }
        format.xml  { head :failure }
      end
      false
    end
  end


  before_filter :setup_filter
  after_filter :set_header  #after necessary in case we use rjs
  
  def get_logged_in_users
    User.get_logged_in_users
  end
  
  protected 
  
  def setup_filter
    @subdomain = request.env['HTTP_HOST'] =~ /^(\w+)/ ? $1 : ''
    if current_user
      true
    end
  end
  
  def set_header
    headers["Expires"] = "Mon, 26 Jul 1997 05:00:00 GMT" #Date in the past
    headers["Last-Modified"] = "Mon, 26 Jul 1997 05:00:00 GMT"  #always modified
    headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0, post-check=0, pre-check=0" 
    headers["Pragma"] = "no-cache"  #HTTP/1.0
  end

  def authorized_if(priv)
    authorize! priv, :all
  end

  ################################################################################
  private
  def set_last_request_at 
    current_user.update_attribute(:last_request_at, Time.now) if user_signed_in? 
  end
  def after_sign_out_path_for(resource_or_scope)
    logged_out_path
  end
end