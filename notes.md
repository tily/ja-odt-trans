---
layout: page
title: "訳注: Web Audio API による実装"
permalink: /notes/
---

<script type="text/javascript" src="/ja-odt-trans/js/coffee-script.js"></script>

翻訳したついでに元記事で実装された機能を Web Audio API で作り直してみました。

## Part 2

### NoteGenerator

<script type="text/coffeescript">
{% include part2-note-generator.coffee %}
</script>

{% highlight coffeescript %}
{% include part2-note-generator.coffee %}
{% endhighlight %}

<button id="part2-note-generator-play">play</button>
<button id="part2-note-generator-pause">pause</button>

### WaveOutput

<script type="text/coffeescript">
{% include part2-wave-output.coffee %}
</script>

{% highlight coffeescript %}
{% include part2-wave-output.coffee %}
{% endhighlight %}

<input id="part2-wave-output-file" type="file">
<button id="part2-wave-output-play">play</button>
<button id="part2-wave-output-pause">pause</button>

## Part 3

## Part 4

## Part 5

## Part 6

## Part 7
