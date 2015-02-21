class Part2NoteGenerator
	constructor: ()->
		@context = new AudioContext
		@source = @context.createBufferSource()
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
		@processor.connect(@context.destination)
	pause: ()=>
		@processor.disconnect()
		@source.disconnect()

part2NoteGenerator = new Part2NoteGenerator
document.querySelector("#part2-note-generator-play").onclick = part2NoteGenerator.play
document.querySelector("#part2-note-generator-pause").onclick = part2NoteGenerator.pause
