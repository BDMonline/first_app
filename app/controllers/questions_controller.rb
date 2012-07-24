include Math

class QuestionsController < ApplicationController
include ApplicationHelper
helper_method :sort_column, :sort_direction
before_filter :author_user



    def show
        @question = Question.find(params[:id])
        session[:new_element_id]= "Q"+@question.id.to_s
        construct(0)

        if @error 
            flash.now[:success] = "There was a problem with this question. Please address the issues below."
            @question.destroy
            render 'edit'
 	    else
            
            @question.update_attributes(params[:question])
            render 'show'
        end

    end

    def edit

        @question = Question.find(params[:id])
        #@question.update_attributes(params[:question])
        construct(0)


        if @error
            render 'edit'
        else
            
            render 'edit'
        end
    end

    def destroy
        Question.find(params[:id]).destroy
        flash[:success] = "Question destroyed."
        redirect_to questions_path
    end

    def index
        params[:sort]||=''
        params[:direction]||=''
        @questions = Question.search(params[:search]).order(params[:sort] + ' ' + params[:direction]).paginate(per_page: number_per_page, page: params[:page])
    end

    def update
        #@testtext=calculate('-2-1/(2-4*(2+ln(2)))')
 
 

        @question = Question.find(params[:id])
        if @question.update_attributes(params[:question])
            if naughty_text?(@question)
                flash.now[:failure] ="Question update attempted, but "+@flash_text
                @question.update_attribute(:text, "")
                @question.update_attribute(:safe_text, "")
                render "edit"
            else
                
                @question.update_attribute(:safe_text, @question.text)
                construct(0)
                if @error
                    flash.now[:failure] = "There was a problem with this question"
                    render 'edit'
                else
                    flash.now[:success] = "The website could not detect a problem with this question. But what does a website know? Please check thoroughly and refresh the page if appropriate to explore the effect of different parameter choices."
                    render 'show'
                
                end
            end
            
        else
            flash.now[:failure] = "There was a problem with this question"
            render 'edit'
        end        
    end


    # def edit
    #     @question = Question.find(params[:id])
    # end

    # def update
    #     @question = Question.find(params[:id])
    #     if @question.update_attributes(params[:question])
    #         # Handle a successful update.
    #     else
    #         render 'edit'
    #     end
    # end


    def new
        @question = Question.new
    end

    def create
        @question = Question.new(params[:question])
        if @question.save
            if naughty_text?(@question)
                flash.now[:failure] ="Question created, but "+@flash_text
                @question.update_attribute(:text, "")
                @question.update_attribute(:safe_text, "")
                render "edit"
            else
                flash.now[:success] = "question created."
                @question.update_attribute(:safe_text, @question.text) 
                redirect_to @question
            end
        else
            render 'new'
        end
    end

    def add_to_item
        @item=Item.find_by_id(session[:current_item_id])
        @item[:content]=(arrayify_item_content(@item[:content]) << ("Q"+params[:question]).to_s).to_s
        @item.update_attributes(params[:item])
        flash.now[:success] = "Added Question "+"Q"+params[:question].to_s+" to Item "+@item.id.to_s
        index
        session[:new_element_id]=nil
        render "index"
    end

    def naughty_text?(question)
        if question[:text].match(/.*<.*>.*/)
            @flash_text = 'for html safeness please avoid using "< ... >". You can use MathJax \\gt and \\lt. Please resubmit content.'
            true
        else
            false
        end
        
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
