class ElementsController < ApplicationController

	helper_method :sort_column, :sort_direction
    before_filter :author_user

    def destroy
        Element.find(params[:id]).destroy
        flash[:success] = "Element destroyed."
        redirect_to elements_path
    end

    def index
        #@elements = Element.paginate(page: params[:page])
        params[:sort]||=''
        params[:direction]||=''
        @elements = Element.search(params[:search]).order(params[:sort] + ' ' + params[:direction]).paginate(per_page: 2, page: params[:page])
    end

    def show
    	@element = Element.find(params[:id])
        session[:new_element_id]= @element.id.to_s
    end

    def edit
        @element = Element.find(params[:id])
    end

    def update
        @element = Element.find(params[:id])
        if @element.update_attributes(params[:element])
          flash[:success] = "Element updated"
        end
    end


	def new
        @element = Element.new
    end

    def create
        @element = Element.new(params[:element])
        if @element.save
            flash.now[:success] = "element created."
            redirect_to @element
        else
            render 'new'
        end
    end

    def add_to_item


        #@element = Element.find(params[:id])
        @item=Item.find_by_id(session[:current_item_id])
        @item[:content]=(eval(@item[:content]) << (params[:format]).to_s).to_s
        @item.update_attributes(params[:item])
        flash.now[:success] = "Added Element "+params[:format].to_s+" to Item "+@item.id.to_s
        @elements = Element.paginate(page: params[:page])
        session[:new_element_id]=nil
        render "index"
    end

    private

    def sort_direction
        %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end

    def sort_column
        Element.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def author_user
        if current_user
            redirect_to(root_path) unless current_user.author
        else
            redirect_to(signin_path)
        end
    end
end