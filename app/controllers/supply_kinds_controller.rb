class SupplyKindsController < ApplicationController
  before_action :set_supply_kind, only: %i[edit update destroy]

  def index
    @supply_kinds = policy_scope(SupplyKind).order(:name)
  end

  def new
    @supply_kind = authorize SupplyKind.new
  end

  def edit
  end

  def create
    @supply_kind = authorize SupplyKind.new(supply_kind_params)

    respond_to do |format|
      if @supply_kind.save
        format.html { redirect_to supply_kinds_path, notice: "El tipo de insumo se creó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El tipo de insumo se creó correctamente." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @supply_kind.update(supply_kind_params)
        format.html { redirect_to supply_kinds_path, notice: "El tipo de insumo se actualizó correctamente.", status: :see_other }
        format.turbo_stream { flash.now[:notice] = "El tipo de insumo se actualizó correctamente." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @discarded = @supply_kind.discard

    respond_to do |format|
      if @discarded
        format.html { redirect_to supply_kinds_path, notice: "El tipo de insumo se eliminó.", status: :see_other }
        format.turbo_stream { flash.now[:notice] = "El tipo de insumo se eliminó." }
      else
        format.html { redirect_to supply_kinds_path, alert: @supply_kind.errors.full_messages.to_sentence, status: :see_other }
        format.turbo_stream { flash.now[:alert] = @supply_kind.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_supply_kind
    @supply_kind = authorize SupplyKind.visible.find(params.expect(:id))
  end

  def supply_kind_params
    params.require(:supply_kind).permit(:name, :description)
  end
end
