class ProfilesController < ApplicationController

include ApplicationHelper

	before_filter :correct_user
	before_filter :abandon_course_build
    before_filter :abandon_item_build

	def new
		@user=User.find_by_id(params[:user_id])
		@course=Course.find_by_id(params[:course_id])
		@existing=Profile.find(:all, :order => :id).find_all {|profile| profile.course== @course.id&&profile.user==@user.id}
		if @existing.count > 0
			@profile=@existing[0]
			params[:profile_id]=@profile.id
			params[:user_id]=@profile.user
			params[:course_id]=@profile.course
			render "show" and return
		end
		@profile=Profile.new
		@profile.update_attribute(:user, params[:user_id])
		@profile.update_attribute(:course, params[:course_id])
		params[:user_id]=@user.id
		params[:course_id]=@course.id
		create
	end


	def create
		# requires params[] to have :user_id and :course_id
	
		
		@profile.update_attribute(:user, params[:user_id])
		@profile.update_attribute(:course, params[:course_id])
		flash[:success]="You have joined this course"
		params[:profile_id]=@profile.id
		params[:user_id]=@profile.user
		params[:course_id]=@profile.course
		render "show"
	end

	def destroy
		if params[:profile_id]
			Profile.find(params[:profile_id]).destroy
		else
	    	Profile.find(params[:id]).destroy
		end
	    flash[:success] = "Course removed."
	    redirect_to current_user
	   
	end

	def delete
		if params(:profile_id)
			Profile.find(params[:profile_id]).destroy
		else
	    	Profile.find(params[:id]).destroy
		end
	    flash[:success] = "Course removed."

	end

	def show_item
		render "courseitem"
	end


	def show
		if params[:course_id]&&params[:user_id]

			@existing=Profile.find(:all, :order => :id).find_all {|profile| profile.course.to_s==params[:course_id]&&profile.user.to_s==params[:user_id]}
			@profile=@existing[0] if @existing[0]
		elsif params[:profile_id]
			@profile=Profile.find(params[:profile_id])
		end

		@profile||=Profile.find_by_id(params[:profile_id])
		@profile||=Profile.find_by_id(params[:id])
		@user=User.find_by_id(@profile.user)
		@course=Course.find_by_id(@profile.course)
		@content=eval(@course.content)
		# @course_html=""
		# @content.each do
		# 	|stage|
		# 	@course_html=@course_html+'<tr><td>'+@content.index(stage).to_s+'</td>'
		# 	(0..2).each do
		# 		|part|
		# 		item_id=stage[part]
		# 		item_name=Item.find_by_id(item_name.to_s).name
		# 		@course_html=@course_html+'<td><a href="/items/'+item_id+'">'+item_name+'</a>'





		# <% @content=eval(@course.content) %>
  #   <% @content.each do %>
  #       <%|stage|%>
  #       <% stage_number=@content.index(stage) %>
  #       <tr><td> <%=stage_number+1%> </td>
  #           <td style="vertical-align:middle" width = "100"> <%= (Item.find_by_id(stage[0])&&Item.find_by_id(stage[0]).name)||(!Item.find_by_id(stage[0])&&"NO SUCH ITEM")%> </td>
  #           <td style="vertical-align:middle" width = "100"> <%= (Item.find_by_id(stage[1])&&Item.find_by_id(stage[1]).name)||(!Item.find_by_id(stage[1])&&"NO SUCH ITEM")%> </td>
  #           <td style="vertical-align:middle" width = "100"> <%= (Item.find_by_id(stage[2])&&Item.find_by_id(stage[2]).name)||(!Item.find_by_id(stage[2])&&"NO SUCH ITEM")%> </td>
  #       </tr>
  #   <% end %>



	end


	private

	    def correct_user
	    	@profile=Profile.find_by_id(params[:profile_id]) if params[:profile_id]
	    	@user = User.find_by_id(@profile.user) if @profile
	      	@user ||= User.find_by_id(params[:user_id]) if params[:user_id]      
	    	redirect_to(user_path) unless (@user && current_user?(@user))
	    end
	
end

