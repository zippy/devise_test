class User < ActiveRecord::Base

  before_create :skip_confirmation!

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :timeoutable, :confirmable, :token_authenticatable


  Permissions = %w(dev admin assignPrivs createAccounts accessAccounts)
  Preferences = %w(terse boxesClosed validateForm enlargeFont)

  validates_uniqueness_of :user_name
  validates_presence_of :user_name,:first_name,:last_name

  with_options :if => :password_required? do |v|
    v.validates_presence_of     :password
    v.validates_confirmation_of :password
    v.validates_length_of       :password, :within => 4..20, :allow_blank => true
  end

  
  def self.get_logged_in_users
    logged_in_users = User.find(:all,:conditions=>["last_request_at > ?",Time.now - SessionExpirationSeconds])
    users_hash = {}
    logged_in_users.each{|u| users_hash[u.id] = u.last_request_at}
    users_hash
  end

  def full_name(lastname_first = true)
    if lastname_first
      "#{last_name}, #{first_name}"
    else
      "#{first_name} #{last_name}"
    end
  end

  def enabled?
    enabled == true
  end

  def deactivated?
    !enabled? && confirmation_token.blank?
  end

  def activated?
    enabled? && confirmation_token.blank?
  end
  
  def activation_pending?
    !enabled? && !confirmation_token.blank?
  end
  
  def humanized_activation_status
    case
      when deactivated?
      "deactivated"
    when activation_pending?
      "activation e-mail sent"
    when activated?
      "active"
    end
  end

  def activate!
    send_confirmation_instructions
  end
  
  def resend_activation_message
    resend_confirmation_token
  end

  def deactivate!
    self.enabled = false
    self.confirmation_token = nil
    self.encrypted_password = ''
    save
  end
  
  def has_preference(pref)
    preferences && preferences.include?(pref)
  end
  
  def has_priv?(priv)
    get_privs.include?(priv.to_s)
  end

  def get_privs
    @privs ||= self.privs.nil? ? [] : (privs.is_a?(String) ? YAML.load(self.privs) : privs)
  end

  def set_privs(*p)
    the_privs = p.flatten.map{|x|x.to_s}.uniq
    the_privs.each {|x| raise "invalid priv #{x}" if !Permissions.include?(x)}
    self.privs = the_privs.sort.to_yaml
    @privs = nil
    save
  end

  def add_privs(*p)
    set_privs(get_privs.concat(p))
  end

  def delete_privs(*p)
    new_privs = get_privs - p.map{|x|x.to_s}
    set_privs(new_privs)
  end

  def localize_time(the_time)
    if the_time && self.timezone_offset
      the_time - self.timezone_offset - SystemTZOffset
    else
      the_time
    end
  end
  

  ##############################################
  # Additions to Devise 
  ##############################################

  # overriden to return many if the many param = true
  def self.find_or_initialize_with_error_by(attribute, value, error=:invalid,many = false) #:nodoc:
    find_or_initialize_with_errors([attribute], { attribute => value }, error, many)
  end

  # overriden to return many if the many param = true
  def self.find_or_initialize_with_errors(required_attributes, attributes, error=:invalid,many = false) #:nodoc:
    case_insensitive_keys.each { |k| attributes[k].try(:downcase!) }
    
    attributes = attributes.slice(*required_attributes)
    attributes.delete_if { |key, value| value.blank? }

    if attributes.size == required_attributes.size
      records = to_adapter.find_all(attributes)
    else
      records = []
    end
    
    if !records.empty?
      records = records[0] if !many
    else
      record = new

      required_attributes.each do |key|
        value = attributes[key]
        record.send("#{key}=", value)
        record.errors.add(key, value.present? ? error : :blank)
      end
      many ? records << record : records = record
    end

    records
  end
  
  # overriden to also enable
  def confirm!
    unless_confirmed do
      self.enabled = true
      self.confirmation_token = nil
      self.confirmed_at = Time.now
      save(:validate => false)
    end
  end

  # overridden to use prepare_to_reset_password and MyDeviseMailer
  def send_reset_password_instructions
    prepare_to_reset_password
    MyDeviseMailer.reset_password_instructions([self]).deliver
  end

  # new function to gain non-protected access to generate_reset_password_token!
  def prepare_to_reset_password
    generate_reset_password_token!
  end

  # new function to set the password without knowing the current password
  # used in our confirmation controller. 
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  # new function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end
  
  # new function to provide access to protected method unless_confirmed
  def only_if_unconfirmed
    unless_confirmed {yield}
  end

  protected 

  # overriden because Devise requires passwords for new records.  We don't
  def password_required?
    !password.nil? || !password_confirmation.nil?
  end

end

module MyDeviseClassMethods
  def send_reset_password_instructions(attributes={})
    recoverables = find_or_initialize_with_errors([:email], attributes, :not_found, true)  # use reset_password_keys instead of [:email] after Devise 038eb321d4ce97d5c8f548fdde5c0de9af07d792
    if recoverables[0].persisted?
      recoverables.each {|r| r.prepare_to_reset_password}
      MyDeviseMailer.reset_password_instructions(recoverables).deliver
    end
    recoverables
  end
end

User.class_eval do
  extend MyDeviseClassMethods
end
