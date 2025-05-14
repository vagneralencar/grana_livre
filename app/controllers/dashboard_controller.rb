class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # Buscar despesas do usuário agrupadas por categoria
    # Placeholder: Implementar a lógica real aqui
    @expenses_by_category = current_user.transactions.where(transaction_type: "expense")
                                      .joins(:category)
                                      .group("categories.name")
                                      .sum(:amount)
                                      .sort_by { |_key, value| value }
                                      .reverse
                                      .to_h

    # Buscar despesas pendentes do usuário (transações do tipo despesa não pagas)
    # Placeholder: Implementar a lógica real aqui
    @pending_expenses = current_user.transactions.where(transaction_type: "expense", paid: false)
                                   .order(transaction_date: :asc)

    # Preparar dados de transações para o calendário do mês atual
    # Placeholder: Implementar a lógica real aqui. 
    # Por simplicidade, vamos pegar todas as transações do mês atual.
    @start_date = Date.today.beginning_of_month
    @end_date = Date.today.end_of_month
    @transactions_for_calendar = current_user.transactions
                                          .where(transaction_date: @start_date..@end_date)
                                          .order(transaction_date: :asc)
    
    # Agrupar transações por dia para o calendário
    @transactions_by_date = @transactions_for_calendar.group_by { |t| t.transaction_date.day }

    # Para um calendário simples na view, podemos precisar de todos os dias do mês
    @days_in_month = (@start_date..@end_date).to_a
  end
end

