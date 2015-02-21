---
layout: post
title: "Part 5: (離散)フーリエ変換"
date:   2010-02-22 00:00:00
categories: onset detection tutorial
---

原文: [Onset Detection Part 5: The (Discrete) Fourier Transform](http://www.badlogicgames.com/wordpress/?p=154)

<!--
Warning: this is how i understood the discrete Fourier transform which might be wrong in a couple of places. For a correct explanation of the fourier transform i suggest reading http://www.dspguide.com/ch8.htm
-->

警告: ここに書いてあるように私は離散フーリエ変換を理解したが何箇所かには誤りがあるかもしれない。フーリエ変換の正しい説明については [http://www.dspguide.com/ch8.htm](http://www.dspguide.com/ch8.htm) を読むことをおすすめする。

<!--
So finally we’ve come to the dreaded Fourier transform article. Let’s review some of the things we already know. The first thing to remember is that our audio data was fetched from some kind of recording device or synthesized digitally. In any case what we have is measurements of amplitudes for discrete points in time which we call samples. We can either have mono or stereo samples, in the later case we just have two samples per point in time instead of only one. The sample frequency is the number of samples we measured per second (for stereo we count both samples for the left and right channel as a single one in this case). Here’s 1024 samples of the note A (440Hz) at a sampling rate of 44100Hz :
-->

とうとう恐れていたフーリエ変換の記事までたどり着いてしまった。すでに知っていることをいくつか復習しておこう。最初に思い出してほしいのは、オーディオデータがなんらかの録音デバイスから取得されるか、デジタル合成されるということだ。どのような場合でも、私たちがそのデータというのは時間軸上の離散した点ごとに計測された振幅であり、それをサンプルと呼ぶ。サンプルにはモノラルのものもステレオのものもあり、後者の場合、1 つの点ごとに 1 つだけでなく 2 つのサンプルが存在する。サンプリングレート 44100Hz で A の音 (440Hz) の 1024 個のサンプルはこんな感じ:

(TODO: 画像)

<!--
Note: the vertical line to the left is not part of the actual image. It’s wordpress fucking up
-->

注意: 左側の縦の線は実際の画像の一部ではない。wordpress のせいでこうなっている。

<!--
1024 samples at a sampling rate of 44100Hz equals a time span of 43,07ms. From this image we can see that the samples form something that resembles a sine wave pretty much. And in fact the samples were generated using Math.sin() as we did in the first article of this series, confirming that sound is nothing but a mixture of sine waves of different frequency and amplitude.
-->

サンプリングレート 44100Hz の 1024 個のサンプルは時間で言うと 43.07ms の範囲に等しい。この画像からサイン波に非常によく似たサンプルだということが分かる。そして実際このサンプルはこのシリーズの最初に記事でやったように Math.sin() を使って生成したものだ。その記事では音というのは異なる周波数と振幅を持ったサイン波を合成したものにすぎないということを確証していた。

<!--
A smart mathemagicion called Fourier once proposed the theorem that all possible functions could be approximated by a series of so called sinusoids, that is sine waves with different frequencies and amplitudes (actually Gauss already knew this but Fourier got the fame).  He did all this magic for so called continuous functions which you will remember from your analysis course in school (you do remember analysis, right?). This was extended to discrete functions and guess what, our samples are just that, a discrete function in time. Now, a Fourier transform decomposes a signal into a set of sinusoids with different frequencies and amplitudes. If we apply a Fourier transform to a discrete audio signal we get the frequency domain representation of our time domain audio signal. This transform is invertable, so we can go one or the other way. From now on we only consider discrete Fourier transforms on audio signals to not overcomplicate matters.
-->

フーリエという賢い数学者がかつてこのような理論を提唱した。「可能なかぎりすべての関数はいわゆる いわゆるシヌソイド、つまり異なる周波数と振幅を持つサイン波で近似することができる。」 (実際にはガウスがすでにこのことを知っていたが名声を得たのはフーリエだった。) 彼はこの魔法をいわゆる連続関数のために考えた。連続関数というのは学校の解析コースでやったので覚えているだろう。(解析のことは覚えているよな？)  これは離散関数へと拡張されたのであり、そして聞いてくれ、私たちのサンプルもゆくゆくは離散関数にすぎないのだ。さて、フーリエ変換は 1 つの信号を異なる周波数と振幅を持つシヌソイドの集合へ分解する。フーリエ変換を離散的な音声信号へ当てはめれば、時間領域の音声信号に対する周波数領域の表現が得られる。この変換は可逆なので、分解することも合成することも可能だ。ここからは音声信号に関するあまり複雑ではない事柄に対しての離散フーリエ変換についてのみ考えることにする。

<!--
What does the frequency domain of our time domain signal tell us? Well, put simply it tells us what frequencies contribute how much to the time domain signal. A frequency domain signal can thus tell us wheter there’s the note a at 440Hz in the audio signal and how loud this note is in respect to the complete tune. This is pretty awesome as it allows us to investigate specific frequencies for our beat detection purposes. From the frequency chart of the last article we know that various instruments have different frequencies they can produce. If we want to focus on say singing we’d have a look at the frequency range 80Hz to 1000Hz for example. Of course instruments overlap in their frequency ranges so that might lead to some problems. But we’ll care for that later.
-->

時間領域の信号の周波数領域というのは何を教えてくれるだろうか？ ふむ、簡単に説明すればそれはどの周波数が時間領域の信号に対してどのくらい貢献しているかを教えてくれる。すなわち周波数領域の信号は音声信号の中に 440Hz の音が存在するかと、すべての音に比べてその音がどのくらいの音量なのかを教えてくれる。これは非常に素晴らしいことである。というのはビート検出のために特定の周波数を詳しく調べることができるからだ。前の記事の周波数チャートから、さまざまな楽器がそれぞれ異なる周波数の音を出すということは分かっている。たとえば歌に焦点を合わせるなら、80Hz から 1000Hz の範囲の周波数を見ることになるだろう。もちろんさまざまな楽器の周波数の範囲が重なりあっているから、いくつか問題はあるだろう。しかしこれについてはあとで気にすればよい。

<!--
Now, what we’ll use for our frequency analysis is called the discrete Fourier transform. Given a discrete time signal, e.g. samples measured at a specific sampling rate we get a discrete frequency domain out. As an intermediate stage we get the so called real and imaginary part of the frequency domain. There is some scary terms in the last sentence so let’s just go over that quickly. The fourier transform decomposes a time signal into coefficients for sinusoids. The real part holds the Fourier coefficients for cosines of specific frequencies (a cosine is a sinusoid) as well as for the sines of the same frequencies. For our use case this representation is not all that important. What we will use is the so called spectrum which is calculated from the real and imaginary parts of the original fourier transform.  The spectrum tells us for each frequency how much the frequency contributes to the original time domain audio signal. From now on we assume that we already have calculated this spectrum, which in the framework is done by a class called FFT (taken from Minim) which relieves some of the pain.  If you want to understand how to go from the real and imaginary parts of the original Fourier transform to the spectrum read the link above.
-->

さて、これから周波数分析に利用するのは離散フーリエ変換というものだ。離散的な時間軸の信号、たとえば特定のサンプリングレートで計測されたサンプルがあれば、離散的な周波数領域を得ることができる。中間段階として、周波数領域のいわゆる実部と虚部を得る。1 つ前の文にはいくつかこわい用語が出てきたが、とりあえずさっさと終わらせよう。フーリエ変換は時間軸上の信号をサイン波の係数へ分解する。実部には特定の周波数のコサイン (コサインはシヌソイド) に関するフーリエ係数と、同じ周波数のサインに関するフーリエ係数を持つ。今回のユースケースではこの表現方法はまったく重要ではない。これから使うのは元のフーリエ変換の実部と虚部から計算される、いわゆるスペクトラムである。スペクトラムはそれぞれの周波数で元の時間領域の音声信号に対してその周波数がどれだけ貢献しているかを教えてくれる。これからはこのスペクトラムを計算済のものとする。計算はフレームワークの中の FFT というクラス (Minim から拝借した) が行ってくれるので、苦痛を緩和してくれる。元のフーリエ変換の実部・虚部からスペクトラムをどう計算していければいいかを理解したいなら、上記のリンクを読んでほしい。

<!--
Not all possible frequencies will be present in the spectrum due to the discrete nature of the transform. Frequencies are binned, that is multiple frequencies are merged together into a single value. Also, there’s a maximum frequency the discrete Fourier transform can give us which is called the Nyquist frequency. It is equal to half the sampling rate of our time domain signal. Say we have an audio signal sampled at 44100Hz the Nyquist frequency is 22050Hz. When we transform the signal to the frequency domain we thus get frequency bins up to 22050Hz. How many of those bins are there? Half the number of samples plus one bin. When we transform 1024 samples we get 513 frequency bins each having a bandwidth (range of frequencies) of the Nyquist frequency divided by the number of bins except for the first and last bin which have half that bandwidth. Say we have 1024 samples we transform, sampled at 44100Hz. The first bin will represent frequencies 0 to 22050 / 513 / 2~ 21.5Hz (remember, the first bin has half the normal bandwidth). The next bin will represent the frequencies from 21.5Hz to 21.5Hz plus 22050 / 513 ~ 43Hz == 64.5 Hz (one more time, 21.5Hz to 64.5Hz, bandwidth is 43Hz). The next bin ranges from 64.5Hz to 107.5Hz and so on and so forth.
-->

変換が離散的な性質を持つため、スペクトラムに可能な限りすべての周波数が存在するわけではない。周波数はビンになる、つまり複数の周波数が 1 つの値にマージされている。また、離散フーリエ変換によって得られる周波数には最大値が存在し、これはナイキスト周波数と呼ばれる。それは時間領域の信号のサンプリングレートの半分に等しい。たとえば 44100Hz でサンプルされた音声信号なら、ナイキスト周波数は 22050Hz である。それゆえ信号を周波数領域へと変換するとき、22050Hz までの周波数のビンが得られる。どのくらいの数の周波数のビンが含まれるだろうか？ サンプルの数の半分に 1 を足した数だ。1024 個のサンプルを変換すると 513 個の周波数のビンが得られ、それぞれはナイキスト周波数をビンの数で割った帯域幅 (周波数の幅) を持つ。例外として最初と最後のビンだけはその半分の帯域幅を持つ。たとえば 44100Hz でサンプルされた 1024 個のサンプルを変換するとしよう。最初のビンは 0 から 22050 を 513 で割り、さらに半分にした周波数、つまり 21.5Hz だ。 (先ほど書いたように、最初のビンは普通の帯域幅の半分だ。) 次のビンは 21.5Hz から 21.5Hz + 22050 / 513 (43Hz) = 64.5Hz までの周波数を表す (ここでも 21.5Hz から 64.5Hz ということで帯域幅は 43Hz。) 次のビンは 64.5Hz から 107.5Hz までの範囲というように続く。

<!--
Whenever we do a discrete Fourier transform on our audio data we do it on a window of samples, e.g. 1024 samples is a common window size. The size of the window dictates the resolution of the resulting spectrum, that is the number of frequency bins in the spectrum will increase linearly with the number of samples we transform. The bigger the sample window the more fine grained the bins will be, that is the smaller their bandwidth. To calculate the spectrum we use a specific algorithm called the Fast Fourier Transform (FFT) which runs in O(n log n), pretty fast compared to a naive fourier transform implementatin which takes O(n*n). Almost all of the FFT implementations demand sample windows with a size being a power of two. So 256, 512, 1024, 2048 is fine, 273 is not. The FFT implementation we use in the framework also has this “limitation”.
-->

音声データに対して離散フーリエ変換を行うときにはいつも、サンプルの幅に基づいている。たとえば 1024 が一般的な 1 つの幅に対するサンプル数だ。幅の数は生成されるスペクトラムの解像度、つまりスペクトラムの中で何個の周波数のビンが変換するサンプルの数に応じて線形に増えていくかを表す。サンプルの幅が大きければ大きいほど、瓶は精緻となり、帯域幅が小さくなる。スペクトラムを計算するのには高速フーリエ変換 (Fast Fourier Transform, FFT) というアルゴリズムを使う。これは 0(n log n) の計算量で実行できるので、O(n*n) かかる元々のフーリエ変換の実装よりかなり速い。FFT 実装のほぼすべては 2 のべき乗個のサンプルの幅を必要とする。つまり、256, 512, 1024, 2048 は大丈夫だが、273 ではダメ。今回のフレームワークで使う FFT の実装には「制限」も存在する。

<!--
So without further ado i present you the spectrum of the samples depicted in the image above
-->

まあこれ以上面倒なことは説明せずに上記の画像に対して描画されたサンプルのスペクトラムをお見せすることにしよう。

(TODO: 画像)

<!--
Note: the vertical lines to the left and right are not part of the actual image. It’s wordpress fucking up
-->

注意: 左側の縦の線は実際の画像の一部ではない。wordpress のせいでこうなっている。

<!--
Yes, that’s it. The x-axis corresponds to the frequency bins while the y-axis tells us the amplitude of a frequency bin. We clearly see a peek at the left side, the rest of the spectrum is zero. This peak corresponds to the frequency bin which contains the frequency 440Hz, the frequency of the note A we generated 1024 samples for. What we also see is that it’s not a clean peak, bins to the left and right also receive some amplitude. This is called leakage and is something we can’t solve. In our case it’s not a big concern really but in other application scenarios it might be. Here’s the program that generated the above two images:
-->

そう、これだけ。x 軸は周波数の瓶に対応し、y 軸は周波数の瓶の振幅を表している。左側にピークが存在し、スペクトラムの残りはゼロであることがはっきりと分かる。このピークがは周波数 440Hz、つまり 1024 個のサンプルとして生成された A という音の周波数の瓶に対応している。また、すっきりとしたピークではなく、左と右の瓶もいくらか振幅を受け取っていることが分かる。これは漏れというものであり、解決することはできない。今回のケースではあまり大きな問題とはならないが、他のアプリケーションのシナリオでは問題を引き起こすこともあるだろう。上記 2 つの画像を生成するプログラムは下記のようになる：

{% highlight java %}
public class FourierTransformPlot 
{
   public static void main( String[] argv )
   {
      final float frequency = 440; // Note A		
      float increment = (float)(2*Math.PI) * frequency / 44100;		
      float angle = 0;		
      float samples[] = new float[1024];      

      for( int i = 0; i < samples.length; i++ )
      {
         samples[i] = ((float)Math.sin( angle ));
         angle += increment;			
      }
		
      FFT fft = new FFT( 1024, 44100 );
      fft.forward( samples );

      Plot plotSamples = new Plot( "Samples", 512, 512 );
      plotSamples.plot( samples, 2, Color.white );

      Plot plotSpectrum = new Plot( "Spectrum", 512, 512);
      plotSpectrum.plot(fft.getSpectrum(), 1, Color.white );
   }
}
{% endhighlight %}

<!--
The first couple of lines should be familiar, we simply generate 1024 samples at a sampling rate of 44000Hz. There's actually only 2 interesting lines in this program. The first one is the one where we instantiate the FFT object. As parameters for it's constructor it wants the sample window size we'll use to generate the spectrum as well as the sampling rate. The next line performs the Fourier transform as well as the spectrum calculation. All we have to do is pass in a float array of samples having the size we specified in the FFT constructor. That's all we need to do to get our precious frequency bins. What's left is plotting the samples as well as the spectrum. Note the call to fft.getSpectrum(). This method will return the spectrum of the last fourier transform we did by calling FFT.forward().
-->

最初の 2,3 行はすでに慣れているだろうが、44000Hz のサンプリングレートで 1024 のサンプルを生成している。実際、このプログラムで興味深いのは 2 行だけだ。最初は FFT オブジェクトをインスタンス化するところ。コンストラクタのパラメータとしてはスペクトラムを生成するのに使うサンプルの幅のサイズと、サンプリングレートを渡す。次の行ではフーリエ変換とスペクトラムの計算を行っている。やらなければならないのは FFT のコンストラクタに指定したのと同じサイズの float 配列を渡すことだけ。これさえやれば、貴重な周波数の瓶を得ることができる。あとはサンプルとスペクトラムをプロットするだけ。fft.getSpectrum() を呼び出していることに注意してほしい。このメソッドは FFT.forward() を呼び出し行った細心のフーリエ変換のスペクトラムを返却する。

<!--
Pfuh, that was pretty nasty. I really suggest reading up on the discrete Fourier transform. It's an essential mathematical tool for all audio engineers. And while most audio engineers will use some sort of toolbox as we did it doesn't hurt to know your way around.
-->

ふー、かなり汚い感じになった。本当に離散フーリエ変換に関する記事は各自で読んだほうがいい。すべてのオーディオエンジニアにとって必須の数学ツールだ。ほとんどのオーディオエンジニアは今回のようにある種のツールボックスを使うだろうが、仕組みを知っておいて損はない。

<!--
We now are equipped with all we need to get our onset/beat detector going. Stay tuned for the next article.
-->

音の立ち上がり/ビート検出を動かすために必要なことはすべて装備できた。次回の記事までチャンネルはそのままで。
