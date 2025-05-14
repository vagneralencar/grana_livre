class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Optional: Configure permitted parameters for Devise if not already handled in initializers or User model
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :language, :time_zone, :currency])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :language, :time_zone, :currency, :photo]) # Add :photo if using Active Storage
  end
end

