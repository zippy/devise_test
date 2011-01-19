class PasswordsController < Devise::PasswordsController
  before_filter :set_request_for_mailer
  # POST /resource/password
  def create
    @resources = User.send_reset_password_instructions(params[resource_name])

    self.resource = @resources.is_a?(Array) ? @resources[0] : @resources
    if resource.errors.empty?
      set_flash_message :notice, :send_instructions
      redirect_to new_session_path(resource_name)
    else
      render_with_scope :new
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.find_or_initialize_with_error_by(:reset_password_token, params[:reset_password_token])
    if resource.errors.empty?
      render_with_scope :edit
    else
      render_with_scope :new
    end
  end
  private
  #note, this is not thread-safe, and only works because the host_with_port is the same for us
  #see http://www.simonecarletti.com/blog/2009/10/actionmailer-and-host-value/
  def set_request_for_mailer
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end
