class MyDeviseMailer < Devise::Mailer
  private
  def initialize_from_record(records)
    if records.is_a?(Array)
      record = records[0]
    else
      record = records
    end
    @scope_name = Devise::Mapping.find_scope!(record)
    @resource   = instance_variable_set("@#{devise_mapping.name}", record)
    @resources = records
  end
end
