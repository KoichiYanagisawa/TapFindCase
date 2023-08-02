# TapFindCase

## サービスURL

スマホとPCどちらにも対応しておりますので、お好きなデバイスでご使用ください。

https://tapfindcase.com

## サービス概要

このサービスはiPhoneのケース探しのハードルを極力下げることを目的に、画面をタップするだけで気に入ったケースを見つけてECサイトまで辿り着けるように開発しました。コンテンツの充実と正確性を重視し、自力での情報収集、手入力はせず、デイリーベースでスクレイピングして情報の更新をしています。

## このサービスに込めた想い

「新しいアプリや機械を触るのが怖い」といった感情を抱いてしまう、苦手意識を持った人でも扱えるサービスがあったら良いなと考えることがありました。私の両親や友人がそういったユーザーでした。そういった人たちが、このサービスを通じて苦手意識を少しでも克服できるお手伝いや成功体験を積んでほしい。そんな想いを込めて制作したのが本サービスとなります。

## 使用画面紹介

### トップページ

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./pc_top.gif">|<img src="./iphone_top.gif" width="390px">|

### 製品一覧

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./pc_products_list.gif">|<img src="./iphone_products_list.gif" width="390px">|

### 商品詳細

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./pc_detail.gif">|<img src="./iphone_detail.gif" width="390px">|

### お気に入り

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./pc_favorites_list.gif">|<img src="./iphone_favorites_list.gif" width="390px">|

### 閲覧履歴

|PC版|スマートフォン版|
|:-----------|:-----------|
|<img src="./pc_histories_list.gif">|<img src="./iphone_histories_list.gif" width="390px">|

## インフラ構成図

<img src="./TapFindCase.drawio.png">

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
