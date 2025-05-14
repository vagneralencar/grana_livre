class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @report_type = params[:report_type] || "expenses_by_category" # Default report
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
    @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today.end_of_month

    case @report_type
    when "expenses_by_category"
      @report_data = current_user.transactions
                                 .where(transaction_type: "expense")
                                 .where(transaction_date: @start_date..@end_date)
                                 .joins(:category)
                                 .group("categories.name")
                                 .sum(:amount)
                                 .sort_by { |_key, value| value }
                                 .reverse
                                 .to_h
      @report_title = "Despesas por Categoria (#{@start_date.strftime("%d/%m/%Y")} - #{@end_date.strftime("%d/%m/%Y")})"
    when "income_by_category"
      @report_data = current_user.transactions
                                 .where(transaction_type: "income")
                                 .where(transaction_date: @start_date..@end_date)
                                 .joins(:category)
                                 .group("categories.name")
                                 .sum(:amount)
                                 .sort_by { |_key, value| value }
                                 .reverse
                                 .to_h
      @report_title = "Receitas por Categoria (#{@start_date.strftime("%d/%m/%Y")} - #{@end_date.strftime("%d/%m/%Y")})"
    when "account_history"
      # For account history, we might want to show balances over time for each account.
      # This is a simplified version showing total income/expense per account in the period.
      @report_data = {}
      current_user.accounts.where(include_in_reports: true).each do |account|
        income = account.transactions.where(transaction_type: "income", transaction_date: @start_date..@end_date).sum(:amount)
        expenses = account.transactions.where(transaction_type: "expense", transaction_date: @start_date..@end_date).sum(:amount)
        @report_data[account.name] = { income: income, expenses: expenses, balance_change: income - expenses }
      end
      @report_title = "Movimentação de Contas (#{@start_date.strftime("%d/%m/%Y")} - #{@end_date.strftime("%d/%m/%Y")})"
    else
      @report_data = {}
      @report_title = "Relatório não encontrado"
    end
    # For charts, you might want to use a gem like `chartkick` and prepare data accordingly.
  end
end

