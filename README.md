# Finder: A job match database for tech jobs
There is wide range of skills and tools in nowadays' tech world, therefore finding the right match between talents and vacancies could be really tricky.

### Problem Statement
1. As a recruiter, I want to list the right match based on the required skills.
2. As a job seeker, I want to find the right match and monitor the ‘hot’ skills in the job market, so I can measure my current position.
3. As an employee, I want to find the average salary for my position and experience. Do I need to negotiate?

### Solution
How this database may help:
- Help recruiters matching the right talent with the right job vacancies.
- Help job seekers to find a job match.
- Help employees to understand and stay competitive in the current job market.


## Usage

### Schema
![finder_er_diagram](https://user-images.githubusercontent.com/101298450/161381304-79299fcd-5c54-4b80-aa62-b0d56d1d9e50.png)

### List of tables
Tables are categorised on four types: Talents, Vacancies, Applications, and Matching Criteria

**Talents** | **Vacancies** | **Application** | **Matching Criteria**
--- | --- | --- | --- |
job_seeker | job_vacancy | job_application | skill
job_seeker_company | company | application_status |
job_seeker_skill | job_vacancy_skill |

_Note:_

1. **job_seeker:** Database of talents with the basic information
2. **job_seeker_company:** Information about talents' current and past companies
3. **job_seeker_skill:** Information about talents' soft and hard skills
4. **job_vacancy:** Database of job vacancies
5. **company:** Database of hiring companies
6. **job_vacancy_skill:** Information about skills requirements in a vacancy
7. **job_application:** Information about a job matching process
8. **application_status:** Information about current job vacancy status

### Queries 
Queries made for this project:

1. **View** to find active job vacancies.
2. **Function** to determine the job level based on years of experience.
3. **Procedure** to register job seeker.
3. **Subquery** to find a candidate based on skill that match the job vacancy requirement.
4. **Group By** to display data in a better visualisation.
5. **Trigger** to update job vacancy status after an applicant got hired.
6. **View** with 6 tables to generate a report of potential candidates for all job vacancies.

### Recommendations
Some ideas to extend this work:

- Develop skills criterias with 'essential', 'preferable', and 'nice to have'
- Add query based on criteria of location_preference and location_type of 'remote', 'on-site', and 'hybrid'
