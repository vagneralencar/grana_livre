class CalendarController < ApplicationController
  before_action :authenticate_user!

  def show
    @today = params[:date] ? Date.parse(params[:date]) : Date.today
    @start_date = @today.beginning_of_month
    @end_date = @today.end_of_month

    # Fetch transactions for the current month view
    @transactions_for_calendar = current_user.transactions
                                          .where(transaction_date: @start_date..@end_date)
                                          .order(transaction_date: :asc)

    # Group transactions by day for easy lookup in the view
    @transactions_by_date = @transactions_for_calendar.group_by { |t| t.transaction_date }

    # For rendering the calendar grid, we need all days of the month
    # and potentially days from previous/next month to fill the first/last week
    @calendar_start_day = @start_date.beginning_of_week(:sunday) # Or :monday depending on preference
    @calendar_end_day = @end_date.end_of_week(:sunday)
    @date_range = (@calendar_start_day..@calendar_end_day).to_a
  end
end

