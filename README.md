# Clirbeaux

ソフトウェア開発をフローにするための補助ツール。

## 必須環境
*   サーバ: DockerおよびLinux環境(Docker for Windows + Windows Subsystem for Linuxでも可)
*   クライアント: IE以外のブラウザ最新版

## サーバセットアップ
1.  このリポジトリをクローンしてクローン先のディレクトリにcdする。
2.  `docker build -t clirbeaux .` でclirbeauxイメージを作成する。
3.  `./sh/setup.sh`を実行し、`./config`ディレクトリに必要なファイルを作成する。
4.  configディレクトリのファイルを編集する。
    *   **project.yml:** プロジェクト定義
        *   最低限このファイルの編集だけは必要。
        *   情報取得先のGitリポジトリを定義する。
        *   **name**と**url**の指定は必須。**branch*と**exclude**は必要に応じて定義する。
        *   **name**と**url**の指定は必須。
    *   **file-type.yml:** ファイルタイプ定義
        *   とりあえず試してみるだけの場合は編集不要。
        *   情報収集するファイルのタイプを定義する。
    *   **index.html:** ユーザーインターフェース定義
        *   とりあえず試してみるだけの場合は編集不要。
        *   画面構成を定義する。
    *   **index.js:** サーバアプリ定義
        *   とりあえず試してみるだけの場合は編集不要。
        *   サーバアプリの構成を定義する。

## サーバ実行
1.  以下のコマンドでサーバを起動する。
    *   `docker run -v $(pwd):/clirbeaux -w /clirbeaux -it --rm -p 9999:9999 clirbeaux ./sh/start.sh`
    *   (Windows + WSLの場合) `docker run -v $(pwd |sed 's|/mnt||'):/clirbeaux -w /clirbeaux -it --rm -p 9999:9999 clirbeaux ./sh/start.sh`
2.  起動直後はGitリポジトリからの情報収集が動作する。コンソールに日付が表示されれば起動終了。

## ブラウザからのアクセス
1.  以下のURLでブラウザからアクセスする。
    *   http://サーバ:9999/
2.  デフォルトのindex.htmlで実行した場合は、最初にEmailの入力が促されるので、Gitコミットで利用したEmailアドレスを入力し、OKをクリックする。


## リファレンス
### Clirbeauxの読み方
「くりあぼー」と読みます。たぶん。

### ディレクトリ構成

```
clirbeaux/
  - config/         ... 設定ファイル
  - data/           ... プレーヤーのデータ格納領域
  - node_modules/   ... サーバアプリ用ライブラリ格納領域
  - plugins/        ... アプリ本体(ソースファイル)格納領域
    - git/            ... gitリポジトリを扱うアプリ
    - util/           ... 共通部品的なもの
    - ...             ... その他のアプリ
  - public/         ... ブラウザ上に表示するファイルの格納領域
  - sh/             ... シェルスクリプト
  - tmp/            ... 一時ファイル(gitリポジトリ等)
```

### configの詳細
#### project.yml (プロジェクト定義)
YAML形式のファイルで、projectの下に以下の定義を行います(複数定義可能)。

*   **name:** リポジトリ名(必須項目)
*   **url:** GitリポジトリURL(必須項目)
*   **branch:** ブランチ(任意項目。指定がない場合はmaster)
*   **exclude:** 除外するディレクトリやファイル(任意項目。glob形式。複数定義可能)

#### file-type.yml (ファイルタイプ定義)
YAML形式のファイルで、fileTypeの下に以下の定義を行います(複数定義可能)。

*   **type:** 言語名(必須項目)
*   **pattern:** ソースファイル拡張子(必須項目。glob形式。複数定義可能)
*   **item:** アイテム定義(任意項目)
    *   **matcher:** アイテム抽出定義(1つのグループ指定がある正規表現。複数定義可能)
    *   **exclude:** 除外するファイルの定義(glob形式。複数定義可能)
    *   **bundle:** アイテムグループ定義
        *   **type:** アイテムグループ名
        *   **pattern:** アイテムグループ検出パターン(glob形式。複数定義可能)

#### index.html (ユーザーインターフェース定義)
画面表示する項目を定義します。
レイアウト調整を行ったり、利用するタグの選定を行います。


#### index.js (サーバアプリ定義)
サーバ側で起動するアプリを定義します。


### 環境変数設定
Docker起動時に以下の環境変数指定が可能です。

*   **UPDATE_INTERVAL_MIN:** Gitリポジトリ情報更新間隔 (単位は「分」)
    *   デフォルト: `60`

### 追加機能開発の方法
このアプリは以下の構成になっています。

*   **サーバ:** nodejs + [Koa](https://github.com/koajs/koa) を用いたRESTアプリ。
*   **クライアント:** [Riot](https://riot.js.org/ja/) を用いたSPA。
    *   画面デザインに[Materialize CSS](https://materializecss.com/)を使用。
    *   サーバとの通信用にjQueryを使用。


以下の場所にソースコードを格納することにより、独自の機能を追加できます。

*   **サーバ側:** ./plugins/作成するアプリ/server/index.js
*   **クライアント側:** ./plugins/作成するアプリ/client/*.tag

#### サーバ側の実装
任意のファンクションを実装し、ルーティング設定を行ってください。

```
const getLevel = async (ctx, next) => {
  ...
  ctx.body = {
    ...
  };
  ctx.status = 200;
};

module.exports.route = (router) => {
  router.get('/myapp/level', getLevel);
};

```

*   複数のファンクションを定義することも可能です(`./plugins/git/server/index.js` 等が参考になります)。


サーバ側に追加したアプリを使用するためには、`./config/index.js` に以下の行を追加します。

```
require('../plugins/作成するアプリ/server').route(router);
```

#### クライアント側の実装
*   [Riotのカスタムタグ](https://riot.js.org/ja/guide/)実装を行います。
*   gulpでビルドすると、`./plugins/myapp/client/*` のファイルが、`./public/myapp/*` にコピーされ、参照可能になります。

##### カスタムタグ実装のコツ
*   事前に [Riot](https://riot.js.org/ja/) を一読してから始めるのが近道です。
*   独自のカスタムタグを作る前に`./plugins/git/client/*.tag`や`./plugins/git/client/*.tag`の実装を眺めてみると、何となくお作法がわかるはず。
*   `./plugins/git/client/ctx.js` には便利なファンクションがありますので、こちらも事前に一読を。
*   functionキーワードは使わない。
*   サーバ呼び出しなどで同期処理を行う場合は、async/await を使いましょう。
*   IEのことは忘れましょう。

#### 開発時のgulp利用方法

1.  以下のコマンドでDockerコンテナ上のシェルを起動する。
    *   `docker run -v $(pwd):/clirbeaux -w /clirbeaux -it --rm -p 9999:9999 clirbeaux sh`
    *   (Windows + WSLの場合) `docker run -v $(pwd |sed 's|/mnt||'):/clirbeaux -w /clirbeaux -it --rm -p 9999:9999 clirbeaux sh`
2.  `./node_modules/.bin/gulp default serve` でgulpビルドを実行すると同時に、サーバを起動する。
    *   上記の状態で、`./plugins/*` のファイルを修正すると自動的にgulpビルドとサーバ再起動が行われます。
    *   ただし、新規ファイルを追加した場合は、一旦Ctrl+C等でgulpを終了させ、再起動する必要があります。
