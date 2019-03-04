CREATE SCHEMA SocialResume CHARACTER SET UTF8;

CREATE TABLE SocialResume.Type(
  ID INT UNSIGNED AUTO_INCREMENT,
  Name VARCHAR(10),
  CONSTRAINT Type_pk PRIMARY KEY (ID)
);
INSERT INTO SocialResume.Type (Name)
VALUES ('Comment'), ('Event'), ('Group'), ('Page'), ('Post'), ('User');

CREATE TABLE SocialResume.Entity(
  ID INT UNSIGNED AUTO_INCREMENT,
  TypeID INT UNSIGNED NOT NULL,
  CreateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Entity_pk PRIMARY KEY (ID),
  CONSTRAINT Entity_TypeID_fk FOREIGN KEY (TypeID) REFERENCES SocialResume.Type(ID)
);

CREATE TABLE SocialResume.User(
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
  CONSTRAINT User_ID_fk FOREIGN KEY (ID) REFERENCES SocialResume.Entity(ID)
);

CREATE TRIGGER SocialResume.BeforeInsertUser BEFORE INSERT ON SocialResume.User FOR EACH ROW
BEGIN
  INSERT INTO SocialResume.Entity (TypeID) SELECT ID FROM SocialResume.Type WHERE Name = 'User';
  SET NEW.ID = LAST_INSERT_ID();
END;

INSERT INTO SocialResume.User (FirstName, MidName, LastName, Email, Location, BirthDate, IsMale, PhoneNo, SettingsLanguage,Skills)
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

CREATE TABLE SocialResume.Friendship(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  Since DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Friendship_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT Friendship_User1ID_fk FOREIGN KEY (User1ID) REFERENCES SocialResume.User(ID),
  CONSTRAINT Friendship_User2ID_fk FOREIGN KEY (User2ID) REFERENCES SocialResume.User(ID)
);
CREATE TRIGGER SocialResume.BeforeInsertFriendship BEFORE INSERT ON SocialResume.Friendship FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM SocialResume.Friendship WHERE (User1ID = NEW.User2ID AND User2ID = NEW.User1ID)) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Users are already friend';
  END IF;
END;
INSERT INTO SocialResume.Friendship(User1ID, User2ID)
VALUES      (1,2),(1,3),(1,7),(1,8),
            (2,4),(2,5),(2,10),
            (3,2),(3,5),(3,9),
            (8,9);

CREATE TABLE SocialResume.FriendshipRequest(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  SendTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT FriendshipRequest_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT FriendshipRequest_User1ID_fk FOREIGN KEY (User1ID) REFERENCES SocialResume.User(ID),
  CONSTRAINT FriendshipRequest_User2ID_fk FOREIGN KEY (User2ID) REFERENCES SocialResume.User(ID)
);
CREATE TRIGGER SocialResume.BeforeInsertFriendshipRequest BEFORE INSERT ON SocialResume.FriendshipRequest FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM SocialResume.Friendship WHERE (User1ID = NEW.User1ID AND User2ID = NEW.User2ID) OR (User1ID = NEW.User2ID AND User2ID = NEW.User1ID)) > 0 THEN
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Users are already friend';
  END IF;

  IF (SELECT COUNT(*) FROM SocialResume.FriendshipRequest WHERE User1ID = NEW.User2ID AND User2ID = NEW.User1ID) > 0 THEN
    SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'Request received from this user';
  END IF;
END;
INSERT INTO SocialResume.FriendshipRequest(User1ID, User2ID)
VALUES     (1,6),(2,8),(3,10),(5,1);

