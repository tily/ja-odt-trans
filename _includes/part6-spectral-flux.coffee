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
			#@plot.plot(data, @SAMPLES_PER_PIXEL, "red")
			spectralFlux = []
			lastSpectrum = []
			for i in [0...data.length/1024-1]
				a = []
				for j in [i*1024...i*1024+1024]
					a.push data[j]
				fft = new FFT(1024, 44100)
				fft.forward a
				spectrum = fft.spectrum
				console.log spectrum.length
				flux = 0.0
				for k in [0...spectrum.length]
					flux += (spectrum[k] - (lastSpectrum[k] || 0))
				spectralFlux.push flux
				lastSpectrum = spectrum
			console.log 'spectralFlux: ', spectralFlux
			@plot.plot(spectralFlux, 0.5, "green")
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

file = document.querySelector("#part6-spectral-flux-file")
canvas = document.querySelector("#part6-spectral-flux-canvas")
part6SpectralFlux = new Part6SpectralFlux file, canvas
document.querySelector("#part6-spectral-flux-play").onclick = part6SpectralFlux.play
