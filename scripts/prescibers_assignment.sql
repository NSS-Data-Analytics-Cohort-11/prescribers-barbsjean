-- 1.

-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
	
SELECT
	DISTINCT npi,
	COUNT (total_claim_count) AS total_number_of_claims
FROM prescription
GROUP BY npi
ORDER BY total_number_of_claims DESC
LIMIT 1;

-- ANSWER: 1356305197 at 379 total claims

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT
	DISTINCT prescriber.npi,
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	specialty_description,
	COUNT (total_claim_count) AS total_number_of_claims
FROM prescriber
	LEFT JOIN prescription
	ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_number_of_claims DESC
LIMIT 1;

-- ANSWER: Michael Cox, internal medicine

**************************************************************

-- 2. a. Which specialty had the most total number of claims (totaled over all drugs)? 

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

SELECT
	specialty_description,
	SUM(total_claim_count) AS total_number_of_claims
FROM prescriber
	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
	INNER JOIN drug
	ON prescription.drug_name = prescription.drug_name	
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_number_of_claims DESC;

-- ANSWER: Family Practice at 887,463,577

-- 2. c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?   -- COME BACK TO THIS ONE

SELECT
	DISTINCT prescriber.specialty_description,
	prescription.drug_name
FROM prescriber
	INNER JOIN prescription
	ON prescriber.npi = prescription.npi;

-- 2. d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids? MAY NOT EVEN ATTEMPT, WE WILL SEE >.<

**************************************************************

-- 3. a. Which drug (generic_name) had the highest total drug cost?

SELECT
	DISTINCT generic_name,
	SUM(total_drug_cost) AS total_drug_cost
FROM drug
	INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name
GROUP BY DISTINCT generic_name
ORDER BY total_drug_cost DESC;

-- ANSWER: Insulin Glargine, HUM.REC.ANLOG

-- 3. b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT *
from prescription
	








