class Part4RealTimePlot
	constructor: (file, canvas, marker)->
		@SAMPLES_PER_PIXEL = 400
		@plot = new Plot(canvas, 512, 512, marker)
		@file = file
		@file.onchange = @onfilechange
		@context = new AudioContext()
		@source = @context.createBufferSource()
		@reader = new FileReader()
		@reader.onload = @onfileload
	onfilechange: (e)=>
		@reader.readAsArrayBuffer(e.target.files[0])
	onfileload: ()=>
		@context.decodeAudioData @reader.result, (buffer)=>
			@plot.plot(buffer.getChannelData(0), @SAMPLES_PER_PIXEL, "red")
			@source.buffer = buffer
			@source.connect(@context.destination)
			@source.loop = true
	play: ()=>
		@startTime = @context.currentTime
		@source.start(0)
		window.requestAnimationFrame(@onAnimationFrame)
	onAnimationFrame: ()=>
		elapse = @context.currentTime - @startTime
		@plot.setMarker(elapse * 44100 / @SAMPLES_PER_PIXEL, "white")
		window.requestAnimationFrame(@onAnimationFrame)

file = document.querySelector("#part4-real-time-plot-file")
canvas = document.querySelector("#part4-real-time-plot-canvas")
part4RealTimePlot = new Part4RealTimePlot file, canvas
document.querySelector("#part4-real-time-plot-play").onclick = part4RealTimePlot.play
