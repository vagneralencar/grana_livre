class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :restrict_with_error # Prevent deletion if transactions exist

  belongs_to :parent, class_name: "Category", optional: true
  has_many :sub_categories, class_name: "Category", foreign_key: "parent_id", dependent: :destroy

  enum category_type: { expense: "expense", income: "income" }

  validates :name, presence: true, uniqueness: { scope: [:user_id, :category_type], message: "already exists for this user and type" }
  validates :category_type, presence: true, inclusion: { in: category_types.keys }
  validates :user_id, presence: true

  # Ensure a category cannot be its own parent
  validate :parent_cannot_be_self

  private

  def parent_cannot_be_self
    if parent_id.present? && parent_id == id
      errors.add(:parent_id, "cannot be self")
    end
  end
end

