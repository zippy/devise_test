class Ability
  include CanCan::Ability
  
  def initialize(user)
    @user = user || User.new # guest user
    
    @user.get_privs.each{|p| can p.to_sym,:all}
    
    if @user.has_priv?(:admin)
      can :read, :logged_in_users
      can :login_as, User
      can :delete, User
      can :change_password, User
    end

    if @user.has_priv?(:accessAccounts)
      can :read, User
      can :edit, User
    end

    if @user.has_priv?(:createAccounts)
      can :create, User
    end
    if @user.persisted?
      can :change_password, User
    end
  end
end