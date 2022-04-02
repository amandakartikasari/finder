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
	current_company VARCHAR(50),
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
    FOREIGN KEY (job_vacancy_id) REFERENCES job_vacancy(id),
    FOREIGN KEY (skill_id) REFERENCES skill(id) 
);

CREATE TABLE job_seeker_skill(
	job_seeker_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    FOREIGN KEY (job_seeker_id) REFERENCES job_seeker(id),
    FOREIGN KEY (skill_id) REFERENCES skill(id) 
);

CREATE TABLE job_seeker_company(
	job_seeker_id INTEGER NOT NULL,
    company_id INTEGER NOT NULL,
    is_current BOOLEAN NOT NULL,
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