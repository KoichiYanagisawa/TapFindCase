#!/bin/bash

# 設定ファイルを読み込む
source .env

# 環境変数を読み込んで.sqlファイルを作成
cat > create_products_table.sql <<EOF
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
CREATE DATABASE $MYSQL_DATABASE;
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
USE $MYSQL_DATABASE;
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    maker VARCHAR(255),
    url TEXT,
    price DECIMAL(10,0)
);
EOF
