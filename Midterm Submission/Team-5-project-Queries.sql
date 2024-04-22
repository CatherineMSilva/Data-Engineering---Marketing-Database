					----Queries For Our Tables----

--Query #1
-- 	Create a view (contract_totals) for influencer name, company name, 
--total contract value (payment + fee), contract_id, start/end dates. 

create view Contract_totals as
	select influencer.name as influencer_name, company.name as company_name, 
	sum (pays.payment + pays.fee) as payment_total,
	contract.contract_id, contract.date_start, contract.date_end
	from influencer, contract, company, pays
	group by contract.date_start, contract.date_end, contract.contract_id, influencer_name, company_name;



--Query #2
--	group countries by youngest age median to olders age

select country.country, median_age
from country
order by median_age ASC;


--Query #3
--	Function to count number of contracts a company has given company ID

CREATE OR REPLACE FUNCTION num_contracts (comp_name VARCHAR(20))
RETURNS INTEGER AS $$
DECLARE
	cont_count INTEGER;
BEGIN
	SELECT COUNT(contract) INTO cont_count
	FROM contract, company
	WHERE company.name = comp_name and contract.company = company.id;
	RETURN cont_count;
END
$$ LANGUAGE plpgsql;

SELECT num_contracts('Amazon');



--Query #4
--	View (Active_contracts)
--	Create a view that shows the deadline for all contracts that are active
-- 	Include dealine, influencer name, company name, payment, fee, contract ID 
--	Rename column as "deadline"

create view Active_contracts as
	select payment_deadline as deadline, influencer.name as influencer_name, 
	company.name as company_name, pays.payment, pays.fee, contract.contract_id
	from pays, contract, company, influencer
	group by deadline, company_name, influencer_name, pays.payment, pays.fee, contract.contract_id;


--Query #5
--	Defining a function that returns a count of influencers after inputting
--of a country Alpha 3 code

CREATE OR REPLACE FUNCTION Influencer_per_country (country_a3_input VARCHAR(3))
RETURNS INTEGER AS $$
DECLARE
	influencer_count INTEGER;
BEGIN
	SELECT COUNT(*) INTO influencer_count
	FROM influencer
	WHERE influencer.country = country_a3_input;
	RETURN influencer_count;
END
$$ LANGUAGE plpgsql;

SELECT influencer_per_country('USA');



-- Query #6
-- Sometimes a company wants to terminate it's contract early. 
-- This function takes a company's name and closes all active contracts 
-- by updating the contract end date to the current date.
-- It then lists the details of all the affected contracts

CREATE OR REPLACE FUNCTION close_active_contracts(company_name VARCHAR)
RETURNS TABLE (
    Contract_ID VARCHAR(20),
    Influencer INT,
    Company INT,
    Date_start DATE,
    Date_end DATE
) AS $$
BEGIN
    -- Update the contracts and directly return the affected rows
    RETURN QUERY
    WITH updated AS (
        UPDATE Contract
        SET Date_end = CURRENT_DATE
        FROM Company
        WHERE Company.Name = company_name
        AND Contract.Company = Company.ID
        AND Contract.Date_end > CURRENT_DATE
        RETURNING Contract.*
    )
    SELECT * FROM updated;
END;
$$ LANGUAGE plpgsql;

--Example:
SELECT * FROM close_active_contracts('Alphabet (Google)');



--Query #7
-- This function automatically generates an entry for the contract table and the pays table
-- It takes 5 pieces of data from the user, and uses that to generate all necessary details.
-- In particular it uses a random number generator to create the contract id and payment id.
-- It also calculates the appropriate fee and payment (split 30%/70%).
-- Returns the new contract ID
CREATE OR REPLACE FUNCTION create_contract_with_payment(
    influencer_name VARCHAR,
    company_name VARCHAR,
    contract_value DECIMAL,
    start_date DATE,
    end_date DATE
)
RETURNS VARCHAR AS $$
DECLARE
    influencer_id INT;
    company_id INT;
    new_contract_id VARCHAR;
    payment_id VARCHAR;
    payment_deadline DATE;
    payment_amount DECIMAL;
    fee_amount DECIMAL;
