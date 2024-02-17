-- 1.

-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.  ***originally did COUNT, wrong answer***
	
SELECT
	DISTINCT npi,
	SUM(total_claim_count) AS total_number_of_claims
FROM prescription
GROUP BY npi
ORDER BY total_number_of_claims DESC
LIMIT 1;

-- ANSWER: 1881634483 at 99707 total claims

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.   ***got it wrong too***

SELECT
	DISTINCT p1.npi,
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	specialty_description,
	SUM(total_claim_count) AS total_number_of_claims
FROM prescriber as p1
	LEFT JOIN prescription AS p2
	ON p1.npi = p2.npi
GROUP BY p1.npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_number_of_claims DESC
LIMIT 1;

-- ANSWER: Michael Cox, internal medicine

**************************************************************

-- 2. a. Which specialty had the most total number of claims (totaled over all drugs)? ***actually got it right***

SELECT
	specialty_description,
	SUM(total_claim_count) AS total_number_of_claims
FROM prescriber
	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
GROUP BY specialty_description
ORDER BY total_number_of_claims DESC;

-- ANSWER: Family Practice at 9,752,347
	
-- 2. b. Which specialty had the most total number of claims for opioids?
-- SUM is correct, but need to order by the opioid drug flag  *** still wrong, revisit on recording


SELECT
	specialty_description,
	SUM(total_claim_count) as total_claims
FROM prescriber
	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
	INNER JOIN drug
	ON prescription.drug_name = prescription.drug_name	
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
--ORDER BY opioid_drug_flag DESC
LIMIT 1;

-- ANSWER: Nurse Practitioner at 14979419

-- 2. c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?   -- COME BACK TO THIS ONE

SELECT
	p1.specialty_description,
	p2.drug_name
FROM prescriber AS P1
	INNER JOIN prescription AS p2
	ON p1.npi = p2.npi;
	


-- 2. d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids? MAY NOT EVEN ATTEMPT, WE WILL SEE >.<

SELECT
	specialty_description,
	SUM(
		CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count
		ELSE 0
	END
	) as opioid_claims,
	
	SUM(total_claim_count) AS total_claims,
	
	SUM(
		CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count
		ELSE 0
	END
	) * 100.0 /  SUM(total_claim_count) AS opioid_percentage
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING(drug_name)
GROUP BY specialty_description
--order by specialty_description;
order by opioid_percentage desc

**************************************************************

-- 3. a. Which drug (generic_name) had the highest total drug cost? *CORRECT*

SELECT
	DISTINCT generic_name,
	SUM(total_drug_cost) AS total_drug_cost
FROM drug
	INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name
GROUP BY DISTINCT generic_name
ORDER BY total_drug_cost DESC;

-- ANSWER: Insulin Glargine, HUM.REC.ANLOG

-- 3. b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**  COME BACK TO THIS ONE

SELECT
	drug_name
	ROUND(SUM(total_drug_cost)/SUM(total_30_day_fill_count),2) as cost
FROM prescription
INNER JOIN drug
	USING (drug_name)



**************************************************************

-- 4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. ***CORRECT***

SELECT 
	drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibotic'
		 ELSE 'neither' END AS drug_type
FROM drug;

-- 4. b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.  **COME BACK TO THIS ONE**

SELECT 
	DISTINCT d.drug_name,
	SUM(total_drug_cost) as total_drug_cost,
	
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibotic'
		 ELSE 'neither' END AS drug_type
		 
FROM drug as d
	INNER JOIN prescription as p
	ON d.drug_name = p.drug_name
GROUP BY d.drug_name, d.opioid_drug_flag, d.antibiotic_drug_flag 
ORDER BY drug_type, total_drug_cost DESC;

**************************************************************

-- 5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.  10 or 42 answers

-- --SELECT
-- 	cbsa, 
-- 	cbsaname            WRONG
-- FROM cbsa
-- WHERE cbsaname ILIKE '%tn%'
-- GROUP BY cbsa, cbsaname;

SELECT COUNT (*)
FROM cbsa
INNER JOIN fips_county
USING (fipscounty)
WHERE state = 'TN';

-- ANSWER: 42

-- 5. b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.   **correct**

SELECT
	cbsa,
	cbsa.cbsaname,
	SUM(population) AS population
FROM cbsa
	INNER JOIN population
	ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsa, cbsaname
ORDER BY population DESC;

-- ANSWER: Largest is Nashville-Davidson-Murfreesboro-Franklin. Smallest is Morristown, TN.

-- 5. c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.  CAN'T FIND JUST THE ONES NOT INCLUDED... COME BACK TO THIS ONE   **wrong**

SELECT 
	f.county,
	SUM(p.population) AS population, 
	c.cbsa
FROM fips_county AS f
	RIGHT JOIN cbsa AS c
	ON f.fipscounty = c.fipscounty
	RIGHT JOIN population as p
	ON c.fipscounty = p.fipscounty
GROUP BY f.county, c.cbsa, p.population
ORDER BY p.population DESC;
	
**************************************************************

-- 6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.  **correct**

SELECT 
	drug_name,
	total_claim_count AS total_claims
FROM prescription
WHERE total_claim_count > 3000;

-- 6. b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT
	p.drug_name,
	total_claim_count AS total_claims,
	
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN opioid_drug_flag = 'N' THEN 'not an opioid'
		 ELSE 'not an opioid' END AS opioid_drug_flag
	
FROM prescription AS p
	INNER JOIN drug AS d
	ON p.drug_name = d.drug_name
WHERE total_claim_count > 3000;

-- 6. c. Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT
	d.drug_name, 
	p2.total_claim_count AS total_claims, 
	p1.nppes_provider_first_name AS provider_first_name,
	p1.nppes_provider_last_org_name AS provider_last_name,
	
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN opioid_drug_flag = 'N' THEN 'not an opioid'
		 ELSE 'not an opioid' END AS opioid_drug_flag
		 
FROM prescriber AS p1
	INNER JOIN prescription AS p2
	ON p1.npi = p2.npi
	LEFT JOIN drug as d
	ON p2.drug_name = d.drug_name
WHERE total_claim_count > 3000;

**************************************************************


-- 7. a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT
	p.npi,
	d.drug_name
FROM prescriber AS p
	CROSS JOIN drug as d
WHERE p.specialty_description ILIKE 'pain management'
	AND p.nppes_provider_city ILIKE 'Nashville'
	AND d.opioid_drug_flag = 'Y';

-- 7. b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).  **wrong... so wrong**

SELECT
	p1.npi,
	d.drug_name,
	SUM(total_claim_count) AS total_number_of_claims
FROM prescriber AS p1
	CROSS JOIN drug as d
	INNER JOIN prescription as p2
	ON d.drug_name = p2.drug_name
WHERE p1.specialty_description ILIKE 'pain management'
	AND p1.nppes_provider_city ILIKE 'Nashville'
	AND d.opioid_drug_flag = 'Y'
GROUP BY
	p1.npi,
	d.drug_name,
	total_claim_count
ORDER BY p1.npi;  -- Why am I getting 364??

-- 7. c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.


SELECT
	p1.npi,
	d.drug_name,
	COALESCE(SUM(total_claim_count)) AS total_number_of_claims
FROM prescriber AS p1
	CROSS JOIN drug as d
	INNER JOIN prescription as p2
	ON d.drug_name = p2.drug_name
WHERE p1.specialty_description ILIKE 'pain management'
	AND p1.nppes_provider_city ILIKE 'Nashville'
	AND d.opioid_drug_flag = 'Y'
GROUP BY
	p1.npi,
	d.drug_name;  -- Why am I getting 364??

