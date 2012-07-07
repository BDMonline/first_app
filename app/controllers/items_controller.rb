
class ItemsController < ApplicationController
    
    def show 
        @item=Item.find(params[:id])
    end

    def destroy
        Item.find(params[:id]).destroy
        flash[:success] = "Item destroyed."
        redirect_to items_path
    end

    def index
        @items = Item.paginate(page: params[:page])
    end

    def new
        @item = Item.new
        @item[:content]="[]"
    end

    def create
        @item = Item.new(params[:item])
        @item[:content]="[]"
        if @item.save
            flash.now[:success] = "Item created."
            session[:current_item_id] = @item.id
            redirect_to @item
        else
            render 'new'
        end
    end

    def edit 
        if session[:current_item_id]
            @item=Item.find_by_id(session[:current_item_id])
            if session[:new_element_id]
                @item[:content]=(eval(@item[:content]) << session[:new_element_id]).to_s
                @item.update_attributes(params[:item])
                flash[:success] = "Item updated"
            end
            render "edit"
        
        else
            session[:current_item_id]=params[:id]
            @item=Item.find_by_id(session[:current_item_id])

            render "edit"
       
        end
    end

    def update
    @item=Item.find_by_id(session[:current_item_id])  
    if @item.update_attributes(params[:item])
        flash[:success] = "Item updated"
        session[:current_item_id] = nil
        redirect_to @item
    else
      #deal with invalid item
    end
  end
end