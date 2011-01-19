# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper
  def notice(note, param)
    case note
    when :user_created_and_activated
      "Account #{param.user_name} was created and activation instructions have been sent to #{param.email}"
    when :user_activated
      "Activation instructions have been sent to #{param.email} for account #{param.user_name}."
    when :user_deactivated
      "Account #{param.user_name} was deactivated."
    when :user_activation_resent
      "Activation instructions have been re-sent to #{param.email} for account #{param.user_name}."
    when :password_reset
      "A password reset e-mail was sent to #{param.email} for account #{param.user_name}."
    when :user_created
      "Account #{param.user_name} was created."
    when :user_deleted
      "Account #{param} was deleted."
    when :user_contact_info_updated
      param == current_user ? "Your contact information was updated." : "The contact info for account #{param.user_name} was updated."
    when :user_preferences_set
      param == current_user ? "Your preferences were updated." : "The preferences for account #{param.user_name} were updated."
    when :password_changed
      param == current_user ? "Your password has been changed." : "The password for account #{param.user_name} was changed."
    when :session_expired
      "Your session has timed out. Please sign in again to continue."
    when :not_allowed
      "You don't have permission to do that."
    else
      note.to_s
    end
  end

  def current_user_can?(permission)
    can?(permission,:all)
  end

  def current_user_is?(user_type)
    u = current_user
    u ? u.user_type == user_type.to_s : false
  end


  def titlize_for_select(list)
    list.collect{|x| [x.titleize, x]}
  end
  
  def localize_time(the_time)
    standard_time(current_user.localize_time(the_time))
  end
  
  def login_url
    new_user_session_url
  end
  def logout_url
    destroy_user_session_url
  end
  
  def my_error_messages_for(object)
    html = ""
    if !object.nil? && object.errors.any?
      html = %Q{<ul class="formError">}+
      object.errors.full_messages.collect { |msg|  %Q|<li class="formError">#{msg}</li>|}.join+
      "</ul>"
    end
    html.html_safe
  end
  
  def search_results_count(objects,entry_name)
    if objects.nil? || ((size = objects.size) == 0)
        html = "No #{entry_name} found"
    else
      html = @search_params[:paginate]=='yes' ?
        page_entries_info(objects,:entry_name => entry_name) :
        (size > 1 ?  "Displaying <b>all #{size}</b> #{entry_name}" : "Displaying <b>1</b> #{entry_name.singularize}")
    end
    html = '<p><i>'+html+'</i></p>'
    html.html_safe
  end
  
end
