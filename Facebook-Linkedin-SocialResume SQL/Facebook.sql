CREATE SCHEMA Facebook CHARACTER SET UTF8;

CREATE TABLE Facebook.Type(
  ID INT UNSIGNED AUTO_INCREMENT,
  Name VARCHAR(10),
  CONSTRAINT Type_pk PRIMARY KEY (ID)
);
INSERT INTO Facebook.Type (Name)
VALUES ('Comment'), ('Event'), ('Group'), ('Page'), ('Post'), ('User');


CREATE TABLE Facebook.Entity(
  ID INT UNSIGNED AUTO_INCREMENT,
  TypeID INT UNSIGNED NOT NULL,
  CreateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Entity_pk PRIMARY KEY (ID),
  CONSTRAINT Entity_TypeID_fk FOREIGN KEY (TypeID) REFERENCES Facebook.Type(ID)
);

CREATE TABLE Facebook.User(
  ID INT UNSIGNED,
  FirstName VARCHAR(32) NOT NULL,
  MidName VARCHAR(32) NULL,
  LastName VARCHAR(32) NULL,
  Email VARCHAR(64) NOT NULL,
  BirthDate DATE NOT NULL,
  IsMale BOOL NOT NULL,
  PhoneNo VARCHAR(11) NULL,
  SettingsLanguage VARCHAR(6) NOT NULL,
  CONSTRAINT User_pk PRIMARY KEY (ID),
  CONSTRAINT User_ID_fk FOREIGN KEY (ID) REFERENCES Facebook.Entity(ID)
);

CREATE TRIGGER Facebook.BeforeInsertUser BEFORE INSERT ON Facebook.User FOR EACH ROW
BEGIN
  INSERT INTO Facebook.Entity (TypeID) SELECT ID FROM Facebook.Type WHERE Name = 'User';
  SET NEW.ID = LAST_INSERT_ID();
END;

INSERT INTO Facebook.User (FirstName, MidName, LastName, Email,BirthDate,IsMale,PhoneNo,SettingsLanguage)
VALUES ('Ahmet', 'Faruk', 'Aktas', 'a.farukakts@outlook.com', '1996-02-20',TRUE ,'05424060743','tr-TR'),
       ('Mertcan', '', 'Takil','mertcantakil@gmail.com','1996-09-18',TRUE ,'05459522854','tr-TR'),
       ('Serkay', '', 'Yuksel','serkayyuksel@gmail.com','1996-01-14',TRUE ,'05388903514','tr-TR'),
       ('Mehmet','Ali','Tosun','mali@gmail.com','1989-10-22',TRUE ,'05324563245','fr-FR'),
       ('Ayşe','Fatma','Yılmaz','afy@gmail.com','1992-03-19',FALSE ,'05556773245','en-US'),
       ('Nesrin','','Cakmak','nc@gmail.com','1960-02-14',FALSE ,'05329887245','de'),
       ('Caroleena','','Ramadan','caroleena@gmail.com','1997-12-11',FALSE ,'80265230315','uk-UA'),
       ('John','','Wash','john@gmail.com','1970-04-22',TRUE ,'0532456945','cs-CZ'),
       ('Micheal','','Schummer','michealsch@gmail.com','1960-06-19',TRUE ,'045855245','de-de'),
       ('Micheal','Emily','Faker','michealemily@hotmail.com','1994-07-12',FALSE ,'05544444245','en-UK'),
       ('Mehmet','','Tosun','mali@gmail.com','1989-10-22',TRUE ,'05324563245','fr-FR'),
       ('Polina','','Ergonova','polina@vk.com','2000-08-08',FALSE ,'2934923445','ru-RU');

-- 1-12

CREATE TABLE Facebook.Friendship(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  Since DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Friendship_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT Friendship_User1ID_fk FOREIGN KEY (User1ID) REFERENCES Facebook.User(ID),
  CONSTRAINT Friendship_User2ID_fk FOREIGN KEY (User2ID) REFERENCES Facebook.User(ID)
);
CREATE TRIGGER Facebook.BeforeInsertFriendship BEFORE INSERT ON Facebook.Friendship
FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM Facebook.Friendship WHERE (User1ID = NEW.User2ID AND User2ID = NEW.User1ID)) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Users are already friend';
  END IF;
