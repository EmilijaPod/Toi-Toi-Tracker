CREATE TABLE toilets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

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
