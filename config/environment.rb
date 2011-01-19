# Load the rails application
require File.expand_path('../application', __FILE__)
SystemTZOffset = Time.now.utc_offset

# Initialize the rails application
Devisetestapp::Application.initialize!
