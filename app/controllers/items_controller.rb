class ItemsController < ApplicationController
    helper_method :sort_column, :sort_direction
    include ApplicationHelper

    before_filter :author_user, only: [:index, :edit, :update, :destroy, :new, :create]
    
    def show 
        @item=Item.find(params[:id])
        create_item(@item)
    end

    def destroy
        Item.find(params[:id]).destroy
        flash[:success] = "Item destroyed."
        redirect_to items_path
    end

    def index
        @user=  User.find_by_remember_token(cookies[:remember_token])
        if session[:current_course_id]
            if session[:current_item_id]
                @item=Item.find_by_id(session[:current_item_id])  
                    if @item.update_attributes(params[:item])
                        flash[:success] = "Stopped editing Item "+session[:current_item_id].to_s
                    end
                session[:current_item_id] = nil
            end 

            @course=Course.find_by_id(session[:current_course_id])

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

            @newtag=params[:@newtag]

            if @newtag && @newtag.match(/[^ ]/)
                unless @course.tag.match(" `"+@newtag+"_"+@user.id.to_s+"`")
                    tag=@course.tag+" `"+@newtag+"_"+@user.id.to_s+"`"
                    @course.update_attribute(:tag, tag)
                end
            end

            @oldtag=params[:@oldtag]

            if @oldtag
                string= " `"+@oldtag+"_"+@user.id.to_s+"`"

                    tag=@course.tag.gsub(string,"")
                    @course.update_attribute(:tag, tag)  
            end

            @course_title=params[:@course_title]

            if @course_title
                @course.update_attribute(:name,@course_title )  
            end

            if params[:r]
                @content.delete(["", "", ""])
            end

            if params[:a]
                
                unless @content[-1]==["", "", ""]
                    @content<<["", "", ""]
                    @course.update_attribute(:content, @content.to_s)
                    flash.now[:success] = "Course updated" 
                else
                    flash.now[:failure] = "Put some items in the blank row before adding another - otherwise you'd have two rows the same."
                end
            
            end

            @okness=true
            @content.each do
                |stage|
                stage.each do
                    |item|
                    unless Item.find_by_id(item.to_i)||item==""
                        @okness=false
                    end
                end
            end

            if @okness
      
                @course.update_attribute(:content, @content.to_s)
                flash.now[:success] = "Course updated"
                if params[:f]
                    id=session[:current_course_id]
                    session[:current_course_id]=nil
                    redirect_to course_path(id)
                end
                    
            else
                flash.now[:failure] = "Some of the items specified do not exist"
            end

            #indexitem code nicked from itemscontroller
            #params[:sort]||=''
            #params[:direction]||=''
            #@items = Item.search(params[:search]).order(params[:sort] + ' ' + params[:direction]).paginate(per_page: number_per_page, page: params[:page])


            #render "#"
           
        

        end
        params[:sort]||='id'
        params[:direction]||='desc'
        @items = Item.search(params[:search],params[:onlyme],current_user.id).order(params[:sort] + ' ' + params[:direction]).paginate(per_page: number_per_page, page: params[:page])
    end

    def new
        @item = Item.new
        @item[:content]="[]"
    end

    def create
        session[:new_element_id]=nil
        @item = Item.new(params[:item])
        @item[:content]="[]"
        if current_user
            @item.update_attribute(:author, current_user.id)
        end
        if @item.save
            flash.now[:success] = "Item created."
            session[:current_item_id] = @item.id
            redirect_to @item
        else
            render 'new'
        end
    end

    def edit 
        if session[:current_item_id]&&Item.find_by_id(session[:current_item_id])
            @item=Item.find_by_id(session[:current_item_id])
            if session[:new_element_id]
                @item[:content]=(arrayify_item_content(@item[:content]) << session[:new_element_id]).to_s
                @item.update_attributes(params[:item])
                flash[:success] = "Item updated"
            end
            create_item(@item)
            render "edit"
        
        else
            session[:current_item_id]=params[:id]
            @item=Item.find_by_id(session[:current_item_id])
            create_item(@item)

            render "edit"
       
        end
    end

    def update
        if session[:current_item_id]
            @item=Item.find_by_id(session[:current_item_id])
        else 
            @item=Item.find_by_id(params[:id])
        end

        if @item.update_attributes(params[:item])
            flash[:success] = "Item updated"
            session[:current_item_id] = nil
            redirect_to @item
        else
          #deal with invalid item
        end
  end

  private

    def sort_direction
        %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end

    def sort_column
        Item.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def author_user
        if current_user
            redirect_to(root_path) unless current_user.author
        else
            redirect_to(signin_path)
        end
    end
end
