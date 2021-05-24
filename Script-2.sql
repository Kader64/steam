----------------------------------------------------------TRANSAKCJE------------------------------------------------
-- Prosty przelew pieniêdzy miêdzy dwoma u¿ytkownikami, który wymaga 100%, wiêc u¿yty zostanie poziom izolacji SERIALIZABLE
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	UPDATE users SET budget = budget-200 WHERE user_id = 2;
	UPDATE users SET budget = budget+200 WHERE user_id = 1;
COMMIT;
SELECT * FROM users;
-- Transakcja dodaj¹ca now¹ grê, a do niej osi¹gniêcia i DLC
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
	INSERT INTO games (title,price,description,release_date) VALUES ('Dying Light',99.99,'First-person action survival game set in a post-apocalyptic open world overrun by flesh-hungry zombies. Roam a city devastated by a mysterious virus epidemic. Scavenge for supplies, craft weapons, and face hordes of the infected.','2015-01-26');
	INSERT INTO dlc (title,price,game_id,release_date) VALUES ('Hellraid',34.99,21,'2020-08-13'),
	('Shu Warrior Bundle',10.99,21,'2020-01-23'),
	('Left 4 Dead 2 Weapon Pack',0,21,'2019-11-24');
	INSERT INTO achievements (title,description,game_id) VALUES ('Hush, Hush Now','Quiet a Screamer',21),
	('Is It Really Necessary?','Kill your first Infected',21),
	('A Long Way Down','Jump to the water from the Infamy Bridge (Slums) at night',21);
	INSERT INTO category_games (category_id,game_id) VALUES (1,21),(6,21);
COMMIT;

----------------------------------------------------------U¯YTKOWNICY--------------------------------------------------
CREATE USER viewer WITH PASSWORD '123456789';
GRANT SELECT ON ALL TABLES IN SCHEMA steam TO viewer;

CREATE USER "admin" WITH PASSWORD '987654321';
GRANT SELECT,INSERT,DELETE,UPDATE,TRUNCATE ON ALL TABLES IN SCHEMA steam TO "admin";
GRANT ALL ON  ALL FUNCTIONS IN SCHEMA steam TO "admin";

CREATE USER games_admin WITH PASSWORD 'games1234';
GRANT INSERT,SELECT,DELETE,UPDATE ON games,games_owned TO games_admin;

CREATE USER steam_moderator WITH PASSWORD 'moderator123';
GRANT ALL ON ALL TABLES IN SCHEMA steam TO steam_moderator;
GRANT ALL ON ALL SEQUENCES IN SCHEMA steam TO steam_moderator;
GRANT ALL ON DATABASE steam TO steam_moderator;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA steam TO steam_moderator;


----------------------------------------------------------WIDOKI----------------------------------------------------
-- Wszystkie dostêpne DLC dla ka¿dej gry.
CREATE OR REPLACE VIEW games_dlc AS
SELECT g.title AS game_title, d.title AS dlc_title, d.price FROM dlc AS d
INNER JOIN games AS g ON g.game_id = d.game_id;

-- Wszystkie dostêpne osi¹gniêcia dla ka¿dej gry.
CREATE OR REPLACE VIEW games_achievements AS
SELECT g.title AS game_title, a.title AS achievements_title, a.description FROM achievements AS a
INNER JOIN games AS g ON g.game_id = a.game_id;

-- Ile procent u¿ytkowników posiada dan¹ grê
CREATE OR REPLACE VIEW games_owned_percent AS
SELECT g.title AS game_title, count(u.user_id)*100/(SELECT count(user_id) FROM users) AS PERCENT FROM users AS u
INNER JOIN games_owned AS g_o ON u.user_id = g_o.user_id
INNER JOIN games AS g ON g.game_id = g_o.game_id GROUP BY g.title;

-- Ile procent u¿ytkowników posiadaj¹cych dan¹ grê ma do niej osi¹gniecia
CREATE OR REPLACE VIEW achievements_earned_percent AS
SELECT a.title AS achievements,count(u.user_id)*100/(SELECT count(u.nick) FROM users AS u 
INNER JOIN games_owned AS g_o ON u.user_id = g_o.user_id
INNER JOIN games AS g ON g.game_id = g_o.game_id 
WHERE g.game_id = a.game_id) AS percent  FROM users AS u
INNER JOIN achievements_earned AS ae ON u.user_id = ae.user_id
INNER JOIN achievements AS a ON ae.achievement_id = a.achievement_id
GROUP BY a.game_id,a.title ORDER BY PERCENT DESC;

