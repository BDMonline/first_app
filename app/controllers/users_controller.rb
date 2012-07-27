
class UsersController < ApplicationController

  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :show]
  before_filter :correct_user,   only: [:edit, :update, :show, :update]
  before_filter :author_user, only: [:index]

  def show
    
    @user = User.find(params[:id])
  end
  
  def new
    if signed_in?
      redirect_to root_path
    end
    @user = User.new
  end

  def create
    if signed_in?
      redirect_to root_path
    else
      @user = User.new(params[:user])
      if @user.update_attributes(:name => @user.name, :email => @user.email, :password => @user.password, :password_confirmation => @user.password_confirmation)
        @user.send_registration_confirmation if @user
        flash[:success]="An email with instructions has been sent to your address. Please follow the instructions to complete your registration. You may sign in here once registration is complete."
        redirect_to signin_path(@user)
      else
        render 'new'
      end
    end
  end
  def edit
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

   def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_path, notice: "Please sign in."
      end
    end

    def correct_user
      @user = User.find_by_id(params[:id])
      unless @user
        @user = User.find_by_login_token(params[:id]) 
        params[:id]=@user.id
      end
      
      redirect_to(root_path) unless current_user?(@user)
      end

    def author_user
      redirect_to(root_path) if current_user==nil
      redirect_to(root_path) unless current_user.author
    end

end
