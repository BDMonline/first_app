module ApplicationHelper

	include Math

	def ln(x)
	    return log(x)
	end

	def lg(x)
	    return log10(x)
	end

	def number(string)  
	    string=string.delete ' '
	    sign=1
	    if  string[0]=='_' then                 # we will be using '_' for unary minus.
	        sign=-1
	        string=string[1..-1]
	    end
	    unless string.match(/\./) 
	        return '<'+(string.to_r*sign).to_s+'>'
	    else
	        int_frac=string.split('.')
	        int=int_frac[0]
	        frac=int_frac[1]
	        if frac==''
	            return '<'+(int.to_r*sign).to_s+'>'
	        else
	            frac=frac.to_r/10**frac.length
	            return '<'+((int.to_r+frac)*sign).to_s+'>'
	        end
	    end
	end

	def prepare(input)
        ourexp=input

        #This is a one-time process of tidying up the input string prior to simplification.

        #Our biggest bugbear is - signs. 

        #It will always be safe to replace '++' and '--' with '+', and '-+' and '+-' with '-'

        while ourexp.match(/[\+-][\+-]/)
            ourexp=ourexp.gsub('++','+')
            ourexp=ourexp.gsub('--','+')
            ourexp=ourexp.gsub('+-','-')
            ourexp=ourexp.gsub('-+','-')
        end

        #We need to distinguish between binary minus, which always follows a number or a ')',
        #and all other uses of -, which are unary. E.g. "-cos(-e^-3)--2" has just one binary -. We're going to use different
        #symbols to distinguish the kinds of -. We want to keep the usual symbol for subtraction, so we'll change unary minuses
        #to '_'. However, since the binary variety is the easy one to characterise, we'll swap them all first and change the
        #binary ones back.

        ourexp=ourexp.gsub('-','_')

        while ourexp.match(/[\d\.\)]_/)
            breakdown=ourexp.partition (/[\d\.\)]_/)
            ourexp=breakdown[0]+breakdown[1][0]+'-'+breakdown[2]
        end

        #While we're at it, we'll do the same for +. Unary plus is lovely - we can delete it!
        
        ourexp=ourexp.gsub('+','&')

        while ourexp.match(/[\d\.\)]&/)
            breakdown=ourexp.partition (/[\d\.\)]&/)
            ourexp=breakdown[0]+breakdown[1][0]+'+'+breakdown[2]
        end

        ourexp=ourexp.delete('&')


        ## Deal with ^-  {replace with ^(-1)^}
        ## ourexp=ourexp.gsub(/\^\-/,'^(-1)^')

        ## deal with other leading -

        ## if ourexp[0]=='-'
        ##  ourexp='(-1)*'+ourexp[1..-1]
        ## end

        ## puts ourexp, "!!!"

        ## while ourexp.match(/[^\d\)]-\d/)
        ##  puts ourexp, '%%%'
        ##  breakdown=ourexp.partition(/[^\d\)]-\d/)
        ##  puts breakdown
        ##  ourexp=breakdown[0]+breakdown[1][0]+'(-1)*'+breakdown[1][-1]+breakdown[2]
        ## end
        ## puts ourexp,'{{}}'
        

        #Unary '-'' before a number can always be sucked into the number itself.
        #Which we'll do below.

        #Meanwhile, let's decide to leave it at that. If we try to deal with e.g. cos-exp-3^2 we'd be guessing where the user
        #wanted the brackets. If you're wondering why we'd even dream of tolerating such things, the intended application is
        #evaluating algebraic formulae into which a machine has gsubbed values. So the user might want the formula to be
        #cosA + sinA, and the computer might sub in A='-3', and then we'd have cos-3.
        #But we are going to be mean to the user and insist on cos(A) etc.

        #So we'll convert all numbers to our preferred format <a/b> or <-a/b>, sucking in all the unary minuses we can.

        head=''
        tail=ourexp
        while tail.length>0
            if tail.match(/\d/)
                start=tail.index(/_?\d/)
                head=head+tail[0..start-1] if start>0
                tail=tail[start..-1]
                
                if tail.match(/\A_?[\d\.]*\z/)
                    num=tail
                    tail=''
                else
                    finish=tail[1..-1].index(/[^\d\.]/)
                    puts finish
                    num=tail[0..finish]
                    tail=tail[finish+1..-1]
                end
                
                head=head+number(num)
                
            else
                head=head+tail
                tail=''
            end
        end
        ourexp=head

        return ourexp

    end


	# Returns the full title on a per page basis
	def full_title(page_title)
		base_title="RoboTutor"
		if page_title.empty?
			base_title
		else
			base_title+" | "+page_title
		end
	end

    def evaluate(input) #input assumed to be a string. 
                        #Output will be a rational, by coercion if necessary
                        #expressed in the format '<a/b>'

        

        # recursively deal with all brackets.
        puts 'starting over with', input

        ourexp=input

        #puts 'starting over with ' ourexp



        


        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            puts 'handing back', ourexp
            return ourexp
        end

        while ourexp.match(/\(/) do
            breakdown=['','','']
            start=ourexp.index(/\(/)
                puts start
            if start==0
                breakdown[0]=''
                breakdown[1]=ourexp[1..-1]
            else
                breakdown[0]=ourexp[0..start-1]
                breakdown[1]=ourexp[start+1..-1]
            end
            puts 1/0 if breakdown[1]==nil  # we have a ( at the end, which is not good.
            puts breakdown, 'initial breakdown'
            count=1
            pos=0
            while count>0
                if breakdown[1][pos]=='('
                    count=count+1
                elsif breakdown[1][pos]==')'
                    count=count-1
                end
                puts 0/1 if pos>breakdown[1].length  # we have a bracket mismatch error.
                pos=pos+1
            end
            #puts pos,"*"
            if pos>breakdown[1].length
                breakdown[2]=''
                breakdown[1]=breakdown[1][0..-2]
            else
                breakdown[2]=breakdown[1][pos..-1]
                breakdown[1]=breakdown[1][0..pos-2]
            end
            print 'dealing with ',breakdown[1], 'but promise not to forget ',breakdown[0], 'or', breakdown[2]
            #If there is a unary '-' in front of this bracket, we'll take the chance to deal with it.

            if breakdown[0]==''
                ourexp=breakdown[0]+evaluate(breakdown[1])+breakdown[2]
            elsif breakdown[0][-1]=='_'
                ourexp=breakdown[0][0..-2]+'(<-1/1>*'+evaluate(breakdown[1])+')'+breakdown[2]
            else
                ourexp=breakdown[0]+evaluate(breakdown[1])+breakdown[2]  ##Yes, I know.
            end

            puts 'bbb', breakdown, 'bbb'


        
            puts ourexp, 'after bracket removed'
        end

        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            puts 'handing back', ourexp
            return ourexp
        end


        ourexp=ourexp.gsub(/e\^/,'exp')
        


    #deal with functions
        ['acos','asin','atan','sin','cos','tan','log','exp','ln','lg'].each do |func|
            puts func
            if ourexp.match(func+'[^<]')
                x=1/0
            end
            ourexp=ourexp.gsub(func,'~#~')
            puts ourexp
        

            puts 'got to 66'
            
            while ourexp.match(/~#~/)
                breakdown=ourexp.partition(/~#~/)
                if breakdown[2]=="" 
                    #function has no argument  
                    x=1/0
                end
                subbreak=breakdown[2].partition(/>/)
                puts subbreak, '@@@'
                if subbreak[0]==""  
                    #function has no argument 
                    x=1/0
                end
                #let's not miss the chance to nail a unary minus
                # unless breakdown[0]==''
                #   if breakdown[0][-1]=='_'
                #       breakdown[0]=breakdown[0][0..-2]+'<-1/1>*'
                #   end
                # end

                # except it doesnt work e.g. in 3/-exp(6). We'll have to deal with /- and *- as special cases later.

                if subbreak[0].match(/\A<-?\d+\/\d+\z/)
                    puts func+'('+subbreak[0][1..-1]+'.to_r)','*&*&**'
                    ourexp=breakdown[0]+ "<" + eval(func+'('+subbreak[0][1..-1]+'.to_r)').to_r.to_s + subbreak[1]+subbreak[2]
                    puts func,ourexp,"!!!!!!"
                else
                    x=1/0 # we insist on brackets after these functions, so by this stage they'd jolly well be followed by just a number.
                    #ourexp=breakdown[0]+ "~#~"+ evaluate(subbreak[0]+'>')+subbreak[1][1..-1]+subbreak[2]### need to fix so we're evaluating the argument of the func
                    #puts ourexp
            
                end
            end
        end

        
    puts 'got to 89'
        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            puts 'handing back', ourexp
            return ourexp
        end

        #deal with pi

        ourexp=ourexp.gsub(/pi/,'<'+PI.to_r.to_s+'>')
        puts ourexp
        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            puts 'handing back', ourexp
            return ourexp
        end

        #deal with e's 

        ourexp=ourexp.gsub(/e/,'<'+exp(1).to_r.to_s+'>')
        puts ourexp
        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            puts 'handing back', ourexp
            return ourexp
        end
    puts 'got to 132'
        #deal with ^/*-+

        #'*_' and '/_' are special cases - ooooh those unary minuses!

        ourexp=ourexp.gsub(/>\*_</,'>*<-1/1>*<')
        ourexp=ourexp.gsub(/>\/_</,'>*<-1/1>/<')

        ['^','/','*','-','+'].each do #order matters
            |operator_raw|
            while ourexp.include?('>'+operator_raw+'<')
                breakdown1=ourexp.partition('>'+operator_raw+'<')   
                if operator_raw =='^'
                    operator ='**'
                else
                    operator = operator_raw
                end
                ourexp=breakdown1[0]+'```'+breakdown1[2]
                puts ourexp

                while ourexp.match(/<-?\d+\/\d+```-?\d+\/\d+>/) do
                    breakdown=ourexp.partition(/<-?\d+\/\d+```-?\d+\/\d+>/)
                    subbreak=breakdown[1].partition(/```/)
                    value1=subbreak[0][1..-1]
                    value2=subbreak[2][0..-2]
                    puts value1+'.to_r'+operator+value2+'.to_r','*&*'
                    value3='<'+eval('('+value1+'.to_r'+')'+operator+'('+value2+'.to_r'+')').to_s+'>'
                    ourexp=breakdown[0]+value3+breakdown[2]
                    puts ourexp
                    if ourexp.match(/\A<-?\d+\/\d+>\z/)
            puts 'handing back', ourexp
            return ourexp
        end
                end
            end
        end
        
        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            puts 'handing back', ourexp
            return ourexp
        end

        
    end
    def calculate(string)
    unless string.count('(')==string.count(')') 
        puts string, "initial input"
        x=1/0
        puts prepare(string), "outcome of prepare"
    end
        x=evaluate(prepare(string))[1..-2].to_r
        d=x.denominator
        if d==1 
            return x.numerator
        elsif d>1000
            return x.to_f
        else
            return x
        end
    end

    def construct
        @error=false
        #@question = Question.find(params[:id])
        @param=@question.parameters.split(' ')
        @paramtext =''
        @param_hash={}

        @paramtext=catch(:parameter_problem) do
            if @param.count.modulo(2)==1
                @error=true
                throw :parameter_problem,'ERROR: string should have variable names and values separated by spaces.'
            end
            @example_param_hash={}
            while @param.count>1
              string1=@param[0]
              string2=@param[1]
              @param_hash[string1] = string2 if string2
              @param = @param[2..@param.count]
            end
            @param_hash.each do
                |string1, string2|
            
                unless string1.match('\A[A-Z]\z')
                    @error=true
                    throw :parameter_problem, '<h1> ERROR: Parameter names must be single uppercase letters </h1>'
                end
            
            
                @paramtext=@paramtext+string1+' is '
                if  string2.match(/\A\((-?(\d)+,)+-?(\d)+\)\z/)
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
                        @error=true
                        throw :parameter_problem, 'ERROR: lower bound must be less than upper'
                    else
                        @paramtext=@paramtext+' an integer in the range '+bounds[0]+' to '+bounds[1]+'. '
                        value=rand(bound_l..bound_h)
                        @example_param_hash[string1]=value
                    end
                elsif string2.match(/\A\[-?(\d)+(\.(\d)+)?\.\.-?(\d)+(\.(\d)+)?\]\z/)
                    dots_pos=string2.index('..')
                    bound_l=string2[1..dots_pos-1].to_r
                    bound_h=string2[dots_pos+2..-2].to_r
                    unless bound_l<bound_h
                        @error=true
                        throw :parameter_problem, 'ERROR: lower bound must be less than upper'
                    else
                        @paramtext=@paramtext+' a real in the range '+bound_l.to_s+' to '+bound_h.to_s+'. '
                        value=rand(bound_l..bound_h)
                        @example_param_hash[string1]=value
                    end 
                end
            end
        end


    


        @example_answers=catch(:answer_problem) do
            @order_matters=false
            answers=@question.answers
            if answers.include?('`')
                if answers[-1].match(/[tf]/)
                    @order_matters=true if answers[-1]="t"
                    answers=answers[0..-2]
                end

                @example_answers = []
                answerlist=answers.split('`')
                answerlist.delete('')

                answerlist.each do
                    |this_answer|
                    #if @example_param_hash==nil
                    #    @error=true
                    #    throw :answer_problem, "ERROR: No valid parameters defined"
                    #end
                    @example_param_hash.each {
                        |name,value|                           
                        this_answer.gsub!(name,value.to_f.to_s)      
                    }
                    # if this_answer.match(/[A-Z]/)
                    #     @error=true
                    #     throw :answer_problem, "ERROR: Answer uses undefined parameter(s) e.g. "+this_answer.match(/[A-Z]/)[0]
                    # end
                    #begin
                        x=calculate(this_answer).to_s
                        
                        @example_answers << x
                    #rescue
                    #    @error=true
                    #    throw :answer_problem, 'ERROR: Answer calculation '+this_answer+' causes evaluation error HERE'
                    #end
                end
                throw :answer_problem, @example_answers
            else 
                @example_answers=answers
            end
        end

        @example_question=catch(:question_problem) do
            question_text=@question.text
            delimcount=question_text.count('`')
            if delimcount==0
                @example_question=question_text
            else
                if delimcount.modulo(2)==1
                    @error=true
                    throw :question_problem, 'ERROR: Invalid question text. ` must occur in pairs.'
                end
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
                    if formula[-1]=='f'
                        formula=formula[0..-2]
                        float=true
                    else
                        float=false
                    end
                    
                    if @example_param_hash==nil
                        @error=true
                        throw :question_problem, "ERROR: No valid parameters defined"
                    end

                    @example_param_hash.each {|name,value| formula.gsub!(name,value.to_s)}               
                    if  formula.match(/[A-Z]/)
                        @error=true
                        throw :question_problem, "ERROR: Question contains formula with undefined parameter"
                    else
                        formula_result=calculate(formula)
                        formula_result=formula_result.to_f if float
                        @example_question=@example_question+formula_result.to_s
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
                    end
                    @example_question.gsub!('+-','-')
                    @example_question.gsub!('-+','-')
                    @example_question.gsub!('++','+')
                    @example_question.gsub!('--','+')
                end
                @example_question=@example_question+question_text
            end
        end
            
        return [@question.text, @param_hash.to_s, @example_param_hash.to_s, @paramtext, @example_answers, @example_question,@error]
        
    
    end

    def create_item(item)
        # create a string containing the html to display an item body
        # and spaces for answers plus feedback.
        @item_html=""
        content=eval(item.content)
        content.each do
            |item_string|
            if item_string[0]=="Q"
               
                @question=Question.find_by_id(item_string[1..-1].to_i)
                construct
                @item_html=@item_html+%Q(
                
                <h9>)+@example_question+%Q(</h9> <p>
                
                )
            else
                element=Element.find_by_id(item_string.to_i)
                if element
                category=element.category
                if category=="text"
                    @item_html=@item_html+%Q(
                    
                    <h9>)+element.content+%Q(</h9> <p>
                  
                    )
                elsif category=="image"
                    @item_html=@item_html+%Q(
                    
                    <h2> <img src = )+element.content+%Q( /> </h2>
                   
                    )
                elsif category=="video"
                    @item_html=@item_html+%Q(
                  
                    <h2> <iframe frameborder="0" width="480" height="360" src= )+element.content+%Q( > </iframe><br /></i> </h2>
                                        )
                end
            end
                    

            end
        end




    end

end
