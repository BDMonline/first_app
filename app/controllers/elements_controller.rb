class ElementsController < ApplicationController
	
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
        session[:new_element_id]= @element.id
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
end