CREATE TABLE SocialResume.Recommend(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  Content VARCHAR(256) NOT NULL,
  WriteTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Recommend_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT Recommend_User1ID_fk FOREIGN KEY (User1ID) REFERENCES SocialResume.User(ID),
  CONSTRAINT Recommend_User2ID_fk FOREIGN KEY (User2ID) REFERENCES SocialResume.User(ID)
);
INSERT INTO SocialResume.Recommend(User1ID, User2ID, Content)
VALUES (1,2,'Kullanici hakkinda tavsiye 0'),(1,3,'Kullanici hakkinda tavsiye 1'),(1,7,'Kullanici hakkinda tavsiye 2'),(1,10,'Kullanici hakkinda tavsiye 3'),
            (2,4,'Kullanici hakkinda tavsiye 4'),(2,5,'Kullanici hakkinda tavsiye 5'),(2,10,'Kullanici hakkinda tavsiye 6'),
            (3,2,'Kullanici hakkinda tavsiye 7'),(3,5,'Kullanici hakkinda tavsiye 8'),(3,10,'Kullanici hakkinda tavsiye 9'),
            (8,9,'Kullanici hakkinda tavsiye 10');

CREATE TABLE SocialResume.RecommendRequest(
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  SendTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  ApproveTime DATETIME NULL,
  CONSTRAINT RecommendRequest_pk PRIMARY KEY (User1ID, User2ID),
  CONSTRAINT RecommendRequest_User1ID_fk FOREIGN KEY (User1ID) REFERENCES SocialResume.User(ID),
  CONSTRAINT RecommendRequest_User2ID_fk FOREIGN KEY (User2ID) REFERENCES SocialResume.User(ID)
);

INSERT INTO SocialResume.RecommendRequest (User1ID, User2ID, ApproveTime)
VALUES (1,8,'2018-09-22'),(2,9,'2017-06-13'),(3,9,'2018-05-28'),(5,1,'2016-07-05');

INSERT INTO SocialResume.RecommendRequest (User1ID, User2ID)
VALUES (2,8),(7,9),(10,9),(4,1);

CREATE TABLE SocialResume.Message(
  ID INT UNSIGNED AUTO_INCREMENT,
  User1ID INT UNSIGNED,
  User2ID INT UNSIGNED,
  Content VARCHAR(256),
  SendTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  ReceiveTime DATETIME NULL,
  CONSTRAINT Message_pk PRIMARY KEY (ID),
  CONSTRAINT Message_User1ID_fk FOREIGN KEY (User1ID) REFERENCES SocialResume.User(ID),
  CONSTRAINT Message_User2ID_fk FOREIGN KEY (User2ID) REFERENCES SocialResume.User(ID)
);
INSERT INTO SocialResume.Message(User1ID, User2ID, Content)
VALUES      (1,2,'Dgko'),
            (1,3,'Ty'),
            (2,10,'Helloo'),
            (3,5,'Whatsup?');
INSERT INTO SocialResume.Message(User1ID, User2ID, Content, ReceiveTime)
VALUES      (8,9,'Heey!',NOW()),
            (9,8,'Hii:)',NOW()),
            (8,9,'How was your today?',NOW()),
            (9,8,'very busy..',NULL),
            (2,6,'Beni ekler misin',NULL),
            (3,10,'Geliyorum',NOW());

