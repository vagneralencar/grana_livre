class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  before_action :set_select_collections, only: [:new, :create, :edit, :update]

  # GET /transactions
  def index
    # Base query for current user's transactions
    @transactions = current_user.transactions.includes(:account, :category).order(transaction_date: :desc)

    # Filtering by period (example: by month)
    if params[:month].present? && params[:year].present?
      month = params[:month].to_i
      year = params[:year].to_i
      @start_date = Date.new(year, month, 1)
      @end_date = @start_date.end_of_month
      @transactions = @transactions.where(transaction_date: @start_date..@end_date)
    else
      # Default to current month if no period is specified
      @start_date = Date.today.beginning_of_month
      @end_date = Date.today.end_of_month
      # @transactions = @transactions.where(transaction_date: @start_date..@end_date) # Uncomment to default filter
    end

    # Filtering by type (expense/income)
    if params[:type].present?
      @transactions = @transactions.where(transaction_type: params[:type])
    end

    # Filtering by account
    if params[:account_id].present?
      @transactions = @transactions.where(account_id: params[:account_id])
    end

    # Filtering by category
    if params[:category_id].present?
      @transactions = @transactions.where(category_id: params[:category_id])
    end

    # Placeholder for pagination (e.g., using kaminari or pagy gem)
    # @transactions = @transactions.page(params[:page]).per(10)
    # For now, no pagination
  end

  # GET /transactions/1
  def show
    # @transaction is set by set_transaction
  end

  # GET /transactions/new
  def new
    @transaction = current_user.transactions.new
  end

  # GET /transactions/1/edit
  def edit
    # @transaction is set by set_transaction
  end

  # POST /transactions
  def create
    @transaction = current_user.transactions.new(transaction_params)
    # Ensure account belongs to user before associating
    if @transaction.account && @transaction.account.user != current_user
      redirect_to transactions_url, alert: "Conta inválida."
      return
    end
    if @transaction.category && @transaction.category.user != current_user
      redirect_to transactions_url, alert: "Categoria inválida."
      return
    end

    if @transaction.save
      # Callback in Transaction model should handle account balance update
      redirect_to @transaction, notice: "Transação criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transactions/1
  def update
    # Ensure new account and category belong to user if changed
    new_account_id = transaction_params[:account_id]
    new_category_id = transaction_params[:category_id]

    if new_account_id.present? && Account.find_by(id: new_account_id, user: current_user).nil?
      redirect_to transactions_url, alert: "Conta inválida."
      return
    end
    if new_category_id.present? && Category.find_by(id: new_category_id, user: current_user).nil?
      redirect_to transactions_url, alert: "Categoria inválida."
      return
    end

    if @transaction.update(transaction_params)
      # Callback in Transaction model should handle account balance update
      redirect_to @transaction, notice: "Transação atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /transactions/1
  def destroy
    # Callback in Transaction model should handle account balance update before destroy
    @transaction.destroy
    redirect_to transactions_url, notice: "Transação excluída com sucesso."
  end

  private
    def set_transaction
      @transaction = current_user.transactions.find_by(id: params[:id])
      if @transaction.nil?
        redirect_to transactions_url, alert: "Transação não encontrada."
      end
    end

    def set_select_collections
      @accounts = current_user.accounts.order(:name)
      @categories = current_user.categories.order(:name) # Consider grouping by type (expense/income)
    end

    def transaction_params
      params.require(:transaction).permit(:description, :amount, :transaction_date, :transaction_type, :account_id, :category_id, :notes, :paid)
    end
end

