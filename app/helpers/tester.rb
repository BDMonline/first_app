include Math

def rounded(number,figs)
	if number<0
		sign ='-'
	else
		sign=''
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

a = [2.984,-400,120000,36/1.to_r,-0.000237]
a.each do |number|
	[1,2,3,4,5].each do |figs|
		puts rounded(number,figs)
	end
end


