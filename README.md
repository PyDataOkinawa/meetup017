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

もう一つの重要なディレクトリは`/magenta-data`です。ここに置かれたデータは、ホストOS（例えばMac）の`/tmp/magenta`と同期されるので、データのやり取りに便利です。また、ここに置かれたファイル以外は、Dockerを再起動すると綺麗さっぱり無くなってしまうので、取っておきたいファイルは`/magenta-data`以下に置いておきましょう。

`exit`と打つとdockerから抜けられます。

### Timidity（MIDI再生用ソフト）のインストール

学習済みのモデルから生成されたMIDIファイルをMacで再生するにはなんらかのソフトが必要となります。今回はTimidityというソフトを使うことにします。TimidityはHomebrewを使って以下のようにインストールできます。

```bash:
brew install timidity
```

## 使い方（ここからの内容はPyData.Okinawa Meetupの当日にカバーします）

### 共有フォルダにスクリプトを配置

先ずは、このGitHubのコンテンツをローカル環境に落としてきます。一時的に置くだけなので、どこに落としてきても良いです。`docker`というフォルダが含まれていることを確認して下さい。

次にDockerを起動させた状態で、`docker`というフォルダの中にある`script`と`midi`というフォルダの両方を、ローカルの`/tmp/magenta`の中にコピーして下さい。

この状態で、Dockerにアクセスできるターミナル上で`cd /magenta-data/script`と入力します。

### MIDIファイルの設置

ローカルの`/tmp/magenta/midi/`の中に学習に用いたいMIDI形式のファイルを配置します。ディレクトリ構造をもたせても大丈夫です。

### データセットの生成

```
./build_dataset.sh
```

このコマンドにより `./tmp/notesequences.tfrecord`  という1つのファイルが生成されます。
すべてのMIDIファイルが、TensorFlowで扱いやすい形に変換され、最終的にこの1つのファイルにまとめられます。

### モデルの学習

```
./train_rnn.sh basic_rnn
```

このコマンドにより２つの処理が実行されます。

１つ目の処理は学習データと評価データの分割です。

 `./tmp/basic_rnn/sequences_exampels` 以下に

- `training_melodies.tfrecord`
- `eval_melodies.tfrecord`

というデータがそれぞれ作成されます。

２つ目の処理はモデルの学習です。

`basic_rnn`のところを`lookback_rnn`や`attention_rnn`とすることで異なるモデルを訓練することもできます。

学習ログは `./tmp/basic_rnn/sequences_exampels/logdir/` 以下に記録されます。

ブラウザのアドレスバーに`localhost:6006`と入力すると、TensorBoardがログディレクトリの中に記録された情報を読み取り、学習の進捗状況をリアルタイムで確認できます。

### 音楽の生成

```
./generate_melodies.sh basic_rnn
```

このコマンドにより
`tmp/basic_rnn/generated/`以下ににMIDIファイルが生成されます。

Docker上ではMIDIを再生できないので、ローカルの `/tmp/magenta/script/tmp/basic_rnn_generated` 以下に同期されているファイルをTimidityなどで再生してみてください。
