class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  # GET /accounts
  def index
    @accounts = current_user.accounts.order(:name)
    # Eager load transactions count or sum if needed for display, or handle in view/decorator
  end

  # GET /accounts/1
  def show
    # @account is set by set_account
    # Consider paginating transactions if the list is long
    @transactions = @account.transactions.order(transaction_date: :desc).limit(20)
  end

  # GET /accounts/new
  def new
    @account = current_user.accounts.new
  end

  # GET /accounts/1/edit
  def edit
    # @account is set by set_account
  end

  # POST /accounts
  def create
    @account = current_user.accounts.new(account_params)
    # Initialize current_amount with initial_amount if not set otherwise
    @account.current_amount = @account.initial_amount if @account.current_amount.nil?

    if @account.save
      redirect_to @account, notice: "Conta criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      # Recalculate current_amount if initial_amount changed? 
      # This might be complex if transactions are involved. 
      # For now, assume current_amount is managed by transactions or manually adjusted if needed.
      redirect_to @account, notice: "Conta atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/1
  def destroy
    # Transactions associated might be destroyed due to `dependent: :destroy` in Account model
    @account.destroy
    redirect_to accounts_url, notice: "Conta excluída com sucesso."
  end

  # GET /accounts/transfer_form or similar for a dedicated transfer page
  # For simplicity, let's assume the transfer action is initiated from somewhere else or a specific route
  # This is a placeholder for the transfer action itself.
  # POST /accounts/:id/transfer or a dedicated /transfers controller might be better.
  # For now, sticking to the route generated: get "accounts/transfer"
  # This should be a POST and likely to a specific account or a general transfer path.
  # Let's adjust the route to be a POST to a member for now.
  # The route was defined as: `get "accounts/transfer"` initially by generator
  # and then `member { post :transfer }` in routes.rb
  
  # GET /accounts/new_transfer (to display the form)
  def new_transfer
    @accounts = current_user.accounts.order(:name)
    # You might want to exclude the current account from destination if transferring from a specific account page
  end

  # POST /accounts/perform_transfer (custom route or part of a TransfersController)
  def perform_transfer
    from_account_id = params[:from_account_id]
    to_account_id = params[:to_account_id]
    amount_to_transfer = params[:amount].to_d # Use .to_d for BigDecimal

    from_account = current_user.accounts.find_by(id: from_account_id)
    to_account = current_user.accounts.find_by(id: to_account_id)

    if from_account && to_account && amount_to_transfer > 0
      if from_account == to_account
        redirect_to new_transfer_accounts_path, alert: "Conta de origem e destino não podem ser a mesma."
        return
      end
      
      # Check if from_account has enough balance (if not allowing negative)
      if !from_account.allow_negative_amount && from_account.current_amount < amount_to_transfer
        redirect_to new_transfer_accounts_path, alert: "Saldo insuficiente na conta de origem."
        return
      end

      begin
        ActiveRecord::Base.transaction do
          # Create debit transaction for from_account
          from_account.transactions.create!(
            description: "Transferência para #{to_account.name}",
            amount: amount_to_transfer,
            transaction_date: Date.today,
            transaction_type: "expense",
            category_id: nil, # Or a specific "Transfer" category
            paid: true # Transfers are immediate
          )
          # Create credit transaction for to_account
          to_account.transactions.create!(
            description: "Transferência de #{from_account.name}",
            amount: amount_to_transfer,
            transaction_date: Date.today,
            transaction_type: "income",
            category_id: nil, # Or a specific "Transfer" category
            paid: true
          )
          # Callbacks in Transaction model should update account balances
        end
        redirect_to accounts_path, notice: "Transferência realizada com sucesso."
      rescue ActiveRecord::RecordInvalid => e
        redirect_to new_transfer_accounts_path, alert: "Erro ao realizar transferência: #{e.message}"
      end
    else
      redirect_to new_transfer_accounts_path, alert: "Contas inválidas ou valor incorreto para transferência."
    end
  end


  private
    def set_account
      @account = current_user.accounts.find_by(id: params[:id])
      if @account.nil?
        redirect_to accounts_url, alert: "Conta não encontrada."
      end
    end

    def account_params
      params.require(:account).permit(:name, :initial_amount, :include_in_reports, :allow_negative_amount)
      # current_amount is not directly permitted, it's calculated or set internally
    end
end

