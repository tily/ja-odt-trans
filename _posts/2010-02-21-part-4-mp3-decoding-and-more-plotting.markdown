---
layout: post
title: "Part 4: MP3 デコードとより高機能なプロット"
date:   2010-02-21 00:00:00
categories: onset detection tutorial
---

原文: [Onset Detection Part 4: MP3 decoding and more Plotting](http://www.badlogicgames.com/wordpress/?p=139)

<!--
In the first article of this series i told you to find out how to decode MP3 files yourself. Well, being the good sport i am i extended the framework with a nice little MP3 decoder based on JLayer. Here’s the class which is analogous to WaveDecoder:
-->

このシリーズの最初の記事で、皆さんに自分で MP3 ファイルをデコードする方法を見つけ出すように指示した。
しかし、私は気前がいいので、例のフレームワークを拡張して JLayer ベースのいい感じの MP3 デコーダーを追加してみた。
ここに WaveDecoder に似たクラスがある：


{% highlight java %}
public class MP3Decoder
{
   public MP3Decoder( InputStream in );
   public void readFrames( float[] samples );
}
{% endhighlight %}

<!--
It works exactly the same as the WaveDecoder. Proper object oriented programming would mean both decoders share the same interface, but i was kind of lazy. Feel free to add that to the source yourself if you feel fuzzier inside with proper interfacing.
-->

これは WaveDecoder と全く同じように機能する。ちゃんとオブジェクト指向プログラミングするなら、2 つのデコーダーは同じインタフェースを共有すべきなのだが、めんどくさかったのでやらなかった。もし適切なインタフェースを設けたほうが落ち着くというのなら、自由に追加してよい。

<!--
Another thing i did to the framework today is giving us a possibility to set a marker line so that we can see where the playback is currently in a plot. Here’s the new method in the Plot class:
-->

もう一つ今日このフレームワークに対して行ったのは、マーカーラインを設定してプレイバックが今プロットのどこにあるのかを確認できるようにしたこと。下記が Plot クラスの新しいメソッドだ:

{% highlight java %}
public class Plot
{
   ...
   public void setMarker( int position, Color color );
}
{% endhighlight %}

<!--
The first parameter specifies the x coordinate in the plot where the marker should be located. The second one is the color of the marker. I also changed the internal workings of the Plot class. The plot is now redrawn constantly and reacts to changes almost immediatly. To illustrate the use of the Plot.setMarker() method i wrote a simple example located in RealTimePlot. I only reproduce the novel parts here:
-->

最初のパラメーターでマーカーが配置されるべきプロット上の x 座標を指定する。2 つ目のパラメーターにはマーカーの色を指定する。また、Plot クラスの内部の機能にも変更を加えた。プロットが定期的に再描画され、変化に対してほぼ瞬間的に反応するようになっている。Plot.setMaker() メソッドの使い方を説明するために [RealTimePlot](http://code.google.com/p/audio-analysis/source/browse/trunk/src/com/badlogic/audio/samples/RealTimePlot.java) に置いてある簡単なサンプルコードを書いた。新しい部分だけを下記にコピペする。

{% highlight java %}
public class RealTimePlot 
{
   private static final int SAMPLE_WINDOW_SIZE = 1024;	
   private static final String FILE = "samples/sample.mp3";
	
   public static void main( String[] argv ) throws FileNotFoundException, Exception
   {
      float[] samples = readInAllSamples( FILE );

      Plot plot = new Plot( "Wave Plot", 1024, 512 );
      plot.plot( samples, SAMPLE_WINDOW_SIZE, Color.red );
		
      MP3Decoder decoder = new MP3Decoder( new FileInputStream( FILE ) );
      AudioDevice device = new AudioDevice( );
      samples = new float[SAMPLE_WINDOW_SIZE];
		
      long startTime = 0;
      while( decoder.readSamples( samples ) > 0 )
      {
         device.writeSamples( samples );
         if( startTime == 0 )
            startTime = System.nanoTime();
         float elapsedTime = (System.nanoTime()-startTime)/1000000000.0f;
         int position = (int)(elapsedTime * (44100/SAMPLE_WINDOW_SIZE)); 
         plot.setMarker( position, Color.white );			
         Thread.sleep(15); // this is needed or else swing has no chance repainting the plot!
      }
   }
...
}
{% endhighlight %}

<!--
First we load all samples from the MP3 file as we’ve done previously. The samples are then plotted, using 1024 samples per pixel ( this is the SAMPLE_WINDOW_SIZE, we have a window of 1024 samples…). Now we want to playback the file and see in the plot where the playback currently is by observing a moving marker, a line from the top to the bottom of the plot that updates with the elapsed time.
-->

最初に、前にやったのと同じように MP3 ファイルからすべてのサンプルを読み込む。サンプルは 1 ピクセルあたり 1024 個のサンプル数でプロットされる (これが SAMPLE_WINDOW_SIZE であり、1024 個のサンプルを持つ範囲が得られるというわけだ)。それではファイルを再生し、プロットの中で今どこが再生されているかを見てみたいと思う。動くマーカー、つまり時間が経過するにつれて更新されるプロットの上から下に引かれた線を観察すればよい。

<!--
Setting up the MP3Decoder and the AudioDevice should be quiet familiar by now. We also need a float array for the samples we read in from the MP3Decoder for playback. Then we enter the decoding/playback loop. We read in the current sample window and write it to the audio device as we’ve done before. Now comes the magic part. After we have written the first window to the device we start measuring the elapsed time. For this we have to know when the playback started, this is done in the body of the condition if( startTime == 0 ). The current time minus the start time divided by a billion gives us the elapsed time in seconds since the playback start. We calculate that in the next line. We record the start time after we decoded and wrote the first sample window as that synchs the audio output with our plotting. The AudioDevice.writeSamples() method blocks till all the samples are written to the sound device. The cursor will thus lag behind a pixel at most which is totally ok for our purposes.
-->

MP3Decoder と AudioDevice をセットアップすることにはもうだいぶ慣れただろう。再生のために MP3Decoder から読み込むサンプル用の float 配列も必要だ。それからデコードと再生のループ処理に入る。現在のサンプルの幅を読み込み、以前やったようにオーディオデバイスへ書き出す。魔法の部分はここからだ。最初の範囲をデバイスへ書き出したあとで経過時間を計測する。このために再生の開始時刻を知る必要があり、 if( startTime == 0 ) という条件文の中で行っている。現在時刻から開始時刻を引いたものを 10 億で割ると再生開始時間からの経過時間を秒で取得できる。それを次の行で計算している。デコードと最初のサンプル範囲書き出しが終わったあとに開始時間を記録しているのは、オーディオの出力とプロットを同期させるためだ。AudioDevice.writeSamples() メソッドはすべてのサンプルがサウンドデバイスに書き出されるまでブロックする。そのためマーカーは最大 1 ピクセル分遅れてしまうが、今回の用途なら特に問題はない。

<!--
All that is left is calculating the pixel position of the marker in the plot based on the elapsed time and set the marker accordingly. The magic formula for the pixel position of the marker is the elapsed time times the sample frequency divided by the number of samples per pixel in the plot. That’s it. If you think about it for a minute you should see how i arrived at this formula. If not, think harder! What’s left is setting the marker position of the plot which we do in the next line. Finally we put the decoding thread to sleep for 15 milliseconds to give the Swing thread that does all the drawing some time to do so. Otherwise the marker will not move smoothly.
-->

あとは経過時間に基づいたプロットの中でのマーカーの位置 (ピクセル) を計算し、その通りにマーカーを設定するだけだ。マーカーの位置 (ピクセル) を計算するための魔法の公式は、経過時間にサンプルの周波数をかけ、プロットの中でのピクセル毎のサンプル数で割るというものだ。それだけ。少し考えてみれば、どうやってこの公式にたどり着いたか分かるだろう。分からなければ、もっと考えろ！ 残りはプロット上のマーカーの位置を設定することで、これは次の行で行っている。最後にデコード用のスレッドに 15 秒スリープさせる。これによって Swing のスレッドにすべての描画を行う時間を与えている。そうしなければマーカーはスムーズに動かないだろう。

<!--
Here’s an image of the resulting output:
-->

これが出力結果の画像だ:

![](http://i.gyazo.com/eb09a77d8ab0871993e7658e6e01ccba.png)

<!--
Hurray! Real-time plotting! To see this example in action download the source code from [http://audio-analysis.googlecode.com/svn/trunk/](http://audio-analysis.googlecode.com/svn/trunk/) via your SVN client of choice, import the project to eclipse and start the RealTimePlot.java example.
-->

やった！ リアルタイム・プロッティングだ！ このサンプルが動いているのを確認するにはお好きな SVN クライアントで http://audio-analysis.googlecode.com/svn/trunk/ をダウンロードし、eclipse へプロジェクトをインポートして RealTimePlot.java というサンプルコードを実行すればよい。

<!--
Next time we are going to finally get to do some mathmagic to finally detect some onsets. The real-time plotting we used here will be of help to visually see where onsets are located with respect to the audio playback.
-->

次回はついに、音の立ち上がり検出を行うためのちょっとした数学に着手しようと思う。ここで利用したリアルタイム・プロッティングはオーディオ再生中のどこに音の立ち上がりが置かれているかを視覚的に確認することに役立つだろう。
