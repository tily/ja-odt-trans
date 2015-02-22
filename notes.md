---
layout: page
title: "訳注: Web Audio API による実装"
permalink: /notes/
---

<script type="text/javascript" src="/ja-odt-trans/js/coffee-script.js"></script>
<script type="text/javascript" src="/ja-odt-trans/js/dsp.js"></script>
<script type="text/javascript" src="/ja-odt-trans/js/plot.js"></script>

翻訳したついでに元記事で実装された機能を Web Audio API で作り直してみました。

## Part 2

### NoteGenerator

<script type="text/coffeescript">
{% include part2-note-generator.coffee %}
</script>

<button id="part2-note-generator-play">play</button>
<button id="part2-note-generator-pause">pause</button>

{% highlight coffeescript %}
{% include part2-note-generator.coffee %}
{% endhighlight %}

### WaveOutput

<script type="text/coffeescript">
{% include part2-wave-output.coffee %}
</script>

<input id="part2-wave-output-file" type="file">
<button id="part2-wave-output-play">play</button>
<button id="part2-wave-output-pause">pause</button>

{% highlight coffeescript %}
{% include part2-wave-output.coffee %}
{% endhighlight %}

## Part 3

### PlotExample

<script type="text/coffeescript">
{% include part3-plot-example.coffee %}
</script>

<input id="part3-plot-example-file" type="file"><br />
<canvas id="part3-plot-example-canvas" style="width:512px; height:512px" />

{% highlight coffeescript %}
{% include part3-plot-example.coffee %}
{% endhighlight %}

## Part 4

### MP3Output

(Part 2 の WaveOutput 参照)

### RealTimePlot

<script type="text/coffeescript">
{% include part4-real-time-plot.coffee %}
</script>

<input id="part4-real-time-plot-file" type="file">
<button id="part4-real-time-plot-play">play</button>
<button id="part4-real-time-plot-pause">pause</button><br />
<canvas id="part4-real-time-plot-canvas" style="width:512px; height:512px;" />

{% highlight coffeescript %}
{% include part4-real-time-plot.coffee %}
{% endhighlight %}

## Part 5

### FourierTransformPlot

<script type="text/coffeescript">
{% include part5-fourier-transform-plot.coffee %}
</script>

<button id="part5-fourier-transform-plot-play">play</button>
<button id="part5-fourier-transform-plot-pause">pause</button><br />
<canvas id="part5-fourier-transform-plot-canvas" style="width:512px; height:512px;" />

{% highlight coffeescript %}
{% include part5-fourier-transform-plot.coffee %}
{% endhighlight %}

## Part 6

### SpectralFlux

<script type="text/coffeescript">
{% include part6-spectral-flux.coffee %}
</script>

<input id="part6-spectral-flux-file" type="file">
<button id="part6-spectral-flux-play">play</button>
<button id="part6-spectral-flux-pause">pause</button><br />
<canvas id="part6-spectral-flux-canvas" style="width:512px; height:512px;" />

{% highlight coffeescript %}
{% include part6-spectral-flux.coffee %}
{% endhighlight %}

## Part 7
