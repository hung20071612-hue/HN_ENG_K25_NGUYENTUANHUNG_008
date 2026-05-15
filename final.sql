CREATE DATABASE sport_system ;
USE sport_system ;

-- tạo bảng đội bóng
CREATE TABLE teams (
	team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    founded_year INT NOT NULL CHECK(founded_year < 2026),
    stadium VARCHAR(100) NOT NULL,
    ranking_position INT DEFAULT 0
);

-- tạo bảng huấn luyện viên
CREATE TABLE coaches (
	coach_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    experience_years INT DEFAULT 0,
    team_id INT NOT NULL,
    FOREIGN KEY(team_id) REFERENCES teams(team_id)
);

-- tạo bảng cầu thủ
CREATE TABLE players (
	player_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    jersey_number INT NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(12,2) NOT NULL,
    team_id INT NOT NULL,
    FOREIGN KEY(team_id) REFERENCES teams(team_id)
);

-- tạo bảng trận đấu
CREATE TABLE matches (
	match_id INT PRIMARY KEY AUTO_INCREMENT,
    home_team_id INT NOT NULL,
    FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    away_team_id INT NOT NULL ,
    FOREIGN KEY (away_team_id) REFERENCES teams(team_id),
    match_date DATETIME NOT NULL,
    stadium VARCHAR(100) NOT NULL,
    match_status VARCHAR(30) DEFAULT('Scheduled')
);

-- tạo bảng phân tích trận đấu
CREATE TABLE player_statistics (
	stat_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT NOT NULL,
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    match_id INT NOT NULL,
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    yellow_cards INT DEFAULT 0,
    rating_score DECIMAL(3,1) DEFAULT 0
);

-- chèn dữ liệu vào bảng teams
INSERT INTO teams (team_name,founded_year,stadium,ranking_position)
VALUES 
('Manchester City',1880,'Etihad Stadium',1),
('Real Madrid',1902,'Santiago Bernabeu',2),
('Hanoi FC',2006,'Hang Day Stadium',3),
('Saigon United',2015,'Thong Nhat Stadium',5),
('Thép xanh Nam Định',1979,'Thiên Trường Stadium',10);

-- chèn dữ liệu vào bảng  coaches
INSERT INTO coaches (full_name,nationality,experience_years,team_id)
VALUES 
('Pep Guardiola','Spanish',15,1),
('Carlo Ancelotti','Italian',25,2),
('Chu Đình Nghiêm','Vietnamese',12,3),
('Alexandre Polking','German-Brazilian',10,4),
('Park Hang-seo','Korean',30,5);

-- chèn dữ liệu vào bảng players
INSERT INTO players (full_name,jersey_number,position,salary,team_id)
VALUES 
('Erling Haaland',9,'Forward',450000000,1),
('Kevin De Bruyne',17,'Midfielder',400000000,1),
('Nguyễn Quang Hải',19,'Midfielder',60000000,3),
('Kylian Mbappe',7,'Forward',500000000,2),
('Nguyễn Văn Quyết',10,'Forward',55000000,3);

-- chèn dữ liệu vào bảng matches
INSERT INTO matches (home_team_id,away_team_id,match_date,stadium,match_status)
VALUES 
(1,2,'2026-05-10 19:00:00','Etihad Stadium','Finished'),
(3,4,'2026-05-12 18:30:00','Hang Day Stadium','Finished'),
(5,1,'2026-05-15 20:00:00','Thien Truong Stadium','Scheduled'),
(2,3,'2026-05-20 21:00:00','Santiago Bernabeu','Scheduled'),
(4,5,'2026-05-25 17:00:00','Thong Nhat Stadium','Scheduled');

-- chèn dữ liệu vào bảng player_statistics
INSERT INTO player_statistics (player_id,match_id,goals,assists,yellow_cards,rating_score)
VALUES 
(1,1,2,1,0,9.5),
(4,1,1,0,1,8.2),
(3,2,0,2,0,8.5),
(5,2,3,0,0,9),
(1,4,0,0,3,5);

-- Cập nhật cầu thủ có vị trí là Forward và có điểm chấm trên 8
UPDATE players p1
JOIN player_statistics p2 ON p1.player_id = p2.player_id
SET salary = salary * 1.15
WHERE position LIKE 'Forward' AND rating_score > 8;

-- xóa phân tích khi có 2 thẻ vàng
DELETE FROM player_statistics 
WHERE yellow_cards > 2;

-- truy vấn đến cầu thủ có lương trên 50 tiệu hoặc có vị trí là Midfielder
SELECT full_name,jersey_number,position
FROM players
WHERE salary > 50000000 OR position LIKE ' Midfielder';

-- truy vấn tên đội có trong xếp hạng từ 1 đến 5 và có tên bắt đầu bằng chữ S
SELECT team_name, stadium
FROM teams 
WHERE (ranking_position BETWEEN 1 AND 5) AND stadium LIKE 'S%';

-- Truy vấn đến các trận đấu gần nhất bắt đầu từ trang 2
SELECT match_id, stadium, match_date
FROM matches
ORDER BY match_date DESC
LIMIT 3 OFFSET 3;

-- truy vấn đến tên cầu thủ của đội của đội có số bàn thắng và số kiến tạo
SELECT full_name,team_name,goals,assists
FROM players p1
JOIN teams t ON p1.team_id = t.team_id
JOIN player_statistics p2 ON p2.player_id = p1.player_id;

-- Truy vấn đến đội có tổng số ghi bàn trên 10 
SELECT team_name, SUM(goals)
FROM players p1
JOIN teams t ON p1.team_id = t.team_id
JOIN player_statistics p2 ON p2.player_id = p1.player_id
GROUP BY team_name
HAVING SUM(goals) > 10;

-- truy vấn đến những cầu thử có mức lương cao nhất trong hệ thống
SELECT player_id,full_name,salary
FROM players 
ORDER BY salary DESC;

-- tạo ra chỉ mục của bảng players với 2 cột position,salary
CREATE INDEX index_po_sa ON players(position,salary);

-- tọa ra view hiển thị tổng cầu thủ, quỹ lương của mỗi đội
CREATE VIEW team_salary AS
SELECT team_name, COUNT(t.team_id) total_player, SUM(salary) total_salary
FROM teams t
JOIN players p ON p.team_id = t.team_id
WHERE salary > 0
GROUP BY team_name;

SELECT * FROM team_salary;

-- tạo ra trigger để cập nhập khi mà có 1 dữ liệu mới của bảng player_statistics 
-- có cầu thử ghi hơn 10 bàn thì cập nhật lương cho cầu thủ đấy
DELIMITER //
CREATE TRIGGER auto_up_salary
AFTER INSERT ON player_statistics
FOR EACH ROW
BEGIN
	IF goals > 10 THEN
    UPDATE players 
    SET salary = salary * 1.05
    WHERE NEW.player_id = player_id;
    END IF;
END //
DELIMITER ;

-- hiển thị thông báo về cầu thủ trong trận đấu
DELIMITER //
CREATE PROCEDURE display_commnet(
IN p_player_id INT,
OUT commet VARCHAR(50)
)
BEGIN
DECLARE v_goals INT;
	SELECT SUM(goals) INTO v_goals
    FROM player_statistics
    WHERE player_id = p_player_id
    GROUP BY player_id;
    IF v_goals > 20 THEN 
    SET commet = 'Excellent';
    ELSEIF v_goals BETWEEN 10 AND 20 THEN
    SET commet = 'Good';
    ELSEIF v_goals < 10 THEN
    SET commet = 'Average';
    END IF;
END //
DELIMITER ;
