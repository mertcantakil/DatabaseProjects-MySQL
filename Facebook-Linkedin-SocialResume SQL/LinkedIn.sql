CREATE SCHEMA LinkedIn CHARACTER SET UTF8;

CREATE TABLE LinkedIn.Type(
  ID INT UNSIGNED AUTO_INCREMENT,
  Name VARCHAR(10),
  CONSTRAINT Type_pk PRIMARY KEY (ID)
);
INSERT INTO LinkedIn.Type (Name)
VALUES ('Comment'), ('Community'), ('Page'), ('Post'), ('User');


CREATE TABLE LinkedIn.Entity(
  ID INT UNSIGNED AUTO_INCREMENT,
  TypeID INT UNSIGNED NOT NULL,
  CreateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Entity_pk PRIMARY KEY (ID),
  CONSTRAINT Entity_TypeID_fk FOREIGN KEY (TypeID) REFERENCES LinkedIn.Type(ID)
);

CREATE TABLE LinkedIn.User(
  ID INT UNSIGNED,
  FirstName VARCHAR(32) NOT NULL,
  MidName VARCHAR(32) NULL,
  LastName VARCHAR(32) NULL,
  Email VARCHAR(64) NOT NULL,
  Location VARCHAR(128) NOT NULL,
  BirthDate DATE NOT NULL,
  IsMale BOOL NOT NULL,
  PhoneNo VARCHAR(11) NULL,
  SettingsLanguage VARCHAR(6) NOT NULL,
  Skills VARCHAR(128) NOT NULL,
  CONSTRAINT User_pk PRIMARY KEY (ID),
  CONSTRAINT User_ID_fk FOREIGN KEY (ID) REFERENCES LinkedIn.Entity(ID)
);

CREATE TRIGGER LinkedIn.BeforeInsertUser BEFORE INSERT ON LinkedIn.User FOR EACH ROW
BEGIN
  INSERT INTO LinkedIn.Entity (TypeID) SELECT ID FROM LinkedIn.Type WHERE Name = 'User';
  SET NEW.ID = LAST_INSERT_ID();
END;

INSERT INTO LinkedIn.User (FirstName, MidName, LastName, Email, Location, BirthDate, IsMale, PhoneNo, SettingsLanguage,Skills)
VALUES ('Ahmet', 'Faruk', 'Aktas', 'a.farukakts@outlook.com','MANISA', '1996-02-20',TRUE ,'05424060743','tr-TR','c#,c++'),
       ('Mertcan', '', 'Takil','mertcantakil@gmail.com','ESKISEHIR','1996-09-18',TRUE ,'05459522854','tr-TR','c++,java'),
       ('Serkay', '', 'Yuksel','serkayyuksel@gmail.com','BANDIRMA','1996-01-14',TRUE ,'05388903514','tr-TR','c,java,sql'),
       ('Mehmet','Ali','Tosun','mali@gmail.com','PARIS','1989-10-22',TRUE ,'05324563245','fr-FR','pyhton,sql'),
       ('Konuralp','','Güler','afy@gmail.com','WASHINGTON','1992-03-19',FALSE ,'05556773245','en-US','pyhton,c++'),
       ('John','','Wash','john@gmail.com','ANTALYA','1970-04-22',TRUE ,'0532456945','cs-CZ','c,html,sql'),
       ('Micheal','','Schummer','michealsch@gmail.com','BERLIN','1960-06-19',TRUE ,'045855245','de-de','java,html,sql'),
       ('Micheal','Emily','Faker','michealemily@hotmail.com','LOS ANGELES','1994-07-12',FALSE ,'05544444245','en-UK','c,sql'),
       ('Mehmet','','Tosun','mali@gmail.com','PARIS','1989-10-22',TRUE ,'05324563245','fr-FR','java,html,sql'),
       ('Polina','','Ergonova','polina@vk.com','MOSCOW','2000-08-08',FALSE ,'2934923445','ru-RU','c,sql');

