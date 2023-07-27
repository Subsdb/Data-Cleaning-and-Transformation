# Data Science Job Posting on Glassdoor

# Data source - https://www.kaggle.com/datasets/rashikrahmanpritom/data-science-job-posting-on-glassdoor?select=Uncleaned_DS_jobs.csv

# I have downloaded this dataset from Kaggle . This dataset contains the Data Science job listed in Glassdoor .
# I have performed Data CLeaning and Transformation using PostgreSQL Database system in order to  make the dataset ready for analysis . 



create table jobs (index varchar(500),	Job_Title varchar(500),	Salary_Estimate	varchar(500),Job_Description varchar(50000),	Rating varchar(500),
						Company_Name varchar(500),	Location varchar(500),	Headquarters varchar(500),
						Size varchar(500),	Founded varchar(500),	Type_of_ownership varchar(500),
						Industry varchar(500) ,	Sector varchar(500),Revenue	varchar(500), Competitors varchar(500));
						
						
					
--  View the dataset
select * from jobs ;


						
-- splitting the expected_salary column into  min salary column and fill the column

alter table jobs 
add column  min_salary varchar(500) ;

update jobs
set min_salary = split_part (salary_estimate,'-',1);


-- We will add avg_salary column and populate the column. 
-- avg_salary = (min_salary + max_salary) / 2
alter table jobs 
add column avg_salary decimal(10,2);

update jobs 
set avg_salary = ((min_salary + max_salary) / 2);




-- Adding column named max_salary and populating the column
alter table jobs 
add column max_salary varchar(500);

update jobs 
set max_salary = split_part (salary_estimate , '-' , 2);


-- Remove the text (Glassdoor est.) from max_salary
update jobs 
set max_salary = replace (max_salary, '(Glassdoor est.)', '');

-- max_salary still has some text concatenated to the salary, Lets remove the text
update jobs 
set max_salary = replace(max_salary , '(Employer est.)' , '');


-- Remove the $ from min and max salary 
update jobs 
set min_salary = replace (min_salary , '$' ,'');

update jobs 
set max_salary = replace (max_salary , '$','');


-- Replacing K by 1000 , 1K = 1000
update jobs 
set min_salary = replace(min_salary, 'K', '000');

update jobs 
set max_salary = replace(max_salary, 'K', '000');



-- converting the data type of min and max salary column to integer
alter table jobs 
alter column min_salary type integer using min_salary::integer;

alter table jobs 
alter column max_salary type integer using max_salary::integer;



-- We will now remove the salary_estimate column
alter table jobs 
drop column salary_estimate;


-- All the columns having record as -1
select 
count (*) filter  (where size = '-1') as size_error,
count (*) filter (where founded = '-1') as founded_error,
count(*) filter (where type_of_ownership = '-1') as ownership_error,
count(*) filter (where industry = '-1') as industry_error,
count(*) filter (where sector = '-1') as sector,
count(*) filter (where revenue = '-1') as revenue_error,
count (*) filter (where revenue = 'Unknown / Non-Applicable') as revenue_NA
from jobs;

-- We see that competitors column has 501 records with '-1' so we can not analyse it . 
-- we will Drop this column 
alter table jobs 
drop column competitors ;


-- We see that most companies (397/672) are private companies . Hence for the sake of analysis we
-- will assume that the records with -1 are also private companies . 
update jobs 
set type_of_ownership = 'Company - Private'
where type_of_ownership = '-1';


-- There are some job titles having 'Senior' keyword. We will create a new column 'seniority' 
-- and fill the columns according to the seniority 
alter table jobs 
add column seniority varchar(500);

update jobs 
set seniority = 'Senior'
where job_title like 'Senior%';

Update jobs 
set seniority = 'Not Given'
where seniority IS NULL;

select job_title ,count(job_title) as count from jobs
where job_title like 'Senior%'
group by job_title
order by count desc;




-- Adding a new column company age and fill the column
alter table jobs
add column company_age_in_years integer;

update jobs 
set company_age_in_years = 2023 - (founded::integer);


-- Added below 4 columns and populated the columns

alter table jobs 
add column company_state varchar (50),
add column company_city varchar (50),
add column HQ_state varchar (50),
add column HQ_city varchar (50);

update jobs 
set 
company_city = split_part (location, ',',1),
company_state = split_part (location, ',',2),
hq_city = split_part (headquarters , ',',1),
hq_state = split_part (headquarters , ',',2);

-- Now that all 4 columns are populated , we will delete the location and headquarters column

alter table jobs 
drop column location,
drop column headquarters;



-- Job description contains lots of text we can not get meaningful information out of it 
-- so we will drop the column
alter table jobs 
drop column job_description ;

-- Dropping the records containing '-1' in founded , industry and sector column 
delete from jobs
where founded = '-1';

delete from jobs 
where  industry = '-1';

delete from  jobs 
where sector = '-1';

-- Finally dropping column index as it is not needed . 
alter table jobs 
drop column index;



-- Our data is now cleaned and ready to be analysed