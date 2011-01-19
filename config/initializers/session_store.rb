# Be sure to restart your server when you modify this file.

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")

Devisetestapp::Application.config.session_store :active_record_store, {
  :key => '_devisetest_session_id',
  :secret =>'klajsdfasdfjkhasdfa8s7df76a5sdf8aga09s8df7a0876gasd87f6a8s7d6fasdf9b736a8ab6b73c08137'
}