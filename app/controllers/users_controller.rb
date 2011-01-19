class UsersController < ApplicationController
  def logged_in_users
    authorize! :read, :logged_in_users
    current_time = Time.now
    @user_ids = get_logged_in_users  #hash of user ids, last_action values
    @users = User.find(:all)
    @logged_in_users = []
    @users.each do |u|
      if @user_ids[u.id]
        @logged_in_users.push({:user => u, :last_action => @user_ids[u.id],:last_action_humanized => time_period_to_s(current_time - @user_ids[u.id])})
      end
     end
     @logged_in_users.sort! {|u1,u2| u2[:last_action] <=> u1[:last_action] }
  end

  # GET /users
  # GET /users.xml
  def index
    authorize! :read, User
        @users = User.find(:all)
    @users ||= []
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @users.to_xml }
    end
  end

  # GET /users/new
  def new
    authorize! :create, User
    @user = User.new
    session[:user_create_return_to] = request.env['HTTP_REFERER'] if !session[:user_create_return_to]
    @certifications = []
  end

  # GET /users/1;edit
  def edit
    authorize! :edit, User
    @user = User.find(params[:id])
  end


  # POST /users
  # POST /users.xml
  def create
    authorize! :create, User
    @user = User.new(params[:user])
    @user.enabled = false
    respond_to do |format|
      if @user.valid? && @user.save
        do_extra_actions
        flash[:notice] = (flash[:notice] == :user_activated) ? :user_created_and_activated : :user_created
        flash[:notice_param] = @user
        format.html do
            redirect_to users_url(:use_session => true)
        end
        format.xml  { head :created, :location => user_url(@user) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    authorize! :edit, User
    @user = User.find(params[:id])
    return_url = users_url(:use_session => true)
    respond_to do |format|
      if @user.update_attributes(params[:user])
        do_extra_actions
        format.html { redirect_to return_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    authorize! :delete, User
    @user = User.find(params[:id])
    flash[:notice_param] = @user.user_name
    @user.destroy
    respond_to do |format|
      flash[:notice] = :user_deleted
      format.html { redirect_to users_url(:use_session => true) }
      format.xml  { head :ok }
    end
  end

  # GET /users/1;login_as
  def login_as
    authorize! :login_as, User
    @user = User.find(params[:id])
    sign_in(:user, @user)
    redirect_to home_url
  end
  
  # GET /users/1;permissions
  def permissions
    authorized_if :assignPrivs
    @user = User.find(params[:id])
    @permissions = @user.get_privs
    respond_to do |format|
      format.html # permissions.rhtml
      format.xml  { render :xml => @permissions.to_xml }
    end
  end

  # PUT /users/1;permissions
  def set_permissions
    authorized_if :assignPrivs
    @user = User.find(params[:id])
    
    if params[:perms]
      privs = []
      params[:perms].keys.each {|r| privs << r}
      @user.set_privs(privs)
    end
    respond_to do |format|
      format.html { redirect_to users_url(:use_session => true) }
      format.xml  { head :ok }
    end
  end
  
  # GET /users/1;preferences
  def preferences
    current_user_action do
      @preferences = @user.preferences.split(',') if @user.preferences?
      @preferences ||= []
      respond_to do |format|
        session[:prefs_return_to] = request.env['HTTP_REFERER'] if !session[:prefs_return_to]
        format.html # preferences.rhtml
        format.xml  { render :xml => @preferences.to_xml }
      end
    end
  end

  # PUT /users/1;preferences
  def set_preferences
    current_user_action do
      @user.update_attributes(:preferences => params[:prefs] ? params[:prefs].keys.join(',') : '', :det_prefix => params[:det_prefix])
      return_url = session[:prefs_return_to] || home_url
      respond_to do |format|
        flash[:notice] = :user_preferences_set
        flash[:notice_param] = @user
        format.html {redirect_to(return_url) }
        format.xml  { head :ok }
        session[:prefs_return_to] = nil
      end
    end
  end
  
  # GET /users/1;password_change
  def password_change
    authorize! :change_password, User
    current_user_or_can?(:admin)
    @user = User.find(params[:id])
  end

  # PUT /users/1;do_password_change
  def do_password_change
    authorize! :change_password, User
    if current_user_or_can?(:admin)
      @user = User.find(params[:id])
      if @user == current_user
        @user.errors.add(:current_password," is incorrect.") if !@user.valid_password?(params[:current_password])
      end
      @user.attempt_set_password(params) if @user.errors.empty?
      if @user.errors.empty?
        sign_in(:user, @user)
        flash[:notice] = :password_changed
        flash[:notice_param] = @user
        redirect_to home_url
      else
        render :action => "password_change"
      end
    end
  end
  
  protected
  def current_user_action
    if current_user_or_can?([:accessAccounts,:createAccounts])
      @user = User.find(params[:id])
      yield
    end
  end

  def do_extra_actions
    if current_user_can?(:createAccounts)
      flash[:notice_param] = @user
      if params[:activate_account] && @user.deactivated?
        @user.activate!
        flash[:notice] = :user_activated
      end
      if params[:deactivate_account] && (@user.activated? || @user.activation_pending?)
        @user.deactivate!
        flash[:notice] = :user_deactivated
      end
      if params[:resend_activation] && @user.activation_pending?
        @user.resend_activation_message
        flash[:notice] = :user_activation_resent
      end
      if params[:assign_paper_code] && !@user.paper_code?
        @user.assign_paper_code
      end
      if params[:reset_password]
        @user.send_reset_password_instructions
        flash[:notice] = :password_reset
      end
    end
  end

  private

  
  def time_period_to_s(time_period)
    result = []
    #interval_array = [ [:weeks, 604800], [:days, 86400], [:hours, 3600], [:mins, 60], [:secs, 1] ]
    interval_array = [[:minutes, 60], [:seconds, 1] ]
    interval_array.each do |sub|
      if time_period >= 0
        time_val, time_period = time_period.divmod( sub[1] )
        time_val == 1 ? name = sub[0].to_s.singularize : name = sub[0].to_s
        result << time_val.to_i.to_s + " #{name}"
      end
    end
    result.join(', ')
  end
  
end
