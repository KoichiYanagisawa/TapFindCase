# Scrapingするためのコンテナ

- **scraper**:webをスクレイピングするコンテナ

## docker-compose.ymlの起動

```
docker-compose up -d
```

## 初回起動時はシェルコマンドを実行する

- src/create_products_table.shを実行

## mysqlに設定する

- mysql -h db -u root -p < create_products_table.sh
