class Settings::NotificationPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  # GET /settings/notification_preferences (corresponds to show action)
  def show
    # @user is set by set_user. We might store notification preferences in a serialized column
    # on the User model (e.g., `serialize :notification_preferences, Hash`)
    # or a separate model if they are complex.
    # For simplicity, let's assume a few boolean flags on the User model itself for now.
    # e.g., user.rb has: attribute :notify_pending_expenses, :boolean, default: true
  end

  # PATCH/PUT /settings/notification_preferences (corresponds to update action)
  def update
    if @user.update(notification_preferences_params)
      redirect_to settings_notification_preferences_path, notice: "Preferências de notificação atualizadas com sucesso."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def notification_preferences_params
    # Ensure these attributes exist on the User model or are handled appropriately
    # (e.g., stored in a serialized field or a related model)
    params.require(:user).permit(:notify_pending_expenses, :notify_monthly_summary) # Example preferences
  end
end

