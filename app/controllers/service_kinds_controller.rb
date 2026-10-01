class ServiceKindsController < ApplicationController
  before_action :set_service_kind, only: %i[edit update destroy]

  def index
    @service_kinds = policy_scope(ServiceKind).includes(:equipment_kinds).order(:name)
  end

  def new
    @service_kind = authorize ServiceKind.new
  end

  def edit
  end

  def create
    @service_kind = authorize ServiceKind.new(service_kind_params)

    respond_to do |format|
      if @service_kind.save
        format.html { redirect_to service_kinds_path, notice: "El tipo de servicio se creó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El tipo de servicio se creó correctamente." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @service_kind.update(service_kind_params)
        format.html { redirect_to service_kinds_path, notice: "El tipo de servicio se actualizó correctamente.", status: :see_other }
        format.turbo_stream { flash.now[:notice] = "El tipo de servicio se actualizó correctamente." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @service_kind.discard!

    respond_to do |format|
      format.html { redirect_to service_kinds_path, notice: "El tipo de servicio a sido eliminado.", status: :see_other }
      format.turbo_stream { flash.now[:notice] = "El tipo de servicio a sido eliminado." }
    end
  end

  private

  def set_service_kind
    @service_kind = authorize ServiceKind.visible.find(params.expect(:id))
  end

  def service_kind_params
    params.require(:service_kind).permit(:name, :recurring, :default_interval, :interval_unit, :priority)
  end
end
