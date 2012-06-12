class QuestionsController < ApplicationController
 
	def construct
        @question = Question.find(params[:id])
    paramerror=false
    @param=@question.parameters.split(' ')
    if @param.count.modulo(2)==1
        paramerror=true
        @paramtext='String should have variable names and values separated by spaces.'
    end
    unless paramerror
        @paramtext =''
        @param_hash={}
        @example_param_hash={}
        while @param.count>1
            string1=@param[0]
            string2=@param[1]
            @param_hash[string1] = string2 if string2
            @param = @param[2..@param.count]
        end
        @param_hash.each do
            |string1, string2|
            unless paramerror
                unless string1.match('\A[A-Z]\z')
                    paramerror=true
                    @paramtext=string1+': Parameter names must be single uppercase letters'
                end
            end
            unless paramerror
                @paramtext=@paramtext+string1+' is '
                if string2.match(/\A\((-?(\d)+,)+-?(\d)+\)\z/)
                    poss=string2.split(/[^1234567890-]/)
                    poss.delete('')
                    @paramtext=@paramtext+'any of '+poss.to_s+'. '
                    value=poss.shuffle.first.to_i
                    @example_param_hash[string1]=value
                
                elsif string2.match(/\A\(-?(\d)+\.\.-?(\d)+\)\z/)
                    bounds=string2.split(/[^1234567890-]/)
                    bounds.delete('')
                    bound_l=bounds[0].to_i
                    bound_h=bounds[1].to_i
                    unless bound_l<bound_h
                        paramerror=true
                        @paramtext=string2+': lower bound must be less than upper'
                    else
                        @paramtext=@paramtext+' an integer in the range '+bounds[0]+' to '+bounds[1]+'. '
                        value=rand(bound_l..bound_h)
                        @example_param_hash[string1]=value
                    end
                elsif string2.match(/\A\[-?(\d)+(\.(\d)+)?\.\.-?(\d)+(\.(\d)+)?]\z/)
                    dots_pos=string2.index('..')
                    bound_l=string2[1..dots_pos-1].to_f
                    bound_h=string2[dots_pos+2..-2].to_f
                    unless bound_l<bound_h
                        paramerror=true
                        @paramtext=string2+': lower bound must be less than upper'
                    else
                        @paramtext=@paramtext+' a real in the range '+bound_l.to_s+' to '+bound_h.to_s+'. '
                        value=rand(bound_l..bound_h)
                        @example_param_hash[string1]=value
                    end 
                end
            end
        end
        answers=@question.answers
        answers=answers[0..-2] if answers[-1].match(/[tf]/)
        @example_answers = []
        answerlist=answers.split('`')
        answerlist.each do
            |this_answer|
            @example_param_hash.each {|name,value| this_answer.gsub!(name,value.to_s)}
            @example_answers << eval(this_answer)
        end
        text_error=false
        question_text=@question.text
        delimcount=question_text.count('`')
        if delimcount==0
            @example_question=question_text
        else
            if delimcount.modulo(2)==1
                text_error=true
                @example_question='Invalid entry: ` must occur in pairs.'
            end
            unless text_error
                @example_question=''
                unless question_text[0]=='`'
                    split_pos=question_text.index('`')
                    @example_question=question_text[0..(split_pos-1)]
                    question_text=question_text[split_pos..-1]
                end
                while question_text.count('`')>0
                    question_text=question_text[1..-1]
                    split_pos=question_text.index('`')
                    formula = question_text[0..split_pos-1] 
                    @example_param_hash.each {|name,value| formula.gsub!(name,value.to_s)}
                    @example_question=@example_question+eval(formula).to_s
                    question_text=question_text[split_pos+1..-1]
                    unless question_text==nil
                        if question_text.count('`')>0
                            split_pos=question_text.index('`')
                            @example_question=@example_question+question_text[0..split_pos-1]
                            question_text=question_text[split_pos..-1]
                        else @example_question=@example_question+question_text+'.'
                            question_text=''
                        end
                    else
                        question_text="."
                    end
                    @example_question.gsub!('+-','-')
                    @example_question.gsub!('-+','-')
                    @example_question.gsub!('++','+')
                    @example_question.gsub!('--','+')
                end
                @example_question=@example_question+question_text
            end
            return [@question.text, @param_hash.to_s, @example_param_hash.to_s, @paramtext, @example_answers, @example_question]
        end

    def show
		#def abandon(message)
		#	@question.destroy
		#	flash[:failure] = message+' Please try again.'
    	#   render 'new'
        #end
  	@question = Question.find(params[:id])
  	#array=construct
    end		





    end

  end

  def new
  	@question = Question.new
  end

  def create
    @question = Question.new(params[:question])
    if @question.save
      redirect_to @question
    else
      render 'new'
    end
end
end
