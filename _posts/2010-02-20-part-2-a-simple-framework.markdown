---
layout: post
title: "Part 2: 簡単なフレームワーク"
date:   2010-02-20 00:00:00
categories: onset detection tutorial
---

原文: [Onset Detection Part 2: A simple framework](http://www.badlogicgames.com/wordpress/?p=125)

<!--
Well, i just put together a simple framework for all our onset detection tutorial needs.
It is located at http://code.google.com/p/audio-analysis/.
To get the code you will need an SVN client, on Windows Tortoise SVN is pretty good, you linux people should know your magic :).
Simply check out the project from the svn URL http://audio-analysis.googlecode.com/svn/trunk/ and import it into Eclipse.
Now that you are ready to go let’s see what this “framework” has in store.
-->

この音の立ち上がり検出チュートリアルで必要になる簡単なフレームワークを作ってみた。
[http://code.google.com/p/audio-analysis/](http://code.google.com/p/audio-analysis/) に置いてある。
コードを取得するには SVN クライアントが必要だ。Windows なら [Tortoise SVN](http://tortoisesvn.tigris.org/) がおすすめだ。Linux ユーザーならやり方はもう分かっているだろう。:)
プロジェクトを svn URL http://audio-analysis.googlecode.com/svn/trunk/ からチェックアウトして Eclipse にインポートしてほしい。
準備ができたら、この「フレームワーク」がどんな機能を持っているか見てみよう。

<!--
The first class is called AudioDevice.
It looks like this
-->

最初のクラスは [AudioDevice](http://code.google.com/p/audio-analysis/source/browse/trunk/src/com/badlogic/audio/io/AudioDevice.java) という名前だ。
下記のような構造になっている。

{% highlight java %}
public class AudioDevice
{
   public AudioDevice( );
   public void writeSamples( float[] samples );
}
{% endhighlight %}

<!--
Pretty simple, eh?
This will setup a connection to your primary audio card in 44100Hz mono mode.
Just invoke the constructor.
It will throw an exception if it couldn’t setup the hardware but “that should never happen”(TM).
To output PCM data to the audio device you invoke AudioDevice.writeSamples and pass in a float array of your 44100Hz mono PCM samples.
-->

とてもシンプルではないか？
このクラスはメインのオーディオカードに 44100Hz モノラルモードで接続する。
コンストラクタを呼び出すだけでよい。
ハードウェアをセットアップすることができなければ例外がスローされることになるが、「それは絶対に起こりえない(TM)」。
PCM データをオーディオデバイスへ出力するには、AudioDevice.writeSamples を呼び出し、float 配列で44100Hz モノラルの PCM サンプルを渡す。

<!--
I wrote a small example which will generate a sine wave at 440Hz and output it to the audio device.
It looks like this:
-->

440Hz のサイン波を生成し、オーディオデバイスへ出力する短いサンプルコードを書いてみた。
こんな感じ：

{% highlight java %}
public class NoteGenerator 
{
   public static void main( String[] argv ) throws Exception
   {
      final float frequency = 880; // 440Hz for note A
      float increment = (float)(2*Math.PI) * frequency / 44100; // angular increment for each sample
      float angle = 0;
      AudioDevice device = new AudioDevice( );
      float samples[] = new float[1024];
		
      while( true )
      {
         for( int i = 0; i < samples.length; i++ )
         {
            samples[i] = (float)Math.sin( angle );
            angle += increment;
         }
			
         device.writeSamples( samples );
      }
   }
}
{% endhighlight %}

<!--
It is basically a rewritten version of the code snippet in part 1 of this series.
In each loop iteration we generate the next 1024 samples of our sine wave and feed it to the audio device.
Play around with this code a little, e.g. change the frequency of the sine wave.
For example, if you double the frequency you get the same note in the next octave.
The inverse is also true.
To stop the program you have to kill it in Eclipse by clicking on the stop button.
A proper GUI would mean to much code for such simple examples.
You can find the source code in the package [com.badlogic.audio.samples](http://code.google.com/p/audio-analysis/source/browse/#svn/trunk/src/com/badlogic/audio/samples).
-->

基本的には、このシリーズのパート 1 に記載したコードスニペットの修正版だ。
ループの中でサイン波の次の 1024 個分のサンプルを生成し、オーディオデバイスへ送るようにしている。
少しこのコードをいじくってみてほしい。たとえばサイン波の周波数を変えてみるとか。
たとえば、もし周波数を 2 倍にすると、同じ高さで 1 つ上のオクターブの音が出る。
逆もまた真なり。
プログラムを終了させるには、停止ボタンをクリックして Eclipse による実行を中止させればよい。
このような簡単な例にとっては適切な GUI が非常に重要だろう。
ソースコードについては com.badlogic.audio.samples パッケージ配下を参照してほしい。

<!--
The second class i provide you is a Wave file decoder.
With this class you can read in Wave files in 16-bit mono/stereo with a sampling rate of 44100.
Wave supports a couple of other formats/sampling rates but for the sake of simplicity i only support the mentioned configurations.
The class that does all this magic is called WaveDecoder.
It will convert the PCM data from the Wave file to 32-bit float samples on the flie.
Here's the signatures of that class:
-->

提供されている第二のクラスは Wave ファイルデコーダーだ。
このクラスを使えば 16bit モノラル/ステレオの Wave ファイルをサンプリングレート 44100 で読み込むことができる。
Wave は他にもいくつかのフォーマットやサンプリングレートをサポートしているが、簡潔さのために上記の設定のみサポートするようにした。
このような魔法の処理を行うのは WaveDecorder という名前のクラスだ。
このクラスはその場で PCM データを Wave ファイルから 32bit float のサンプルに変換してくれる。
クラスのシグネチャは下記の通り：

{% highlight java %}
public class WaveDecoder
{ 
   public WaveDecoder( InputStream stream ) throws Exception;
   public int readSamples( float[] samples );
}
{% endhighlight %}

<!--
Again pretty slick.
In the constructor you pass in the InputStream from where the Wave file should be read.
If an error occured an exception will be thrown.
After you instantiated the class properly you can read the samples from the Wave file by a call to WaveDecoder.readSamples().
The method will try to read as many samples from the Wave file as there are elements in the samples array you pass in.
It will return you the actual number of samples read in.
If the Wave file is stereo the stereo samples get converted to a single mono sample as explained in part 1 of this series.
If the method returns 0 you know that the end of the stream has been reached or an error occured.
Here's a simple example how to use the WaveDecoder in combination with the AudioDevice to output sound read in from a Wave file:
-->

今度もスッキリしている。
コンストラクタには Wave ファイルを読み出すための InputStream を渡す。
エラーが起きたら例外がスローされる。
適切にクラスをインスタンス化することができたら、WaveDecoder.readSamples() を呼び出し、Wave ファイルからサンプルを読み込むことができる。
このメソッドはあなたが渡したサンプルの配列の要素数の限界まで Wave ファイルからサンプルを読み出そうと試みる。
戻り値には実際に読み込んだサンプルの数を返却する。
パート 1 で説明した通り、Wave ファイルがステレオならステレオの場合にはステレオのサンプルはモノラルに変換される。
メソッドが 0 を返した場合、ストリームの終端に到達してしまっているかエラーが発生したということだ。
下記の簡単な例では、WaveDecoder を AudioDevice と組み合わせ、Wave ファイルから読み込んだ音を出力するやり方を説明している:

{% highlight java %}
public class WaveOutput 
{
   public static void main( String[] argv ) throws Exception
   {
      AudioDevice device = new AudioDevice( );
      WaveDecoder decoder = new WaveDecoder( new FileInputStream( "samples/sample.wav" ) );
      float[] samples = new float[1024];
                
      while( decoder.readSamples( samples ) > 0 )
         device.writeSamples( samples );
   }
}
{% endhighlight %}

<!--
We first construct the AudioDevice and the WaveDecoder as well as a float array that holds the samples read in from the Wave file. In each loop iteration we try to read in 1024 samples (the length of the samples array) and write those samples to the AudioDevice. That's it.
Sound programming is really that easy. The code for the example can be found in the package com.badlogic.audio.samples. Play around with it. You could for example alter the amplitude of the samples, e.g. half the loudness by multiplying each sample with 0.5 before writting them to the AudioDevice.
-->

最初に AudioDevice, WaveDecoder および Wave ファイルから読みこんだサンプルを保存するための float 配列をインスタンス化する。
ループの中では、1024 個 (サンプルの配列の長さ) のサンプルを読みこみ、AudioDevice へ書き出そうとする。
それだけだ。
サウンドプログラミングは本当にこんなに簡単なのだ。この例のコードは com.badlogic.audio.samples パッケージにある。いじってみてほしい。たとえば、AudioDevice へ書き出す前にサンプルの振幅を変えてみるとか。各サンプルに 0.5 をかければ音の大きさが半分になったりする。

<!--
I'll add some helper classes to this project to visualize the data we process/generate over the course of the series.
We'll also extend the project by some nifty analysis classes that will allow us to do proper beat detection (can you say Fast Fourier Transform?).
You will be surprised at how easy it is to do simple beat detection :)
-->

このシリーズの講義を通して、このプロジェクトへいくつかヘルパークラスを追加して、処理・生成するデータを可視化できるようにしようと思う。
また、適切なビート検出 (高速フーリエ変換とかいうやつ) を行うためにいくつかかっこいい分析用のクラスを作ってプロジェクトを拡張するつもりだ。
簡単なビート検出を行うのはあまりに簡単なので驚くことになるだろう。

<!--
Over and Out.
-->

以上！
