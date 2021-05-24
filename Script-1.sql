DROP SCHEMA IF EXISTS steam CASCADE;
CREATE SCHEMA steam;
 
CREATE TABLE games (
game_id serial,
title varchar(60) NOT NULL,
price float NOT NULL,
description TEXT DEFAULT 'No description',
release_date date DEFAULT current_date,
CONSTRAINT PK_games PRIMARY KEY (game_id)
);

CREATE TYPE statusEnum AS ENUM ('Online','Offline','Invisible','Away');
CREATE TABLE users (
user_id serial,
nick varchar(30) NOT NULL,
budget NUMERIC(15,2),
email varchar(60) NOT NULL UNIQUE,
password varchar(200) NOT NULL,
status statusEnum NOT NULL,
firstname varchar(45),
lastname varchar(45),
birth_date date NOT null,
registration_date timestamp default CURRENT_TIMESTAMP,
CONSTRAINT PK_users PRIMARY KEY (user_id)
);

CREATE TABLE games_owned (
games_owned_id serial,
game_id integer NOT null, 
user_id integer NOT null,
purchase_date timestamp default CURRENT_TIMESTAMP,
CONSTRAINT PK_games_owned PRIMARY KEY (games_owned_id),
CONSTRAINT FK_games_owned_games FOREIGN KEY (game_id) REFERENCES games(game_id),
CONSTRAINT FK_games_owned_users FOREIGN KEY (user_id) REFERENCES users(user_id),
CONSTRAINT UQ_games_owned UNIQUE (game_id,user_id)
);

CREATE TABLE category (
category_id serial,
name VARCHAR(45) NOT NULL,
CONSTRAINT PK_category PRIMARY KEY (category_id)
);

CREATE TABLE category_games(
category_games_id serial,
category_id integer NOT NULL,
game_id integer NOT NULL,
CONSTRAINT PK_category_games PRIMARY KEY (category_games_id),
CONSTRAINT FK_category_games_category FOREIGN KEY (category_id) REFERENCES category(category_id),
CONSTRAINT FK_category_games_games FOREIGN KEY (game_id) REFERENCES games(game_id),
CONSTRAINT UQ_category_games UNIQUE (category_id,game_id)
);

CREATE TABLE achievements (
achievement_id serial,
title varchar(60) NOT NULL,
description text DEFAULT 'No description',
game_id integer NOT NULL,
CONSTRAINT PK_achievements PRIMARY KEY (achievement_id),
CONSTRAINT FK_achievements_games FOREIGN KEY (game_id) REFERENCES games(game_id)
);

CREATE TABLE achievements_earned (
achievements_earned_id serial,
achievement_id integer,
user_id integer,
earn_date timestamp default CURRENT_TIMESTAMP
);
ALTER TABLE achievements_earned ADD CONSTRAINT PK_achievements_earned PRIMARY KEY (achievements_earned_id);
ALTER TABLE achievements_earned ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE achievements_earned ALTER COLUMN achievement_id SET NOT NULL;
ALTER TABLE achievements_earned ADD CONSTRAINT FK_achievements_earned_games FOREIGN KEY (user_id) REFERENCES users(user_id);
ALTER TABLE achievements_earned ADD CONSTRAINT FK_achievements_earned_achievements FOREIGN KEY (achievement_id) REFERENCES achievements(achievement_id);
ALTER TABLE achievements_earned ADD CONSTRAINT UQ_achievements_earned UNIQUE (achievement_id,user_id);

CREATE TABLE dlc (
dlc_id serial,
title varchar(60),
price float,
game_id integer,
release_date date DEFAULT current_date
);
ALTER TABLE dlc ADD CONSTRAINT PK_dlc PRIMARY KEY (dlc_id);
ALTER TABLE dlc ALTER COLUMN title SET NOT NULL;
ALTER TABLE dlc ALTER COLUMN price SET NOT NULL;
ALTER TABLE dlc ALTER COLUMN game_id SET NOT NULL;
ALTER TABLE dlc ADD CONSTRAINT FK_dlc_games FOREIGN KEY (game_id) REFERENCES games(game_id);


