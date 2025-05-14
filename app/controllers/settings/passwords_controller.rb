class Settings::PasswordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  # GET /settings/password (corresponds to show action)
  def show
    # Devise handles password changes, so this action might just render the form.
    # The form will typically POST to the user registration path or a custom Devise controller.
    # For simplicity, we assume Devise's default routes or a custom route for password update.
  end

  # PATCH/PUT /settings/password (corresponds to update action)
  # This action would typically be handled by Devise::RegistrationsController#update
  # if using standard Devise routes for password changes for a signed-in user.
  # If we are overriding, this is where the logic would go.
  def update
    if @user.update_with_password(password_params)
      # Sign in the user by passing validation in case their session expired
      bypass_sign_in(@user)
      redirect_to settings_profile_path, notice: "Senha atualizada com sucesso."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end

