---
layout: post
title: "Part 7: しきい値の設定とピークの選別"
date:   2010-02-23 00:00:00
categories: onset detection tutorial
---

原文: [Onset Detection Part 7: Thresholding & Peak picking](http://www.badlogicgames.com/wordpress/?p=187)

<!--
In the last article we saw how to reduce a complex spectrum that evolves over time to a simple one dimensional function called the spectral flux. On the way we did some improvements to the spectral flux function like rectifying it and enabling Hamming smoothing of the audio samples. In this article we will talk about a so called threshold function which we derive from the spectral flux function.
-->

前の記事では時間が経つにつれ徐々に進化する複雑なスペクトラムを、スペクトラル・フラックスというシンプルな 1 次元の関数に変換する方法を見た。その途中で、整流 (rectify) したり音声サンプルのハミングによる平滑化を有効化したり、スペクトラル・フラックスの機能にいくつか改善を加えた。この記事ではスペクトラル・フラックスの機能から派生して、いわゆるしきい値の機能について論じることにしよう。

<!--
That’s a rectified, Hamming smoothed spectral flux function. It’s for an excerpt of the song “Judith” by “A Perfect Circle” and already shows quiet some peaks which we could directly interpret as onsets. However, there’s still some noise in that function, especially when the crashs are hit for example. We can’t do any better filtering, like for example smoothing out the function a bit as this would get rid of a lot of the small peaks. Instead we do something totally simple: we calculate a threshold function which is derived from the spectral flux function. This threshold function is then later used to discard spectral flux values that are noise.
-->

それは、整流 (rectify) されハミングで平滑化されたスペクトラル・フラックスの機能だ。"A Perfect Circle" の "Judith" という曲の抜粋に利用したら、音の立ち上がりとしてすぐに解釈可能ないくつかのピークが表示された。しかしながらこの機能には、たとえばクラッシュが叩かれたときなどは特に、まだいくらかノイズが混じる。たとえば少しこのサンプルを平滑化させるといった、もっとよいフィルタリングを行うことはできない。というのはたくさんの小さなピークを取り除いてしまうからだ。代わりにシンプルなことを行う。スペクトラム・フラックス機能から派生したしきい値機能を計算するのだ。このしきい値機能はのちにノイズであるスペクトラル・フラックスの値を捨てるために利用される。

<!--
The threshold function is actually pretty simple. Given our spectral flux function we calculate the mean or average value of a window around each spectral flux value. Say we have 3000 spectral flux values, each specifying the spectral flux of a 1024 sample window. 1024 samples at a sampling rate of 44100Hz equal a time span of around 43ms. The window size we use for the threshold function should be derived from some time value, say we want the average spectral flux of a time span of 0.5 seconds. That’s 0.5 / 0.043 = 11 sample windows or 11 spectral flux values. For each spectral flux value we take the 5 samples before it, 5 samples after it and the current value and calculate their average. We thus get for each spectral flux value a single value we call the threshold (for reasons that will become apearant shortly). Here’s some code that does this:
-->

しきい値機能は実際にはかなりシンプルだ。スペクトラル・フラックス機能があったとしてそれぞれのスペクトラル・フラックスの値のウィンドウの平均値を計算する。たとえば 3000 個のスペクトラル・フラックス値があり、それぞれが 1024 個のサンプル幅を持つスペクトラル・フラックスを表している。サンプリングレート 44100Hz の 1024 個のサンプルは約 43ms の時間に相当する。しきい値の機能に利用する幅のサイズはなんらかの時間の値から派生させるべきであり、たとえば 0.5 秒間のスペクトラル・フラックスの平均値がほしい。つまり 0.5 / 0.0043 = 11 個のサンプル幅、すなわち 11 個のスペクトラル・フラックス値の平均だ。それぞれのスペクトラル・フラックス値について、直前の 5 個と直後の 5 個の値と現在の値をとり、平均値を計算する。このようにしてそれぞれのスペクトラル・フラックス値についてしきい値と呼ばれる 1 の値が得られる。(その理由はすぐに明らかになる。) これを行うコードが下記だ:

{% highlight java %}
public class Threshold 
{
   public static final String FILE = "samples/explosivo.mp3";	
   public static final int THRESHOLD_WINDOW_SIZE = 10;
   public static final float MULTIPLIER = 1.5f;
	
   public static void main( String[] argv ) throws Exception
   {
      MP3Decoder decoder = new MP3Decoder( new FileInputStream( FILE  ) );							
      FFT fft = new FFT( 1024, 44100 );
      fft.window( FFT.HAMMING );
      float[] samples = new float[1024];
      float[] spectrum = new float[1024 / 2 + 1];
      float[] lastSpectrum = new float[1024 / 2 + 1];
      List spectralFlux = new ArrayList( );
      List threshold = new ArrayList( );
	
      while( decoder.readSamples( samples ) > 0 )
      {			
         fft.forward( samples );
         System.arraycopy( spectrum, 0, lastSpectrum, 0, spectrum.length ); 
         System.arraycopy( fft.getSpectrum(), 0, spectrum, 0, spectrum.length );
	
         float flux = 0;
         for( int i = 0; i < spectrum.length; i++ )	
         {
            float value = (spectrum[i] - lastSpectrum[i]);
            flux += value < 0? 0: value;
         }
         spectralFlux.add( flux );					
      }		
		
      for( int i = 0; i < spectralFlux.size(); i++ )
      {
         int start = Math.max( 0, i - THRESHOLD_WINDOW_SIZE );
         int end = Math.min( spectralFlux.size() - 1, i + THRESHOLD_WINDOW_SIZE );
         float mean = 0;
         for( int j = start; j <= end; j++ )
            mean += spectralFlux.get(j);
         mean /= (end - start);
         threshold.add( mean * MULTIPLIER );
      }
		
      Plot plot = new Plot( "Spectral Flux", 1024, 512 );
      plot.plot( spectralFlux, 1, Color.red );		
      plot.plot( threshold, 1, Color.green ) ;
      new PlaybackVisualizer( plot, 1024, new MP3Decoder( new FileInputStream( FILE ) ) );
   }
}
{% endhighlight %}

<!--
Not a lot of new things in there. First we calculate the spectral flux function as we did in the last article. Based on this spectral flux function we then calculate the threshold function. For each spectral flux value in the ArrayList spectralFlux we take the THRESHOLD_WINDOW_SIZE spectral flux values before and after it and calculate the average. The resulting mean value is then stored in an ArrayList called threshold. Note that we also multiply each threshold value by MULTIPLIER which is set to 1.5 in this example. After we finished calculating all our functions we plot them. The result looks like this:
-->

目新しいことはそんなに出てきていない。最初に前の記事でやったようにスペクトラル・フラックスの機能を計算する。それから、このスペクトラル・フラックスに基づきしきい値の機能を計算する。spectralFlux ArrayList の中のそれぞれのスペクトラル・フラックス値について THRESHOLD_WINDOW_SIZE 分の前後のスペクトラル・フラックス値をとり、平均を計算する。その結果の平均値は threshold という名前の ArrayList に保存される。それぞれのしきい値を MULTIPLIER (この例では 1.5 に設定されている) でかけていることにも注目してほしい。すべての機能の計算が終わったらプロットする。その結果は下記のようになる:

(TODO: 画像)

<!--
What we just did is calculating a running average of the spectral flux function. With this we can detect so called outliers. Anything above the threshold function is an outlier and marks an onset of some kind! It should also be clear why the threshold function values are multiplied by a constant > 1. Outliers must be bigger than the average, in this case 1.5 times bigger than the average. This multiplier is an important parameter of our onset detector as it governs the sensitivity. However, when i apply the detector to songs i try to come up with a single value that works for all of them. I actually did that and arrived at the magic 1.5 multiplier used above. It works well for all the samples that you can find in the svn as well as a lot of other songs i tested.
-->

今やったのはスペクトラル・フラックス機能の移動平均値 (running average) の計算だ。これを使えばいわゆる異常値を検出することができる。しきい値機能より高い値を持つものはなんでも異常値でありなんらかの音の立ち上がりを示している！ しきい値の機能の値を 1 より大きい値でかけている理由も明確だろう。異常値は平均値よりも大きくなければならず、この場合では平均より 1.5 倍大きくなければならない。この掛け算の値は感度をコントロールするため、音の立ち上がり検出器にとって重要なパラメーターだ。しかしながら、検出器をいくつかの曲に適用したとき、すべてでうまくいくような 1 つの値が見つけ出そうとしてみた。実際にやってみて上記で利用している 1.5 という掛け算の値に行き着いた。この値は svn で見つかるすべてのサンプルや、私がテストした他のたくさんの曲でもうまく機能した。

<!--
Now let us combine the spectral flux function and the threshold function. Basically we want a prunned spectral flux function that only contains values that are bigger or equal to the threshold function. We extend the above program by the following lines:
-->

さてスペクトラル・フラックス機能としきい値機能を連結させよう。基本的にはしきい値機能以上の値を持つ除去版スペクトラルフラックス機能がほしい。上記のプログラムを拡張し、下記の行を追加する:

{% highlight java %}
for( int i = 0; i < threshold.size(); i++ )
{
   if( threshold.get(i) <= spectralFlux.get(i) )
      prunnedSpectralFlux.add( spectralFlux.get(i) - threshold.get(i) );
   else
      prunnedSpectralFlux.add( (float)0 );
}
{% endhighlight %}

<!--
The variable prunnedSpectralFlux is just another ArrayList. The loop is pretty simple, we add zero to the prunnedSpectralFlux list of the current spectral flux is less than the corresponding threshold function value or we add the spectrul flux value minus the threshold value at position i. The resulting prunned spectral flux function looks like this:
-->

prunnedSpectralFlux 変数はただの ArrayList だ。ループは極めてシンプルで、現在のスペクトラル・フラックスが対応するしきい値機能より小さい場合には prunnedSpectalFlux に 0 を追加し、そうでない場合には i の位置のスペクトラル・フラックス値からしきい値を引いたものを追加する。結果の除去版スペクトラル・フラックス機能は下記のようになる:

(TODO: 画像)

<!--
Awesome, we are nearly finished! All that is left is to search for peaks in this prunned spectral flux. A Peak is a value that is bigger then the next value. That's all there is to peak detection. We are nearly done. Let's write the small code for the peak detection producing a peak ArrayList:
-->

すばらしい、あとちょっとで完了だ！ 残りはこの除去版スペクトラル・フラックスの中のピークを探すだけだ。ピークは次の値より大きい値のことだ。ピーク検出というのはただそれだけのことだ。ほぼ完了したようなもの。peak という ArrayList を生成するピーク検出の小さなコードを書いてみよう:

{% highlight java %}
for( int i = 0; i < prunnedSpectralFlux.size() - 1; i++ )
{
   if( prunnedSpectralFlux.get(i) > prunnedSpectralFlux.get(i+1) )
      peaks.add( prunnedSpectralFlux.get(i) );
   else
      peaks.add( (float)0 );				
}
{% endhighlight %}

<!--
And that's it. Any value > 0 in the ArrayList peaks is an onset or beat now. To calculate the point in time for each peak in peaks we simply take its index and multiply it by the time span that the original sample window takes up. Say we used a sample window of 1024 samples at a sampling rate of 44100Hz then we have the simple forumula time = index * (1024 / 44100). That's it. Here's the output:
-->

これだけだ。peaks 配列の中で 0 より大きい値はどれも音の立ち上がり、つまりビートだ。peaks の中のそれぞれのピークについて時間的な位置を計算したければ、単にインデクスをとり、元のサンプル幅が持っていた時間幅をかければよい。たとえば今回はサンプリングレート 44100Hz で 1024 個のサンプルから成るサンプル幅を使ったので、シンプルな式、時間 = インデクス * (1024 / 44100) という式で計算可能だ。それだけ。出力結果は下記の通り:

<!--
We are done. Kind off. That's the most basic onset detector we can write. Let's review some of it's properties. As with many systems we have a few parametes we can tweak. The first one is the sample window size. I almost always use 1024. Lowering this will result in a more fine grained spectrum but might not gain you much. The next parameter is wheter to use Hamming smoothing on the samples before doing the FFT on them. I did see a bit of improvement turning that on but it will also cost you some cycles calculating it. This might be of importance if you plan on doing this on a mobile device with not FPU. Every cycle saved is a good cycle there. Next is the threshold window size. This can have a huge impact on the outcome of the detection stage. I stick to a window of 20 spectal flux values in total as in the example above. This is motivated by calculating how big of a time span those 20 values represent. In the case of a sample window 1024 samples at a sampling rate of 44100Hz that's roughly have a second worth of data. The value worked well on all the genres i tested the simple detector on but your mileage may vary. The last and probably most important parameter is the multiplier for the threshold function. To low and the detector is to sensitive, to high and nothing get's cought. In my day job i sometimes have to do outlier analysis which is pretty similar to what we do here. Sometimes i use simple threshold based methods and a value between 1.3-1.6 seems to be some sort of magic number when doing statistics based outlier detection relative to some means. I'd say that the threshold multiplier and the threshold window size should be the only parameters you tweak. Forget about the rest and use the defaults of 1024 for sample window size and Hamming smoothing on. Doing a parameter seach for to many parameters is no fun so boiling it down to "only" two makes sense in this case. The defaults i gave you above work reasonably well with the detector we developed in this series. If you do multi-band analysis you might have to tweak them individually for each band.
-->

完了。ほぼ完了。これが書きうる中でもっとも基本的な音の立ち上がり検出器だ。いくつか検出器の性質を復習しよう。多くのシステムと同じように調整できるパラメーターが 2,3 個ある。最初のパラメーターはサンプル幅のサイズ。私はいつも 1024 を使う。この値を低くするともっと精緻なスペクトラムが得られるがあまり利益はないように思う。次のパラメーターは FFT を行う前にハミングによる平滑化を使うかどうか。実際これをオンにすると少し改善されることは確認したが、これはまた計算を行うのにいくらか CPU サイクルのコストがかかる。これは、FPU を持たないモバイルデバイスで音の立ち上がり検出を行う計画がある場合には重要な観点となるだろう。そのような場合では削減できる CPU サイクルはすべて削減すべきだからだ。次は、しきい値の幅のサイズ。これは検出段階での結果に甚大な影響を及ぼす。私は上記の例にもあるように、いつも合計にしてスペクトラル・フラックスの値 20 個分の幅を使うようにしている。これはその 20 個の値が表しているのがどのくらいの長さの時間なのかを計算することがモチベーションとなっている。サンプリングレート 44100Hz で 1024 サンプルのサンプル幅の場合には、だいたい a second worth (TODO) のデータだ。この値はシンプルな検出器でテストしたすべてのジャンルでうまく動いたが、読者諸君の走行距離は異なるかもしれない。最後のパラメーターがおそらくもっとも重要で、しきい値の機能のための掛け算の値である。この値を低くすると検出器が敏感になり、高くすると何も検出されなくなる。私の日々の仕事ではここでやったのにかなり似ている異常値分析をたまに行わなければならない。時々シンプルなしきい値をベースとした手法を用いるが、1.3-1.6 の間の値は、ある平均値に関連した異常値検出をベースとした統計を行うときには、ある意味マジックナンバーのように見える。しきい値の掛け算の値と、しきい値の幅の数だけがチューニングすべきパラメーターだと言ってもいいぐらいだろう。ほかは忘れて、デフォルトの通り 1024 のサンプル幅数を使い、ハミングによる平滑化をオンにしておけばよい。たくさんのパラメーターの中でどれが有効なのか探すのはぜんぜんおもしろくないし、結局のところこの場合では 2 つ「だけ」に意味があったというわけだ。上記で利用したデフォルト値はこのシリーズで開発した検出器でまあまあうまく動く。複数の周波数帯の分析を行う際には、それぞれの周波数帯でそれらの値をチューニングしなければならない。

<!--
What's left is some improvements like doing this complete process not for the whole spectrum but sub-bands so that we can do onset detection for various instruments (sort of, as we know they overlap in frequency range). Another improvement is to use overlapping sample windows, say by 50%. This smooths out the Fourier transform a bit more and gives better results. One could also try to do dynamic range compression on the whole audio signal before passing it to the FFT and so on and so forth. The code in the framework allows you to experiment easily with various additional steps. You will also want to maybe clean up the resulting peak list and remove any peaks that are to close together, say < 10ms. Learning by doing is the big mantra. Now go out and write awesome music games!
-->

いくつか改善の余地はあって、たとえばこのプロセス全体をスペクトラム全体ではなく下位の周波数帯へ適用し、さまざまな楽器の音の立ち上がり検出ができるようにすることだ。(さまざまな楽器の周波数帯が重なり合っているから、完全にやるのは難しいが。) 別の改善としては重なりあうサンプルの幅を使い、よりよい結果を得ること。FT へ渡す前に音声信号全体にダイナミックレンジ圧縮を行ってみるとか、いろいろ試すことはある。フレームワーク中のコードを使えば、さまざまな追加のステップを簡単に実験することができる。あと、結果として得られたピークの一覧を整理し、たとえば 10ms 以内とか、互いに近すぎるピークを削除したほうがいいかもしれない。

<!--
Here's a couple of papers and links i found very useful in the process of getting this to work:
-->

下記は今回の音の立ち上がり検出器をうまく動かす過程で非常に役立った論文やリンクだ:

<!--
* http://www.dspguide.com/ An awesome online book (also available as hard cover) called "The Scientist and Engineer's Guide to Digital Signal Processing" featuring anything you'll ever want to know about digital signal processing (as an engineer :)).
* https://ccrma.stanford.edu/~jos/dft/ Another online book called "Mathematics of the discrete Fourier Transform with audio applications" coping with anything related to the discrete Fourier Transform. Pretty heavy on math but a very good read.
* http://old.lam.jussieu.fr/src/Membres/Daudet/Publications_files/Onset_Tutorial.pdf A very good scientific paper called "A tutorial on onset detection for musical signals". Features various onset detection functions (we used the un-banded spectral flux here) as well as some data on the performance of various functions on a standardized data set (Mirex 2006 Onset Detection Challenge). Look out for any other papers by Bello, he's a big player in the field it seems.
* http://www.dafx.ca/proceedings/papers/p_133.pdf "Onset detection revisited" by Dixon, another big name in the field (at least it seems so from the citation counts, but we all know how much they really tell you...). Very good paper, must read.
-->

* [http://www.dspguide.com/](http://www.dspguide.com/) すばらしいオンライン書籍 (ハードカバーでも購入可能) "The Scientist and Engineer's Guide to Digital Signal Processing" (エンジニアとして :)) デジタル信号処理について知りたいと思うようなことはなんでもフィーチャーされている。
* [https://ccrma.stanford.edu/~jos/dft/](https://ccrma.stanford.edu/~jos/dft/) もう 1 つのオンライン書籍 "Mathematics of the discrete Fourier Transform with audio applications" 離散フーリエ変換に関することならなんでも使っている。かなり数学寄りだが読むと非常に参考になる。
* [http://old.lam.jussieu.fr/src/Membres/Daudet/Publications_files/Onset_Tutorial.pdf](http://old.lam.jussieu.fr/src/Membres/Daudet/Publications_files/Onset_Tutorial.pdf) 非常に品質のよい科学論文 "A tutorial on onset detection for musical signals" さまざまな音の立ち上がり検出の機能がフィーチャーされているし (今回は un-banded (TODO) スペクトラル・フラックスを利用した) some data on the performance of various functions on a standardized data set (Mirex 2006 Onset Detection Challenge). Bello はこの分野でのビッグ・プレイヤーらしいので、ほかの論文も探してみるとよい。
* [http://www.dafx.ca/proceedings/papers/p_133.pdf](http://www.dafx.ca/proceedings/papers/p_133.pdf) Dixon の "Onset detection revisited" このフィールドのもう一人のビッグネームだ。 (少なくとも引用の数からはそう見えるのだが、知っての通り引用の数というのは非常に重要だ…) 非常に良い論文、必読。

<!--
If you check out the citation graph of the two papers mentioned on google schoolar you will many more papers talking about onset detection that might interest you. Google *is* your friend in this case. Always read your fine papers!
-->

Google Scholar で上記 2 つの論文の引用グラフをチェックすれば、あなたの興味を引く論文がもっと見つかるはずだ。こんなときは Google **が**頼りになる。いつでもよい論文を読もう！
