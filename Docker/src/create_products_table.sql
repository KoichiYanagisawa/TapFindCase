CREATE USER 'scraper'@'%' IDENTIFIED BY 'scraper';
CREATE DATABASE scraper;
GRANT ALL PRIVILEGES ON scraper.* TO 'scraper'@'%';
FLUSH PRIVILEGES;
USE scraper;
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    maker VARCHAR(255),
    url TEXT,
    price DECIMAL(10,2)
);
