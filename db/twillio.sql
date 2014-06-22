DROP TABLE IF EXISTS shops;

CREATE TABLE shops(
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  tel VARCHAR(12),
  passcode VARCHAR(10),
  flg INTEGER not NULL,
  teled_at DATETIME,
  created_at DATETIME not NULL,
  INDEX (tel)
)CHARACTER SET utf8 COLLATE utf8_unicode_ci;
