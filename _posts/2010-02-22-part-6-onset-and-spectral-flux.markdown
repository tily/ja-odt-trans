---
layout: post
title: "Part 6: 音の立ち上がりとスペクトラル・フラックス"
date:   2010-02-22 00:00:00
categories: onset detection tutorial
---

原文: [Onset Detection Part 6: Onsets & Spectral Flux](http://www.badlogicgames.com/wordpress/?p=161)

<!--
In an earlier post i talked about the scientific view of onset/beat detection. There’s a lot of different schemes out there that do the job more or less well. However, one approach was so intriguingly simple and performed so well compared to other more elaborate algorithms that i chose to use it for my purposes. It’s called spectral flux or spectral difference analysis and i’ll try to give you an insight of it workings in this article.
-->

今までの投稿では音の立ち上がり/ビート検出について科学的な観点から説明してきた。この目的を果たすのにもっとうまくやれたり、あまりうまくやれなかったりするスキーマはもっとたくさん存在する。しかし、ある方法が謎なほどシンプルでほかのもっと精緻なアルゴリズムよりうまく動いたので、私はこのアルゴリズムを選んだ。それがスペクトラル・フラックスまたはスペクトラルディファレンス解析というものであり、この記事ではこのアルゴリズムについて洞察しよう。

<!--
One of the best papers on the matter of onset detection is by Bello at al. which you can view here. I’ll review some of the concepts mentioned in there here and will steal a couple of images.
-->

音の立ち上がり検出というテーマについての最高の論文の 1 つは Bello その他によるものだ。[ここ](http://old.lam.jussieu.fr/src/Membres/Daudet/Publications_files/Onset_Tutorial.pdf)で読める。ここではこの論文で言及された概念のいくつかについて説明し、何個かの画像を転用させてもらう。

<!--
First of what is an onset? Looky:
-->

最初に音の立ち上がりとは何だ？ 下記を見てほしい:

(TODO: 画像)

<!--
At the top we see the sample amplitudes or wave form of a single note. The onset is the first thing to happen when playing a note, followed by an attack until it reaches its maximum amplitude followed by a decay phase. I refrain from defining the transient as it is of no concern for us.
-->

一番上には 1 つの音のサンプルの振幅、つまり波形が見られる。音の立ち上がりは 1 つの音を演奏するときに最初に起こることであり、そのあと振幅が最大値に達するまでアタックが起こり、そのあとディケイが続く。今回はあまり関係ないのでトランジェントについては定義するのは差し控えておく。

<!--
The audio signals we want to process are of course a tiny bit more complex than a single note. We want to detect onsets in polyphonic music containing pitched instruments like guitars or violins, vocals and non pitched drums. As we have seen in the frequency chart a couple of articles back most of the pitched instruments overlap in their frequency range (mostly between 70Hz and 4000Hz). Perfect onset detection is thus impossible, however we can try to get an approximate estimation.
-->

私たちが処理したい音声信号はもちろん 1 つの音よりほんの少し複雑だ。ギターやバイオリン、ボーカルのように調性のある楽器、調性のないドラムを含む多声的な音楽から音の立ち上がりを検出したいのだ。2, 3 個前の記事で見た周波数チャートから分かるように、調性のある楽器は周波数の範囲 (たいていは 70Hz～4000Hz) において重なり合っている。それゆえ完璧な音の立ち上がり検出は不可能だが、近似的な見積もりを得るために試行することは可能だ。

<!--
From what i could gather from the papers i read on the topic onset detection almost always follows the same schema. First you read in your audio signal, next you transform it to a onset detection function (just another array of floats corresponding to your original audio samples in some way) and finally you pick the peaks in this detection function as onsets/beats. The first stage we already talked about and it turned out to be pretty easy. The second stage of the process is often pretty elaborate doing some magic to transform the audio signal into another simpler, compressed one dimensional function. The last stage is not covered in detail in most of the literature. However, while i was working on a prototype it turned out that this stage is probably the most important one, even more important than the onset detection function calculation. In a future article we’ll concentrate on peak detection, for now let’s stick to onset detection functions.
-->

このトピックに関する複数の論文を読んでみた知識から総合すると、音の立ち上がり検出はいつも同じスキーマに従っている。最初に音声信号を読み込み、次にそれを音の立ち上がり検出用の関数に変換し (元々の音声信号になんらかのやり方で対応しているもう一つの float 配列に過ぎない)、最後にこの検出用の関数からピークを選び出しそれを音の立ち上がり/ビートとする。最初の段階についてはすでに説明し非常に簡単であることが分かった。処理の第二の段階はたいていかなり複雑で、なんらかの魔法を使い音声信号をもう 1 つのよりシンプルな、圧縮された 1 次元の関数に変換する。最後の段階についてはほとんどの文献で詳細まで論じられていない。しかし、プロトタイプを作りながら気づいたのは、この段階がおそらくはもっとも重要で、音の立ち上がり検出の関数による計算よりも重要かもしれないということだった。今後の記事ではピーク検出にも集中するが、今は音の立ち上がり検出の関数に専念しよう。

<!--
Here’s a nice little chart for the general process of onset detection, again taken from Bello et al.
-->

下記は音の立ち上がり検出の一般的な過程を説明した小さな表だ。再び Bello et al から拝借した。

(TODO: 画像)

<!--
The pre-processing stage could for example do dynamic range compression, that is making everything equally loud, a shitty habit used in almost all mixes of modern day music. However shitty DRC might sound it is benefial for some onset detection functions. We won’t use one that benefits from it so we don’t care for pre-processing.
-->

処理の前段階としてたとえばダイナミックレンジ圧縮 (dynamic range compression, DRC) を行う。これはすべてを同じ音量まで高めることであり、今日の音楽のミックスのほとんどすべてで利用されているつまらない習慣だ。しかし、DRC をつまらなく感じたとしても、それはいくつかの音の立ち上がり検出の関数にとっては有益である。今回は DRC から恩恵を受けるような関数は使わないので、処理の前段階については気にしないことにする。

<!--
The reduction phase is equal to constructing the onset detection function. The goal of this stage is it to get a compressed view of the structure of the musical signal. The onset detection function should be able to catch musical events and make it easier to detect onsets as compared to trying that on the plain wave form of the audio signal. The output of the onset detection function are values indicating the presence or absence of a musical event for successive time spans. Remember how we read in samples for playback. We read in 1024 samples in each iteration. For such a sample window an onset detection function would output a value. For one second of music sampled at 44100Hz and using 1024 samples as the time span for the onset detection function we’d get roughly 43 values (44100/1024) that model the structure of the audio signal. Coincidentially the sample window size of 1024 can be processed by our FFT class. To summarize: generating the values of the onset detection function means calculating a value for each successive sample window which gives us a hopefully nice curve we perform peak detection on.
-->

縮小の段階は音の立ち上がり検出の関数を作ることに等しい。この段階におけるゴールは、音楽信号の構造について圧縮された概観を取得することだ。音の立ち上がり検出の関数は、音楽的なイベントを補足し、音声信号のそのままの波形で試すのより簡単に音の立ち上がりを検出できるべきだ。音の立ち上がり検出の関数の出力は、連続する時間の範囲の中に音楽的なイベントが存在するか不在かを示す値である。どうやって再生のためにサンプルを読み込んだかを思い出してほしい。イテレーションの中で 1024 個ずつサンプルを読み込んだ。このようなサンプル幅に対して音の立ち上がり検出の関数は値を出力する。44100Hz でサンプルされた 1 秒の音楽で、時間の範囲に 1024 個のサンプルを用いるなら、音声信号の構造をモデル化しただいたい 43 個 (44100/1024) の値が取得されるだろう。偶然にも 1024 個のサンプル幅なら、FFT クラスで処理することができる。要約すると: 音の立ち上がり検出の関数による値の生成とは、連続したサンプル幅ごとの値を計算することであり、それはピーク検出を行うためのすばらしい曲線をもたらすはずだ。

<!--
Now, i introduced the FFT in the last article so we are going to use it for generating the onset detection function. What’s the motivation for this? Listen to the following excerpt from “Judith” by “A Perfect Circle” and have a look at the image below:
-->

さて、前回の記事で FFT については紹介したので、音の立ち上がり検出の関数を生成するために使ってみよう。これをやる動機はなんだろう？ 下記の "A Perfect Circle" の "Judith" からの抜粋を聴き、下記の画像を見てみてほしい:

(TODO: 音声ファイル)

(TODO: 画像)

<!--
The image depicts the spectra of successive 1024 sample windows of the audio signal. Each vertical pixel colum corresponds to one spectrum. Each pixel in a column stands for a frequency bin. The color tells us how much this frequency bin contributes to the audio signal in the sample window the spectrum was taken from. The values range from blue to red to white, increasing in that order. For reference the y-axis is labeled with the frequencies, the x-axis is labeled with the time. And holy shit batman we can see beats! I took the freedom to mark them with awesome arrows in Paint. The beats are visible only in the high frequency range from a bit about 5000Hz to 16000Hz. They correspond to the hi-hat being played. When you hit a hi-hat it produces something called white noise, a sound that spans the compelte frequency spectrum. Compared to other instruments it has a very high energy when hit. And we can clearly see that in the spectrum plot.
-->

画像には連続する 1024 サンプル幅の音声信号スペクトラムが描かれている。縦に見たピクセルの 1 カラム 1 カラムは 1 つのスペクトラムに対応している。カラムの中のそれぞれのピクセルは周波数ビンを表している。色によってその周波数ビンがスペクトラムが抽出されたサンプル幅中の音声信号にどのくらい貢献しているかが分かる。色の値の範囲は青から赤を経過して白までであり、この順に貢献が強くなる。参照用に y 軸には周波数のラベル、x 軸には時間のラベルをつけてある。そしてなんとビートが見てとれるではないか！ 気ままにペイントで矢印のマークをつけてみた。ビートは 5000Hz から 16000Hz あたりの高い周波数帯にしか見られない。これらはハイハットが叩かれるタイミングに対応している。ハイハットを叩くといわゆるホワイトノイズ、周波数スペクトラムのすべてまたがる音が出る。他の楽器に比べるとハイハットは叩くときに非常に強いエネルギーを持っている。これもスペクトラムのプロットの中にはっきりと確認することができる。

<!--
Now, processing this spectrum plot wouldn’t be a lot easier than going for the wave form. For comparison here’s the waveform of the same song excerpt:
-->

さて、このスペクトラムのプロットを処理するにしても、元の波形を処理しようとするのに比べてそんなに簡単ではない。比較のために、下記に同じ曲の抜粋の波形を示す：

(TODO: 画像)

<!--
We can see the hi-hat hits in the waveform too. So what’s the benefit of going to Fourier transform route? Well, it allows us to focus on specific frequencies. For example, if we are only interested in detecting the beats of the hi-hat or the crash or ride we’d go for the very high frequency range only as this is were those instruments will leave a note of their presence. We can’t do that with the amplitudes alone. The same is true for other instruments like the kick drum or the bass which we’d look for in the very low frequencies only. If we inspect multiple frequency ranges of the spectrum seperately we call it multi-band onset detection. Just to give you some keywords for Mr. Google.
-->

波形でもハイハットが打たれたところは分かる。それではフーリエ変換という方法を経由する利点はなんだろう？ それは特定の周波数に焦点を当てることができるということだ。たとえば、ハイハットまたはクラッシュまたはライドのビートだけを検出することに興味があるのなら、非常に高い周波数だけに注目すればよい。これらの楽器はそのような周波数にのみ存在感のある音を残すからだ。振幅だけではこのようなことはできない。楽器にも同じことが言えて、キックドラムやベースなら低い周波数だけに注目すればよい。複数の周波数帯のスペクトラムを別々に調査するのは、複数帯音の立ち上がり検出 (multi-band onset detection) と呼ばれている。このキーワードが気になったらググってみるとよい。

<!--
So we know why we do our onset detection in the frequency domain but we are not any wiser on how to compress all the information of the spectrum plot to a managable one dimensional array of floats we can easily do peak detection on. Let me introduce you to our new best friend the spectral difference vulgo spectral flux. The concept is incredibly simple: for each spectrum we calculate the difference to the spectrum of the sample window before the current spectrum. That’s it. What we get is a single number that tells us the absolute difference between the bin values of the current spectrum and the bin values of the last spectrum. Here’s a nice little formula (so i get to use the latex wordpress plugin):
-->

このようになぜ周波数領域で音の立ち上がり検出を行うべきなのかは分かったが、スペクトラムのプロットに含まれるすべての情報を圧縮して、ピーク検出をしやすい管理可能な 1 次元配列にする方法についてはまだ分かっていない。ここで新しい我々のベストフレンドであるスペクトラル・ディファレンスまたはスペクトラル・フラックスを紹介しよう。コンセプトは信じられないぐらいにシンプルだ: スペクトラムのそれぞれに対して現在のスペクトラムより 1 つ前の同じサンプル幅のスペクトラムとの差を計算する。それだけ。これによって得られるのは現在のスペクトラムのビン値と、1 つ前のスペクトラムのビン値との絶対値としての差を表す 1 つの数だ。これがそのいい感じの数式だ (数式を書くために wordpress の latex プラグインを使うことになった):

```math
SF(k) =\displaystyle \sum_{i=0}^{n-1} s(k,i) – s(k-1,i)
```

<!--
SF(k) gives us the spectral flux of the kth spectrum. s(k,i) gives us the value of the ith bin in the kth spectrum, s(k-1,i) is analogous for the spectrum before k. We substract the values of each bin of the previous spectrum from the values of the corresponding bin in the current spectrum and sum those differences up to arrive at a final value, the spectral flux of spectrum k!
-->

SF(k) は k 番目のスペクトラムについてのスペクトラル・フラックスを表す。s(k,i) は k 番目のスペクトラム i 番目のビンの値を示し、s(k-1,i) は k の前のスペクトラムについて i 番目のビンを表す。現在のスペクトラムのビンから、前のスペクトラムの対応するそれぞれのビンを引き、最後の値にたどりつくまでその差を足していけば、それがスペクトラム k のスペクトラム・フラックスだ。

<!--
Let’s write a small program that calculates and visualizes the spectral flux of an mp3:
-->

ある mp3 ファイルのスペクトラル・フラックスを計算して可視化する小さなプログラムを書いてみよう:

{% highlight java %}
public class SpectralFlux 
{
   public static final String FILE = "samples/judith.mp3";	
	
   public static void main( String[] argv ) throws Exception
   {
      MP3Decoder decoder = new MP3Decoder( new FileInputStream( FILE  ) );							
      FFT fft = new FFT( 1024, 44100 );
      float[] samples = new float[1024];
      float[] spectrum = new float[1024 / 2 + 1];
      float[] lastSpectrum = new float[1024 / 2 + 1];
      List spectralFlux = new ArrayList( );
		
      while( decoder.readSamples( samples ) > 0 )
      {			
         fft.forward( samples );
         System.arraycopy( spectrum, 0, lastSpectrum, 0, spectrum.length ); 
         System.arraycopy( fft.getSpectrum(), 0, spectrum, 0, spectrum.length );
			
         float flux = 0;
         for( int i = 0; i < spectrum.length; i++ )			
            flux += (spectrum[i] - lastSpectrum[i]);			
         spectralFlux.add( flux );					
      }		
				
      Plot plot = new Plot( "Spectral Flux", 1024, 512 );
      plot.plot( spectralFlux, 1, Color.red );		
      new PlaybackVisualizer( plot, 1024, new MP3Decoder( new FileInputStream( FILE ) ) );
   }
}
{% endhighlight %}

<!--
We start of by instantiating a decoder that will read in the samples from an mp3 file. We also instantiate an FFT object telling it to expect sample windows of 1024 samples and a sampling rate of 44100Hz. Next we create a float array for the samples we read from the decoder. We use a window size of 1024 samples. The next two lines instantiate auxiliary float arrays that will contain the current spectrum and the last spectrum. Finally we also need a place to write the spectral flux for each sample window to, an ArrayList will do the job here.
-->

まず mp3 ファイルからサンプルを読み込むデコーダーのインスタンスを生成する。また、FFT のオブジェクトも生成し、1024 個のサンプル幅と 44100Hz のサンプリングレートを設定する。次にデコーダーから読み込むサンプルを保存するための float 配列を作成する。幅の数には 1024 個のサンプルを使う。次の 2 行では現在のスペクトラムと 1 つ前のスペクトラムを保存するための補助的な float 配列を生成する。最後にそれぞれのサンプル幅に対するスペクトラム・フラックスを書き込むための場所も必要であり、ここでは ArrayList がその役割を果たす。

<!--
The following loop does the nasty job of calculating the spectral flux'. First we read in the next 1024 samples from the decoder. If that succeeded we calculate the Fourier transform and spectrum of this sample window via a call to fft.forward(samples). We then copy the last current spectrum to the array lastSpectrum and the spectrum we just calculated to the array spectrum. What follows is the implementation of the formula above. For each bin we substract the value of the last spectrum's bin from the current spectrum's bin and add it to a sum variable called flux. When the loop has finished flux contains... the spectral flux of the current spectrum. This value is added to the spectralFlux ArrayList and we continue with decoding the next sample window. We repeat this for each sample window we can read in from the decoder. After the loop is done spectralFlux contains a spectral flux for each sample window we read in. The last three lines just create a plot and visualize the result. Note: i created a small helper class called PlaybackVisualizer which takes a plot, the number of samples per pixel and a decoder that will playback the audio fromt he decoder while setting the marker in the plot correspondingly. Nothing to complex, we saw how to do that in one of the earlier articles. Here's the output for the song "Judith" we used above already:
-->

次のループの中ではスペクトラム・フラックスを計算する汚い仕事を行っている。最初にデコーダーから次の 1024 サンプルを読み込む。それが成功したら fft.forward(samples) の呼び出しによりこのサンプル幅に関するフーリエ変換とスペクトラムの計算を行う。それから直前のスペクトラムを lastSpectrum 配列にコピーし、今計算したばかりのスペクトラムを spectrum 配列へコピーする。そのあとに続くのは上記の公式の実装だ。それぞれのビンについて現在のスペクトラムのビンから直前のスペクトラムのビンの値を引き、flux という名前の合計を保持する値に足す。ループが終わると flux には現在のスペクトラムのスペクトラル・フラックスが含まれている。この値は spectralFlux ArrayList に追加され、続けて次のサンプル幅のデコード処理が行われる。これをデコーダーから読み込んだそれぞれのサンプル幅に対して繰り返す。ループが終わると spectralFlux には読み込んだそれぞれのサンプル幅に対するスペクトラル・フラックスが含まれる。最後の 3 行でプロットを作成し、結果を可視化している。注意: PlaybackVisualizer という名前の小さなヘルパークラスを作成した。このクラスはプロットと、ピクセル毎のサンプルの数と、デコーダーを引数に取り、デコーダーから受け取った音声を再生しつつ、再生時間に合わせてプロットの中にマーカーを設定してくれる。何も複雑なことはなく、やり方は前の記事で見た。下記は上でもすでに利用した "Judith" という曲の出力結果だ:

![](http://i.gyazo.com/a26a2a334b1442ed569aa9f842452d10.png)

<!--
Hurray! we can again see peaks. This time they not only correspond to the hi-hat but also to the snare and the kick drum. The reason for this is that use the complete spectrum so the spectral flux values are governed by the instruments that have the most energy, in this case hi-hat, snare and kick drum. Now let's review what we just did. Take the original spectrum image from above were i marked the hits of the hi-hat. What the code does is essentially creating a sum over the differences of the bins of two successive spectra. When the current spectrum has more overall energy than the previous spectrum the spectral flux function will rise. If the current spectrum has less energy than the previous spectrum the spectral flux function will fall. So we successfully mapped the 2D spectrum plot to a 1D function we can perform peak detection on. Well, sort of...
-->

バンザイ！ またピークが確認できた。今度はハイハットだけでなくスネアやキックドラムに対応している。これは、完全なスペクトラムを使うとスペクトラル・フラックスの値がもっともエネルギーのある楽器、この場合はハイハット・スネア・キックドラムに支配されるからだ。今やったことの復習をしよう。上記の元々のスペクトラムをとってきてハイハットのヒットをマークしてみた。コードがしているのは本質的には 2 つの連続したスペクトラムのビンの差を合計することだ。現在のスペクトラムが前のスペクトラムより全体として大きいエネルギーを持っているとき、スペクトラル・フラックスは上昇する。現在のスペクトラムが前のスペクトラムより小さなエネルギーしか持っていないときにはスペクトラル・フラックスは下降する。よって 2 次元のスペクトラムのプロットをピーク検出を実行できる 1 次元の機能にマッピングできたわけだ。どんな形にせよ。

<!--
Before we do any peak detection we have to clean up the spectral flux function a little bit. Let's start with ignoring negative spectral flux values. We are not interested in falling spectral flux but only in rising spectral flux. The process of ignoring the spectral flux values that are negative is called rectifying. Here's the modified loop for calculating the spectral flux:
-->

ピーク検出を行う前にスペクトラル・フラックス関数を少しだけ整理しなければならない。スペクトラル・フラックスの値が負の数のとき無視するようにすることからはじめよう。降下するスペクトラル・フラックスではなく、上昇するスペクトラル・フラックスにだけ興味があるからだ。負のスペクトラル・フラックスの値を無視するプロセスは「整流」(rectifying) と呼ばれる。これがスペクトラル・フラックスを計算するループを修正したものだ。

{% highlight java %}
   float flux = 0;
   for( int i = 0; i < spectrum.length; i++ )			
   {
      float value = (spectrum[i] - lastSpectrum[i]);			
      flux += value < 0? 0: value;
   }
   spectralFlux.add( flux );
{% endhighlight %}

<!--
And the corresponding output:
-->

そしてこれに対応する出力がこれ:

![](http://i.gyazo.com/6365b7287a180ee3d9ff2582ecc9cbe6.png)

<!--
A bit nicer. Rectifying the spectral flux will aid us when we calculate the a threshold function for peak detection.
-->

ちょっとだけ良くなった。スペクトラル・フラックスを修正したのでピーク関数のためにしきい値を計算するのが楽になるだろう。

<!--
Another clean up process is using a so called Hamming window. This Hamming window is applied to the samples before calculating the Fourier transform. It's basically a smoothing function that will make our samples look a bit nicer. The FFT class has a function by which we can enable Hamming window smoothing:
-->

もう 1 つ整理するプロセスとしていわゆるハミング窓を使う。このハミング窓というのはフーリエ変換の計算を行う前にサンプルに適用される。これはサンプルをちょっとよくする平滑剤のような役割を果たす。FFT クラスはハミング窓による平滑化を有効にする機能を持っている。

{% highlight java %}
fft.window(FFT.HAMMING);
{% endhighlight %}

<!--
That's all there is to do, here's the result:
-->

やるべきことはすべて終わった。これが結果だ:

![](http://i.gyazo.com/55d499ad7f43a6b235760836e3d03146.png)

<!--
Not a big difference but we can see how it equalizes the first 4 hits a little bit while removing one at the end of the sample. In other songs the hamming window has a bigger effect on the resulting spectral flux but it's really up to you wheter to use it or not. It doesn't cost a lot of performance.
-->

そんなに大きな違いはないが最初の 4 つのヒットが少し均質化 (TODO) されたのと、サンプルの最後の 1 つのヒットが除去されたのが分かる。他の曲ではハミング窓はスペクトラル・フラックスに対してより大きな効果を持つことがあるが、使うかどうかはあなた次第だ。大幅にパフォーマンスを犠牲にしてしまうようなことは起こらない。

<!--
With this i want to conclude this article. We have seen how to go from samples to spectrums to calculating a 1D function that we'll later use to detect the peaks and therefore onsets in an audio signal. From the images above we can already see a lot of peaks which seem easy to detect. In the next article we'll go a step further and calculate the spectral flux of different frequency bands. By this we hope to be able to extract various instruments as oposed to focusing on the loudest thing in the complete spectrum. We'll also employ a technique called hopping where we calculate the spectral flux not on overlapping successive sample windows instead of non-overlapping sample windows. This will further smooth the resulting spectral flux function a little bit. We are then ready to create a simple but effective peak detector that gives us the final onset times.
-->

これをもってこの記事を締めくくろうと思う。サンプルからはじめて、スペクトラムを計算し、ゆくゆくはピーク、すなわち音声信号における音の立ち上がりを検出するために使う 1 次元配列を計算する方法を見てきた。上記の画像から、容易に検出できそうなたくさんのピークがすでに分かると思う。次の記事では 1 ステップ進んでさまざまな周波数帯のスペクトラル・フラックスを計算する。これによりスペクトラム全体で一番大きな音量の楽器にフォーカスするのではなく、さまざまな楽器を抽出できればよいと思う。また、ホッピングと呼ばれるテクニックを利用し、重なり合わないサンプル幅ではなく、重なり合う連続したサンプル幅でのスペクトラム・フラックスを計算してみる。この結果としてスペクトラル・フラックスの機能がもう少し平滑になるだろう。それだけやれば最終的な音の立ち上がり時間を教えてくれるシンプルだが効果的なピーク検出器を作る準備は完了だ。

<!--
As always you can find all the source code at http://code.google.com/p/audio-analysis/. Over and out.
-->

いつも通り、すべてのソースコードは [http://code.google.com/p/audio-analysis/](http://code.google.com/p/audio-analysis/) で見つかる。以上。