CREATE TABLE SocialResume.Page(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  Location VARCHAR(128) NULL,
  Industry VARCHAR(64) NULL,
  Name VARCHAR(32) NOT NULL,
  Specialities VARCHAR(256) NULL,-- NULL sa EduPage'dir Degilse sirket bos stringse normal sayfa
  CONSTRAINT Page_pk PRIMARY KEY (ID),
  CONSTRAINT Page_ID_fk FOREIGN KEY (ID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Page_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES SocialResume.User(ID)
);

CREATE TABLE SocialResume.PageAdmin(
  UserID INT UNSIGNED,
  PageID INT UNSIGNED,
  CONSTRAINT PageAdmin_pk PRIMARY KEY (UserID, PageID),
  CONSTRAINT PageAdmin_UserID_fk FOREIGN KEY (UserID) REFERENCES SocialResume.User(ID),
  CONSTRAINT PageAdmin_PageID_fk FOREIGN KEY (PageID) REFERENCES SocialResume.Page(ID)
);

CREATE TRIGGER SocialResume.BeforeInsertPage BEFORE INSERT ON SocialResume.Page FOR EACH ROW
BEGIN
  INSERT INTO SocialResume.Entity (TypeID) SELECT ID FROM SocialResume.Type WHERE Name = 'Page';
  SET NEW.ID = LAST_INSERT_ID();
END;
CREATE TRIGGER SocialResume.AfterInsertPage AFTER INSERT ON SocialResume.Page FOR EACH ROW
BEGIN
  INSERT INTO SocialResume.PageAdmin (UserID, PageID) VALUES (NEW.CreatorID, NEW.ID);
END;
-- Company Page
INSERT INTO SocialResume.Page(CreatorID, Location, Industry, Name, Specialities)
VALUES (1,'ANKARA','YAZILIM ŞİRKETİ','DATABASE','SAS,SOFTWARE DEVELOPMENT '),
       (1,'MANAVGAT','BIRA','EFES PİLSEN','Arpa üretimi ve bira yapımı'),
       (2,'ISTANBUL','AYAKKABI','JAPON AYAKKABICILIK','En hızlı zamanda üretilen ayakkabılar'),
       (3,'BRAZIL','FUTBOL','SAMBA TEAM','Futbol Fabrikası');
-- EduPage
INSERT INTO SocialResume.Page(CreatorID, Location, Industry, Name)
VALUES (3,'TURKEY','OKUL','HERKES OKUSUN');
-- Normal Sayfa
INSERT INTO SocialResume.Page(CreatorID,Name,Specialities)
VALUES (1,'NBA TURKIYE',''),(2,'IZMIR ETKINLIKLERI',''),(3,'CUKUR',''),(1,'CEZMI','');

INSERT INTO SocialResume.PageAdmin(UserID, PageID)
VALUES (3,13),(4,14);

CREATE TABLE SocialResume.ExperienceAndEduInfo(
  ID INT UNSIGNED AUTO_INCREMENT,
  UserID INT UNSIGNED,
  PageID INT UNSIGNED,
  StartDate DATE NOT NULL,
  FinishDate DATE NULL,
  PositionOrDegree VARCHAR(64) NOT NULL,
  CONSTRAINT Experience_pk PRIMARY KEY (ID),
  CONSTRAINT Experience_UserID_fk FOREIGN KEY (UserID) REFERENCES SocialResume.User(ID),
  CONSTRAINT Experience_PageID_fk FOREIGN KEY (PageID) REFERENCES SocialResume.Page(ID)
);

CREATE TRIGGER SocialResume.BeforeInsertExperienceAndEduInfo BEFORE INSERT ON SocialResume.ExperienceAndEduInfo FOR EACH ROW
BEGIN
  IF NEW.FinishDate IS NOT NULL AND (NEW.FinishDate <= NEW.StartDate) THEN
    SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'FinishDate must be greater than StartDate';
  END IF;
END;
-- Experience
INSERT INTO SocialResume.ExperienceAndEduInfo (UserID, PageID, StartDate, FinishDate, PositionOrDegree)
VALUES (1,11,'2017-05-20','2017-12-31','Software Development'),
       (1,12,'2018-01-01','2018-06-25','Yazılım Uzmanı'),
       (2,13,'2018-12-25','2018-12-26','İş analisti');
INSERT INTO SocialResume.ExperienceAndEduInfo(UserID, PageID, StartDate, PositionOrDegree)
VALUES (1,14,'2018-07-30','C++ Uzmanı'),
       (5,14,'2018-12-20','Java Uzmanı');
-- EduInfo
INSERT INTO SocialResume.ExperienceAndEduInfo(UserID, PageID, StartDate, FinishDate, PositionOrDegree)
VALUES (9,15,'2014-08-26','2018-07-14','Lisans'),
       (1,15,'2014-12-25','2017-06-17','Yukseklisans'),
       (3,15,'2014-02-15','2018-12-12','lisans');
INSERT INTO SocialResume.ExperienceAndEduInfo(UserID, PageID, StartDate,PositionOrDegree)
VALUES (2,15,'2010-06-06','Lisans'),
       (5,15,'2016-12-02','Doktora');

CREATE TABLE SocialResume.JobAdvert(
  ID INT UNSIGNED AUTO_INCREMENT,
  PageID INT UNSIGNED,
  Location VARCHAR(128) NOT NULL,
  PublishTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  Position VARCHAR(32) NOT NULL,
  Name VARCHAR(32) NOT NULL,
  CONSTRAINT JobAdvert_pk PRIMARY KEY (ID),
  CONSTRAINT JobAdvert_PageID_fk FOREIGN KEY (PageID) REFERENCES SocialResume.Page(ID)
);

CREATE TRIGGER SocialResume.BeforeInsertJobAdvert BEFORE INSERT ON SocialResume.JobAdvert FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM SocialResume.Page WHERE ID = NEW.PageID AND Specialities IS NOT NULL) = 0 THEN
    SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'CompanyPage not found';
  END IF;
