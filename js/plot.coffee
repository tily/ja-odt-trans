---
---
window.Plot = class Plot
	constructor: (canvas, width, height, marker)->
		@canvas = canvas
		@canvas.width = width
		@canvas.height = height
		@context = @canvas.getContext('2d')
		@clear()

		@marker = document.createElement('canvas')
		document.querySelector("body").appendChild @marker
		@marker.style.position = "absolute"
		@marker.style.left = @canvas.offsetLeft + "px"
		@marker.style.top = @canvas.offsetTop + "px"
		@marker.style.zIndex = "1000"
		@marker.width = width
		@marker.height = height
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
			value = (sample / scalingFactor)  * @canvas.height / 3 + @canvas.height / 2
			@context.beginPath()
			@context.moveTo (i-1) / samplesPerPixel, @canvas.height - lastValue
			@context.lineTo i / samplesPerPixel, @canvas.height - value
			@context.closePath()
			@context.stroke()
			lastValue = value
	clear: ()->
		@context.fillStyle = "black"
		@context.fillRect(0, 0, @canvas.width, @canvas.height)
	setMarker: (position, color)->
		context = @marker.getContext("2d")
		context.clearRect(0, 0, @canvas.width, @canvas.height)
		context.strokeStyle = color
		context.beginPath()
		context.moveTo(position, 0)
		context.lineTo(position, @marker.height)
		context.closePath()
		context.stroke()
