class SuppliesController < ApplicationController
  before_action :set_supply, only: %i[edit update destroy]

  def index
    @supply_kind_ids = Array(params[:supply_kind_ids]).compact_blank
    @supplies = policy_scope(Supply.filter(supply_kind_ids: @supply_kind_ids))
      .includes(:supply_kind, replacement_links: :replacement, replaced_by_links: :supply)
      .order(:name)
  end

  def new
    @supply = authorize Supply.new
  end

  def edit
  end

  def create
    @supply = authorize Supply.new(supply_params)

    respond_to do |format|
      if @supply.save
        format.html { redirect_to supplies_path, notice: "El insumo se creó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El insumo se creó correctamente." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @supply.update(supply_params)
        format.html { redirect_to supplies_path, notice: "El insumo se actualizó correctamente.", status: :see_other }
        format.turbo_stream { flash.now[:notice] = "El insumo se actualizó correctamente." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @supply.discard!

    respond_to do |format|
      format.html { redirect_to supplies_path, notice: "El insumo se eliminó.", status: :see_other }
      format.turbo_stream { flash.now[:notice] = "El insumo se eliminó." }
    end
  end

  private

  def set_supply
    @supply = authorize Supply.visible.find(params.expect(:id))
  end

  def supply_params
    params.require(:supply).permit(:supply_kind_id, :name, :description, :reference_url, :avatar, replacement_ids: [])
  end
end
