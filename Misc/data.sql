CREATE DATABASE IF NOT EXISTS toitoi;
USE toitoi;

-- 1. Tualetų lentelė
CREATE TABLE IF NOT EXISTS toilets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- 2. Tualetų duomenys
INSERT INTO toilets (id, name, location) VALUES
(1, 'Cathedral Square', '54.6860,25.2869'),
(2, 'Lukiškės Square', '54.6887,25.2714'),
(3, 'Rotušės Square', '54.6785,25.2869'),
(4, 'Vingio Park', '54.6830,25.2395'),
(5, 'Bernardinų Garden', '54.6828,25.2941'),
(6, 'Kalnų Park / Three Crosses Hill', '54.6888,25.2978'),
(7, 'Verkiai Regional Park', '54.7556,25.3032'),
(8, 'Justiniškės', '54.7311,25.2200'),
(9, 'Krokuvos str Construction', '54.6966,25.2814'),
(10, 'Railway Station Development Area', '54.6695,25.2813'),
(11, 'Neris', '54.6962,25.2689'),
(12, 'Pilaitės Construction', '54.7058,25.1666'),
(13, 'Rasų Seniūnijos Construction', '54.6462,25.3054'),
(14, 'Pašilaičių Construction', '54.7399,25.2234'),
(15, 'Rokantiškių Construction', '54.6922,25.4022'),
(16, 'Naujininkų Construction', '54.6341,25.2624'),
(17, 'Saltoniškių Construction', '54.6990,25.2612'),
(18, 'Šnipiškių Construction', '54.7036,25.2814'),
(19, 'Šeškinės Construction', '54.7161,25.2506'),
(20, 'Akropolio Stadiono Statybos', '54.7087,25.2591');

-- 3. Atsiliepimų lentelė
CREATE TABLE IF NOT EXISTS reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    toilet_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT NOT NULL,
    FOREIGN KEY (toilet_id) REFERENCES toilets(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Atsiliepimų duomenys
INSERT INTO reviews (toilet_id, rating, comment) VALUES
(1,5,'Very clean and maintained, quick service.'),
(1,4,'Well-kept, but had a long line at peak hours.'),
(1,5,'Excellent location and hygiene.'),
(2,4,'Good condition but paper dispenser was empty.'),
(2,3,'Smelled a bit, but usable.'),
(2,4,'Clean overall, needs minor improvements.'),
(3,3,'Smelled a bit, but usable.'),
(3,2,'Not very clean during weekends.'),
(3,3,'Basic facilities, could be improved.'),
(4,5,'Spacious, good for festivals.'),
(4,5,'Very well-maintained, ideal for events.'),
(4,4,'Good location.'),
(5,3,'Clean but it was out of toilet paper.'),
(5,5,'Nice and tidy, good for tourists.'),
(5,3,'A bit dirty near the fountain.'),
(6,3,'Rough condition, but acceptable for hikers.'),
(6,2,'The seat was cracked.'),
(6,3,'Okay for quick use, not great.'),
(7,4,'Well-placed and mostly clean.'),
(7,4,'Convenient and functional.'),
(7,3,'Could use more frequent cleaning.'),
(8,3,'Small and a bit dirty, but usable.'),
(8,2,'Not ideal, very basic.'),
(8,3,'Functional but a bit rough looking.'),
(9,3,'Construction area, a bit rough but available.'),
(9,3,'Functional, but dusty and noisy.'),
(9,2,'Not very clean.'),
(10,4,'Clean for workers, basic facilities.'),
(10,3,'Functional but has a bad smell.'),
(10,4,'Well-maintained, easy access.'),
(11,3,'Functional but could be cleaner.'),
(11,1,'Terrible smell.'),
(11,3,'Acceptable for quick use.'),
(12,3,'Functional but dusty due to construction.'),
(12,3,'Usable, but rough conditions.'),
(12,2,'Basic facilities only.'),
(13,3,'Usable, a bit messy from ongoing work.'),
(13,3,'Functional, minimal stalls.'),
(13,2,'Construction area, rough conditions.'),
(14,4,'Clean and accessible, decent for workers.'),
(14,4,'Well-maintained, easy to find.'),
(14,3,'It smells, but is functional.'),
(15,3,'Basic facilities, not very clean.'),
(15,2,'Small, could use more cleaning.'),
(15,3,'Usable, but rough conditions.'),
(16,3,'Small portable toilet, has a smell.'),
(16,2,'Not very clean, limited space.'),
(16,3,'Basic, functional for quick use.'),
(17,4,'Well-maintained.'),
(17,4,'Clean and convenient location.'),
(17,3,'Minor smell, but functional.'),
(18,3,'Construction site facility, rough but usable.'),
(18,3,'Basic, could use more maintenance.'),
(18,2,'A bit dirty.'),
(19,4,'Clean and functional.'),
(19,3,'Minor smell occasionally.'),
(19,4,'Accessible and usable for workers.'),
(20,3,'Basic, slightly dirty but accessible.'),
(20,2,'Construction zone, rough conditions.'),
(20,3,'Functional but could be cleaner.');
