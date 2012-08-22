
class UsersController < ApplicationController

  include ApplicationHelper


  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :show]
  before_filter :correct_user,   only: [:edit, :update, :show, :update]
  before_filter :admin_user, only: [:index]
  before_filter :abandon_course_build
  before_filter :abandon_item_build


  def show
    @author=current_user if current_user&&current_user.author
    @profiles=Profile.find(:all, :order => :id)
    @user = User.find(params[:id])
    @user.update_attribute(:tag, "") unless @user.tag 
    tags=@user.tag.split(' ')
    tags=tags.delete('') if tags.include?('')
    @oldcourses=Course.find(:all, :order => :name).find_all {|course| Profile.find(:all, :order => :id).find_all {|profile| profile.course== course.id&&profile.user==@user.id}.count>0}
    #@courses_html=displaycourses(@user.id, @oldcourses)
    @scores=[]
    @profiles=[]
    @oldcourses.each do 
      |course|
      profile=(Profile.find(:all, :order => :id).find_all {|profile| profile.course==course.id&&profile.user==@user.id})[0]
      @profiles<<profile
      @scores<<score(profile)
    end
    @courses=Course.find(:all, :order => :name).find_all {|course| tags.find_all {|tag| course.tag.match('`'+tag+'`')}.count>0}
    @newcourses=@courses.find_all {|course| @oldcourses.include?(course)==false}

    @authorhtml=''

    if @author
      @authorcourses=Course.find(:all, :order => :name).find_all {|course| course.tag.match('_'+@author.id.to_s+'`')}
      @authorusers=User.find(:all, :order => :name).find_all {|user| user.tag.match(Regexp::new('_'+@author.id.to_s+'(\z| )'))}
      
      @authortags=[]
     @authorcourses.each do
        |course|
        reg= Regexp::new('`[^`]+_'+@author.id.to_s+'`' )
        tags=matches(course.tag,reg)
        tags.each do
          |tag|
          @authortags<<tag unless @authortags.include?(tag)
        end
      end

      @authortags.each do
        |tag|
        @authorhtml=@authorhtml+'<h5a><br>With tag: '+tag[1..-2]+'</h5a><br>'
        courses=@authorcourses.find_all {|course| course.tag.match(tag)}
        courses.each do
          |course|
          @authorhtml=@authorhtml+'<br><h3>'+course.name+'</h3><table class="table"><tr>'
          users=@authorusers.find_all {|user| user.tag.match(Regexp::new('(\A| )'+tag[1..-2]+'(\z| )'))}
          users.each do
            |user|
            name=User.find_by_id(user).name
            profile=Profile.find(:all, :order => :id).find_all {|profile| profile.course==course.id&&profile.user==user.id}[0]
            name=name+' <h8>(not joined)</h8>' unless profile
            @authorhtml=@authorhtml+' <td style="vertical-align:middle" width="20">'+name+'</td><td style="vertical-align:middle" width="50"><img src="http://i970.photobucket.com/albums/ae189/gumboil/website/starsfinishline.png" width="10">'
            score=score(profile)
            score[2].each do
              |stage|
              @authorhtml=@authorhtml+'<img src="http://i970.photobucket.com/albums/ae189/gumboil/website/stars'+stage+'.png" width="10">
              <img src="http://i970.photobucket.com/albums/ae189/gumboil/website/starsfinishline.png" width="10">'
            end
            @authorhtml=@authorhtml+'</td><td style="vertical-align:middle" width="100">'+score[0].to_s+'</td><td style="vertical-align:middle" width="100">'
            @authorhtml=@authorhtml+'<img src="http://i970.photobucket.com/albums/ae189/gumboil/website/'+ score[1]+'" width="25"></td></tr>'

          end
          @authorhtml=@authorhtml+'</table>'
        end
      end
    end


    
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
    elsif !params[:@agree]
      flash[:failure]="You must agree to the terms and conditions and accept the cookies and privacy policy"
      redirect_to signup_path
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
    user=User.find(params[:id])
    unless current_user?(user)
      user.destroy
      flash[:success] = "User destroyed."
      redirect_to users_path
    else
      flash[:alert] = "You cannot destroy yourself."
      redirect_to user_path
    end

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

  def matches(string,pattern)
    partn= string.partition(pattern)
    if string==partn[2]
      return []
    else
      return matches(partn[2],pattern)<<partn[1]
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

    def admin_user
      redirect_to(root_path) if current_user==nil
      redirect_to(root_path) unless current_user.admin
    end

end