BEGIN
    -- Lookup IDs
    SELECT ID INTO influencer_id FROM Influencer WHERE Name = influencer_name;
    SELECT ID INTO company_id FROM Company WHERE Name = company_name;

    -- Generate Contract ID with underscores
    new_contract_id := UPPER(SUBSTRING(company_name FROM 1 FOR 3)) || '_' || 
                       TO_CHAR(NOW(), 'MONYY') || '_' || 
                       LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');

    -- Insert into Contract table
    INSERT INTO Contract (Contract_ID, Influencer, Company, Date_start, Date_end)
    VALUES (new_contract_id, influencer_id, company_id, start_date, end_date);

    -- Generate Payment ID and Payment Deadline
    payment_id := LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');
    payment_deadline := start_date + INTERVAL '30 days';

    -- Calculate Payment and Fee
    payment_amount := contract_value * 0.7;
    fee_amount := contract_value * 0.3;

    -- Insert into Pays table
    INSERT INTO Pays (Payment_ID, contract_ID, Payment_deadline, payment, fee)
    VALUES (payment_id, new_contract_id, payment_deadline, payment_amount, fee_amount);
    
    -- Return the newly created Contract ID
    RETURN new_contract_id;
END;
$$ LANGUAGE plpgsql;


--Example:
SELECT create_contract_with_payment('leomessi', 'Amazon', 93467, '2025-05-06', '2024-09-03');


--Query #8
-- Hypothetically, a company might want to see all the influencers who reside in the same country as it's headquarters
-- This function takes a company name and outputs all the influencers who reside in that country.

CREATE OR REPLACE FUNCTION get_influencers_by_company_country(company_name VARCHAR)
RETURNS TABLE (
    ID INT,
    Name VARCHAR(35),
    Platform VARCHAR(12),
    Followers_in_millions DECIMAL(7, 2),
    Country CHAR(3)
) AS $$
BEGIN
    -- Directly return all influencers from the country of the given company
	-- I tried just using select * from influencer, but then it joined with company and tried to output all columns from both
    RETURN QUERY 
    SELECT Influencer.ID, Influencer.Name, Influencer.Platform, Influencer.Followers_in_millions, Influencer.Country
    FROM Influencer
    JOIN Company ON Influencer.Country = Company.HQ_Location
    WHERE Company.Name = company_name;
END;
$$ LANGUAGE plpgsql;

--Example
SELECT * FROM get_influencers_by_company_country('Amazon');



--Query #9
-- Our marketing team is really good, just absolutely exceptional.
-- Somehow they got the companies to agree to pay a bonus given certain conditions.
-- In this case, if the influencer's followers go up by 10 million, their payment will go up by 3%
-- This applies only to active contracts
CREATE OR REPLACE FUNCTION update_payment_for_influencer()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the new follower count is at least 10 million higher than the old count
    IF NEW.Followers_in_millions >= OLD.Followers_in_millions + 10 THEN
        -- Update payment for all active contracts associated with this influencer
        UPDATE Pays
        SET payment = payment * 1.03
        FROM Contract
        WHERE Pays.contract_ID = Contract.Contract_ID
        AND Contract.Influencer = NEW.ID
        AND Contract.Date_end > CURRENT_DATE;
    END IF;
    
    -- Return the new record to indicate the update operation should proceed
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Only triggers if the follower count is updated
CREATE TRIGGER influencer_followers_update
AFTER UPDATE OF Followers_in_millions ON Influencer
FOR EACH ROW
WHEN (OLD.Followers_in_millions IS DISTINCT FROM NEW.Followers_in_millions)
EXECUTE FUNCTION update_payment_for_influencer();

--Example:
UPDATE Influencer
SET Followers_in_millions = 37.4
WHERE ID = 1572;


-- Query #10
-- In a similar situation as before, we negotiated a deal that if a company's market cap
-- increases, it is obviously due to the the high quality advertising we bring them.
-- If a company's market cap increases by 10 billion, our fee goes up by 3%
CREATE OR REPLACE FUNCTION update_fee_for_company()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the new market cap is at least 10 billion higher than the old market cap
    IF NEW.Market_Cap_In_Billions >= OLD.Market_Cap_In_Billions + 10 THEN
        -- Update fee for all active contracts associated with this company
        UPDATE Pays
        SET fee = fee * 1.03
        FROM Contract
        WHERE Pays.contract_ID = Contract.Contract_ID
        AND Contract.Company = NEW.ID
        AND Contract.Date_end > CURRENT_DATE;
    END IF;
    
    -- Return the new record to indicate the update operation should proceed
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Only triggers if the Market cap value is updated
CREATE TRIGGER company_market_cap_update
AFTER UPDATE OF Market_Cap_In_Billions ON Company
FOR EACH ROW
WHEN (OLD.Market_Cap_In_Billions IS DISTINCT FROM NEW.Market_Cap_In_Billions)
EXECUTE FUNCTION update_fee_for_company();

--Example:
UPDATE Company
SET Market_Cap_In_Billions = 139.73
WHERE ID = 105;