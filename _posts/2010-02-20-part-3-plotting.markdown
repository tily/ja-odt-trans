---
layout: post
title: "Part 3: プロッティング"
date:   2010-02-20 00:00:00
categories: onset detection tutorial
---

原文: [Onset Detection Part 3: Plotting](http://www.badlogicgames.com/wordpress/?p=129)

<!--
Processing and analysing audio can be quiet tedious without visualizing what’s going on.
We could want to see the amplitudes of our samples for example.
To facilitate this need i wrote a very simple Swing based class called Plot.
It will allow us to easily plot one or more arrays of floats to a window, scaling the values along the way so we are guaranteed to see something.
Here’s the signatures:
-->

音声を処理したり分析したりするときには、何が起きているかを可視化しないと非常に退屈だ。たとえばサンプルの振幅を見てみたいことがあるだろう。そのような場合に助けるになるよう、非常に簡単な Swing ベースの [Plot](http://code.google.com/p/audio-analysis/source/browse/trunk/src/com/badlogic/audio/visualization/Plot.java) というクラスを書いた。これを使えば、1 つまたは複数の float 配列を簡単にウィンドウへプロットすることができる。値は適切な縮尺にしてくれるので必ずなんらかの結果を確認することができる。
シグネチャは下記のような感じ：

{% highlight java %}
public class Plot
{
   public Plot( String title, int width, int height );
   public void clear( );
   public void plot( float[] samples, float samplesPerPixel, Color color );
}
{% endhighlight %}

<!--
As always a pretty tiny class with just enough methods to get things done.
At construction time of the Plot you pass in its title and its width and height in pixels.
To plot an array of values you use the Plot.plot() method.
The first argument is the array of samples we want to plot.
Note that samples here does not necessarily mean PCM samples.
You could pass in anything you want really.
The next parameter defines how many samples of the array should be used per pixel in the plot.
This allows you to scale the plot on the x-Axis.
The last parameter is the color of the plotted samples.
If you want to erase what you have plotted so far you simply call Plot.clear().
Note that if you plot multiple arrays they all should be on the same scale value wise.
It is for example ok to plot two arrays that have values somewhere in the range of [-1, 1].
It is not such a wise idea to plot arrays where one is say in the range [-1,1] and the other is in the range [0, 200].
Keep that in mind.
In this series we will only plot arrays that are on the same scale.
If you want to plot arrays of different scale you should use different Plot instances for each plot.
Also, the Plot class uses Swing only and is totally slow.
You don’t want to use it to visualize real-time data, it will not be in synch.
-->

いつも通りとても小さなクラスであり、やりたいことをやるのには十分なメソッドが備わっている。
Plot クラスをインスタンス化するときには、タイトルと幅・高さ (ピクセル) を渡す。
値の配列をプロットするには Plot.plot() メソッドを使う。
最初の引数はプロットしたいサンプルの配列だ。
注意してほしいのはここで言うサンプルは必ずしも PCM サンプルではないということ。
実際にあなたが渡したいものならなんでも渡すことができる。

次のパラメーターではプロットの中で 1 ピクセルごとに配列の中の何個のサンプルが使われるべきかを定義する。
これによって X 軸のプロットの縮尺を適切に設定することができる。
最後のパラメーターはプロットされるサンプルの色だ。
これまでにプロットしたものを消去したい場合には、Plot.clear() を呼べばよい。
注意してほしいのは、複数の配列をプロットしたいときにはすべてに同じ縮尺の値を指定すべきだということだ。
たとえば [-1, 1] の範囲の値を要素として持つ 2 つの配列をプロットするのは OK。
[-1, 1] の範囲の値を持つ配列と、[0, 200] の範囲の値を持つ配列をプロットするのはあまりよい考えとは言えない。
このシリーズでは同じ縮尺の値を持つ複数の配列だけをプロットするだろう。
もし違う縮尺の複数の配列をプロットしたい場合には、それぞれのプロットで別々の Plot インスタンスを利用すべきだ。
また、Plot クラスは Swing しか利用していないので全体的に遅い。
同期がうまく行えないので、リアルタイムデータの可視化には使わないほうがよいだろう。

<!--
Let’s do something interesting and plot all the samples of the song stored in the “samples/” folder (Plot Example):
-->

興味深いことをやってみよう。"samples/" フォルダに保存した曲のすべてのサンプルをプロットしてみる (PlotExample):

{% highlight java %}
public class PlotExample 
{
   public static void main( String[] argv ) throws FileNotFoundException, Exception
   {
      WaveDecoder decoder = new WaveDecoder( new FileInputStream( "samples/sample.wav" ) );
      ArrayList allSamples = new ArrayList( );
      float[] samples = new float[1024];
		
      while( decoder.readSamples( samples ) > 0 )
      {
         for( int i = 0; i < samples.length; i++ )
            allSamples.add( samples[i] );
      }
		
      samples = new float[allSamples.size()];
      for( int i = 0; i < samples.length; i++ )
         samples[i] = allSamples.get(i);
		
      Plot plot = new Plot( "Wave Plot", 512, 512 );
      plot.plot( samples, 44100 / 100, Color.red );
   }
}
{% endhighlight %}

<!--
First we open a WaveDecoder that will give us the PCM data of the Wave file.
The ArrayList allSamples will be used to (slowly) read in all the samples from the decoder.
It will handle resizing the internal array for the samples for us, we are lazy again.
Note that it is not a good idea to do it like this as we have to convert from float to its cousin Float which is an object instance.
This is called auto-boxing and it's nasty.
After we read in all the samples we transfer them to a float[] array so we can plot them.
The last two lines instantiate the Plot and draw the samples we just read in.
Take a look at the second parameter of the invocation of Plot.plot().
It tells the Plot to use one Pixel for 44100 / 100 = 441 samples in the final output.
So each pixel shows us the amplitude of a sound sequence of 0.001 seconds.
You can play around with this parameter to get a finer grained insight into the waveform (warning: you will need to give more heap memory to the vm in case you set the samplePerPixel parameter very low as the produced image will be extremely large!).
Here's the output of this program:
-->

最初に Wave ファイルの PCM データを得るために WaveDecoder を開いている。
allSamples という名前の ArraList は (低速に) デコーダーからすべてのサンプルを読み込むために利用される。
allSamples はサンプル保存用の内部配列をリサイズしてくれるので、私たちはここでもなまけていられる。
注意すべきなのは、float をそのいとこ的な存在のオブジェクト・インスタンスである Float へ変換したいときにこのような処理を行うのはよい考えとは言えない。
それはオートボクシングと呼ばれており、扱いづらい。
すべてのサンプルを読み込んだら、プロットできるように float[] へと移動させる。

最後の 2 行で Plot インスタンスを作り、読み込んだばかりのサンプルを描画する。
Plot.plot() 呼び出しの 2 番目のパラメーターを見てほしい。
最終的な出力で 44100 / 100 = 441 サンプルごとに 1 ピクセルを使うように Plot に指示している。
よって各ピクセルは 0.0001 秒の音の連続についての振幅を表す。
このパラメーターをいじってより精細に wave ファイルの形式を洞察してみるとよい (注意: samplePerPixel パラメーターの値をとても低く設定する際には、JVM により大きなヒープメモリを割り当てる必要があるだろう。生成される画像が極端に大きくなるので！)
下記がこのプログラムの出力だ。

![](http://i.gyazo.com/0418bf9bce9b51e773cdbf215ed72ea9.png)

<!--
This is an amplitude plot of all samples in the audio file. It doesn't give us a hole lot of information concerning onsets. It looks like one big mess. Let's see what we get when we set the samplesPerPixel to a lower value (thus giving us more resolution in the plot (samplesPerPixel = 44100/1000):
-->

これがオーディオファイルのすべてのサンプルの振幅のプロットである。このプロットでは音の立ち上がりに関する情報はそんなに多くは得られない。ひどい混乱状態のようだ。samplesPerPixcel をより低い値に設定したらどうなるか見てみよう (そうするとプロットの解像度がよくなる) (samplesPerPixel = 44100/1000)

![](http://i.gyazo.com/7ae26cf3cf0967dcf735990d626ade8e.png)

<!--
Now it seems that there is structure in the sound! As a first guess the peaks in this seem to indicate sudden bursts of sound, probably from the drums. However, it would be pretty hard to detect peaks in this form. In the next article we'll see how to arrive at a form of the samples that makes our live a little bit easier.
-->

これを見ると音の中に構造があるようだ。ぱっと推測するなら、ピークとなっている部分はおそらくはドラムから、急に音が出たことを表していそうだ。しかしながら、この形式ではピークを検出するのはかなり難しいだろう。次の記事では、やりたいことを少しだけラクにしてくれるサンプルの形式へたどり着く方法を見ることになるだろう。
