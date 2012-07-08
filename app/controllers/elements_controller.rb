class ElementsController < ApplicationController
	
    before_filter :author_user

    def destroy
        Element.find(params[:id]).destroy
        flash[:success] = "Element destroyed."
        redirect_to elements_path
    end

    def index
        @elements = Element.paginate(page: params[:page])
    end

    def show
    	@element = Element.find(params[:id])
        session[:new_element_id]= @element.id.to_s
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

    private
    def author_user
      redirect_to(root_path) unless current_user.author
    end
end