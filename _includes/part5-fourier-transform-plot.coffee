class Part5FourierTransformPlot
	constructor: (canvas)->
		@plot = new Plot(canvas, 512, 512)

		@context = new AudioContext
		@source = @context.createBufferSource()

		@analyser = @context.createAnalyser()
		@analyser.fftSize = 1024

		@processor = @context.createScriptProcessor(1024, 1, 1)
		@processor.onaudioprocess = @onaudioprocess

		@x = 0
		@angle = 2 * Math.PI * 440 / 44100
	onaudioprocess: (e)=>
		data = e.outputBuffer.getChannelData(0)
		for i in [0...e.outputBuffer.length]
			data[i] = Math.sin(@x)
			@x += @angle
	play: ()=>
		@source.connect(@processor)
		@processor.connect(@analyser)
		@analyser.connect(@context.destination)
		window.requestAnimationFrame @onAnimationFrame	
	pause: ()=>
		@processor.disconnect()
		@source.disconnect()
	onAnimationFrame: ()=>
		data = new Uint8Array(256)
		@analyser.getByteFrequencyData(data)
		@plot.plot(data, 0.5, "red")
		window.requestAnimationFrame @onAnimationFrame	

canvas = document.querySelector("#part5-fourier-transform-plot-canvas")
part5FourierTransformPlot = new Part5FourierTransformPlot(canvas)
document.querySelector("#part5-fourier-transform-plot-play").onclick = part5FourierTransformPlot.play
document.querySelector("#part5-fourier-transform-plot-pause").onclick = part5FourierTransformPlot.pause