END;
INSERT INTO SocialResume.JobAdvert(PageID, Location, Position, Name)
VALUES (14,'ARJANTIN','Müdür','Genel Müdür alımı'),
       (12,'INGILTERE','Sofware Development','C Uzmanı'),
       (11,'MARDIN','İş analisti','İş Analist Uzmanı');

CREATE TABLE SocialResume.JobApply(
  UserID INT UNSIGNED,
  JobAdvertID INT UNSIGNED,
  ApplyTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT JobApply_pk PRIMARY KEY (UserID, JobAdvertID),
  CONSTRAINT JobApply_UserID_fk FOREIGN KEY (UserID) REFERENCES SocialResume.User(ID),
  CONSTRAINT JobApply_JobAdvertID_fk FOREIGN KEY (JobAdvertID) REFERENCES SocialResume.JobAdvert(ID)
);
INSERT INTO SocialResume.JobApply(UserID, JobAdvertID)
VALUES (1,1),(1,2),(1,3),(5,1),(5,2),(8,3);

CREATE TABLE SocialResume.ShowcasePage(
  ID INT UNSIGNED AUTO_INCREMENT,
  PageID INT UNSIGNED,
  Name VARCHAR(32) NOT NULL,
  Content VARCHAR(256) NOT NULL,
  CreateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ShowcasePage_pk PRIMARY KEY (ID),
  CONSTRAINT ShowcasePage_PageID_fk FOREIGN KEY (PageID) REFERENCES SocialResume.Page(ID)
);
INSERT INTO SocialResume.ShowcasePage(PageID, Name, Content)
VALUES (11,'Izmır Şubesi','Yazılımcı mısınız, buyrun gelin'),
       (11,'Istanbul Şubesi','İş Analisti alımı'),
       (12,'Tadım Uzmanı','100 çeşit biramızdan tadabilirsiniz ');

