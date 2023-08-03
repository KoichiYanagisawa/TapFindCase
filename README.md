# TapFindCase

## サービスURL

スマホとPCどちらにも対応しておりますので、お好きなデバイスでご使用ください。

https://tapfindcase.com

## サービス概要

このサービスは**iPhoneのケース探しのハードルを極力下げることを目的に、画面をタップするだけで気に入ったケースを見つけてECサイトまで辿り着ける**ように開発しました。コンテンツの充実と正確性を重視し、自力での情報収集、手入力はせず、デイリーベースでスクレイピングして情報の更新をしています。

## このサービスに込めた想い

「新しいアプリや機械を触るのが怖い」といった感情を抱いてしまう、苦手意識を持った人でも扱えるサービスがあったら良いなと思う出来事が過去にありました。私の両親や友人がそういったユーザーでしたので、何としてでもこのサービスを通じて苦手意識を少しでも克服できるお手伝いや成功体験を積んでほしい。そんな想いを込めて制作したのが本サービスとなります。

<details>

<summary>作るきっかけとなった失敗談</summary>

<br>

スマートフォンの使用割合がLINE8割、電話2割の私の家族が、自力でiPhoneケースを購入しようとしました。本来欲しかったのは「iPhone 13 Pro」のケースでしたが、「iPhone 13」のケースを購入(以下写真参照)してしまいました。
検索キーワードが足りなかったのか、おすすめに出てくる商品を見ていくうちに別のモデルの商品を案内されていたようです。この失敗を機にさらにWEBサイトやスマホ操作に対して苦手意識を持ってしまいました。そこを何とかしてあげたいと思ったのが本サービスのきっかけです。

<img src="./documents/IMG_0414.jpeg" width="400px" />

</details>

## こだわりポイント

1. 一切文字入力をせずに操作するUI。
2. サーバーレス化。
3. スクレイピングによるコンテンツの自動拡充。
4. CI/CDでコンテナを使用し本番環境に近付けた。
5. 

## 使用画面紹介

### DEMO

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./documents/pc_demo.gif">|<img src="./documents/iphone_demo.gif">|

### トップページ

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./documents/pc_top.png">|<img src="./documents/iphone_top.PNG">|

### 製品一覧

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./documents/pc_products_list.png">|<img src="./documents/iphone_products_list.PNG">|

### 商品詳細

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./documents/pc_detail.png">|<img src="./documents/iphone_detail.PNG">|

### お気に入り

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./documents/pc_favorites_list.png">|<img src="./documents/iphone_favorites_list.PNG">|

### 閲覧履歴

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./documents/pc_histories_list.png">|<img src="./documents/iphone_histories_list.PNG">|

## インフラ構成図

<img src="./documents/TapFindCase.drawio.png">

## 使用技術

### Backend

- Ruby 3.2.2
- Ruby on Rails 7.0.6
  - RuboCop
  - RSpec
  - AWS-SDK for Ruby

### Frontend

- JavaScript ES6
- React 18
  - Router
  - Emotion
  - ResponsiveCarousel
  - Icons
  - Redux

### Infrastructure

- AWS
  - Frontend
    - S3
    - CloudFront
  - Backend
    - APIGateway
    - Lambda
  - Server
    - DynamoDB
    - S3
  - Scraping
    - ECS
    - ECR
  - Secrets
    - Secrets Manager
    - System Manager
  - Events
    - EventBridge
    - Lambda
  - Monitoring
    - Route53
    - SNS

### CI/CD

- GitHub Actions
- Docker(Amazonlinux:2)
- Serverless Framework

### Others

- Git,GitHub
- AdobeXD

## 今後の予定

- UXの向上
  - サーバーレスによるコールドスタートで初期のレスポンスが悪いので改善。
  - 価格、色によるソート機能の追加。

- スクレイピング機能の拡張
  - S3へのPutをトリガーに次のタスクが起動するようにしているのを、SQSによるキューを使った管理へ切り替える。
  - 商品の詳細情報が載っているURLを別タブで開くようにしてコード内のsleepの数と秒数を減らす。
  - 4900点に取り扱い点数を増やす(現在906点)。最終目標は約33000点。
