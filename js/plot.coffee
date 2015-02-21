---
---
window.Plot = class Plot
	constructor: (canvas, width, height)->
		@canvas = canvas
		@canvas.width = width
		@canvas.height = height
		@context = @canvas.getContext('2d')
		@clear()
	plot: (samples, samplesPerPixel, color)-> # samples should be array of float numbers
		@clear()	
		@context.strokeStyle = color
		max = 0
		min = 0
		for sample in samples
			max = Math.max(max, sample)
			min = Math.min(min, sample)
		scalingFactor = max - min
		lastValue = null
		for sample, i in samples
			#value = (sample / scalingFactor)  * @canvas.height / 3 + @canvas.height / 2
			value = (sample / scalingFactor)  * @canvas.height + @canvas.height / 2
			@context.beginPath()
			@context.moveTo (i-1) / samplesPerPixel, @canvas.height - lastValue
			@context.lineTo i / samplesPerPixel, @canvas.height - value
			@context.closePath()
			@context.stroke()
			lastValue = value
	clear: ()->
		@context.fillStyle = "black"
		@context.fillRect(0, 0, @canvas.width, @canvas.height)
