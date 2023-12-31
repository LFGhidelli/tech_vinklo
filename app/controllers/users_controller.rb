class UsersController < ApplicationController
  before_action :set_user, only: %i[ edit update destroy ]

  # GET /users or /users.json
  def index
    if params[:search]
      # @users = User.where("name LIKE ? OR email LIKE ? OR phone LIKE ? OR cpf LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
      @users = User.where(
        "name LIKE ? OR
        email LIKE ? OR
        REPLACE(phone, ' ', '') LIKE ? OR
        REPLACE(REPLACE(cpf, '.', ''), '-', '') LIKE ?",
        "%#{params[:search]}%",
        "%#{params[:search]}%",
        "%#{params[:search]}%",
        "%#{params[:search]}%"
      )
    else
      @users = User.all
    end
  end

  # # GET /users/1 or /users/1.json
  # def show
  # end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  # def update
  # end


  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path(@user), notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: "User was successfully updated." }  # Redirecting to index page
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone, :cpf)
  end
end