END;
INSERT INTO Facebook.Friendship(User1ID, User2ID)
VALUES      (1,2),(1,3),(1,7),(1,12),
            (2,4),(2,5),(2,12),
            (3,2),(3,5),(3,11),
            (8,9);


CREATE TABLE Facebook.FriendshipRequest(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  SendTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT FriendshipRequest_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT FriendshipRequest_User1ID_fk FOREIGN KEY (User1ID) REFERENCES Facebook.User(ID),
  CONSTRAINT FriendshipRequest_User2ID_fk FOREIGN KEY (User2ID) REFERENCES Facebook.User(ID)
);
CREATE TRIGGER Facebook.BeforeInsertFriendshipRequest BEFORE INSERT ON Facebook.FriendshipRequest FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM Facebook.Friendship WHERE (User1ID = NEW.User1ID AND User2ID = NEW.User2ID) OR (User1ID = NEW.User2ID AND User2ID = NEW.User1ID)) > 0 THEN
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Users are already friend';
  END IF;

  IF (SELECT COUNT(*) FROM Facebook.FriendshipRequest WHERE User1ID = NEW.User2ID AND User2ID = NEW.User1ID) > 0 THEN
    SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'Request received from this user';
  END IF;
END;
INSERT INTO Facebook.FriendshipRequest(User1ID, User2ID)
VALUES     (1,8),(2,10),(3,12),(5,1);
INSERT INTO Facebook.FriendshipRequest(User1ID, User2ID)
VALUES     (1,2);
CREATE TABLE Facebook.Message(
  ID INT UNSIGNED AUTO_INCREMENT,
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  Content VARCHAR(256),
  SendTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  ReceiveTime DATETIME NULL,
  CONSTRAINT Message_pk PRIMARY KEY (ID),
  CONSTRAINT Message_User1ID_fk FOREIGN KEY (User1ID) REFERENCES Facebook.User(ID),
  CONSTRAINT Message_User2ID_fk FOREIGN KEY (User2ID) REFERENCES Facebook.User(ID)
);
INSERT INTO Facebook.Message(User1ID, User2ID, Content)
VALUES      (1,2,'Selamın Aleyküm'),
            (1,3,'Eve gelirken ekmek al'),
            (2,12,'Helloo'),
            (3,5,'Whatsup?');
INSERT INTO Facebook.Message(User1ID, User2ID, Content, ReceiveTime)
VALUES      (8,9,'Heey!',NOW()),
            (9,8,'Hii:)',NOW()),
            (8,9,'How was your today?',NOW()),
            (9,8,'very busy..',NULL),
            (2,6,'Beni ekler misin',NULL),
            (3,11,'Geliyorum',NOW());

