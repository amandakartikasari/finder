-- CR3 Create a view to find active job openings

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
