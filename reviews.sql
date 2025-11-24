CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    toilet_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT NOT NULL,
    FOREIGN KEY (toilet_id) REFERENCES toilets(id)
) ENGINE=InnoDB;

INSERT INTO reviews (toilet_id, rating, comment) VALUES
-- Cathedral Square
(1,5,'Very clean and maintained, quick service.'),
(1,4,'Well-kept, but had a long line at peak hours.'),
(1,5,'Excellent location and hygiene.'),

-- Lukiškės Square
(2,4,'Good condition but paper dispenser was empty.'),
(2,3,'Smelled a bit, but usable.'),
(2,4,'Clean overall, needs minor improvements.'),

-- Rotušės Square
(3,3,'Smelled a bit, but usable.'),
(3,2,'Not very clean during weekends.'),
(3,3,'Basic facilities, could be improved.'),

-- Vingio Park
(4,5,'Spacious, good for festivals.'),
(4,5,'Very well-maintained, ideal for events.'),
(4,4,'Good location.'),

-- Bernardinų Garden
(5,3,'Clean but it was out of toilet paper.'),
(5,5,'Nice and tidy, good for tourists.'),
(5,3,'A bit dirty near the fountain.'),

-- Kalnų Park / Three Crosses Hill
(6,3,'Rough condition, but acceptable for hikers.'),
(6,2,'The seat was cracked.'),
(6,3,'Okay for quick use, not great.'),

-- Verkiai Regional Park
(7,4,'Well-placed and mostly clean.'),
(7,4,'Convenient and functional.'),
(7,3,'Could use more frequent cleaning.'),

-- Justiniškės
(8,3,'Small and a bit dirty, but usable.'),
(8,2,'Not ideal, very basic.'),
(8,3,'Functional but a bit rough looking.'),

-- Krokuvos str Construction
(9,3,'Construction area, a bit rough but available.'),
(9,3,'Functional, but dusty and noisy.'),
(9,2,'Not very clean.'),

-- Railway Station Development Area
(10,4,'Clean for workers, basic facilities.'),
(10,3,'Functional but has a bad smell.'),
(10,4,'Well-maintained, easy access.'),

-- Neris
(11,3,'Functional but could be cleaner.'),
(11,1,'Terrible smell.'),
(11,3,'Acceptable for quick use.'),

-- Pilaitės Construction
(12,3,'Functional but dusty due to construction.'),
(12,3,'Usable, but rough conditions.'),
(12,2,'Basic facilities only.'),

-- Rasų Seniūnijos Construction
(13,3,'Usable, a bit messy from ongoing work.'),
(13,3,'Functional, minimal stalls.'),
(13,2,'Construction area, rough conditions.'),

-- Pašilaičių Construction
(14,4,'Clean and accessible, decent for workers.'),
(14,4,'Well-maintained, easy to find.'),
(14,3,'It smells, but is functional.'),

-- Rokantiškių Construction
(15,3,'Basic facilities, not very clean.'),
(15,2,'Small, could use more cleaning.'),
(15,3,'Usable, but rough conditions.'),

-- Naujininkų Construction
(16,3,'Small portable toilet, has a smell.'),
(16,2,'Not very clean, limited space.'),
(16,3,'Basic, functional for quick use.'),

-- Saltoniškių Construction
(17,4,'Well-maintained.'),
(17,4,'Clean and convenient location.'),
(17,3,'Minor smell, but functional.'),

-- Šnipiškių Construction
(18,3,'Construction site facility, rough but usable.'),
(18,3,'Basic, could use more maintenance.'),
(18,2,'A bit dirty.'),

-- Šeškinės Construction
(19,4,'Clean and functional.'),
(19,3,'Minor smell occasionally.'),
(19,4,'Accessible and usable for workers.'),

-- Akropolio Stadiono Construction
(20,3,'Basic, slightly dirty but accessible.'),
(20,2,'Construction zone, rough conditions.'),
(20,3,'Functional but could be cleaner.');