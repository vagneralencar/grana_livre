class Settings::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  # GET /settings/profile (corresponds to show action)
  def show
    # @user is set by set_user
  end

  # PATCH/PUT /settings/profile (corresponds to update action)
  def update
    if @user.update(user_params)
      redirect_to settings_profile_path, notice: "Perfil atualizado com sucesso."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    # Ensure you have `photo` configured for Active Storage in your User model
    # e.g., `has_one_attached :photo`
    params.require(:user).permit(:name, :email, :photo) # Add other permitted attributes like :language, :time_zone, :currency if they are edited here
  end
end

