class AlgorithmsController < ApplicationController
  def new

  	table = [[2,3,4],[1,0,1]]
  	tablehtml = '
<table class="table">'
	table.each do |row|
		tablehtml += "<tr>"
		row.each do |item|
			tablehtml += '<th class="tg-yw4l">'+ item.to_s + '</th>'
		end
		tablehtml += "</tr>"
	end
	@tablehtml = tablehtml + '</table>'

  end
  def table
  	

  end
end
