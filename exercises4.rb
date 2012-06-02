class String
	def shuffle
		self.split('').shuffle.join
	end
end

person1=Hash.new
person1[:name]="Bill"
person1[:last]="Tidy"
person2={:name => "Ronald", :last => "Searle" }
person3 = { name:"Gerald", last:"Scarfe"}
#	puts person1, person2, person3
params={mother:person2, father:person1, child:person3 }
 puts params[:father][:name]

