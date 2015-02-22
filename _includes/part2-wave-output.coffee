class Part2WaveOutput
	constructor: (file)->
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
			@source.buffer = buffer
			@source.connect(@context.destination)
			@source.loop = true
	play: ()=>
		@source.start(0)
	pause: ()=>
		@source.stop(0)

part2WaveOutput = new Part2WaveOutput document.querySelector("#part2-wave-output-file")
document.querySelector("#part2-wave-output-play").onclick = part2WaveOutput.play
document.querySelector("#part2-wave-output-pause").onclick = part2WaveOutput.pause
