# 設計

## ステップ1

1. 業務フロー

  <img src="./workflow.png" />

2. 画面遷移図

  <img src="./screen_transition_diagram.png" />

3. ワイヤーフレーム

<a href="https://xd.adobe.com/view/1d001441-66de-4edf-b514-529cb98e2cef-4853/">色の組み合わせ要相談</a>

## ステップ2(テーブル定義書)

**productsテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|product_id|BIGINT|NO|PRIMARY|NULL|YES|
|product_name|VARCHAR(255)|NO||NULL|NO|
|description|TEXT|YES||NULL|NO|
|image_url|VARCHAR(255)|NO|UNIQUE|NULL|NO|
|price|DECIMAL(10,2)|YES||NULL|NO|
|ec_site_url|VARCHAR(255)|NO|UNIQUE|NULL|NO|

**ec_sitesテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|site_id|BIGINT|NO|PRIMARY|NULL|YES|
|site_name|VARCHAR(255)|NO||NULL|NO|
|site_url|VARCHAR(255)|NO|UNIQUE|NULL|NO|

**product_ec_site_relationshipテーブル**

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
|-------|--------|----|---|-----|--------------|
|product_id|BIGINT|NO|FOREIGN|NULL|NO|
|site_id|BIGINT|NO|FOREIGN|NULL|NO|

## ステップ3(システム構成図)

- NoSQLから変更中

<img src="./TapFindCase.drawio.png">
