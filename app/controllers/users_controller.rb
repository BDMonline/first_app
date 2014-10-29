
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
      #@authorusers=User.find(:all, :order => :name).find_all {|user| user.tag.match(Regexp::new('_'+@author.id.to_s+'(\z| )'))}
      
      @authortags=[]
      @authorcourses.each do
        |course|
        reg= Regexp::new('`[^`]+_'+@author.id.to_s+'`' )
        tags=matches(course.tag,reg)
        tags.each do
          |tag|
          @authortags<<tag unless @authortags.include?(tag)||tag==''
        end
      end


      if @authortags.count>0
        session[:authortag]=params[:newtag] if params[:newtag]
        if session[:authortag]
          oldtag=session[:authortag]
          if @authortags.index(oldtag)
            authortag=oldtag
          else
            authortag=@authortags[0]
          end
        else
          authortag=@authortags[0]
        end
        session[:authortag]=authortag

        if @authortags.count>1
          @authorhtml='<br><h7a>You have courses with the following tags:</h7a><form><br><h10><table width=100%><COLGROUP span="5" width=20%>
   </COLGROUP><tr>'
   count=0
          @authortags.each do |tag|
            count=count+1
            @authorhtml=@authorhtml+'<td><INPUT type="radio" name="newtag" value="'+tag+'"'
            @authorhtml=@authorhtml+' CHECKED ' if tag==authortag
            @authorhtml=@authorhtml+'> <tag>'+tag[1..-2]+'</tag></td>'
            @authorhtml=@authorhtml + '</tr><tr>' if count.gcd(5)==5
          end
          @authorhtml=@authorhtml+%Q(</tr></table><br>Choose a tag and click </h10><h8><b><INPUT type="submit" value="Select"></b></h8><h10>
            </table>
            </form></h10>)
        end

        selected_courses=@authorcourses.find_all {|course| course.tag.match(authortag)} 


#session[:authorcourse]=nil
        if selected_courses.count==1
          authorcourse=[selected_courses[0]]
          session[:authorcourse]=[authorcourse[0].id]
          @authorhtml=@authorhtml+'<h7a>Your only course with this tag is</h7a> <course>' + authorcourse[0].name + '</course><br><br>'
        else

          @authorhtml=@authorhtml+'<BR><h7a>You have the following courses tagged <tag>'+authortag[1..-2]+ '</tag></h7a> <br>'


          if params[:newcourse]&&params[:newcourse].count>0
            authorcourse=[]
            params[:newcourse].each do |coursename|
              authorcourse<<Course.find_by_name(coursename)
            end
          elsif session[:authorcourse]
            oldcourses=[]
            session[:authorcourse].each do |course_id|
              this_course=Course.find_by_id(course_id) 
              oldcourses<<this_course if selected_courses.index(this_course) 
            end
            if oldcourses.count>0
              authorcourse=oldcourses
            else
              authorcourse=[selected_courses[0]]
            end
       
          else
            authorcourse=[selected_courses[0]]
          end
          session[:authorcourse]=[]
          authorcourse.each do |course|
            session[:authorcourse]<<course.id
          end

        
          @authorhtml=@authorhtml+'<BR><form><h10><table width=100%><tr><COLGROUP span="4" width=25%>
   </COLGROUP><tr>'
          count=0
          selected_courses.each do |course|
            count=count+1
            @authorhtml=@authorhtml+'<td><INPUT type="checkbox" name="newcourse[]" value="'+course.name+'"'
            @authorhtml=@authorhtml+' CHECKED ' if authorcourse.index(course)
            @authorhtml=@authorhtml+'><course> '+course.name + '</course></td>'
            @authorhtml=@authorhtml+'</tr><tr>' if count.gcd(4)==4
          end
          @authorhtml=@authorhtml+%Q(</tr><tr></table>Choose one or more courses (not too many!) and click </h10><h8><INPUT type="submit" value="Select"></h8>
           </table></form>)
        end
        authorcourse.each do |course|

          @authorhtml=@authorhtml+'<BR><h7a>User progress with course <course>'+course.name+ ':</course> </h7a><br>'
        

          @authorhtml=@authorhtml+'<br><h3><course>'+course.name+'</course></h3><table class="table"><tr>'
          users=User.find(:all, :order => :name).find_all {|user| user.tag.match(Regexp::new('(\A| )'+authortag[1..-2]+'(\z| )'))}
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



      # @authortags.each do
      #   |tag|
      #   @authorhtml=@authorhtml+'<h5a><br>With tag: '+tag[1..-2]+'</h5a><br>'
      #   courses=@authorcourses.find_all {|course| course.tag.match(tag)}
      #   courses.each do
      #     |course|
      #     @authorhtml=@authorhtml+'<br><h3>'+course.name+'</h3><table class="table"><tr>'
      #     users=@authorusers.find_all {|user| user.tag.match(Regexp::new('(\A| )'+tag[1..-2]+'(\z| )'))}
      #     users.each do
      #       |user|
      #       name=User.find_by_id(user).name
      #       profile=Profile.find(:all, :order => :id).find_all {|profile| profile.course==course.id&&profile.user==user.id}[0]
      #       name=name+' <h8>(not joined)</h8>' unless profile
      #       @authorhtml=@authorhtml+' <td style="vertical-align:middle" width="20">'+name+'</td><td style="vertical-align:middle" width="50"><img src="http://i970.photobucket.com/albums/ae189/gumboil/website/starsfinishline.png" width="10">'
      #       score=score(profile)
      #       score[2].each do
      #         |stage|
      #         @authorhtml=@authorhtml+'<img src="http://i970.photobucket.com/albums/ae189/gumboil/website/stars'+stage+'.png" width="10">
      #         <img src="http://i970.photobucket.com/albums/ae189/gumboil/website/starsfinishline.png" width="10">'
      #       end
      #       @authorhtml=@authorhtml+'</td><td style="vertical-align:middle" width="100">'+score[0].to_s+'</td><td style="vertical-align:middle" width="100">'
      #       @authorhtml=@authorhtml+'<img src="http://i970.photobucket.com/albums/ae189/gumboil/website/'+ score[1]+'" width="25"></td></tr>'

      #     end
      #     @authorhtml=@authorhtml+'</table>'
      #   end
      # end

      





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
      @existing_user=User.find_by_email(params[:user][:email])
      if @existing_user&&!@existing_user.confirmed
        User.find_by_email(params[:user][:email]).destroy
      end
      @user = User.new(params[:user])
      if @user.update_attributes(:name => @user.name, :email => @user.email.downcase, :password => @user.password, :password_confirmation => @user.password_confirmation)
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
    #@users = User.paginate(page: params[:page])
    params[:sort]||='id'
        params[:direction]||='desc'
        @users = User.order(params[:sort] + ' ' + params[:direction]).paginate(per_page: number_per_page, page: params[:page])
  end

  def update
    if params[:tagedit]='1'
      oldtag=User.find(@user.id).tag
      newtag=params[:user][:tag]
    
      @user.update_attribute(:tag, newtag)
      flash[:success] = "Tags updated"
      sign_in @user
      redirect_to @user
    elsif @user.update_attributes(params[:user])
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
      
    redirect_to(root_path) unless current_user?(@user)||@user.admin
    end

    def admin_user
      redirect_to(root_path) if current_user==nil
      redirect_to(root_path) unless current_user.admin
    end

end
