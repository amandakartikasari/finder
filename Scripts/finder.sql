CREATE DATABASE finder;

USE finder;

CREATE TABLE company(
	id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
	country VARCHAR(50) NOT NULL,
    industry VARCHAR(50) NOT NULL,
    contact_person VARCHAR(50) NOT NULL,
	email VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL
    );
    
CREATE TABLE job_seeker(
	id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
	country VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    years_of_experience INTEGER,
    industry VARCHAR(50),
    current_job_title VARCHAR(50),
    salary_expectation DECIMAL(12,2),
    location_preference VARCHAR(50)
    );
    
CREATE TABLE skill(
	id INTEGER NOT NULL PRIMARY KEY,
    skill VARCHAR(50) NOT NULL
    );

CREATE TABLE job_vacancy(
	id INTEGER NOT NULL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    publish_date DATE NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    location VARCHAR(50) NOT NULL,
    min_years_of_exp INTEGER NOT NULL,
    salary_range_start DECIMAL(12,2),
    salary_range_end DECIMAL(12,2),
    is_active BOOLEAN NOT NULL,
    FOREIGN KEY (company_id) REFERENCES company(id)
);

CREATE TABLE job_vacancy_skill(
	job_vacancy_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    required BOOLEAN NOT NULL,
	PRIMARY KEY(job_vacancy_id, skill_id),
    FOREIGN KEY (job_vacancy_id) REFERENCES job_vacancy(id),
    FOREIGN KEY (skill_id) REFERENCES skill(id) 
);

CREATE TABLE job_seeker_skill(
	job_seeker_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    PRIMARY KEY(job_seeker_id, skill_id),
    FOREIGN KEY (job_seeker_id) REFERENCES job_seeker(id),
    FOREIGN KEY (skill_id) REFERENCES skill(id) 
);

CREATE TABLE job_seeker_company(
	job_seeker_id INTEGER NOT NULL,
    company_id INTEGER NOT NULL,
    is_current BOOLEAN NOT NULL,
    PRIMARY KEY(job_seeker_id, company_id),
    FOREIGN KEY (job_seeker_id) REFERENCES job_seeker(id),
    FOREIGN KEY (company_id) REFERENCES company(id)
);

CREATE TABLE application_status(
	id INTEGER NOT NULL PRIMARY KEY,
    status VARCHAR(50) NOT NULL
);

CREATE TABLE job_application(
	job_seeker_id INTEGER NOT NULL,
    job_vacancy_id INTEGER NOT NULL,
    application_status_id INTEGER NOT NULL,
    FOREIGN KEY (job_seeker_id) REFERENCES job_seeker(id),
    FOREIGN KEY (job_vacancy_id) REFERENCES job_vacancy(id),
    FOREIGN KEY (application_status_id) REFERENCES application_status(id)
);

-- AO1 CREATE PROCEDURE
-- Job seeker registration procedure

DELIMITER //
CREATE PROCEDURE job_seeker_registration_procedure(
	IN job_seeker_id INT,
	IN name VARCHAR(50),
	IN country VARCHAR(50),
    IN email VARCHAR(50),
    IN phone VARCHAR(50),
	IN years_of_experience INTEGER,
	IN industry VARCHAR(50),
	IN current_job_title VARCHAR(50),
	IN salary_expectation DECIMAL(10,2),
	IN location_preference VARCHAR(50),
    IN companies VARCHAR(500),
    IN skills VARCHAR(500)
    )
BEGIN
	DECLARE company_id INT;
	DECLARE skill_id INT;

	-- 1. INSERT INTO job_seeker

	INSERT IGNORE INTO job_seeker(
		id,
		name,
		country,
		email,
		phone,
		years_of_experience,
		industry,
		current_job_title,
		salary_expectation,
		location_preference)
		VALUES
		(job_seeker_id, name, country,email, phone, years_of_experience, industry, current_job_title, salary_expectation, location_preference);

	-- 2. INSERT INTO job_seeker_company
	SET company_id = (SELECT u.id FROM company u WHERE u.name = companies);
	INSERT IGNORE INTO job_seeker_company(
		job_seeker_id,
		company_id,
		is_current)
		VALUES
		(job_seeker_id, company_id, 1);

	-- 3. INSERT INTO job_seeker_skill
	SET skill_id = (SELECT s.id FROM skill s WHERE s.skill = skills);
	INSERT IGNORE INTO job_seeker_skill(
		job_seeker_id,
		skill_id)
		VALUES
		(job_seeker_id, skill_id);

END //
DELIMITER ;

