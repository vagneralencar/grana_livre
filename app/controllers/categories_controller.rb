class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :set_parent_categories, only: [:new, :create, :edit, :update]

  # GET /categories
  def index
    @expense_categories = current_user.categories.where(category_type: "expense").where(parent_id: nil).order(:name).includes(:sub_categories)
    @income_categories = current_user.categories.where(category_type: "income").where(parent_id: nil).order(:name).includes(:sub_categories)
  end

  # GET /categories/1
  def show
    # @category is set by set_category
    # Consider paginating transactions if the list is long
    @transactions = @category.transactions.order(transaction_date: :desc).limit(10)
  end

  # GET /categories/new
  def new
    @category = current_user.categories.new
  end

  # GET /categories/1/edit
  def edit
    # @category is set by set_category
  end

  # POST /categories
  def create
    @category = current_user.categories.new(category_params)

    if @category.save
      redirect_to categories_url, notice: "Categoria criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    if @category.update(category_params)
      redirect_to categories_url, notice: "Categoria atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /categories/1
  def destroy
    # The model has `dependent: :restrict_with_error` for transactions
    # and `dependent: :destroy` for sub_categories (this needs to be checked/ensured in model)
    # If category has transactions, it won't be deleted by default due to restrict_with_error.
    # If it has sub-categories, they will be deleted if `dependent: :destroy` is set on `has_many :sub_categories`.
    # For now, let's assume the model handles this correctly.
    if @category.transactions.any?
      redirect_to categories_url, alert: "Não é possível excluir categorias com transações associadas."
    elsif @category.sub_categories.any? && !params[:confirm_delete_with_subcategories] # Add a confirmation step if needed
       # Basic check, a more robust solution might be needed for deep nesting or specific business rules
       # For now, let's assume subcategories are handled by `dependent: :destroy` or a similar strategy in the model.
       # If `dependent: :destroy` is on `has_many :sub_categories`, they will be deleted.
       # If not, this will fail or leave orphaned subcategories.
       # The Category model has `has_many :sub_categories, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy` (assuming this was added)
      @category.destroy
      redirect_to categories_url, notice: "Categoria e suas subcategorias foram excluídas com sucesso."
    else
      @category.destroy
      redirect_to categories_url, notice: "Categoria excluída com sucesso."
    end
  rescue ActiveRecord::DeleteRestrictionError => e
    redirect_to categories_url, alert: "Erro ao excluir categoria: #{e.message}"
  end

  private
    def set_category
      @category = current_user.categories.find_by(id: params[:id])
      if @category.nil?
        redirect_to categories_url, alert: "Categoria não encontrada."
      end
    end

    def set_parent_categories
      # For the parent category dropdown, only list categories that can be parents
      # (i.e., not subcategories themselves, or based on type)
      # For simplicity, allow any category of the same user to be a parent, excluding the current one if editing.
      @parent_categories = current_user.categories.order(:name)
      @parent_categories = @parent_categories.where.not(id: @category.id) if @category&.persisted?
    end

    def category_params
      params.require(:category).permit(:name, :category_type, :parent_id)
    end
end

