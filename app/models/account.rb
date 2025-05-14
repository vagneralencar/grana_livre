class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates :name, presence: true
  validates :user_id, presence: true
  validates :initial_amount, numericality: true, presence: true
  validates :current_amount, numericality: true, presence: true

  after_initialize :set_default_values, if: :new_record?

  # Callback to update current_amount when a transaction is made is handled in Transaction model

  private

  def set_default_values
    self.initial_amount ||= 0.0
    self.current_amount ||= self.initial_amount
    self.include_in_reports = true if self.include_in_reports.nil?
    self.allow_negative_amount = true if self.allow_negative_amount.nil?
  end
end

