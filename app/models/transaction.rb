class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :category

  # Enum for transaction_type if not deriving from category
  # enum transaction_type: { expense: "expense", income: "income" }

  validates :description, presence: true, length: { maximum: 255 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_date, presence: true
  validates :account_id, presence: true
  validates :category_id, presence: true
  # validates :transaction_type, presence: true, inclusion: { in: transaction_types.keys } # if using enum

  # Callbacks to update account balance
  after_create :update_account_balance_on_create
  after_destroy :update_account_balance_on_destroy
  after_update :update_account_balance_on_update, if: :saved_change_to_amount? # or if category_type changed

  private

  def transaction_type_from_category
    category&.category_type
  end

  def update_account_balance_on_create
    if transaction_type_from_category == "income"
      account.update(current_amount: account.current_amount + amount)
    elsif transaction_type_from_category == "expense"
      account.update(current_amount: account.current_amount - amount)
    end
  end

  def update_account_balance_on_destroy
    if transaction_type_from_category == "income"
      account.update(current_amount: account.current_amount - amount)
    elsif transaction_type_from_category == "expense"
      account.update(current_amount: account.current_amount + amount)
    end
  end

  def update_account_balance_on_update
    # This logic needs to be more robust if amount or type changes.
    # It should revert the old transaction's effect and apply the new one.
    # For simplicity, assuming only amount might change for now, and type remains consistent.
    # A more complex scenario would involve amount_before_last_save and category_id_before_last_save

    original_amount = amount_before_last_save
    current_amount_change = amount - original_amount

    if transaction_type_from_category == "income"
      account.update(current_amount: account.current_amount + current_amount_change)
    elsif transaction_type_from_category == "expense"
      account.update(current_amount: account.current_amount - current_amount_change)
    end
  end
end

