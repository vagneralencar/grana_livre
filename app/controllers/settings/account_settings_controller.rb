class Settings::AccountSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  # GET /settings/account (corresponds to show action)
  def show
    # @user is set by set_user
  end

  # PATCH/PUT /settings/account (corresponds to update action)
  def update
    if @user.update(account_settings_params)
      # Apply settings if needed (e.g., I18n.locale = @user.language)
      redirect_to settings_account_path, notice: "Configurações da conta atualizadas com sucesso."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def account_settings_params
    params.require(:user).permit(:language, :time_zone, :currency)
  end
end