-- AO2 CREATE TRIGGER
-- AFTER APPLICATION STATUS UPDATE

DELIMITER //
CREATE TRIGGER after_application_status_update
AFTER UPDATE
ON job_application FOR EACH ROW
BEGIN
	IF new.application_status_id = 5 THEN
		UPDATE job_vacancy
		SET is_active = 0
		WHERE id = new.job_vacancy_id;
	ELSE
		UPDATE job_vacancy
		SET is_active = 1
		WHERE id = new.job_vacancy_id;
    END IF;
END //

DELIMITER ;

/*
SELECT * FROM job_vacancy WHERE id = 1;

UPDATE job_application
SET application_status_id = 4
WHERE job_vacancy_id = 1;
*/

-- CR3 Create a view to find active job vacancies

CREATE VIEW active_job_view AS
SELECT
	c.name AS company,
    jv.job_title,
    c.country,
    jv.min_years_of_exp,
    jv.salary_range_start,
	jv.is_active
FROM job_vacancy jv
JOIN company c ON c.id = jv.company_id
    WHERE jv.is_active = 1
;

SELECT *
FROM active_job_view
ORDER BY c.country, jv.min_years_of_exp DESC;


-- CR4 Create a stored function to determine job level based on years of experience
	-- 0-2 = entry level
	-- 3-5 = mid level
	-- 5+ = senior level

