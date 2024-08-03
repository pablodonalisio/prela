class UsersController < ApplicationController
  before_action :set_users, only: %i[index destroy update]

  def index
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

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
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to users_path, notice: "Usuario actualizado exitosamente" }
        format.turbo_stream { flash.now[:notice] = "Usuario actualizado exitosamente" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash.now[:notice] = "El usuario ha sido eliminado." if User.find(params[:id]).destroy
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :role)
  end

  def set_users
    @users = User.all.order(created_at: :desc)
  end
end