CREATE TABLE dlc_owned (
dlc_owned_id serial,
dlc_id integer,
user_id integer,
purchase_date timestamp default CURRENT_TIMESTAMP
);
ALTER TABLE dlc_owned ADD CONSTRAINT PK_dlc_owned PRIMARY KEY (dlc_owned_id);
ALTER TABLE dlc_owned ALTER COLUMN dlc_id SET NOT NULL;
ALTER TABLE dlc_owned ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE dlc_owned ADD CONSTRAINT FK_dlc_owned_dlc FOREIGN KEY (dlc_id) REFERENCES dlc(dlc_id);
ALTER TABLE dlc_owned ADD CONSTRAINT FK_dlc_owned_users FOREIGN KEY (user_id) REFERENCES users(user_id);
ALTER TABLE dlc_owned ADD CONSTRAINT UQ_dlc_owned UNIQUE (dlc_id,user_id);


CREATE TABLE groups (
group_id serial,
name varchar(60),
description text DEFAULT 'No description',
creation_date timestamp DEFAULT current_timestamp
);
ALTER TABLE groups ADD CONSTRAINT PK_groups PRIMARY KEY (group_id);
ALTER TABLE groups ALTER COLUMN name SET NOT NULL;


CREATE TABLE groups_members (
groups_members_id serial,
group_id integer,
user_id integer
);
ALTER TABLE groups_members ADD CONSTRAINT PK_groups_members PRIMARY KEY (groups_members_id);
ALTER TABLE groups_members ALTER COLUMN group_id SET NOT NULL;
ALTER TABLE groups_members ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE groups_members ADD CONSTRAINT FK_groups_members_groups FOREIGN KEY (group_id) REFERENCES groups(group_id);
ALTER TABLE groups_members ADD CONSTRAINT FK_groups_members_users FOREIGN KEY (user_id) REFERENCES users(user_id);
ALTER TABLE groups_members ADD CONSTRAINT UQ_groups_members UNIQUE (group_id,user_id);



-------INSERTY-------

