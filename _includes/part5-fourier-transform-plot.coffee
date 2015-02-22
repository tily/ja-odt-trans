class Part5FourierTransformPlot
	constructor: (canvas)->
		@plot = new Plot(canvas, 512, 512)

canvas = document.querySelector("#part5-fourier-transform-plot-canvas")
part5FourierTransformPlot = new Part5FourierTransformPlot(canvas)
