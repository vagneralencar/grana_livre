class Settings::BackupsController < ApplicationController
  before_action :authenticate_user!

  # GET /settings/backup (corresponds to show action)
  def show
    # This page will offer the option to download data.
  end

  # POST /settings/backup (corresponds to create action for initiating the download)
  def create
    # Placeholder for data generation and download logic
    # This would involve collecting user data (transactions, accounts, categories, etc.)
    # and formatting it (e.g., as JSON or CSV).

    user_data = {
      user: current_user.as_json(only: [:id, :name, :email, :language, :time_zone, :currency]),
      accounts: current_user.accounts.as_json(except: [:user_id]),
      categories: current_user.categories.as_json(except: [:user_id]),
      transactions: current_user.transactions.as_json(except: [:user_id])
      # Add other relevant data as needed
    }

    respond_to do |format|
      format.json do
        send_data user_data.to_json,
                  filename: "grana_livre_backup_#{Time.current.strftime("%Y%m%d%H%M%S")}.json",
                  type: "application/json"
      end
      # format.csv { # Implement CSV generation logic here }
    end
  end
end

