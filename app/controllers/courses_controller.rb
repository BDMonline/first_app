class CoursesController < ApplicationController
  helper_method :sort_column, :sort_direction
    include ApplicationHelper

    before_filter :author_user
    
    def show 
        @course=Course.find(params[:id])
        @content = eval(@course.content)
        
    end

    def destroy
        Course.find(params[:id]).destroy
        flash[:success] = "Course destroyed."
        redirect_to courses_path
    end

    def index
        params[:sort]||=''
        params[:direction]||=''
        @courses = Course.search(params[:search]).order(params[:sort] + ' ' + params[:direction]).paginate(per_page: 2, page: params[:page])
    end

    def new
    	abandon_item_build
        @course = Course.new
        @course[:content]='[["1","2","2"]]'
    end

    def create
        @course = Course.new(params[:course])
        @course[:content]='[["1","2","2"]]'
        if @course.save
            flash.now[:success] = "Course created."
            session[:current_course_id] = @course.id
            redirect_to @course
        else
            render 'new'
        end
    end

    def edit 
        abandon_item_build
      


        session[:current_course_id]=params[:id]

        @course=Course.find_by_id(params[:id])

        @values=params[:@values]

        @content = eval(@course.content)

        if @values
        	@content.each do 
        		|stage|
        		number1=@content.index(stage)
        		(0..2).each do
        			|number2|
        			refstring = number1.to_s+"x"+number2.to_s
        			if @values[refstring]
        				@content[number1][number2]=@values[refstring]
        				@course.content=@content.to_s
        			end
        		end
        	end
        end

        okness=true
        @content.each do
        	|stage|
        	stage.each do
        		|item|
        		unless Item.find_by_id(item.to_i)||item==""
        			okness=false
        		end
        	end
        end

        if okness
  
	        if @course.update_attributes(params[:course])
			    flash.now[:success] = "Course updated"
			  
			else
				flash.now[:failure] = "Course NOT updated"

			end
		else
			flash.now[:failure] = "Some of the items specified do not exist"
		end

		if params[:t]
			
			add_stage
		else

			render "edit"

		end
        #indexitem code nicked from itemscontroller
        #params[:sort]||=''
        #params[:direction]||=''
        #@items = Item.search(params[:search]).order(params[:sort] + ' ' + params[:direction]).paginate(per_page: number_per_page, page: params[:page])


        #render "#"
       
    end

    def update
    @course=Course.find_by_id(session[:current_course_id])  
    if @course.update_attributes(params[:course])
        flash.now[:success] = "Course updated"
        session[:current_course_id] = nil
        redirect_to @course
    else
      #deal with invalid course
    end
  end

  def abandon_item_build
  	if session[:current_item_id]
    	@item=Item.find_by_id(session[:current_item_id])  
			if @item.update_attributes(params[:item])
    			flash[:success] = "Stopped editing Item "+session[:current_item_id].to_s
    		end
    	session[:current_item_id] = nil
    end	
  end

  def add_stage

  	

  	unless @content[-1]==["" ,"", ""]
	  	@content<<["" ,"", ""]
	  	@course.content=@content.to_s
	  	if @course.update_attributes(params[:course])
	        flash.now[:success] = "Course updated" 
	    end
	else
		flash.now[:failure] = "Put some items in the blank row before adding another"
	end


  end


  private

    def sort_direction
        %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end

    def sort_column
        Course.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def author_user
        if current_user
            redirect_to(root_path) unless current_user.author
        else
            redirect_to(signin_path)
        end
    end
end
