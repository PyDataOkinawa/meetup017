# PyData.Okinawa Meetup #17 - Magentaで音楽生成

2016年09月17日（土）に開催予定のPyData.Okinawa Meetup #17 - Magentaで音楽生成の発表資料等をまとめたページです。

## 環境設定

### Dockerのインストールと設定

Macの場合は[こちら](https://docs.docker.com/docker-for-mac/)から「Get Docker for Mac (stable)」をダウンロードすると吉です。それ以外のOSを用いている方は[こちら](https://docs.docker.com/engine/installation/)から探せます。

以下、環境としてMacを仮定しますので、Mac以外のOSを使っている方は適宜読み替えて下さい。

docker.appを立ち上げ、言われるがままに設定します。
設定が終わったらターミナルに戻り、`docker version`と打ってみて下さい。
それっぽい感じのバージョン番号などが現れたらDockerの設定はOKです。

### TensorFlowとMagentaが使えるDockerイメージの呼び出し

Dockerの設定が終わったら、以下の起動コマンドをおもむろにターミナルに打ち込んでみて下さい。

```bash:
docker run -it -p 6006:6006 -v /tmp/magenta:/magenta-data tensorflow/magenta
```

最初にDockerを起動する際には、約2.5Gほどのデータをダウンロードしてくるので結構時間がかかります。お茶でも飲みながら気長に待ちましょう。最終的に`root@ab123c45678d:/magenta#`のような感じのコンソール画面が出てきたら成功です。途中でダウンロードが止まったりしたときには、もう一度先ほどの起動コマンドを打ってみて下さい。

以後、Dockerを起動したいときには、同じコマンドを使って下さい。二回目以降の起動の際には、ファイルをダウンロードしないので、すぐにDockerが立ち上がります。

Dockerを起動すると、`/magenta`というディレクトリに降り立ちます。ここがメインディレクトリです。Magentaの実行ファイルはこのディレクトリ以下に置いてあります。`ls`と打って、それっぽいファイルが出てきたらOKです。`cd`と打つと他のディレクトリに行ってしまうので、そのときは慌てずに`cd /magenta`で戻ってこればOKです。

もう一つの重要なディレクトリは`/magenta-data`です。ここに置かれたデータは、ホストOS（例えばMac）の`/tmp/magenta`と同期されるので、データのやり取りに便利です。また、ここに置かれたファイル以外は、Dockerを再起動すると綺麗さっぱり無くなってしまうので、取っておきたいファイルは`/magenta-data`以下に置いておきましょう。

`exit`と打つとdockerから抜けられます。

### Timidity（MIDI再生用ソフト）のインストール

学習済みのモデルから生成されたMIDIファイルをMacで再生するにはなんらかのソフトが必要となります。今回はTimidityというソフトを使うことにします。TimidityはHomebrewを使って以下のようにインストールできます。

```bash:
brew install timidity
```
