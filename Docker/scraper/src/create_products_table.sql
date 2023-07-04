CREATE USER 'scraper-user'@'%' IDENTIFIED BY 'scraper-password';
CREATE DATABASE scraper;
GRANT ALL PRIVILEGES ON scraper.* TO 'scraper-user'@'%';
FLUSH PRIVILEGES;
USE scraper;
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    maker VARCHAR(255),
    url TEXT,
    price DECIMAL(10,0)
);
