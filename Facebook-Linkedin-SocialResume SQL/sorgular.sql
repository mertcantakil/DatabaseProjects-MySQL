use facebook;
select PhoneNo from user where SettingsLanguage='tr-TR' ; -- Dili türkçe olanların telefon numaraları sorguladık.
select FirstName,MidName,LastName from user where YEAR(BirthDate)<=1970 order by  BirthDate; -- Doğum tarihi 1970'ten küçük olanların isimleri sorguladık.
select COUNT(city) as Sayi, city from location group by city; -- Locationda hangi sehirden kac tane oldugunu sorguladık.
select distinct COUNT(city) as sehirsayisi, Country from location group by  Country,City; -- hangi ülkeden kaç tane şehir oldugunu sorguladık.
select distinct Country from location; -- location tablosunda hangi ülkelerin olduğunu sorguladık.
select id, FirstName
from user, groupmember
where groupmember.IsAdmin=TRUE AND  groupmember.UserID=ID; -- Hangi userların grupta admin oldugunu sorguladık.

select user.ID, FirstName, `group`.Name
from user, `group`
where user.ID=CreatorID ; -- hangi userlar grup kurmuslar ve grupların isimleri


select *
from user, message
where user.ID=message.ID; -- userların attıgı mesajların hepsi


select *
from user, message
where User1ID=1 AND user.ID=message.ID; -- id'si 1 olan kullanıcın attıgı mesajlar

select *
from user, page
where page.CreatorID=user.ID; -- user'ın kurdugu pageler

use facebook;
select user.ID,FirstName , page.Name
from user, pageadmin, page
where user.ID=pageadmin.UserID AND user.ID<>page.CreatorID AND PageID=page.ID; -- Sayfa kurmadığı halde admini olan userlar

select user.ID, FirstName , page.Name, group.Name
from user, page, `group`
where user.ID=page.CreatorID AND user.ID=`group`.CreatorID ; -- hangi user hem page sahibi hem grup sahibi

select distinct user.ID,user.FirstName, Content
from user, location, post
where user.ID=post.CreatorID AND post.LocationID=LocationID; -- userın attığı postlardan hangisinde location bilgisi var ve postun içeriği ne oldugunu sorguladık.


use linkedin;
select * from linkedin.user;

select linkedin.user.FirstName, linkedin.user.Location from linkedin.user where SettingsLanguage='tr-TR'; -- dili türkce olanlar hangi locationlarda oldugun sorguladık.
select linkedin.user.FirstName from linkedin.user order by linkedin.user.FirstName; -- isimlere göre sıraladık.
select linkedin.user.FirstName from linkedin.user order by linkedin.user.FirstName desc ; -- isimlere göre ters sıraladık.
select * from linkedin.user where Skills LIKE '%html%'; -- Skillerinde HTML Bilenlerin bilgileri
select COUNT(communitymember.UserID) as uye_sayisi, linkedin.community.Name from community,communitymember
  where communitymember.CommunityID=community.ID  GROUP BY community.ID; -- Bir communityde kaç member oldugunu sorguladık.
select linkedin.page.Name,linkedin.jobadvert.Name from linkedin.page, jobadvert
  where jobadvert.Location='ARJANTIN'; -- arjantinde yayınlanan iş ilanı yayınlayan sayfanın adı
select * from linkedin.post, linkedin.comment
  where linkedin.post.ID=linkedin.comment.CommentableID; -- postlara atılan yorumları sorguladık.
use linkedin ;
select user.ID,Skills from linkedin.user, jobapply,jobadvert
  where jobadvert.Name='C Uzmanı' AND jobapply.UserID=linkedin.user.ID AND jobadvert.ID=jobapply.JobAdvertID; -- C Uzmani adındaki işe başvuranların yeteneklerini sorguladık.
use socialresume;
select * from socialresume.user;
use socialresume;
select COUNT(socialresume.user.Location) as Sayi, socialresume.user.Location from socialresume.user group by Location; -- Hangi location da kaç kullanıcı olduğunu sorguladık.
select Skills from user where SettingsLanguage='tr-TR' ; -- Dili türkçe olanların yeteneklerini sorguladık.
select FirstName, MidName, LastName, StartDate from socialresume.user, socialresume.experienceandeduinfo, socialresume.page
  where user.ID = experienceandeduinfo.UserID AND experienceandeduinfo.FinishDate IS NULL AND experienceandeduinfo.PageID = socialresume.page.ID AND
    page.Specialities IS NOT NULL AND page.Specialities != ''; -- Bir şirkette çalışmaya devam eden
select Count(*) as LikeCount, socialresume.page.Name from socialresume.page, socialresume.like, socialresume.user
  where socialresume.page.ID = socialresume.`like`.LikeableID AND socialresume.`like`.CanLikeID = socialresume.user.ID group by socialresume.page.ID;-- Kullanıcılar tarafından hangi sayfalar ne kadar begenilmiş
select Count(*) as basvuranSayisi, socialresume.page.Name from socialresume.page, socialresume.jobadvert, socialresume.jobapply
  where socialresume.jobapply.JobAdvertID = socialresume.jobadvert.ID AND socialresume.jobadvert.PageID = socialresume.page.ID group by socialresume.page.ID;-- iş ilanlarına kaçar başvuru olmuş
select socialresume.event.Name from socialresume.user, socialresume.event, socialresume.eventinteraction
  where socialresume.user.Skills like '%java%' AND socialresume.user.ID = socialresume.eventinteraction.UserID AND
        socialresume.eventinteraction.EventID = socialresume.event.ID;-- java bilen kullanıcıların katıldığı veya ilgilendiği etkinlikler
select socialresume.user.FirstName from socialresume.post ,socialresume.`like`,socialresume.user  -- bir postun kimler tarafından likelandığı
  where socialresume.post.ID=26 AND socialresume.post.ID=socialresume.`like`.LikeableID AND socialresume.user.ID=socialresume.`like`.CanLikeID;

select socialresume.user.FirstName , socialresume.message.Content
from socialresume.message , socialresume.user
where socialresume.user.ID =socialresume.message.User1ID; -- Kimin hangi mesajları attığı

select count(*) as sayı , socialresume.user.FirstName
from socialresume.user , socialresume.friendshiprequest
where socialresume.user.ID=socialresume.friendshiprequest.User2ID group by socialresume.user.ID; -- kullanıcıların kaçar tane arkadaşlık isteği aldıkları



select
from
where