-- Ile procent u¿ytkowników posiadaj¹cych dan¹ grê ma do niej DLC
CREATE OR REPLACE VIEW dlc_owned_percent AS
SELECT d.title AS dlc, count(u.user_id)*100/(SELECT count(u.nick) FROM users AS u 
INNER JOIN games_owned AS g_o ON u.user_id = g_o.user_id
INNER JOIN games AS g ON g.game_id = g_o.game_id 
WHERE g.game_id = d.game_id) AS PERCENT FROM users AS u
INNER JOIN dlc_owned AS d_o ON u.user_id = d_o.user_id 
INNER JOIN dlc AS d ON d.dlc_id = d_o.dlc_id
GROUP BY d.game_id,d.title ORDER BY PERCENT DESC;

--Wyœwietlanie widoków
SELECT * FROM games_dlc;
SELECT * FROM games_achievements;
SELECT * FROM games_owned_percent;
SELECT * FROM achievements_earned_percent;
SELECT * FROM dlc_owned_percent;

----------------------------------------------------------PROCEDURY----------------------------------------------------

-- Procedura odpowiedzialna za zakup gry przez u¿ytkownika. (Sprawdza czy bud¿et jest wystarczaj¹cy i aktualizuje go oraz dodaje grê)
CREATE OR REPLACE PROCEDURE buyGame(g int, u int)
LANGUAGE plpgsql
AS $$
DECLARE 
	price numeric(10,2) DEFAULT (SELECT price FROM games WHERE game_id = g);
BEGIN
	IF (SELECT budget FROM users WHERE user_id = u) >= price THEN
		UPDATE users SET budget=budget-price WHERE user_id = u;
		INSERT INTO games_owned (game_id,user_id) VALUES  (g,u);
		RAISE NOTICE 'Zakup gry zakoñczony sukcesem';
	ELSE
		RAISE EXCEPTION 'Œrodki na koncie s¹ niewystarczaj¹ce na zakup tej gry';
	END IF;
END;
$$;

--Procedura odpowiedzialna za zakup DLC. (Sprawdza czy u¿ytkownik posiada grê do której chcê zakupiæ DLC oraz 
--sprawdza czy bud¿et jest wystarczaj¹cy i aktualizuje go, dodaj¹c DLC)
CREATE OR REPLACE PROCEDURE buyDLC(d int, u int)
LANGUAGE plpgsql
AS $$
DECLARE 
	price numeric(10,2) DEFAULT (SELECT price FROM dlc WHERE dlc_id = d);
BEGIN
	IF (SELECT count(g.title) FROM users AS u INNER JOIN games_owned AS g_o ON u.user_id = g_o.user_id 
	INNER JOIN games AS g ON g.game_id = g_o.game_id WHERE u.user_id = 3 AND g.game_id = 1) > 0 THEN
		IF (SELECT budget FROM users WHERE user_id = u) >= price THEN
			UPDATE users SET budget=budget-price WHERE user_id = u;
			INSERT INTO dlc_owned (dlc_id,user_id) VALUES (d,u);
			RAISE NOTICE 'Zakup DLC zakoñczony sukcesem';
		ELSE
			RAISE EXCEPTION 'Œrodki na koncie s¹ niewystarczaj¹ce na zakup tego DLC';
		END IF;
	ELSE
		RAISE EXCEPTION 'Nie mo¿na zakupiæ DLC, poniewa¿ u¿ytkownik nie posiada do niego gry';
	END IF;
END;
$$;

--Wywo³anie procedur
CALL buyGame(11, 3);
CALL buyDLC(21, 10);


--Trigger, który usuwa grupê, gdy wszyscy u¿ytkownicy j¹ upuszcz¹
DROP TRIGGER IF EXISTS trigger_delete_group ON groups_members;
CREATE TRIGGER trigger_delete_group AFTER DELETE ON groups_members FOR EACH ROW EXECUTE PROCEDURE delete_group();

CREATE OR REPLACE FUNCTION delete_group() RETURNS TRIGGER AS $delete$
BEGIN
	IF (SELECT count(user_id) FROM groups_members WHERE group_id = OLD.group_id) = 0 THEN 
		DELETE FROM "groups" WHERE group_id = OLD.group_id;
		RAISE NOTICE 'Grupa usuniêta pomyœlnie';
	END IF;
    RETURN NEW;
END;
$delete$ LANGUAGE plpgsql;

--Wywo³anie triggera nast¹pi po u¿yciu DELETE na tabeli groups_members.
DELETE FROM groups_members WHERE groups_members_id = 36;
