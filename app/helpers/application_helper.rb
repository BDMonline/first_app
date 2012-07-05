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
end
