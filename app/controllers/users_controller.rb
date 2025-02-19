class UsersController < ApplicationController
  before_action :set_users, only: %i[index destroy update]

  def index
  end

  def new
    @user = authorize User.new
  end

  def create
    @user = authorize User.new(user_params)

    if @user.save
      respond_to do |format|
        format.html { redirect_to users_path, notice: "Usuario creado exitosamente" }
        format.turbo_stream { flash.now[:notice] = "Usuario creado exitosamente" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = user
    @change_password = params[:change_password]
  end

  def update
    @user = user

    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to users_path, notice: "Usuario actualizado exitosamente" }
        format.turbo_stream { flash.now[:notice] = "Usuario actualizado exitosamente" }
      end
    else
      @change_password = params[:user][:change_password]
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash.now[:notice] = "El usuario ha sido eliminado." if user.destroy
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :role, :client_id)
  end

  def set_users
    @users = authorize User.all.order(created_at: :desc)
  end

  def user
    @user ||= authorize User.find(params[:id])
  end
end
