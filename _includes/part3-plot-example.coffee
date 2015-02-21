class Part3PlotExample
	constructor: (file, canvas)->
		@plot = new Plot(canvas, 512, 512)
		@file = file
		@file.onchange = @onfilechange
		@context = new AudioContext()
		@reader = new FileReader()
		@reader.onload = @onfileload
	onfilechange: (e)=>
		@reader.readAsArrayBuffer(e.target.files[0])
	onfileload: ()=>
		@context.decodeAudioData @reader.result, (buffer)=>
			@plot.plot(buffer.getChannelData(0), 44100 / 100, "red")

file = document.querySelector("#part3-plot-example-file")
canvas = document.querySelector("#part3-plot-example-canvas")
part3PlotExample = new Part3PlotExample file, canvas