CREATE TABLE Facebook.Page(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  Name VARCHAR(32) NOT NULL,
  CONSTRAINT Page_pk PRIMARY KEY (ID),
  CONSTRAINT Page_ID_fk FOREIGN KEY (ID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Page_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES Facebook.User(ID)
);
CREATE TABLE Facebook.PageAdmin(
  UserID INT UNSIGNED,
  PageID INT UNSIGNED,
  CONSTRAINT PageAdmin_pk PRIMARY KEY (UserID, PageID),
  CONSTRAINT PageAdmin_UserID_fk FOREIGN KEY (UserID) REFERENCES Facebook.User(ID),
  CONSTRAINT PageAdmin_PageID_fk FOREIGN KEY (PageID) REFERENCES Facebook.Page(ID)
);

CREATE TRIGGER Facebook.BeforeInsertPage BEFORE INSERT ON Facebook.Page FOR EACH ROW
BEGIN
  INSERT INTO Facebook.Entity (TypeID) SELECT ID FROM Facebook.Type WHERE Name = 'Page';
  SET NEW.ID = LAST_INSERT_ID();
END;
CREATE TRIGGER Facebook.AfterInsertPage AFTER INSERT ON Facebook.Page FOR EACH ROW
BEGIN
  INSERT INTO Facebook.PageAdmin (UserID, PageID) VALUES (NEW.CreatorID, NEW.ID);
END;

INSERT INTO Facebook.Page(CreatorID,Name)
VALUES (1,'NBA TURKIYE'),(2,'IZMIR ETKINLIKLERI'),(3,'CUKUR'),(1,'CEZMI');

INSERT INTO Facebook.PageAdmin(UserID, PageID)
VALUES (3,13),(4,14);



CREATE TABLE Facebook.Group(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  Name VARCHAR(32) NOT NULL,
  CONSTRAINT Group_pk PRIMARY KEY (ID),
  CONSTRAINT Group_ID_fk FOREIGN KEY (ID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Group_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES Facebook.User(ID)
);

CREATE TABLE Facebook.GroupMember(
  UserID INT UNSIGNED,
  GroupID INT UNSIGNED,
  IsAdmin BOOL NOT NULL ,
  JoinDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT GroupMember_pk PRIMARY KEY (UserID, GroupID),
  CONSTRAINT GroupMember_UserID_fk FOREIGN KEY (UserID) REFERENCES Facebook.User(ID),
  CONSTRAINT GroupMember_GroupID_fk FOREIGN KEY (GroupID) REFERENCES Facebook.Group(ID)
);

CREATE TRIGGER Facebook.BeforeInsertGroup BEFORE INSERT ON Facebook.Group FOR EACH ROW
BEGIN
  INSERT INTO Facebook.Entity (TypeID) SELECT ID FROM Facebook.Type WHERE Name = 'Group';
  SET NEW.ID = LAST_INSERT_ID();
END;

CREATE TRIGGER Facebook.AfterInsertGroup AFTER INSERT ON Facebook.Group FOR EACH ROW
BEGIN
  INSERT INTO Facebook.GroupMember (UserID, GroupID, IsAdmin) VALUES (NEW.CreatorID, NEW.ID, TRUE);
END;

INSERT INTO Facebook.Group (CreatorID, Name)
VALUES   (1,'Manisalılar Briç Kulubü'),(4,'MALATYALILAR DERNEGI'),(9,'FERRARI HASTALARI');

INSERT INTO Facebook.GroupMember(UserID, GroupID, IsAdmin)
VALUES   (6,17,FALSE),(6,18,FALSE),(7,18,FALSE),(7,19,FALSE),(12,19,TRUE);


CREATE TABLE Facebook.Location(
  ID INT UNSIGNED AUTO_INCREMENT,
  Country VARCHAR(32) NOT NULL ,
  City VARCHAR(32) NOT NULL ,
  Place VARCHAR(64) NOT NULL ,
  CONSTRAINT Location_pk PRIMARY KEY (ID)
);
INSERT INTO Facebook.Location (ID,Country,City,Place)
VALUES   (1,'Turkey','Izmır','Ege Universitesi');
INSERT INTO Facebook.Location (Country, City, Place)
VALUES  ('Turkey','Izmır','Tavacı Recep'),
        ('Turkey','Ankara','Otogar'),
        ('Turkey','Ankara','ODTU'),
        ('Spain','Madrid','Santiago Bernabau'),
        ('England','London','London Eye');



CREATE TABLE Facebook.Post(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  LocationID INT UNSIGNED NULL,
  Content VARCHAR(256) NOT NULL,
  CONSTRAINT Post_pk PRIMARY KEY (ID),
  CONSTRAINT Post_ID_fk FOREIGN KEY (ID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Post_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Post_LocationID_fk FOREIGN KEY (LocationID) REFERENCES Facebook.Location(ID)
);

CREATE TRIGGER Facebook.BeforeInsertPost BEFORE INSERT ON Facebook.Post FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM Facebook.Entity e LEFT JOIN Facebook.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CreatorID AND t.Name IN ('Page', 'User')) = 0 THEN
    SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'This entity can not create post';
  END IF;

  INSERT INTO Facebook.Entity (TypeID) SELECT ID FROM Facebook.Type WHERE Name = 'Post';
  SET NEW.ID = LAST_INSERT_ID();
END;
INSERT INTO Facebook.Post (CreatorID, LocationID, Content )
VALUES       (1,1,'Hello World'),
             (1,6,'Yağmurlu Bir Gün'),
             (12,5,'Maç Zamanı'),
             (13,4,'Altyapı Seçmeleri Ankara'),
             (13,1,'Altyapı Seçmeleri İzmir'),
             (15,3,'Racon Sahnesi Kamera Arkası');
INSERT INTO Facebook.Post (CreatorID, Content )
VALUES       (2,'Foto'),
             (2,'Video'),
             (3,'Şampiyon Beşiktaş'),
             (14,'Duman Konseri'),
             (14,'Midye Festivali'),
             (16,'2019 un En komik Videosu');

CREATE TABLE Facebook.Comment(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  CommentableID INT UNSIGNED NOT NULL,
  Content VARCHAR(256),
  CONSTRAINT Comment_pk PRIMARY KEY (ID),
  CONSTRAINT Comment_ID_fk FOREIGN KEY (ID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Comment_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Comment_CommentableID_fk FOREIGN KEY (CommentableID) REFERENCES Facebook.Entity(ID)
);

CREATE TRIGGER Facebook.BeforeInsertComment BEFORE INSERT ON Facebook.Comment FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM Facebook.Entity e LEFT JOIN Facebook.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CreatorID AND t.Name IN ('Page', 'User')) = 0 THEN
    SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'This entity can not comment';
  END IF;

  IF (SELECT COUNT(*) FROM Facebook.Entity e LEFT JOIN Facebook.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CommentableID AND t.Name IN ('Comment', 'Post')) = 0 THEN
    SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'This entity is not commentable';
  END IF;

  INSERT INTO Facebook.Entity (TypeID) SELECT ID FROM Facebook.Type WHERE Name = 'Comment';
  SET NEW.ID = LAST_INSERT_ID();
END;
INSERT INTO Facebook.Comment(CreatorID, CommentableID, Content)
VALUES      (1,21,'Aga Naber'),
            (2,25,'Of Çok Inanılmaz Gaza Geldim'),
            (1,21,'Çok Güzel'),
            (1,24,'Umarım Seçilirim'),
            (2,26,'Harikayım Yine xD'),
            (13,23,'Güzel Bir Ankara Gününden Seçmeler'),
            (13,23,'Son Başvuraları Kaçırmayın'),
            (14,25,'Çekimler Son Hızıyla Devam Ediyor');
INSERT INTO Facebook.Comment(CreatorID, CommentableID, Content)
VALUES      (1,33,'Görüşelim Bir Gün'),
            (1,33,'xD'),
            (2,36,'Aa Benmişim'),
            (13,32,'İyi Sen?'),
            (13,37,'İyi Olan Kazansın'),
            (14,34,'Harika');





CREATE TABLE Facebook.Event(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  LocationID INT UNSIGNED NOT NULL,
  StartDate DATETIME NOT NULL,
  FinishDate DATETIME NOT NULL,
  Name VARCHAR(64) NOT NULL,
  CONSTRAINT Event_pk PRIMARY KEY (ID),
  CONSTRAINT Event_ID_fk FOREIGN KEY (ID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Event_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Event_LocationID_fk FOREIGN KEY (LocationID) REFERENCES Facebook.Location(ID)
);

CREATE TRIGGER Facebook.BeforeInsertEvent BEFORE INSERT ON Facebook.Event FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM Facebook.Entity e LEFT JOIN Facebook.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CreatorID AND t.Name IN ('Page', 'User')) = 0 THEN
    SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'This entity can not create event';
  END IF;
  IF NEW.FinishDate <= NEW.StartDate THEN
    SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'FinishDate must be later than StartDate';
  END IF;
  INSERT INTO Facebook.Entity (TypeID) SELECT ID FROM Facebook.Type WHERE Name = 'Event';
  SET NEW.ID = LAST_INSERT_ID();
END;

INSERT INTO Facebook.Event (CreatorID, LocationID, StartDate, FinishDate,Name)
VALUES      (1,1,'2018-12-31','2019-01-01','Yılbaşı Partisi'),
            (1,1,'2019-01-14','2019-01-15','Tava Festivali'),
            (3,5,'2019-02-20 19:0:0','2019-02-20 21:0:0','Real Madrid-Barcelona'),
            (13,2,'2019-05-25 08:0:0','2019-05-25 17:0:0','Seçmeler Tüm Hızıyla Devam Ediyor'),
            (13,5,'2019-07-04','2019-07-10','Derbi Zamanı'),
            (15,1,'2025-04-16 20:0:0','2025-04-16 21:0:0','Gala');



CREATE TABLE Facebook.EventInteraction(
  EventID INT UNSIGNED,
  UserID INT UNSIGNED,
  Participation  BOOL NOT NULL,
  CONSTRAINT EventInteraction_pk PRIMARY KEY (EventID, UserID),
  CONSTRAINT EventInteraction_EventID_fk FOREIGN KEY (EventID) REFERENCES Facebook.Event(ID),
  CONSTRAINT EventInteraction_UserID_fk FOREIGN KEY (UserID) REFERENCES Facebook.User(ID)
);
INSERT INTO Facebook.EventInteraction (EventID, UserID, Participation)
VALUES      (46,1,TRUE), (51,1,FALSE ), (48,2,FALSE ), (50,3,TRUE ), (46,12,TRUE );





CREATE TABLE Facebook.Like(
  CanLikeID INT UNSIGNED,
  LikeableID INT UNSIGNED,
  LikeTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Like_pk PRIMARY KEY (CanLikeID, LikeableID),
  CONSTRAINT Like_CanLikeID_fk FOREIGN KEY (CanLikeID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Like_LikeableID_fk FOREIGN KEY (LikeableID) REFERENCES Facebook.Entity(ID)
);
CREATE TRIGGER Facebook.BeforeInsertLike BEFORE INSERT ON Facebook.Like FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM Facebook.Entity e LEFT JOIN Facebook.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CanLikeID AND t.Name IN ('Page', 'User')) = 0 THEN
    SIGNAL SQLSTATE '45008' SET MESSAGE_TEXT = 'This entity can not like';
  END IF;

  IF (SELECT COUNT(*) FROM Facebook.Entity e LEFT JOIN Facebook.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.LikeableID AND t.Name IN ('Comment', 'Page', 'Post')) = 0 THEN
    SIGNAL SQLSTATE '45009' SET MESSAGE_TEXT = 'This entity is not likeable';
  END IF;
END;
INSERT INTO Facebook.Like (CanLikeID, LikeableID)
VALUES  (1,20),(1,13),(1,32),(2,20),(2,13),(2,36),(2,35),(3,27),(7,20),(8,20),(10,45),
        (12,16),(13,33),(13,25),(13,14),(14,33),(14,36),(16,28),(16,30),(16,13),(16,14);





CREATE TABLE Facebook.Share(
  UserID INT UNSIGNED,
  ShareableID INT UNSIGNED,
  SharedInID INT UNSIGNED,
  ShareTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Share_pk PRIMARY KEY (UserID, ShareableID, SharedInID),
  CONSTRAINT Share_UserID_fk FOREIGN KEY (UserID) REFERENCES Facebook.User(ID),
  CONSTRAINT Share_ShareableID_fk FOREIGN KEY (ShareableID) REFERENCES Facebook.Entity(ID),
  CONSTRAINT Share_SharedInID_fk FOREIGN KEY (SharedInID) REFERENCES Facebook.Entity(ID)
);
-- User Group/User Event/Group/Page/Post
CREATE TRIGGER Facebook.BeforeInsertShare BEFORE INSERT ON Facebook.Share FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM Facebook.Entity e LEFT JOIN Facebook.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.ShareableID AND t.Name IN ('Event', 'Group', 'Page', 'Post')) = 0 THEN
    SIGNAL SQLSTATE '45010' SET MESSAGE_TEXT = 'This entity is not shareable';
  END IF;

  IF (SELECT COUNT(*) FROM Facebook.Entity e LEFT JOIN Facebook.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.SharedInID AND
      ((t.Name = 'Group' AND (SELECT COUNT(*) FROM GroupMember gm WHERE gm.UserID = NEW.UserID AND gm.GroupID = NEW.SharedInID) > 0) OR (t.Name = 'User' AND NEW.UserID = NEW.SharedInID))) = 0 THEN
    SIGNAL SQLSTATE '45011' SET MESSAGE_TEXT = 'User can not share in this entity';
  END IF;
END;
 INSERT INTO Facebook.Share (UserID, ShareableID, SharedInID)
 VALUES     (4,46,18),(7,46,19),(1,46,17),(2,47,2),(2,46,2),(3,20,3),
            (3,21,3),(10,13,10),(5,31,5),(7,16,18),(9,18,19),(12,18,19);