BEGIN;
INSERT INTO games (title,price,release_date,description) VALUES
('Breathedge',62.99,'2021-02-25','Breathedge is an ironic outer space survival adventure game. Take on the role of a simple guy called the Man who is just carrying his grandpas ashes to a galactic funeral and suddenly finds himself in the middle of a universal conspiracy.'),
('Last Year',35.99,'2019-12-10','Team up with four other Classmates to survive against a sixth player controlling a dreadful, horrifying Fiend, in this evolution of multiplayer horror games inspired by classic horror stories.'),
('Stellaris',142.99,'2016-05-09','Explore a galaxy full of wonders in this sci-fi grand strategy game from Paradox Development Studios. Interact with diverse alien races, discover strange new worlds with unexpected events and expand the reach of your empire. Each new adventure holds almost limitless possibilities.'),
('PAYDAY 2',17.99,'2013-08-13','PAYDAY 2 is an action-packed, four-player co-op shooter that once again lets gamers don the masks of the original PAYDAY crew - Dallas, Hoxton, Wolf and Chains - as they descend on Washington DC for an epic crime spree.'),
('Warframe',0,'2013-03-25','Warframe is a cooperative free-to-play third person online action game set in an evolving sci-fi world.'),
('Forza Horizon 4',214.99,'2021-03-09','Dynamic seasons change everything at the world’s greatest automotive festival. Go it alone or team up with others to explore beautiful and historic Britain in a shared open world.'),
('LEGO® Star Wars™ - The Complete Saga',71.99,'2009-11-13','Kick Some Brick in I through VI! Play through all six Star Wars movies in one videogame! Adding new characters, new levels, new features and for the first time ever, the chance to build and battle your way through a fun Star Wars galaxy on your PC!'),
('GreedFall',199.99,'2019-09-10','Engage in a core roleplaying experience, and forge the destiny of a new world seeping with magic, and filled with riches, lost secrets, and fantastic creatures. With diplomacy, deception and force, become part of a living, evolving world - influence its course and shape your story.'),
('STAR WARS™ Battlefront™ II',139.99,'2020-06-11','Be the hero in the ultimate STAR WARS™ battle fantasy with STAR WARS™ Battlefront™ II: Celebration Edition!'),
('Mafia',42.99,'2002-08-28','It’s 1930. After an inadvertent brush with the mafia, cabdriver Tommy Angelo is reluctantly thrust into the world of organized crime. Initially, he is uneasy about falling in with the Salieri family, but soon the rewards become too big to ignore.'),
('Farming Simulator 19',69.99,'2018-11-20','The best-selling franchise takes a giant leap forward with a complete overhaul of the graphics engine, offering the most striking and immersive visuals and effects, along with the deepest and most complete farming experience ever. '),
('Left 4 Dead 2',35.99,'2009-11-17','Set in the zombie apocalypse, Left 4 Dead 2 (L4D2) is the highly anticipated sequel to the award-winning Left 4 Dead, the #1 co-op game of 2008. This co-operative action horror FPS takes you and your friends through the cities, swamps and cemeteries of the Deep South, from Savannah to New Orleans '),
('Terraria',35.99,'2011-05-16','Dig, fight, explore, build! Nothing is impossible in this action-packed adventure game. Four Pack also available! '),
('Dead by Daylight',71.99,'2016-06-14','Dead by Daylight is a multiplayer (4vs1) horror game where one player takes on the role of the savage Killer, and the other four players play as Survivors, trying to escape the Killer and avoid being caught and killed.'),
('Among Us',17.99,'2018-08-16','An online and local party game of teamwork and betrayal for 4-10 players...in space! '),
('Arma 3',119.99,'2013-09-12','Experience true combat gameplay in a massive military sandbox. Deploying a wide variety of single- and multiplayer content, over 20 vehicles and 40 weapons, and limitless opportunities for content creation, this is the PC’s premier military game. Authentic, diverse, open - Arma 3 sends you to war. '),
('Counter-Strike: Global Offensive',0,'2012-08-21','Counter-Strike: Global Offensive (CS: GO) expands upon the team-based action gameplay that it pioneered when it was launched 19 years ago. CS: GO features new maps, characters, weapons, and game modes, and delivers updated versions of the classic CS content (de_dust2, etc.).'),
('Love Dating',7.19,'2021-04-27','This is a casual draw line game. The girls in the game have different stories. You can chat with girls. The secret hidden in the girl is waiting for you to discover. '),
('Predator: Hunting Grounds',169.00,'2020-04-24','Hunt or be hunted in this asymmetrical multiplayer shooter that pits man against Predator. As part of a Fireteam, complete missions before the Predator finds you. Or be the Predator and hunt your prey. '),
('Chromatic Labyrinth',7.19,'2021-04-30','A FPS with Rogue-like elements. Features a random level generator and collectable items with passive effects. ');
INSERT INTO dlc (title,price,game_id,release_date) VALUES
('The Nightmare',35.99,2,'2020-10-26'),
('The Nightmare Official Artbook',7.19,2,'2020-10-27'),
('The Nightmare Soundtrack',17.99,2,'2020-10-26'),
('Nemesis',71.99,3,'2021-04-15'),
('Necroids Species Pack',28.99,3,'2020-10-29'),
('Federations',71.99,3,'2020-03-17'),
('Lithoids Species Pack',28.99,3,'2019-10-24'),
('Megacorp',71.99,3,'2018-12-06'),
('Apocalypse',71.99,3,'2018-02-22'),
('Dragon Pack',25.49,4,'2021-03-17'),
('Tailor Pack',10.99,4,'2020-11-11'),
('Weapon Color Pack 3',10.99,4,'2020-11-11'),
('Gunsliger Weapon Pack',10.99,4,'2020-11-11'),
('Weapon Color Pack 2',10.99,4,'2020-06-30'),
('Weapon Color Pack 1',10.99,4,'2020-02-27'),
('John Wick Heists',10.99,4,'2017-02-09'),
('The Overkills Pack',7.19,4,'2015-03-06'),
('Prime Vault - Chroma Prime Accessories',71.99,5,'2021-04-27'),
('Prime Vault - Zephyr Prime Accessories',71.99,5,'2021-04-27'),
('Tennocon 2021 Digital Pack',93.00,5,'2021-04-22'),
('Railjack Instant Access Pack',71.99,5,'2021-04-13'),
('1938 MG TA Nidget',10.99,6,'2021-03-10'),
('Fortune Island',71.99,6,'2021-03-09'),
('VIP',71.99,6,'2021-03-09'),
('Treasure Map',10.99,6,'2021-03-09'),
('Adventurers Gear DLC',11.99,8,'2019-09-10'),
('Rottne DLC',13.99,11,'2021-03-16'),
('Alpine Farming Expansion',64.99,11,'2020-11-12'),
('Season Pass',109.99,11,'2020-11-12'),
('Platinum Expansion',69.99,11,'2019-09-22'),
('Official Soundtrack',17.99,13,'2015-09-13'),
('Otherworld Official Soundtrack',17.99,13,'2020-04-25'),
('The Halloween Chapter',25.49,14,'2016-08-23'),
('Of Flesh and Mud Chapter',25.49,14,'2016-12-08'),
('Curtain Call Chapter',25.49,14,'2018-06-12'),
('Darkness Amoung us Chapter',25.49,14,'2018-12-11'),
('Stranger Things Chapter',43.99,14,'2019-08-17'),
('A Binding of Kin Chapter',25.49,14,'2020-12-01'),
('Airship Skins',7.19,15,'2021-03-31'),
('Polus Skins',7.19,15,'2019-09-12'),
('Mira HQ Skins',7.19,15,'2019-09-08'),
('Contact',99.99,16,'2019-06-25'),
('Tanks',36.99,16,'2018-04-11'),
('Laws of War',36.99,16,'2017-09-07'),
('Malden',0.0,16,'2017-06-22'),
('Operation Broken',58.99,17,'2020-12-03'),
('Dutch 2025 DLC Pack',29.00,19,'2021-04-29'),
('Dutch 87 DLC Pack',29.00,19,'2021-04-29'),
('City Hunter Predator DLC',21.00,19,'2021-04-29');
INSERT INTO achievements(title,game_id,description) VALUES
('Survivor',1,'Every survivor deserves an Oscar. So it goes.'),
('Chicken dielectric',1,'An immortal Chicken on a stick makes an excellent dielectric. We do not recommend trying this in real life, unless you have an immortal chicken and an immortal you.'),
('Smuggler',1,'No description'),
('Multilayer',1,'Its warm in underpants, and you can hibernate in winter if you have a whole lot of them!'),
('A contributor to the industry',1,'Congratulations! If you didnt cheat, then you are helping the industry to develop! In some way, not necessarily in the right one.'),
('Sir, no sir!',1,'Someone always has to control an army, even if its an army of crazy coffins. A coffin squadron without a general is just a bunch of stupid meat containers, and a coffin squadron with a general is also just a bunch of stupid meat containers, but with a general. Thats a fact!'),
('Energetic',3,'Store/have 1000 EC'),
('Brave New World',3,'Colonize a planet'),
('Power Overwhelming',3,'Store/have 5000 EC'),
('Strategic Initiative',3,'Build a Strategic Coordination Center'),
('I Want to Get Away',4,'Jump. Unlocks the "Funnyman" mask.'),
('How Do You Like Me Now?',4,'Equip an armor for the first time.'),
('Man of Iron',4,'Equip the Improved Combined Tactical Vest.'),
('Weaponsmith',5,'Build an item in the Foundry.'),
('Greater Than the Sum',5,'Fuse mods together to create a more powerful mod.'),
('Angel of Death',5,'Get 100 kills in a single mission'),
('Collector',5,'Find 100 Mods'),
('Welcome to Britain',6,'Arrive at the Horizon Festival.'),
('Cashing In',6,'Earn 1 Season Completion Bonus.'),
('Purple Split!',6,'In Rivals, beat a Rival without receiving a "dirty time" penalty.'),
('Autumn-mobiles',6,'Win all Seasonal Championships in one Autumn season.'),
('On the path to power',8,'Allocate a new attribute point'),
('Full pockets',8,'Empty 100 containers'),
('Artisan',8,'Craft 10 equipment improvements'),
('Battle Beyond the Stars',9,'Win a match of Galactic Assault.'),
('A Job Well Done',9,'Complete 25 Multiplayer Milestones.'),
('Heavy is the Hand',9,'Win a match of Heroes vs Villains'),
('Outbound Flight',9,'Win a match of Starfighter Assault.'),
('Plant Prosperity',11,'Sow 10 hectares'),
('A Good Deed',11,'Complete 1 mission'),
('Pink Progress',11,'Breed 50 pigs'),
('ACID REFLEX',12,'Kill a Spitter before she is able to spit.'),
('CLUB DEAD',12,'Use every melee weapon to kill Common Infected'),
('FRIED PIPER',12,'Using a Molotov, burn a Clown leading at least 10 Common Infected.'),
('KILL BILL',12,'Have Bill sacrifice himself for the team.'),
('Timber!!',13,'Chop down your first tree.'),
('Hold on Tight!',13,'Equip your first grappling hook.'),
('The Frequent Flyer',13,'Spend over 1 gold being treated by the nurse.'),
('Sick Throw',13,'Obtain the Terrarian.'),
('Serial Killer',14,'In public matches, Sacrifice the Obsession 30 times.'),
('III',14,'Reach prestige Level III with any character.'),
('Legendary survivor',14,'Reach survivor online rank 1.'),
('Adept Trapper',14,'In a public match, achieve a merciless victory with the Trapper using only his 3 unique perks.'),
('Bodyguard',14,'In public matches, take a protection hit while the Killer is carrying a Survivor, 30 times.'),
('This is War',16,'Started your first Arma 3 scenario - welcome!'),
('Worshiper',16,'Pinged your Zeus'),
('Changing the Balance',16,'Modified your difficulty options and saved the custom settings.'),
('Puppeteer',16,'Played a scenario as a non-player character in the Eden Editor.'),
('Points in Your Favor',17,'Inflict 2,500 total points of damage to enemies'),
('Pro-moted',17,'Win 200 rounds'),
('Sknifed',17,'Kill a zoomed-in enemy sniper with a knife'),
('The 1st date',18,'Clear level 5'),
('The 12th date',18,'Clear level 60'),
('Need some help',18,'Press Key "C"'),
('If it Bleeds..',19,'Wound a Predator so it leaves a green blood trail'),
('Clutch',19,'As a Fireteam member, Reinforce your entire team back into the match'),
('Hunting Grounds Master',19,'Reach Player level 100'),
('Ultimate Hunter',19,'Unlocked after all other trophies are unlocked');
INSERT INTO users(nick,email,budget,PASSWORD,status,firstname,lastname,birth_date) VALUES
('Player','player@gmail.com',20.99,'player123','Online',NULL,NULL,'2006-04-02'),
('Bogdan','goracybodzio@wp.pl',200,'rosolpolski','Away',NULL,NULL,'1998-04-27'),
('Dede','michal@gmail.com',0,'haslomaslo','Offline','Michał','Morawiecki','1980-12-12'),
('Piotr123','piterparker@o2.pl',10.99,'12345678','Invisible','Piotr','Teder','2007-03-29'),
('xHalinax','biedra@gmail.com',99.59,'haslooo56','Online',NULL,NULL,'2010-10-10'),
('GamerPRO','gamer@wp.pl',13.59,'winner69','Offline','Mateusz','Kowalski','2003-07-12'),
('Luki','luki@o2.pl',1.49,'o22oplay','Invisible','Tadek','Sędzia','2006-05-15'),
('Destroyer','kacper@gmail.com',153.15,'kacper123','Online','Kacper','Michalski','1997-09-28'),
('Staliński','staliński@o2.pl',7.99,'lubieplacki','Offline',NULL,NULL,'2000-02-01'),
('Kitty','kitty@gmail.com',1000.99,'ilikecats','Invisible','Magda','Kolasińska','2004-11-07'),
('Mafioso','mafia@onet.pl',0,'123killer123','Away',NULL,NULL,'2004-05-22'),
('WinnerGamerPRO','dominiczek@onet.pl',79.99,'domino123','Online','Dominik','Kołacz','2009-12-24'),
('Sania','saniaPlay@gmail.com',0,'7Sania@Games7','Online',NULL,NULL,'2002-03-13'),
('Lightning','thunder@interia.pl',0,'trudnehaslo','Invisible',NULL,NULL,'1999-08-09'),
('Belle','asiagra@onet.pl',17.99,'gramywgryhaslo','Offline','Asia','Nowicka','1996-07-16');
INSERT INTO category(name) VALUES
('Action'),('Adventure'),('Indie'),('Simulation'),('Strategy'),
('RPG'),('Free to Play'),('Racing'),('Casual');
INSERT INTO category_games(category_id,game_id) VALUES
(1,1),(2,1),(3,1),(4,1),(1,2),(4,3),(5,3),(1,4),(6,4),
(1,5),(7,5),(8,6),(2,7),(6,8),(1,9),(2,9),(1,10),(2,10),
(4,11),(1,12),(1,13),(2,13),(3,13),(6,13),(1,14),(9,15),
(1,16),(4,16),(5,16),(1,17),(7,17),(1,18),(3,18),(9,18),
(1,19),(1,20),(3,20);
INSERT INTO "groups"(name,description) VALUES
('Łowcy Gier','Łowcy Gier to serwis, mający za zadanie agregowanie i selekcję najciekawszych promocji na gry video. Informujemy o najlepszych cenach zarówno w dystrybucji pudełkowej, jak i cyfrowej.'),
('PC Gamer','Hello, and welcome to the PC Gamer Steam group, a place to meet fellow readers. We only have one main rule: dont be a dick. That means no racist/sexist language, no trolling, no spamming, no false claims about the release date of...'),
('VigilanteGamers','=== Community Links ===→ Website & Forums[vgamers.net]→ Join the Community[forums.vigilantegamers.net]→ 
Apply for Admin[forums.vigilantegamers.net]→ Bans[forums.vigilantegamers.net]→ Stats[forums.vigilantegamers.net]=== Counter-Strike: Source ===ZombieMod - 
66.150.214.172:27015[vgamers.net]GunGame - 66.150.214.190:27015[vgamers.net]Scoutzknivez - 74.91.114.104:27015[vgamers.net]=== Disc-FF (Affiliates) ===Disc-FF Steam GroupVGamers.net  '),
('MCML: The Original','Welcome to PBFORTRESS From professionals to beginners, gamers of all age and skill are welcome into the PBFortress community. Feel free to play on our servers, talk with us on Discord, or join our forums. New events, features, and servers to come!'),
('Prima.gg','[h1]Preview:[/h1] [b]Prima eSport[/b] is a non-profit organization that started back in 2017 as a gaming association focusing on eSport, Streaming and Gaming.'),
('Hot Random Keys','[h1] [b]What is HRK?[/b][/h1] HRK is a new platform which includes the following sections: [url=https://www.hotrandomkeys.com/randomkeyshop/buy] (I) HRK Lottery: [/url] With only $2 you will receive a game which worth from $2.99');
INSERT INTO groups_members (group_id,user_id) VALUES
(1,2),(1,5),(1,8),(1,9),(1,4),(2,9),(2,13),(2,12),(2,14),(2,6),(3,7),(3,8),(3,1),(3,2),(3,4),(4,1),(4,10),
(4,11),(4,12),(4,13),(5,5),(5,6),(5,7),(5,1),(5,9),(6,13),(6,4),(6,5),(6,8),(6,9),(6,11),(6,1),(6,6),(4,15),(4,7),(1,15),(1,6),(2,4),(2,8),(3,13),(3,14),(4,5);
INSERT INTO games_owned (game_id,user_id) VALUES 
(18,1),(14,1),(10,1),(13,1),(9,1),
(14,2),(6,2),(16,2),(9,2),(17,2),(3,2),(11,2),
(6,3),(7,3),(1,3),(20,3),
(10,4),(18,4),(14,4),(1,4),(17,4),(9,4),(15,4),(19,4),(11,4),(20,4),
(16,5),(13,5),(15,5),(8,5),(11,5),(12,5),(4,5),
(2,6),(15,6),(1,6),(4,6),(8,6),(19,6),(18,6),
(15,7),(13,7),(19,7),(16,7),(2,7),(3,7),(6,7),(20,7),(4,7),(9,7),(17,7),(7,7),(10,7),(1,7),
(19,8),(3,8),(20,8),(14,8),(9,8),(8,8),
(1,9),(4,9),(11,9),(15,9),(16,9),(6,9),(10,9),
(10,10),(19,10),(17,10),(12,10),
(6,11),(5,11),(13,11),(17,11),(8,11),
(17,12),(14,12),(4,12),(2,12),(8,12),(9,12),(13,12),(7,12),(18,12),
(20,13),(12,13),(11,13),(4,13),(16,13),
(16,14),(5,14),(7,14),(13,14),(17,14),(18,14),(9,14),(3,14),
(11,15),(1,15),(2,15),(19,15),(8,15);
INSERT INTO achievements_earned (achievement_id,user_id) VALUES
(52,1),(53,1),(40,1),(41,1),(42,1),(43,1),(36,1),(24,1),(26,1),
(40,2),(42,2),(43,2),(19,2),(20,2),(21,2),(45,2),(25,2),(49,2),(7,2),(8,2),(29,2),
(18,3),(19,3),(1,3),(2,3),(4,3),
(52,4),(53,4),(42,4),(43,4),(3,4),(4,4),(50,4),(51,4),(57,4),(28,4),(58,4),(29,4),(30,4),
(45,5),(46,5),(48,5),(36,5),(37,5),(22,5),(23,5),(24,5),(29,5),(30,5),(31,5),(33,5),(34,5),(35,5),(12,5),(13,5),
(1,6),(3,6),(5,6),(6,6),(12,6),(24,6),(58,6),(57,6),(54,6),(53,6),(52,6),
(36,7),(37,7),(56,7),(57,7),(45,7),(46,7),(19,7),(20,7),(21,7),(11,7),(13,7),(49,7),(50,7),(6,7),(5,7),(4,7),
(55,8),(56,8),(57,8),(7,8),(8,8),(9,8),(44,8),(43,8),(26,8),(27,8),(22,8),(24,8),
(6,9),(5,9),(3,9),(1,9),(13,9),(11,9),(29,9),(30,9),(46,9),(47,9),(18,9),(19,9),
(55,10),(56,10),(50,10),(51,10),(22,10),(23,10),(24,10),
(19,11),(20,11),(21,11),(15,11),(17,11),(37,11),(38,11),(49,11),(50,11),(51,11),(22,11),(23,11),
(50,12),(51,12),(40,12),(41,12),(42,12),(44,12),(11,12),(12,12),(13,12),(23,12),(24,12),(25,12),(26,12),(27,12),(37,12),(38,12),(52,12),(53,12),(54,12),
(32,13),(33,13),(34,13),(30,13),(31,13),(11,13),(12,13),(13,13),(47,13),(46,13),(45,13),
(45,14),(46,14),(47,14),(14,14),(15,14),(16,14),(50,14),(51,14),(52,14),(26,14),(27,14),(7,14),(8,14),
(29,15),(30,15),(31,15),(1,15),(2,15),(4,15),(6,15),(58,15),(57,15),(23,15);
INSERT INTO dlc_owned (dlc_id,user_id) VALUES
(33,1),(34,1),(37,1),(38,1),(31,1),(32,1),
(34,2),(37,2),(36,2),(23,2),(24,2),(43,2),(7,3),(6,3),(4,3),(28,3),
(24,3),(8,3),
(34,4),(37,4),(38,4),(35,4),(46,4),(39,4),(40,4),(41,4),(47,4),(28,4),(29,4),
(43,5),(44,5),(39,5),(26,5),
(1,6),(2,6),(3,6),(40,6),(10,6),(11,6),(13,6),(16,6),(49,6),
(31,7),(32,7),(48,7),(45,7),(44,7),(4,7),(7,7),(8,7),(23,7),(22,7),(24,7),(46,7),
(47,8),(48,8),(49,8),(4,8),(7,8),(8,8),(34,8),(35,8),(36,8),(26,8),
(11,9),(12,9),(13,9),(15,9),(17,9),(30,9),(40,9),(41,9),(22,9),(23,9),
(48,10),(46,10),
(18,11),(19,11),(20,11),(32,11),(46,11),
(33,12),(34,12),(35,12),(36,12),(37,12),(38,12),(14,12),(15,12),(16,12),(26,12),
(27,13),(28,13),(29,13),(44,13),
(42,14),(43,14),(45,14),(19,14),(20,14),(31,14),
(29,15),(1,15),(2,15),(3,15),(26,15);
COMMIT;

