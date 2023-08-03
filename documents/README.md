# 設計

## ステップ1

1. 業務フロー

![業務フロー](業務フロー.png)

2. 画面遷移図

![画面遷移図](画面遷移図.png)

3. ワイヤーフレーム

https://xd.adobe.com/view/1d001441-66de-4edf-b514-529cb98e2cef-4853/

## ステップ2(テーブル定義書)

**productsテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|id|BIGINT|NO|PRIMARY|NULL|YES|
|name|VARCHAR(255)|NO||NULL|NO|
|color|VARCHAR(255)|NO||NULL|NO|
|maker|VARCHAR(255)|NO||NULL|NO|
|price|CHAR(20)|YES||NULL|NO|
|ec_site_url|VARCHAR(255)|NO|UNIQUE|NULL|NO|
|checked_at|TIMESTAMP|NO||CURRENT_TIMESTAMP|NO|

**imagesテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|id|BIGINT|NO|PRIMARY|NULL|YES|
|product_id|BIGINT|NO|FOREIGN KEY|NULL|NO|
|image_url|VARCHAR(255)|NO||NULL|NO|
|thumbnail_url|VARCHAR(255)|NO||NULL|NO|

**modelsテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|id|BIGINT|NO|PRIMARY|NULL|YES|
|model|CHAR(30)|NO||NULL|NO|

**product_modelsテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|id|BIGINT|NO|PRIMARY|NULL|YES|
|product_id|BIGINT|NO|FOREIGN KEY|NULL|NO|
|model_id|BIGINT|NO|FOREIGN KEY|NULL|NO|

**usersテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|id|BIGINT|NO|PRIMARY|NULL|YES|
|cookie_id|VARCHAR(255)|NO|UNIQUE|NULL|NO|

**favoritesテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|id|BIGINT|NO|PRIMARY|NULL|YES|
|user_id|BIGINT|NO|FOREIGN KEY|NULL|NO|
|product_id|BIGINT|NO|FOREIGN KEY|NULL|NO|

**historiesテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|id|BIGINT|NO|PRIMARY|NULL|YES|
|user_id|BIGINT|NO|FOREIGN KEY|NULL|NO|
|product_id|BIGINT|NO|FOREIGN KEY|NULL|NO|
|viewed_at|DATETIME|NO||NULL|NO|

**マイグレーションファイル作成コマンドは以下**

```
rails generate migration CreateProducts name:string color:string maker:string price:char[20] ec_site_url:string:uniq checked_at:timestamp
rails generate migration CreateImages product:references image_url:string thumbnail_url:string
rails generate migration CreateModels model:char[30]
rails generate migration CreateProductModels product:references model:references
rails generate migration CreateUsers cookie_id:string:uniq
rails generate migration CreateFavorites user:references product:references
rails generate migration CreateHistories user:references product:references viewed_at:datetime
```

## ステップ3(システム構成図)

- SQLからNoSQLに変更しました。

<img src="./TapFindCase.drawio.png">
