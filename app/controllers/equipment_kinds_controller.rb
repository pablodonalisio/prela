class EquipmentKindsController < ApplicationController
  before_action :set_equipment_kind, only: %i[show edit update destroy]

  def index
    @equipment_kinds = policy_scope(EquipmentKind)
  end

  def show
  end

  def new
    @equipment_kind = authorize EquipmentKind.new
  end

  def edit
  end

  def create
    @equipment_kind = authorize EquipmentKind.new(equipment_kind_params)

    respond_to do |format|
      if @equipment_kind.save
        format.html { redirect_to @equipment_kind, notice: "Equipment kind was successfully created." }
        format.turbo_stream { flash.now[:notice] = "El tipo de activo se creo correctamente." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @equipment_kind.update(equipment_kind_params)
        format.html { redirect_to @equipment_kind, notice: "El tipo de activo se actualizo correctamente.", status: :see_other }
        format.turbo_stream { flash.now[:notice] = "El tipo de activo se actualizo correctamente." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @equipment_kind.discard!

    respond_to do |format|
      format.html { redirect_to equipment_kinds_path, notice: "El tipo de activo a sido eliminado.", status: :see_other }
      format.turbo_stream { flash.now[:notice] = "El tipo de activo a sido eliminado." }
    end
  end


  def add_field
    @field_set = field_set_param
    @field_key = EquipmentKind.generate_field_key

    respond_to do |format|
      format.turbo_stream
    end
  end

  def remove_field
    @field_key = params[:field_key]

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_equipment_kind
    @equipment_kind = authorize EquipmentKind.visible.find(params.expect(:id))
  end


  def equipment_kind_params
    permitted = params.require(:equipment_kind).permit(:name, :description, generic_fields: {}, specific_fields: {})
    permitted[:generic_fields] ||= {}
    permitted[:specific_fields] ||= {}
    permitted
  end

  def field_set_param
    field_set = params.fetch(:field_set, "generic_fields")
    EquipmentKind::FIELD_SETS.include?(field_set) ? field_set : "generic_fields"
  end
end
