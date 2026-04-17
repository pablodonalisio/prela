class EquipmentKindsController < ApplicationController
  before_action :set_equipment_kind, only: %i[show edit update destroy]

  # GET /equipment_kinds or /equipment_kinds.json
  def index
    @equipment_kinds = policy_scope(EquipmentKind)
  end

  # GET /equipment_kinds/1 or /equipment_kinds/1.json
  def show
  end

  # GET /equipment_kinds/new
  def new
    @equipment_kind = authorize EquipmentKind.new
  end

  # GET /equipment_kinds/1/edit
  def edit
  end

  # POST /equipment_kinds or /equipment_kinds.json
  def create
    @equipment_kind = authorize EquipmentKind.new(equipment_kind_params)

    respond_to do |format|
      if @equipment_kind.save
        format.html { redirect_to @equipment_kind, notice: "Equipment kind was successfully created." }
        format.turbo_stream { flash.now[:notice] = "El tipo de activo se creo correctamente." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /equipment_kinds/1 or /equipment_kinds/1.json
  def update
    respond_to do |format|
      if @equipment_kind.update(equipment_kind_params)
        format.html { redirect_to @equipment_kind, notice: "El tipo de activo se actualizo correctamente.", status: :see_other }
        format.turbo_stream { flash.now[:notice] = "El tipo de activo se actualizo correctamente." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /equipment_kinds/1 or /equipment_kinds/1.json
  def destroy
    @equipment_kind.destroy!

    respond_to do |format|
      format.html { redirect_to equipment_kinds_path, notice: "El tipo de activo a sido eliminado.", status: :see_other }
      format.turbo_stream { flash.now[:notice] = "El tipo de activo a sido eliminado." }
    end
  end

  def add_field
    @field_key = Time.now.to_i

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_equipment_kind
    @equipment_kind = authorize EquipmentKind.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def equipment_kind_params
    params.require(:equipment_kind).permit(:name, fields: {})
  end
end