DELIMITER //
CREATE FUNCTION get_job_level(years_of_exp INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
	DECLARE job_level VARCHAR(20);
	IF years_of_exp <= 1 THEN
	SET job_level = 'Entry Level';
	ELSEIF(years_of_exp BETWEEN 2 AND 4) THEN
	SET job_level = 'Mid Level';
	ELSEIF years_of_exp > 4 THEN
	SET job_level = 'Senior Level';
	END IF;
	RETURN (job_level);
END//

-- CR4 Example: I want to list all active job vacancies with the seniority level

SELECT
	c.name AS company,
    jv.job_title,
    c.country,
    jv.min_years_of_exp,
    get_job_level(min_years_of_exp) AS level,
    jv.salary_range_start,
	jv.is_active
FROM job_vacancy jv
JOIN company c ON c.id = jv.company_id
    WHERE jv.is_active = 1
;

-- As a recruiter, I find it difficult to find candidates that match the job requirements. I want to list the right match based on the required skills.
-- CR5 Subquery

SELECT js.name, js.country, js.email, js.phone
FROM job_seeker js
WHERE js.id IN
	(SELECT jss.job_seeker_id
    FROM job_seeker_skill jss
    WHERE jss.skill_id IN
		(SELECT jvs.skill_id
        FROM job_vacancy_skill jvs
        JOIN skill s
			ON s.id = jvs.skill_id
        WHERE s.skill = 'A/B Testing')
);

-- Find a candidate's skills

SELECT js.name, s.skill
FROM job_seeker js
	JOIN job_seeker_skill jss
		ON jss.job_seeker_id = js.id
	JOIN skill s
		ON s.id = jss.skill_id
    WHERE js.name = 'Janet Kim';

-- Visualize the data with GROUP BY query

SELECT js.name, GROUP_CONCAT(s.skill) AS skills
FROM job_seeker js
	JOIN job_seeker_skill jss
		ON jss.job_seeker_id = js.id
	JOIN skill s
		ON s.id = jss.skill_id
    WHERE js.name = 'Janet Kim'
	GROUP BY js.name;

-- VIEW ON 3-4 BASE TABLES
-- Display a report that contains company name, job vacancy name, starting salary, minimum years of experience, required skills (comma-separated), potential candidate name (comma-separated)
-- example: Barclays, Digital Analyst, 45000, 2, "YouTube, SQL", "Janet Kim (044120329458), Jess Mariano (01924577012)"

CREATE VIEW potential_candidates_report
AS
SELECT
	c.name,
	jv.job_title,
    jv.salary_range_start,
    jv.min_years_of_exp,
    GROUP_CONCAT(s.skill) AS skills,
    GROUP_CONCAT(js.name) AS potential_candidates
FROM job_vacancy jv
	JOIN company c
		ON c.id = jv.company_id
	JOIN job_vacancy_skill jvs
		ON jvs.job_vacancy_id = jv.id
	JOIN skill s
		ON s.id = jvs.skill_id
	JOIN job_seeker_skill jss
		ON jss.skill_id = jvs.skill_id
	JOIN job_seeker js
		ON js.id = jss.job_seeker_id
	GROUP BY
		c.name,
		jv.job_title,
		jv.salary_range_start,
		jv.min_years_of_exp
;

INSERT INTO company
	(id, name, country, industry, contact_person, email, phone)
    VALUES
	(1, 'Wellcome Trust', 'England', 'Philantrophic Fundarising Services', 'Gareth Jones', 'g.jones@wellcome.org', '+44403700100'),
	(2, 'HelloFresh', 'England', 'Consumer Services', 'Valerie Stanga', 'valerie.s@hellofresh.com', '+44555444333'),
	(3, 'Barclays', 'Scotland', 'Financial Services', 'Robin Jackson', 'jackson.robin@barclays.com', '+447909109238'),
	(4, 'eFishery', 'Indonesia', 'Information Technology & Services', 'Cantik Mustika', 'cantik@efishery.com', '+62623245246'),
	(5, 'WeLab', 'Indonesia', 'Financial Services', 'Noel Chen', 'noelchen@welab.co.id', '+62009009001'),
	(6, 'BCG', 'USA', 'Business Consulting and Services', 'Sophie Rafter', 'sofierafter@bcg.com', '+12345678910'),
	(7, 'Lyft', 'USA', 'Travel Arrangements', 'Katelyn Amidon', 'katelyn.amidon@lyft.com', '+19876543210')
;

SELECT 
	id, 
    name, 
    country, 
    industry, 
    contact_person, 
    email, 
    phone 
FROM 
	company;

INSERT INTO job_vacancy
	(id, company_id, publish_date, job_title, location, min_years_of_exp, salary_range_start, salary_range_end, is_active)
    VALUES
	(1, 1, '2022-03-04', 'Digital Analytics Specialist', 'Hybrid', 0, 41000, 43000, TRUE),
	(2, 1, '2022-02-28', 'Head of Technology', 'Hybrid', 5, 100000, 120000, TRUE),
	(3, 2, '2022-02-25', 'Senior Growth Marketing Executive', 'On Site', 5, 42000, 45000, TRUE),
	(4, 3, '2022-03-04', 'Business Analyst', 'On Site', 3, 27000, 28000, TRUE),
	(5, 4, '2022-03-01', 'Data Analyst', 'Remote', 2, 10000, 12000, TRUE),
	(6, 4, '2022-02-27', 'Senior Product Manager', 'Remote', 3, 24000, 25000, TRUE),
	(7, 5, '2022-02-18', 'Data Analyst, Business Intelligence', 'On Site', 3, 10000, 12000, FALSE),
	(8, 5, '2022-02-18', 'Product Manager', 'On Site', 3, 14000, 16000, TRUE),
	(9, 6, '2022-03-03', 'Knowledge Analyst - Digital Marketing', 'Hybrid', 3, 30000, 32000, TRUE),
	(10, 6, '2022-03-03', 'Knowledge Analyst - Senior Digital Marketing', 'Hybrid', 5, 35000, 37000, TRUE),
	(11, 7, '2022-02-26', 'Marketing Analyst', 'On Site', 0, 24000, 27000, TRUE),
	(12, 7, '2022-03-01', 'Product Marketing Manager', 'On Site', 4, 30000, 33000, FALSE)
;

SELECT
	id,
	company_id,
	publish_date,
	job_title,
    location,
    min_years_of_exp,
    salary_range_start,
    salary_range_end,
    is_active
FROM
	job_vacancy;


INSERT INTO skill
	(id, skill)
    VALUES
	(1, 'A/B testing'),
	(2, 'Adobe Analytics'),
	(3, 'Financial technology'),
	(4, 'Adobe Illustrator'),
	(5, 'Adobe InDesign'),
	(6, 'Adobe Photoshop'),
	(7, 'Algorithms'),
	(8, 'Artificial Intelligence'),
	(9, 'Big Data'),
	(10, 'C++'),
	(11, 'Content management systems (CMS)'),
	(12, 'CSS'),
	(13, 'Digital Marketing'),
	(14, 'Facebook'),
	(15, 'GitHub'),
	(16, 'Google Analytics'),
	(17, 'Google Tag Manager'),
	(18, 'HTML'),
	(19, 'Instagram'),
	(20, 'JavaScript'),
	(21, 'LinkedIn'),
	(22, 'Looker'),
	(23, 'Microsoft Access'),
	(24, 'Microsoft Excel'),
	(25, 'Microsoft Office'),
	(26, 'Microsoft PowerPoint'),
	(27, 'Network security'),
	(28, 'Phyton'),
	(29, 'R'),
	(30, 'R Shiny'),
	(31, 'Ruby'),
	(32, 'SAS'),
	(33, 'SEO'),
	(34, 'Servers'),
	(35, 'SPARK'),
	(36, 'Statistics'),
	(37, 'SQL'),
	(38, 'Tableau'),
	(39, 'TikTok'),
	(40, 'Twitter'),
	(41, 'YouTube'),
	(42, 'WordPress'),
	(43, 'Customer experience'),
	(44, 'Applications'),
	(45, 'Cloud services'),
	(46, 'Agile'),
	(47, 'Leadership'),
	(48, 'General Data Protection Regulation (GDPR)'),
	(49, 'Stakeholder management'),
	(50, 'Prioritization'),
	(51, 'Time management'),
	(52, 'Mathematical'),
	(53, 'Analytical'),
	(54, 'Organisational'),
	(55, 'Communication'),
	(56, 'Market risk'),
	(57, 'Data modelling'),
	(58, 'CRM'),
	(59, 'Product management'),
	(60, 'Design thinking'),
	(61, 'Entrepreneurial'),
	(62, 'Google Ads'),
	(63, 'Facebook Ads'),
	(64, 'Consulting'),
	(65, 'Intellectual Property'),
	(66, 'Google DoubleClick'),
	(67, 'Product marketing'),
	(68, 'Consumer insight')
;

INSERT INTO job_vacancy_skill
	(job_vacancy_id, skill_id, required)
	VALUES
    (1, 1, TRUE),
	(1, 14, TRUE),
	(1, 16, TRUE),
	(1, 21, TRUE),
	(1, 33, TRUE),
	(1, 38, TRUE),
	(1, 40, TRUE),
	(1, 41, TRUE),
	(1, 49, TRUE),
	(1, 36, TRUE),
	(1, 48, TRUE),
	(2, 43, TRUE),
	(2, 44, TRUE),
	(2, 45, TRUE),
	(2, 46, TRUE),
	(2, 47, TRUE),
	(2, 9, TRUE),
	(3, 27, FALSE),
	(3, 43, TRUE),
	(3, 48, FALSE),
	(3, 49, TRUE),
	(3, 50, TRUE),
	(3, 51, TRUE),
	(3, 13, TRUE),
	(3, 16, TRUE),
	(4, 49, TRUE),
	(4, 52, TRUE),
	(4, 53, TRUE),
	(4, 54, TRUE),
	(4, 55, TRUE),
	(4, 56, FALSE),
	(5, 24, TRUE),
	(5, 36, TRUE),
	(5, 37, TRUE),
	(5, 38, TRUE),
	(5, 53, TRUE),
	(5, 57, TRUE),
	(6, 9, FALSE),
	(6, 59, TRUE),
	(6, 60, TRUE),
	(6, 53, TRUE),
	(6, 49, TRUE),
	(6, 55, TRUE),
	(6, 3, FALSE),
	(7, 9, TRUE),
	(7, 13, TRUE),
	(7, 16, FALSE),
	(7, 28, FALSE),
	(7, 36, TRUE),
	(7, 37, TRUE),
	(7, 38, TRUE),
	(7, 53, TRUE),
	(7, 57, TRUE),
	(7, 58, FALSE),
	(8, 1, TRUE),
	(8, 3, TRUE),
	(8, 61, FALSE),
	(8, 43, TRUE),
	(8, 55, TRUE),
	(8, 53, TRUE),
	(8, 56, FALSE),
	(9, 13, TRUE),
	(9, 16, TRUE),
	(9, 24, TRUE),
	(9, 49, TRUE),
	(9, 38, TRUE),
	(9, 53, TRUE),
	(9, 55, FALSE),
	(9, 62, FALSE),
	(9, 63, FALSE),
	(9, 64, FALSE),
	(10, 8, FALSE),
	(10, 23, TRUE),
	(10, 24, TRUE),
	(10, 38, TRUE),
	(10, 53, TRUE),
	(10, 55, TRUE),
	(10, 62, TRUE),
	(10, 63, TRUE),
	(10, 64, TRUE),
	(10, 65, FALSE),
	(10, 66, FALSE),
	(11, 1, TRUE),
	(11, 3, FALSE),
	(11, 24, TRUE),
	(11, 37, TRUE),
	(11, 38, TRUE),
	(11, 53, TRUE),
	(11, 64, TRUE),
	(12, 13, TRUE),
	(12, 53, TRUE),
	(12, 55, TRUE),
	(12, 67, TRUE),
	(12, 68, FALSE)
;

-- Register job seekers

CALL job_seeker_registration_procedure(6, 'Dean Forester', 'Scotland', 'dean.f@gmail.com', '+447123123123', 5, 'Hospital & Health Care', 'Health Intelligence Analyst', 55000, NULL, 'BCG', 'SQL');
CALL job_seeker_registration_procedure(17, 'Chandler Bing', 'USA', 'cbing@yahoo.com', '+19555019012', 10, 'Marketing & Advertising', 'Senior Marketing Consultant', 65000, 'Remote', 'HelloFresh', 'R');
CALL job_seeker_registration_procedure(1, 'Rory Gilmore', 'England', 'rorygimore@yahoo.com', '+440982012930', 0, 'Journalism', 'Student', 26000, NULL, NULL, 'SEO');
CALL job_seeker_registration_procedure(2, 'Lorelai Gilmore', 'England', 'lorelaigilmore@gmail.com', '+447093085656', 5, 'Hospitality', 'Marketing Manager', 95000, 'Hybrid', 'Wellcome Trust', 'Customer Experience');
CALL job_seeker_registration_procedure(3, 'Kimchee', 'England', 'kimchee@yahoo.com', '+827819451945', 1, 'Marketing & Advertising', 'Data Analyst', 30000, 'Remote', 'HelloFresh', 'Phyton');
CALL job_seeker_registration_procedure(4, 'Nayoung', 'England', 'nayoungkim@yahoo.com', '+827909109238', 5, 'Marketing & Advertising', 'Software Engineer', 90000, 'Hybrid', 'HelloFresh', 'Tableau');
CALL job_seeker_registration_procedure(5, 'Jess Mariano', 'Scotland', 'jmariano@gmail.com', '+447389110345', 2, 'Renewables & Environment', 'Marketing Executive', 45000, 'On Site', 'Barclays', 'A/B Testing');
CALL job_seeker_registration_procedure(7, 'Logan Huntzberger', 'Scotland', 'loganh@gmail.com', '+447550099120', 3, 'Technology', 'Entrepreneur', 40000, 'Remote', 'Barclays', 'Stakeholder Management');
CALL job_seeker_registration_procedure(8, 'Stephanie Geller', 'Indonesia', 'paris.geller@yahoo.com', '+6281834140358', 2, 'Information Technology & Services', 'Data Engineer', 8000, 'Remote', 'WeLab', 'Statistics');
CALL job_seeker_registration_procedure(9, 'Lane Kim', 'Indonesia', 'kim.lane@gmail.com', '+628991230987', 5, 'Information Technology & Services', 'Product Manager', 20000, 'Remote', 'WeLab', 'Agile');
CALL job_seeker_registration_procedure(10, 'Tristan Dugray', 'Indonesia', 'tristan.d@gmail.com', '+6287788009911', 5, 'Internet', 'Client Growth Manager', 15000, 'On Site', 'BCG', 'Leadership');
CALL job_seeker_registration_procedure(11, 'Richard Burke', 'Indonesia', 'richardburke@gmail.com', '+628565056701', 3, 'Management Consulting', 'Advisor - Strategy & Content', 11000, 'Hybrid', 'eFishery', 'Google Analytics');
CALL job_seeker_registration_procedure(12, 'Shannon Ross', 'USA', 'r.shannon@gmail.com', '+21623245246', 0, 'Management', 'Student', NULL, NULL, NULL, NULL);
CALL job_seeker_registration_procedure(13, 'Janet Kim', 'USA', 'janetkim@yahoo.com', '+25009009001', 6, 'Travel', 'Digital Marketing Strategist', 50000, 'Hybrid', 'Lyft', 'A/B Testing');
CALL job_seeker_registration_procedure(14, 'Rachel Green', 'USA', 'rachelgreen@gmail.com', '+19727309820', 1, 'Retail', 'Shop Assistant', 24000, NULL, NULL, 'Communication');
CALL job_seeker_registration_procedure(15, 'Monica Geller', 'USA', 'monicageller@gmail.com', '+19731009001', 3, 'Financial Services', 'Product Owner', 32000, NULL, 'Lyft', 'Organisational');
CALL job_seeker_registration_procedure(16, 'Joey Tribbiani', 'USA', 'joeyt@yahoo.com', '+19451708194', 5, 'Accounting', 'Technology Consultant Associate', 65000, 'On Site', 'BCG', 'Consulting');


INSERT INTO application_status(
	id,
    status)
    VALUES
    (1, 'Submitted'),
	(2, 'Under Review'),
    (3, 'Interview Scheduled'),
    (4, 'Rejected'),
    (5, 'Hired')
;

INSERT INTO job_application(
	job_seeker_id,
    job_vacancy_id,
    application_status_id)
    VALUES
    (5, 1, 1)
;