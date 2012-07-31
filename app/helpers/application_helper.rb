module ApplicationHelper

	include Math

    def sortable(column, title = nil)
        title ||= column.titleize
        css_class = (column == sort_column) ? "current #{sort_direction}" : nil
        direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
        link_to title, params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
    end

    def number_per_page
        15
    end

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
                start=tail.index(/_?[\d\.]/)
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
		base_title="StemLoops"
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

           # puts 'bbb', breakdown, 'bbb'


        
           # puts ourexp, 'after bracket removed'
        end

        if ourexp.match(/\A<-?\d+\/\d+>\z/)
          #  puts 'handing back', ourexp
            return ourexp
        end


        ourexp=ourexp.gsub(/e\^/,'exp')
        


    #deal with functions
        ['acos','asin','atan','sin','cos','tan','log','exp','ln','lg'].each do |func|
           # puts func
            if ourexp.match(func+'[^<]')
                x=1/0
            end
            ourexp=ourexp.gsub(func,'~#~')
         #   puts ourexp
        

         #   puts 'got to 66'
            
            while ourexp.match(/~#~/)
                breakdown=ourexp.partition(/~#~/)
                if breakdown[2]=="" 
                    #function has no argument  
                    x=1/0
                end
                subbreak=breakdown[2].partition(/>/)
                #puts subbreak, '@@@'
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
                    #puts func+'('+subbreak[0][1..-1]+'.to_r)','*&*&**'
                    ourexp=breakdown[0]+ "<" + eval(func+'('+subbreak[0][1..-1]+'.to_r)').to_r.to_s + subbreak[1]+subbreak[2]
                    #puts func,ourexp,"!!!!!!"
                else
                    x=1/0 # we insist on brackets after these functions, so by this stage they'd jolly well be followed by just a number.
                    #ourexp=breakdown[0]+ "~#~"+ evaluate(subbreak[0]+'>')+subbreak[1][1..-1]+subbreak[2]### need to fix so we're evaluating the argument of the func
                    #puts ourexp
            
                end
            end
        end

        
    puts 'got to 89'
        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            #puts 'handing back', ourexp
            return ourexp
        end

        #deal with pi

        ourexp=ourexp.gsub(/pi/,'<'+PI.to_r.to_s+'>')
        #puts ourexp
        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            #puts 'handing back', ourexp
            return ourexp
        end

        #deal with e's 

        ourexp=ourexp.gsub(/e/,'<'+exp(1).to_r.to_s+'>')
        #puts ourexp
        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            #puts 'handing back', ourexp
            return ourexp
        end
    #puts 'got to 132'
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
                #puts ourexp

                while ourexp.match(/<-?\d+\/\d+```-?\d+\/\d+>/) do
                    breakdown=ourexp.partition(/<-?\d+\/\d+```-?\d+\/\d+>/)
                    subbreak=breakdown[1].partition(/```/)
                    value1=subbreak[0][1..-1]
                    value2=subbreak[2][0..-2]
                    #puts value1+'.to_r'+operator+value2+'.to_r','*&*'
                    value3='<'+eval('('+value1+'.to_r'+')'+operator+'('+value2+'.to_r'+')').to_r.to_s+'>'
                    ourexp=breakdown[0]+value3+breakdown[2]
                    #puts ourexp
                    if ourexp.match(/\A<-?\d+\/\d+>\z/)
            #puts 'handing back', ourexp
            return ourexp
        end
                end
            end
        end
        
        if ourexp.match(/\A<-?\d+\/\d+>\z/)
            #puts 'handing back', ourexp
            return ourexp
        end

        
    end
    def calculate(string, precision_regime)
    unless string.count('(')==string.count(')') 
        #puts string, "initial input"
        x=1/0
        #puts prepare(string), "outcome of prepare"
    end
        x=evaluate(prepare(string))[1..-2].to_r
        if precision_regime[1..-1]=='0'
            d=x.denominator
            if d==1 
                return x.numerator
            else
                return x
            end
        end
        figures=(precision_regime[1..-1]).to_i

        return rounded(x,figures)
        #return x.to_s+figures.to_s
    end

    def construct(fix_to_user)
        if fix_to_user==1
            srand(@question.id+current_user.id)
        else
            srand()
        end 
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
            #if answers.include?('`')
                if answers[-1].match(/[tf]/)
                    @order_matters=true if answers[-1]="t"
                    answers=answers[0..-2]
                end

                @example_answers = []
                answerlist=answers.split(/\[[^\[\]]*\]/)
                answerlist.delete('')

                @promptlist=answers.scan(/\[[^\[\]]*\]/)
                (0..@promptlist.count-1).each do
                    |index|
                    @promptlist[index]=@promptlist[index][1..-2]
                end

                answerlist.each do
                    |this_answer|
                    precision_regime=@question.precision_regime
                    if this_answer[-2] && this_answer[-2].match(/[hsr]/)
                        precision_regime=this_answer[-2..-1]
                        this_answer=this_answer[0..-3]
                    end

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
                        x=calculate(this_answer,precision_regime).to_s
                        
                        @example_answers << x+precision_regime
                    #rescue
                    #    @error=true
                    #    throw :answer_problem, 'ERROR: Answer calculation '+this_answer+' causes evaluation error HERE'
                    #end
                end
                throw :answer_problem, @example_answers
            #else 
                #@example_answers=answers
            #end
        end

        @example_question=catch(:question_problem) do
            question_text=@question.safe_text
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
                        formula_result=calculate(formula,@question.precision_regime)
                        formula_result=formula_result.to_f if float
                        @example_question=@example_question+formula_result.to_s
                        question_text=question_text[split_pos+1..-1]
                        unless question_text==nil
                            if question_text.count('`')>0
                               split_pos=question_text.index('`')
                               @example_question=@example_question+question_text[0..split_pos-1]
                               question_text=question_text[split_pos..-1]
                            else @example_question=@example_question+question_text
                              question_text=''
                            end
                        else
                        question_text=""
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
            
        return [@question.text, @param_hash.to_s, @example_param_hash.to_s, @paramtext, @example_answers, @example_question,@error,@promptlist]
        
    
    end

    def rounded(number,figs)
        if number<0
            sign ='-'
        else
            sign=''
        end
        if number==0
            answer="0"
            if figs>1
                answer=answer+'.'+'0'*(figs-1)
            end
            return answer
        end
        number = number.abs
        exponent=(log10(number)).floor
        abscissa=number.to_f/(10**exponent)
        abscissa=abscissa.round(figs-1).to_s.delete('.')
        shortness=figs-abscissa.length
        if shortness>0
            abscissa=abscissa+"0"*shortness
        end
        if exponent == figs-1
            return sign+abscissa
        elsif exponent < 0
            return sign+"0."+"0"*(-1-exponent)+abscissa
        elsif exponent >= figs
            return sign+abscissa + "0"*(exponent-figs+1)
        else
            return sign+abscissa[0..exponent]+"."+abscissa[exponent+1..-1]
        end
    end
                
      
    def match(stringx,stringy,precision_regime)
        figs=precision_regime[1..-1].to_i
     
        if figs==0
            if stringx==stringy
                return 0
            elsif stringx.to_f==stringy.to_f
                return 1
            else
                return 2
            end
        elsif precision_regime[0]=="h"
            if stringx==stringy
                return 0
            elsif stringx==rounded(stringy.to_f,figs)
                return 1
            else
                return 2
            end
        elsif precision_regime[0]=="r"
            if stringx==rounded(stringy.to_f,figs)
                return 0
            else
                return 2
            end
        elsif precision_regime[0]=="s"
            diff=(rounded(stringx.to_f,figs).delete('.')[0..figs-1].to_i-rounded(stringy.to_f,figs).delete('.')[0..figs-1].to_i).abs
            if diff>1
                return 2
            else
                excess_figs=stringy.delete('.').to_i.to_s.length-figs
                if excess_figs>1
                    return 1
                else
                    return 0
                end
            end
        end
    end


     def arrayify_item_content(string)
        unless string.match(/\A\[.*\]\z/)
            return []
        end
        if string=="[]"
            return []
        else
            answer=[]
            middle=string[1..-2].delete(' ')
            bits=middle.split(",")
            bits.each do
                |bit|
                bot=bit[1..-2]
                answer<<bot
            end
            return answer
        end
    end

    def create_item(item)

        # create a string containing the html to display an item body
        # and spaces for answers plus feedback.
        @ans=params["@ans"]
        @item_html="<form>"
        count=0
        hint_div_count=0
        content=arrayify_item_content(item.content)
        correct=0
        total=0

        @item_html=@item_html+%Q(
                <table class="table">  
                <tbody>
                )

        content.each do
            
            |item_string|

            @item_html=@item_html+" <tr> "

            hint_array=item_string.split("h")[1..-1]

            item_string=item_string.split("h")[0]

            hint_html=' '
            hint_array.each do
                |hint|
                hint_element=Element.find_by_id(hint.to_i)
                unless hint_element==nil

                    if hint_element.category=="text"
                        hint_div_count=hint_div_count+1
                        div_id="link-"+hint_div_count.to_s
                        @item_html='<div id= "'+div_id+ '" class="hide"><h3><p>'+hint_element.safe_content+'</p></h3></div>'+@item_html
                        hint_html=hint_html+'<a href="#'+div_id+'" rel="prettyPhoto" title=""><img src="http://i970.photobucket.com/albums/ae189/gumboil/website/Hintbutton-1.png" alt="Hint" width="70" /></a> '
                    end

                    if hint_element.category=="video"
                        hint_html=hint_html+'<a href="'+hint_element.safe_content+'?iframe=true&width=100%&height=100%" rel="prettyPhoto[iframes]" title="Video"><img src="http://i970.photobucket.com/albums/ae189/gumboil/website/Videobutton.png" width="70" alt="Video" /> </a>'
                    end

                    if hint_element.category=="image"
                        hint_html=hint_html+'<a href="'+hint_element.safe_content+'" rel="prettyPhoto" title="Image"><img src="http://i970.photobucket.com/albums/ae189/gumboil/website/Imagebutton.png" width="70" alt="Image" /></a>'
                    end

                    hint_html=hint_html+' <br />'

                else
                    hint_html=hint_html+'no such element as '+hint
                end

            end
            
            if item_string[0]=="Q"

               
                @question=Question.find_by_id(item_string[1..-1].to_i)
                if @question
                    construct(1)
                    @item_html=@item_html+%Q(
                    
                    <p>
                    <td style="vertical-align:middle">
                    <h9>)+@example_question+%Q(</h9> </td> 
                    <td style="vertical-align:middle"> 
                    <p align="right">
                    )+hint_html+%Q(     
                    </td> 
                    </tr>
                    </tbody>
                    </table>         
                    )
                    
                    @item_html=@item_html+%Q(
                    <table class="table">  
                    <tbody>
                    )
                    total=total+@example_answers.count

                    (0..@example_answers.count-1).each do
                        |index|
                        answer=@example_answers[index]

                        @precision_regime=answer[-2..-1]
                        answer=answer[0..-3]
                        if @ans && @ans[count]
                            answer_given=@ans[count].to_s
                        else
                            answer_given=''
                        end

                        top_tail=@promptlist[index].split('`')
                        if top_tail[0]
                            top=top_tail[0]
                        else
                            top=''
                        end
                        if top_tail[1]
                            tail=top_tail[1]
                        else
                            tail=''
                        end

                        @item_html=@item_html+%Q(
                            <tr>
                            <td style="vertical-align:middle">
                            <h5>
                            )
                        @item_html=@item_html+top+'</h5></td><td style="vertical-align:middle" width = "100"> <input type="textarea"  name="@ans[]" value="'+ answer_given + '" rows="1" cols="20" > </td>'
                        @item_html=@item_html+'<td style="vertical-align:middle"><h5a>'+tail+'</h5a></td>'
                        if @ans && @ans[count]
                            ans_match=match(answer,@ans[count],@precision_regime)
                            if ans_match==0
                                 @item_html=@item_html+'<td> <p align="right"> <img src = http://i970.photobucket.com/albums/ae189/gumboil/tick.jpg width="70" height="70" /> </p> </td>'
                                correct=correct+1
                            elsif ans_match==1
                                 @item_html=@item_html+'<td> <p align="right"> <img src = http://i970.photobucket.com/albums/ae189/gumboil/orangetriangle-1.jpg width="70" height="70" /> </p> </td>'
                            else
                                 @item_html=@item_html+'<td> <p align="right"> <img src = http://i970.photobucket.com/albums/ae189/gumboil/cross.jpg width="70" height="70" /> </p> </td>'
                            end
                        end
                        count=count+1
                        @item_html=@item_html+ '</tr>'
                    end
                    @item_html=@item_html+ '</tbody> </table>'
                    @item_html=@item_html+%Q(
                    <table class="table">  
                    <tbody>
                    <tr>
                    )
                else
                    @item_html=@item_html+ 'No such question as '+item_string[1..-1]
                end




            else
                element=Element.find_by_id(item_string.to_i)
                if element
                    category=element.category
                    if category=="text"
                        content_html=' <h9> '+ element.safe_content+ ' </h9> '
                        #@item_html=@item_html+%Q(
                        
                        #<p><h9>)+element.safe_content+hint_html+%Q(</h9>
                      
                        #)
                    elsif category=="image"
                        content_html=' <h2> <img src = '+element.safe_content+ ' /> </h2> '
                        # @item_html=@item_html+%Q(
                        
                        # <h2> <img src = )+element.safe_content+%Q( /> </h2>
                       
                        # )
                    elsif category=="video"
                        content_html='<h2> <iframe frameborder="0" width="480" height="360" src= '+element.safe_content+' > </iframe><br /></i> </h2> '
                        # @item_html=@item_html+%Q(
                      
                        # <h2> <iframe frameborder="0" width="480" height="360" src= )+element.safe_content+%Q( > </iframe><br /></i> </h2>
                        #                     )
                    end
                    @item_html=@item_html+'<td style="vertical-align:middle" > ' +content_html+' </td> <td style="vertical-align:middle"> <p align="right">'+hint_html+%Q(</p> 
                    </td> 
                    </tr>
                    )
                else
                    @item_html=@item_html+ 'No such element as '+item_string
                end
                    

            end
        end

        @item_html=@item_html+%Q(
        <table class="table">  
        <tbody>
        <tr>
        <td>
        )

        

        


        #@item_html=@item_html+'Score: \(\frac{'+correct.to_s+'}{'+total.to_s+'}\)'
        @item_html=@item_html+'<h9> Current score: '+correct.to_s+'/'+total.to_s+ "</h9> </td>"

        if correct==total && total>0
            @item_html='<div> <table class="table"> <tbody <tr> <td> <img src = http://i970.photobucket.com/albums/ae189/gumboil/Goldstarnew.jpg width="150" height="90" /> </td> <td style="vertical-align:middle"> <p align="right"> <h9>Item solved</h9> </p> </td> </tr> </tbody> </table> </div>' + @item_html
            success_array=eval(current_user.item_successes)
            unless success_array.include?(@item.id)
                success_array << @item.id
            end
            
            current_user.update_attribute(:item_successes, success_array.to_s)
            
        elsif eval(current_user.item_successes).include?(@item.id)
            @item_html='<div> <table class="table"> <tbody <tr> <td> <img src = http://i970.photobucket.com/albums/ae189/gumboil/Greystar.jpg width="150" height="90" /> </td> <td style="vertical-align:middle"> <p align="right"> <h9>Item previously solved</h9> </p> </td> </tr> </tbody> </table> </div>' + @item_html
        end

        # unless correct==total 
        #     success_array=eval(current_user.item_successes)
        #     if success_array.include?(@item.id)
        #         success_array.delete(@item.id)
        #         current_user.update_attribute(:item_successes, success_array.to_s)
        #     end
        # end



        sign_in current_user

        @item_html=@item_html+ %Q(
            </tr>
            </tbody> 
            </table>
            )






    end

    def score(profile)
        return ["0/0","none.jpg",[]] if profile == nil
        content=eval(Course.find_by_id(profile.course).content)
        user=User.find_by_id(profile.user)
        return ["0/0","none.jpg",[]] if content == []
        successes=0
        total=0
        medals=[1,1,1]
        success_array=[]
        content.each do
            |stage|
            stagecode=''
            (0..2).each do
                |part|
                unless stage[part]==""
                    total=total+1
                    if eval(user.item_successes).include?(stage[part].to_i)
                        stagecode=stagecode+'T'
                        successes=successes+1
                    else
                        stagecode=stagecode+'F'
                        medals[part]=0
                    end
                else
                    stagecode=stagecode+'F'
                    medals[part]=0
                end
            end
            success_array<<stagecode
        end
        medal="none.jpg"
        
        medal="bronze.png" if medals[0]==1        
        medal="silver.png" if medals[1]==1 && medals[0]==1     
        medal="gold.png" if medals[2]==1 && medals[1]==1 && medals[0]==1

        return [successes.to_s+'/'+total.to_s,medal,success_array]
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

  def abandon_course_build
    if session[:current_course_id]
      @course=Course.find_by_id(session[:current_course_id])  
      if @course.update_attributes(params[:course])
          flash[:success] = "Stopped editing Course "+session[:current_course_id].to_s
        end
      session[:current_course_id] = nil
    end 
  end

  def displaycourse(profile)
  end

  def displaycourses(user, coursearray)
  end
end
