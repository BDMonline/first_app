include Math

class QuestionsController < ApplicationController
include ApplicationHelper

before_filter :author_user

# begin

#     #We want to express numbers as rationals enclosed in angle brackets.

    



    


#     #puts number('3.2'), number('-3')

    




    


# rescue
#     return "An error was caused"
# end


#     class QuestionTextError < Exception
#     end
    
#     class ParameterError < Exception
#     end

#     class AnswersError < Exception
#     end


	

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
        @questions = Question.paginate(page: params[:page])
    end

    def update
        #@testtext=calculate('-2-1/(2-4*(2+ln(2)))')
 
 

        @question = Question.find(params[:id])
        if @question.update_attributes(params[:question])
            construct(0)
            if @error
                flash.now[:failure] = "There was a problem with this question"
                render 'edit'
            else
                flash.now[:success] = "The website could not detect a problem with this question. But what does a website know? Please check thoroughly and refresh the page if appropriate to explore the effect of different parameter choices."
                render 'show'
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
            flash.now[:success] = "Question created."
            redirect_to @question
        else
            render 'new'
        end
    end
    private
    def author_user
      redirect_to(root_path) if current_user.nil?
      redirect_to(root_path) unless current_user.author
    end
end
