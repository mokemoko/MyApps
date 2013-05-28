DROP TABLE IF EXISTS artists;

CREATE TABLE artists(
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(256),
  updated_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL,
  INDEX (name)
)CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS images;

CREATE TABLE images(
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  gid INTEGER,
  path VARCHAR(256),
  posted_at TIMESTAMP NOT NULL,
  INDEX (posted_at)
)CHARACTER SET utf8 COLLATE utf8_unicode_ci;
