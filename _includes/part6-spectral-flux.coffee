class Part6SpectralFlux
	constructor: (file, canvas, marker)->
		@SAMPLES_PER_PIXEL = 512
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
			data = buffer.getChannelData(0)
			spectralFlux = []
			lastSpectrum = []
			for i in [0...data.length/1024-1]
				fft = new FFT(1024, 44100)
				samples = []
				for j in [i*1024...i*1024+1024]
					samples.push data[j]
				fft.forward samples
				spectrum = fft.spectrum
				flux = 0
				for j in [0...spectrum.length]
					flux += (spectrum[j] - (lastSpectrum[j] || 0))
				spectralFlux.push flux
				lastSpectrum = spectrum
			@plot.plot(spectralFlux, 0.5, "green")
			@source.buffer = buffer
			@source.connect(@context.destination)
			@source.loop = true
	start: ()=>
		@startTime = @context.currentTime
		@source.start(0)
		window.requestAnimationFrame(@onAnimationFrame)
	stop: ()=>
		@source.stop(0)
	onAnimationFrame: ()=>
		elapse = @context.currentTime - @startTime
		@plot.setMarker(elapse * 44100 / @SAMPLES_PER_PIXEL, "white")
		window.requestAnimationFrame(@onAnimationFrame)

file = document.querySelector("#part6-spectral-flux-file")
canvas = document.querySelector("#part6-spectral-flux-canvas")
part6SpectralFlux = new Part6SpectralFlux file, canvas
document.querySelector("#part6-spectral-flux-start").onclick = part6SpectralFlux.start
document.querySelector("#part6-spectral-flux-stop").onclick = part6SpectralFlux.stop