CREATE TABLE LinkedIn.Connection(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  Since DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Connection_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT Connection_User1ID_fk FOREIGN KEY (User1ID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT Connection_User2ID_fk FOREIGN KEY (User2ID) REFERENCES LinkedIn.User(ID)
);
CREATE TRIGGER LinkedIn.BeforeInsertConnection BEFORE INSERT ON LinkedIn.Connection FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM LinkedIn.Connection WHERE (User1ID = NEW.User2ID AND User2ID = NEW.User1ID)) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Users are already connected';
  END IF;
END;
INSERT INTO LinkedIn.Connection(User1ID, User2ID)
VALUES (1,2),(1,3),(1,7),(1,10),
            (2,4),(2,5),(2,10),
            (3,2),(3,5),(3,10),
            (8,9);

CREATE TABLE LinkedIn.ConnectionInvite(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  SendTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ConnectionInvite_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT ConnectionInvite_User1ID_fk FOREIGN KEY (User1ID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT ConnectionInvite_User2ID_fk FOREIGN KEY (User2ID) REFERENCES LinkedIn.User(ID)
);
CREATE TRIGGER LinkedIn.BeforeInsertConnectionInvite BEFORE INSERT ON LinkedIn.ConnectionInvite FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM LinkedIn.Connection WHERE  (User1ID = NEW.User1ID AND User2ID = NEW.User2ID) OR (User1ID = NEW.User2ID AND User2ID = NEW.User1ID)) > 0 THEN
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Users are already connected';
  END IF;

  IF (SELECT COUNT(*) FROM LinkedIn.ConnectionInvite WHERE User1ID = NEW.User2ID AND User2ID = NEW.User1ID) > 0 THEN
    SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Invite received from this user';
  END IF;
END;
INSERT INTO LinkedIn.ConnectionInvite (User1ID, User2ID)
VALUES (1,8),(2,9),(3,9),(5,1);