CREATE TABLE SocialResume.Group(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  Name VARCHAR(32) NOT NULL,
  CONSTRAINT Group_pk PRIMARY KEY (ID),
  CONSTRAINT Group_ID_fk FOREIGN KEY (ID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Group_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES SocialResume.User(ID)
);

CREATE TABLE SocialResume.GroupMember(
  UserID INT UNSIGNED,
  GroupID INT UNSIGNED,
  IsAdmin BOOL NOT NULL ,
  JoinDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT GroupMember_pk PRIMARY KEY (UserID, GroupID),
  CONSTRAINT GroupMember_UserID_fk FOREIGN KEY (UserID) REFERENCES SocialResume.User(ID),
  CONSTRAINT GroupMember_GroupID_fk FOREIGN KEY (GroupID) REFERENCES SocialResume.Group(ID)
);

CREATE TRIGGER SocialResume.BeforeInsertGroup BEFORE INSERT ON SocialResume.Group FOR EACH ROW
BEGIN
  INSERT INTO SocialResume.Entity (TypeID) SELECT ID FROM SocialResume.Type WHERE Name = 'Group';
  SET NEW.ID = LAST_INSERT_ID();
END;

CREATE TRIGGER SocialResume.AfterInsertGroup AFTER INSERT ON SocialResume.Group FOR EACH ROW
BEGIN
  INSERT INTO SocialResume.GroupMember (UserID, GroupID, IsAdmin) VALUES (NEW.CreatorID, NEW.ID, TRUE);
END;

INSERT INTO SocialResume.Group(CreatorID, Name)
VALUES (1,'İzmir Yazılımcıları'),(2,'İş Analisti Uzmanları'),(8,'90 Günde devri-alem'),
       (1,'Manisalılar Briç Kulubü'),(4,'MALATYALILAR DERNEGI'),(9,'FERRARI HASTALARI');
INSERT INTO SocialResume.GroupMember(UserID, GroupID, IsAdmin)
VALUES (3,20,TRUE),(5,20,TRUE),(7,21,TRUE),(10,22,TRUE),(4,20,FALSE),(3,21,FALSE),
       (6,23,FALSE),(6,24,FALSE),(7,24,FALSE),(7,25,FALSE),(8,25,TRUE);


CREATE TABLE SocialResume.Location(
  ID INT UNSIGNED AUTO_INCREMENT,
  Country VARCHAR(32) NOT NULL ,
  City VARCHAR(32) NOT NULL ,
  Place VARCHAR(64) NOT NULL ,
  CONSTRAINT Location_pk PRIMARY KEY (ID)
);
INSERT INTO SocialResume.Location (ID,Country,City,Place)
VALUES   (1,'Turkey','Izmır','Ege Universitesi');
INSERT INTO SocialResume.Location (Country, City, Place)
VALUES  ('Turkey','Izmır','Tavacı Recep'),
        ('Turkey','Ankara','Otogar'),
        ('Turkey','Ankara','ODTU'),
        ('Spain','Madrid','Santiago Bernabau'),
        ('England','London','London Eye');

CREATE TABLE SocialResume.Post(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  LocationID INT UNSIGNED NULL,
  Content VARCHAR(256) NOT NULL,
  CONSTRAINT Post_pk PRIMARY KEY (ID),
  CONSTRAINT Post_ID_fk FOREIGN KEY (ID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Post_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Post_LocationID_fk FOREIGN KEY (LocationID) REFERENCES SocialResume.Location(ID)
);

CREATE TRIGGER SocialResume.BeforeInsertPost BEFORE INSERT ON SocialResume.Post FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM SocialResume.Entity e LEFT JOIN SocialResume.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CreatorID AND t.Name IN ('Page', 'User')) = 0 THEN
    SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'This entity can not create post';
  END IF;

  INSERT INTO SocialResume.Entity (TypeID) SELECT ID FROM SocialResume.Type WHERE Name = 'Post';
  SET NEW.ID = LAST_INSERT_ID();
END;
INSERT INTO SocialResume.Post (CreatorID, LocationID, Content )
VALUES       (1,1,'Hello World'),
             (1,6,'Yağmurlu Bir Gün'),
             (10,5,'Maç Zamanı'),
             (16,4,'Altyapı Seçmeleri Ankara'),
             (16,1,'Altyapı Seçmeleri İzmir'),
             (18,3,'Racon Sahnesi Kamera Arkası');
INSERT INTO SocialResume.Post (CreatorID, Content )
VALUES       (2,'Foto'),
             (2,'Video'),
             (3,'Şampiyon Beşiktaş'),
             (17,'Duman Konseri'),
             (17,'Midye Festivali'),
             (19,'2019 un En komik Videosu'),
       (1,'Harika Bir Video'),
       (1,'Çok eğlenceli'),
       (2,'Dikkatle izleyiniz'),
       (11,'2018 in en çok gelişen şirketi seçildik'),
       (11,'Bu kazandığımız ödülü bütün çalışanlarımız için aldık'),
       (14,'Pazartesi sendromunu atlatmak için mutlaka izleyiniz');

CREATE TABLE SocialResume.Comment(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  CommentableID INT UNSIGNED NOT NULL,
  Content VARCHAR(256),
  CONSTRAINT Comment_pk PRIMARY KEY (ID),
  CONSTRAINT Comment_ID_fk FOREIGN KEY (ID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Comment_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Comment_CommentableID_fk FOREIGN KEY (CommentableID) REFERENCES SocialResume.Entity(ID)
);

CREATE TRIGGER SocialResume.BeforeInsertComment BEFORE INSERT ON SocialResume.Comment FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM SocialResume.Entity e LEFT JOIN SocialResume.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CreatorID AND t.Name IN ('Page', 'User')) = 0 THEN
    SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'This entity can not comment';
  END IF;

  IF (SELECT COUNT(*) FROM SocialResume.Entity e LEFT JOIN SocialResume.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CommentableID AND t.Name IN ('Comment', 'Post')) = 0 THEN
    SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'This entity is not commentable';
  END IF;

  INSERT INTO SocialResume.Entity (TypeID) SELECT ID FROM SocialResume.Type WHERE Name = 'Comment';
  SET NEW.ID = LAST_INSERT_ID();
END;
INSERT INTO SocialResume.Comment(CreatorID, CommentableID, Content)
VALUES      (1,27,'Aga Naber'),
            (2,31,'Of Çok Inanılmaz Gaza Geldim'),
            (1,27,'Çok Güzel'),
            (1,30,'Umarım Seçilirim'),
            (2,32,'Harikayım Yine xD'),
            (16,29,'Güzel Bir Ankara Gününden Seçmeler'),
            (16,29,'Son Başvuraları Kaçırmayın'),
            (17,31,'Çekimler Son Hızıyla Devam Ediyor'),
       (5,38,'Hariden çok güzel bir video'),
       (5,38,'Çok sevimliler'),
       (5,39,'Gerçekten çok etkilendim'),
       (1,40,'Gerçekten heyecanlı'),
       (2,41,'keşke herkes işini böyle yapsa');
INSERT INTO SocialResume.Comment(CreatorID, CommentableID, Content)
VALUES      (1,45,'Görüşelim Bir Gün'),
            (1,45,'xD'),
            (2,48,'Aa Benmişim'),
            (13,44,'İyi Sen?'),
            (13,49,'İyi Olan Kazansın'),
            (14,46,'Harika');

CREATE TABLE SocialResume.Event(
  ID INT UNSIGNED,
  CreatorID INT UNSIGNED NOT NULL,
  LocationID INT UNSIGNED NOT NULL,
  StartDate DATETIME NOT NULL,
  FinishDate DATETIME NOT NULL,
  Name VARCHAR(64) NOT NULL,
  CONSTRAINT Event_pk PRIMARY KEY (ID),
  CONSTRAINT Event_ID_fk FOREIGN KEY (ID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Event_CreatorID_fk FOREIGN KEY (CreatorID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Event_LocationID_fk FOREIGN KEY (LocationID) REFERENCES SocialResume.Location(ID)
);

CREATE TRIGGER SocialResume.BeforeInsertEvent BEFORE INSERT ON SocialResume.Event FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM SocialResume.Entity e LEFT JOIN SocialResume.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CreatorID AND t.Name IN ('Page', 'User')) = 0 THEN
    SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'This entity can not create event';
  END IF;
  IF NEW.FinishDate <= NEW.StartDate THEN
    SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'FinishDate must be later than StartDate';
  END IF;
  INSERT INTO SocialResume.Entity (TypeID) SELECT ID FROM SocialResume.Type WHERE Name = 'Event';
  SET NEW.ID = LAST_INSERT_ID();
END;

INSERT INTO SocialResume.Event (CreatorID, LocationID, StartDate, FinishDate,Name)
VALUES      (1,1,'2018-12-31','2019-01-01','Yılbaşı Partisi'),
            (1,1,'2019-01-14','2019-01-15','Tava Festivali'),
            (3,5,'2019-02-20 19:0:0','2019-02-20 21:0:0','Real Madrid-Barcelona'),
            (16,2,'2019-05-25 08:0:0','2019-05-25 17:0:0','Seçmeler Tüm Hızıyla Devam Ediyor'),
            (16,5,'2019-07-04','2019-07-10','Derbi Zamanı'),
            (18,1,'2025-04-16 20:0:0','2025-04-16 21:0:0','Gala');



CREATE TABLE SocialResume.EventInteraction(
  EventID INT UNSIGNED,
  UserID INT UNSIGNED,
  Participation  BOOL NOT NULL,
  CONSTRAINT EventInteraction_pk PRIMARY KEY (EventID, UserID),
  CONSTRAINT EventInteraction_EventID_fk FOREIGN KEY (EventID) REFERENCES SocialResume.Event(ID),
  CONSTRAINT EventInteraction_UserID_fk FOREIGN KEY (UserID) REFERENCES SocialResume.User(ID)
);
INSERT INTO SocialResume.EventInteraction (EventID, UserID, Participation)
VALUES      (63,1,TRUE), (68,1,FALSE ), (65,2,FALSE ), (67,3,TRUE ), (63,10,TRUE );

CREATE TABLE SocialResume.Like(
  CanLikeID INT UNSIGNED,
  LikeableID INT UNSIGNED,
  LikeTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Like_pk PRIMARY KEY (CanLikeID, LikeableID),
  CONSTRAINT Like_CanLikeID_fk FOREIGN KEY (CanLikeID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Like_LikeableID_fk FOREIGN KEY (LikeableID) REFERENCES SocialResume.Entity(ID)
);
CREATE TRIGGER SocialResume.BeforeInsertLike BEFORE INSERT ON SocialResume.Like FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM SocialResume.Entity e LEFT JOIN SocialResume.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.CanLikeID AND t.Name IN ('Page', 'User')) = 0 THEN
    SIGNAL SQLSTATE '45008' SET MESSAGE_TEXT = 'This entity can not like';
  END IF;

  IF (SELECT COUNT(*) FROM SocialResume.Entity e LEFT JOIN SocialResume.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.LikeableID AND t.Name IN ('Comment', 'Page', 'Post')) = 0 THEN
    SIGNAL SQLSTATE '45009' SET MESSAGE_TEXT = 'This entity is not likeable';
  END IF;
END;
INSERT INTO SocialResume.Like (CanLikeID, LikeableID)
VALUES  (1,26),(1,16),(1,44),(2,26),(2,16),(2,48),(2,47),(3,33),(7,26),(8,26),(10,62),
        (10,19),(16,45),(16,31),(16,17),(17,45),(17,48),(19,34),(19,36),(19,16),(19,17);





CREATE TABLE SocialResume.Share(
  UserID INT UNSIGNED,
  ShareableID INT UNSIGNED,
  SharedInID INT UNSIGNED,
  ShareTime DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT Share_pk PRIMARY KEY (UserID, ShareableID, SharedInID),
  CONSTRAINT Share_UserID_fk FOREIGN KEY (UserID) REFERENCES SocialResume.User(ID),
  CONSTRAINT Share_ShareableID_fk FOREIGN KEY (ShareableID) REFERENCES SocialResume.Entity(ID),
  CONSTRAINT Share_SharedInID_fk FOREIGN KEY (SharedInID) REFERENCES SocialResume.Entity(ID)
);
-- User Group/User Event/Group/Page/Post
CREATE TRIGGER SocialResume.BeforeInsertShare BEFORE INSERT ON SocialResume.Share FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM SocialResume.Entity e LEFT JOIN SocialResume.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.ShareableID AND t.Name IN ('Event', 'Group', 'Page', 'Post')) = 0 THEN
    SIGNAL SQLSTATE '45010' SET MESSAGE_TEXT = 'This entity is not shareable';
  END IF;

  IF (SELECT COUNT(*) FROM SocialResume.Entity e LEFT JOIN SocialResume.Type t ON e.TypeID = t.ID WHERE e.ID = NEW.SharedInID AND
      ((t.Name = 'Group' AND (SELECT COUNT(*) FROM GroupMember gm WHERE gm.UserID = NEW.UserID AND gm.GroupID = NEW.SharedInID) > 0) OR (t.Name = 'User' AND NEW.UserID = NEW.SharedInID))) = 0 THEN
    SIGNAL SQLSTATE '45011' SET MESSAGE_TEXT = 'User can not share in this entity';
  END IF;
END;
 INSERT INTO SocialResume.Share (UserID, ShareableID, SharedInID)
 VALUES     (4,63,24),(7,63,25),(1,63,23),(2,64,2),(2,63,2),(3,26,3),
            (3,27,3),(10,16,10),(5,37,5),(7,19,24),(9,24,25),(8,24,25);