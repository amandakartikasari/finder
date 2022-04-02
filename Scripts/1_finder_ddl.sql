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
    
CREATE TABLE application_status(
	id INTEGER NOT NULL PRIMARY KEY,
    status VARCHAR(50) NOT NULL
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
    FOREIGN KEY (application_statucompanys_id) REFERENCES application_status(id)
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


SELECT * FROM job_vacancy WHERE id = 1;

UPDATE job_application
SET application_status_id = 4
WHERE job_vacancy_id = 1;