CREATE TABLE LinkedIn.Recommend(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  Content VARCHAR(256) NOT NULL,
  WriteTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Recommend_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT Recommend_User1ID_fk FOREIGN KEY (User1ID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT Recommend_User2ID_fk FOREIGN KEY (User2ID) REFERENCES LinkedIn.User(ID)
);
INSERT INTO LinkedIn.Recommend(User1ID, User2ID, Content)
VALUES (1,2,'Kullanici hakkinda tavsiye 0'),(1,3,'Kullanici hakkinda tavsiye 1'),(1,7,'Kullanici hakkinda tavsiye 2'),(1,10,'Kullanici hakkinda tavsiye 3'),
            (2,4,'Kullanici hakkinda tavsiye 4'),(2,5,'Kullanici hakkinda tavsiye 5'),(2,10,'Kullanici hakkinda tavsiye 6'),
            (3,2,'Kullanici hakkinda tavsiye 7'),(3,5,'Kullanici hakkinda tavsiye 8'),(3,10,'Kullanici hakkinda tavsiye 9'),
            (8,9,'Kullanici hakkinda tavsiye 10');

CREATE TABLE LinkedIn.RecommendRequest(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  SendTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  ApproveTime DATETIME NULL,
  CONSTRAINT RecommendRequest_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT RecommendRequest_User1ID_fk FOREIGN KEY (User1ID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT RecommendRequest_User2ID_fk FOREIGN KEY (User2ID) REFERENCES LinkedIn.User(ID)
);

INSERT INTO LinkedIn.RecommendRequest (User1ID, User2ID, ApproveTime)
VALUES (1,8,'2018-09-22'),(2,9,'2017-06-13'),(3,9,'2018-05-28'),(5,1,'2016-07-05');

INSERT INTO LinkedIn.RecommendRequest (User1ID, User2ID)
VALUES (2,8),(7,9),(10,9),(4,1);


CREATE TABLE LinkedIn.Message(
  ID INT UNSIGNED AUTO_INCREMENT,
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  Content VARCHAR(256),
  SendTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  ReceiveTime DATETIME NULL,
  CONSTRAINT Message_pk PRIMARY KEY (ID),
  CONSTRAINT Message_User1ID_fk FOREIGN KEY (User1ID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT Message_User2ID_fk FOREIGN KEY (User2ID) REFERENCES LinkedIn.User(ID)
);
INSERT INTO LinkedIn.Message(User1ID, User2ID, Content)
VALUES      (1,2,'Dgko'),
            (1,3,'Ty'),
            (2,10,'Helloo'),
            (3,5,'Whatsup?');
INSERT INTO LinkedIn.Message(User1ID, User2ID, Content, ReceiveTime)
VALUES      (8,9,'Heey!',NOW()),
            (9,8,'Hii:)',NOW()),
            (8,9,'How was your today?',NOW()),
            (9,8,'very busy..',NULL),
            (2,6,'Beni ekler misin',NULL),
            (3,10,'Geliyorum',NOW());


CREATE TABLE LinkedIn.Page(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  Location VARCHAR(128) NOT NULL,
  Industry VARCHAR(64) NOT NULL,
  Name VARCHAR(32) NOT NULL,
  Specialities VARCHAR(256) NULL,-- Bossa EduPage'dir
  CONSTRAINT Page_pk PRIMARY KEY (ID),
  CONSTRAINT Page_ID_fk FOREIGN KEY (ID) REFERENCES LinkedIn.Entity(ID),
  CONSTRAINT Page_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES LinkedIn.User(ID)
);

CREATE TABLE LinkedIn.PageAdmin(
  UserID INT UNSIGNED,
  PageID INT UNSIGNED,
  CONSTRAINT PageAdmin_pk PRIMARY KEY (UserID, PageID),
  CONSTRAINT PageAdmin_UserID_fk FOREIGN KEY (UserID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT PageAdmin_PageID_fk FOREIGN KEY (PageID) REFERENCES LinkedIn.Page(ID)
);

CREATE TRIGGER LinkedIn.BeforeInsertPage BEFORE INSERT ON LinkedIn.Page FOR EACH ROW
BEGIN
  INSERT INTO LinkedIn.Entity (TypeID) SELECT ID FROM LinkedIn.Type WHERE Name = 'Page';
  SET NEW.ID = LAST_INSERT_ID();
END;
CREATE TRIGGER LinkedIn.AfterInsertPage AFTER INSERT ON LinkedIn.Page FOR EACH ROW
BEGIN
  INSERT INTO LinkedIn.PageAdmin (UserID, PageID) VALUES (NEW.CreatorID, NEW.ID);
END;
INSERT INTO LinkedIn.Page(CreatorID, Location, Industry, Name, Specialities)
VALUES (1,'ANKARA','YAZILIM ŞİRKETİ','DATABASE','SAS,SOFTWARE DEVELOPMENT '),
       (1,'MANAVGAT','BIRA','EFES PİLSEN','Arpa üretimi ve bira yapımı'),
       (2,'ISTANBUL','AYAKKABI','JAPON AYAKKABICILIK','En hızlı zamanda üretilen ayakkabılar'),
       (3,'BRAZIL','FUTBOL','SAMBA TEAM','Futbol Fabrikası');
INSERT INTO LinkedIn.Page(CreatorID, Location, Industry, Name)
VALUES (3,'TURKEY','OKUL','HERKES OKUSUN');


CREATE TABLE LinkedIn.ExperienceAndEduInfo(
  ID INT UNSIGNED AUTO_INCREMENT,
  UserID INT UNSIGNED,
  PageID INT UNSIGNED,
  StartDate DATE NOT NULL,
  FinishDate DATE NULL,
  PositionOrDegree VARCHAR(64) NOT NULL,
  CONSTRAINT Experience_pk PRIMARY KEY (ID),
  CONSTRAINT Experience_UserID_fk FOREIGN KEY (UserID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT Experience_PageID_fk FOREIGN KEY (PageID) REFERENCES LinkedIn.Page(ID)
);

CREATE TRIGGER LinkedIn.BeforeInsertExperienceAndEduInfo BEFORE INSERT ON LinkedIn.ExperienceAndEduInfo FOR EACH ROW
BEGIN
  IF NEW.FinishDate IS NOT NULL AND (NEW.FinishDate <= NEW.StartDate) THEN
    SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'FinishDate must be greater than StartDate';
  END IF;
END;
-- Experience
INSERT INTO LinkedIn.ExperienceAndEduInfo (UserID, PageID, StartDate, FinishDate, PositionOrDegree)
VALUES (1,11,'2017-05-20','2017-12-31','Software Development'),
       (1,12,'2018-01-01','2018-06-25','Yazılım Uzmanı'),
       (2,13,'2018-12-25','2018-12-26','İş analisti');
INSERT INTO LinkedIn.ExperienceAndEduInfo(UserID, PageID, StartDate, PositionOrDegree)
VALUES (1,14,'2018-07-30','C++ Uzmanı'),
       (5,14,'2018-12-20','Java Uzmanı');
-- EduInfo
INSERT INTO LinkedIn.ExperienceAndEduInfo(UserID, PageID, StartDate, FinishDate, PositionOrDegree)
VALUES (9,15,'2014-08-26','2018-07-14','Lisans'),
       (1,15,'2014-12-25','2017-06-17','Yukseklisans'),
       (3,15,'2014-02-15','2018-12-12','lisans');
INSERT INTO LinkedIn.ExperienceAndEduInfo(UserID, PageID, StartDate,PositionOrDegree)
VALUES (2,15,'2010-06-06','Lisans'),
       (5,15,'2016-12-02','Doktora');

CREATE TABLE LinkedIn.JobAdvert(
  ID INT UNSIGNED AUTO_INCREMENT,
  PageID INT UNSIGNED,
  Location VARCHAR(128) NOT NULL,
  PublishTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  Position VARCHAR(32) NOT NULL,
  Name VARCHAR(32) NOT NULL,
  CONSTRAINT JobAdvert_pk PRIMARY KEY (ID),
  CONSTRAINT JobAdvert_PageID_fk FOREIGN KEY (PageID) REFERENCES LinkedIn.Page(ID)
);

CREATE TRIGGER LinkedIn.BeforeInsertJobAdvert BEFORE INSERT ON LinkedIn.JobAdvert FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM LinkedIn.Page WHERE ID = NEW.PageID AND Specialities IS NOT NULL) = 0 THEN
    SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'CompanyPage not found';
  END IF;
END;
INSERT INTO LinkedIn.JobAdvert(PageID, Location, Position, Name)
VALUES (14,'ARJANTIN','Müdür','Genel Müdür alımı'),
       (12,'INGILTERE','Sofware Development','C Uzmanı'),
       (11,'MARDIN','İş analisti','İş Analist Uzmanı');

CREATE TABLE LinkedIn.JobApply(
  UserID INT UNSIGNED,
  JobAdvertID INT UNSIGNED,
  ApplyTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT JobApply_pk PRIMARY KEY (UserID, JobAdvertID),
  CONSTRAINT JobApply_UserID_fk FOREIGN KEY (UserID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT JobApply_JobAdvertID_fk FOREIGN KEY (JobAdvertID) REFERENCES LinkedIn.JobAdvert(ID)
);
INSERT INTO LinkedIn.JobApply(UserID, JobAdvertID)
VALUES (1,1),(1,2),(1,3),(5,1),(5,2),(8,3);

CREATE TABLE LinkedIn.ShowcasePage(
  ID INT UNSIGNED AUTO_INCREMENT,
  PageID INT UNSIGNED,
  Name VARCHAR(32) NOT NULL,
  Content VARCHAR(256) NOT NULL,
  CreateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ShowcasePage_pk PRIMARY KEY (ID),
  CONSTRAINT ShowcasePage_PageID_fk FOREIGN KEY (PageID) REFERENCES LinkedIn.Page(ID)
);
INSERT INTO LinkedIn.ShowcasePage(PageID, Name, Content)
VALUES (11,'Izmır Şubesi','Yazılımcı mısınız, buyrun gelin'),
       (11,'Istanbul Şubesi','İş Analisti alımı'),
       (12,'Tadım Uzmanı','100 çeşit biramızdan tadabilirsiniz ');


CREATE TABLE LinkedIn.Community(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  Name VARCHAR(32) NOT NULL,
  CONSTRAINT Community_pk PRIMARY KEY (ID),
  CONSTRAINT Community_ID_fk FOREIGN KEY (ID) REFERENCES LinkedIn.Entity(ID),
  CONSTRAINT Community_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES LinkedIn.User(ID)
);

CREATE TABLE LinkedIn.CommunityMember(
  UserID INT UNSIGNED,
  CommunityID INT UNSIGNED,
  IsAdmin BOOL NOT NULL,
  JoinDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT CommunityMember_pk PRIMARY KEY (UserID, CommunityID),
  CONSTRAINT CommunityMember_UserID_fk FOREIGN KEY (UserID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT CommunityMember_CommunityID_fk FOREIGN KEY (CommunityID) REFERENCES LinkedIn.Community(ID)
);

CREATE TRIGGER LinkedIn.BeforeInsertCommunity BEFORE INSERT ON LinkedIn.Community FOR EACH ROW
BEGIN
  INSERT INTO LinkedIn.Entity (TypeID) SELECT ID FROM LinkedIn.Type WHERE Name = 'Community';
  SET NEW.ID = LAST_INSERT_ID();
END;
CREATE TRIGGER LinkedIn.AfterInsertCommunity AFTER INSERT ON LinkedIn.Community FOR EACH ROW
BEGIN
  INSERT INTO LinkedIn.CommunityMember (UserID, CommunityID, IsAdmin) VALUES (NEW.CreatorID, NEW.ID, TRUE);
END;
INSERT INTO LinkedIn.Community(CreatorID, Name)
VALUES (1,'İzmir Yazılımcıları'),
       (2,'İş Analisti Uzmanları'),
       (8,'90 Günde devri-alem');
INSERT INTO LinkedIn.CommunityMember(UserID, CommunityID, IsAdmin)
VALUES (3,16,TRUE),(5,16,TRUE),(7,17,TRUE),(10,18,TRUE),(4,16,FALSE),(3,17,FALSE);

CREATE TABLE LinkedIn.Post(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  Content VARCHAR(256) NOT NULL,
  CONSTRAINT Post_pk PRIMARY KEY (ID),
  CONSTRAINT Post_ID_fk FOREIGN KEY (ID) REFERENCES LinkedIn.Entity(ID),
  CONSTRAINT Post_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES LinkedIn.Entity(ID)
);

CREATE TRIGGER LinkedIn.BeforeInsertPost BEFORE INSERT ON LinkedIn.Post FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM LinkedIn.Entity e LEFT JOIN LinkedIn.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CreatorID AND t.Name IN ('Page', 'User')) = 0 THEN
    SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'This entity can not create post';
  END IF;

  INSERT INTO LinkedIn.Entity (TypeID) SELECT ID FROM LinkedIn.Type WHERE Name = 'Post';
  SET NEW.ID = LAST_INSERT_ID();
END;
INSERT INTO LinkedIn.Post(CreatorID, Content)
VALUES (1,'Harika Bir Video'),
       (1,'Çok eğlenceli'),
       (2,'Dikkatle izleyiniz'),
       (11,'2018 in en çok gelişen şirketi seçildik'),
       (11,'Bu kazandığımız ödülü bütün çalışanlarımız için aldık'),
       (14,'Pazartesi sendromunu atlatmak için mutlaka izleyiniz');

CREATE TABLE LinkedIn.Comment(
  ID INT UNSIGNED,
  UserID INT UNSIGNED NOT NULL,
  CommentableID INT UNSIGNED NOT NULL,
  Content VARCHAR(256),
  CONSTRAINT Comment_pk PRIMARY KEY (ID),
  CONSTRAINT Comment_ID_fk FOREIGN KEY (ID) REFERENCES LinkedIn.Entity(ID),
  CONSTRAINT Comment_UserID_fk FOREIGN KEY (UserID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT Comment_CommentableID_fk FOREIGN KEY (CommentableID) REFERENCES LinkedIn.Entity(ID)
);

CREATE TRIGGER LinkedIn.BeforeInsertComment BEFORE INSERT ON LinkedIn.Comment FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM LinkedIn.Entity e LEFT JOIN LinkedIn.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CommentableID AND t.Name IN ('Comment', 'Post')) = 0 THEN
    SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'This entity is not commentable';
  END IF;

  INSERT INTO LinkedIn.Entity (TypeID) SELECT ID FROM LinkedIn.Type WHERE Name = 'Comment';
  SET NEW.ID = LAST_INSERT_ID();
END;
INSERT INTO LinkedIn.Comment(UserID, CommentableID, Content)
VALUES (5,19,'Hariden çok güzel bir video'),
       (5,19,'Çok sevimliler'),
       (5,20,'Gerçekten çok etkilendim'),
       (1,21,'Gerçekten heyecanlı'),
       (2,22,'keşke herkes işini böyle yapsa');


CREATE TABLE LinkedIn.Like(
  UserID INT UNSIGNED,
  LikeableID INT UNSIGNED,
  LikeTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Like_pk PRIMARY KEY (UserID, LikeableID),
  CONSTRAINT Like_UserID_fk FOREIGN KEY (UserID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT Like_LikeableID_fk FOREIGN KEY (LikeableID) REFERENCES LinkedIn.Entity(ID)
);
CREATE TRIGGER LinkedIn.BeforeInsertLike BEFORE INSERT ON LinkedIn.Like FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM LinkedIn.Entity e LEFT JOIN LinkedIn.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.LikeableID AND t.Name IN ('Comment', 'Post')) = 0 THEN
    SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'This entity is not likeable';
  END IF;
END;
INSERT INTO LinkedIn.Like(UserID, LikeableID)
VALUES(1,19),(1,20),(1,26),(1,27),(2,19),(2,26),(3,21),(4,28);



CREATE TABLE LinkedIn.Follow(
  UserID INT UNSIGNED,
  FollowableID INT UNSIGNED,
  FollowTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Follow_pk PRIMARY KEY (UserID, FollowableID),
  CONSTRAINT Follow_UserID_fk FOREIGN KEY (UserID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT Follow_FollowableID_fk FOREIGN KEY (FollowableID) REFERENCES LinkedIn.Entity(ID)
);
CREATE TRIGGER LinkedIn.BeforeInsertFollow BEFORE INSERT ON LinkedIn.Follow FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM LinkedIn.Entity e LEFT JOIN LinkedIn.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.FollowableID AND t.Name IN ('Community', 'Page')) = 0 THEN
    SIGNAL SQLSTATE '45008' SET MESSAGE_TEXT = 'This entity is not followable';
  END IF;
END;
INSERT INTO LinkedIn.Follow(UserID, FollowableID)
VALUES(1,11),(1,12),(1,15),(1,17),(2,11),(2,16),(3,13),(4,18);


CREATE TABLE LinkedIn.Share(
  UserID INT UNSIGNED,
  PostID INT UNSIGNED,
  ShareTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Share_pk PRIMARY KEY (UserID, PostID),
  CONSTRAINT Share_UserID_fk FOREIGN KEY (UserID) REFERENCES LinkedIn.User(ID),
  CONSTRAINT Share_PostID_fk FOREIGN KEY (PostID) REFERENCES LinkedIn.Post(ID)
);
INSERT INTO LinkedIn.Share(UserID, PostID)
VALUES (1,21),(1,22),(2,19),(3,23);


