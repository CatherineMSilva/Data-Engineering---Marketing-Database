					----Queries For Our Tables----

--Query #1
-- Create a view (contract_totals) for influencer name, company name, 
-- total contract value (payment + fee), contract_id, start/end dates. 
CREATE VIEW Contract_totals AS
SELECT 
    i.Name AS Influencer_Name,
    c.Name AS Company_Name,
    SUM(p.Payment + p.Fee) AS Payment_Total,
    ct.Contract_ID,
    ct.Date_Start,
    ct.Date_End
FROM 
    Contract ct
JOIN 
    Influencer i ON ct.Influencer_ID = i.ID
JOIN 
    Company c ON ct.Company_Ticker = c.Ticker_Symbol
JOIN 
    Pays p ON ct.Contract_ID = p.Contract_ID
GROUP BY 
    ct.Contract_ID, ct.Date_Start, ct.Date_End, i.Name, c.Name;
	
	
-- Query #2
-- List countries ordered by median age from youngest to oldest

SELECT Country, Median_age
FROM Country
ORDER BY Median_age ASC;
	

-- Query #3
-- Function to count number of contracts given a company name

CREATE OR REPLACE FUNCTION num_contracts(comp_name VARCHAR(50))
RETURNS INTEGER AS $$
DECLARE
    cont_count INTEGER;
    v_ticker_symbol VARCHAR(20); -- Avoiding ambiguity by using a different variable name
BEGIN
    -- Retrieve the ticker symbol for the given company name using LIKE for partial matching
    SELECT Ticker_Symbol INTO v_ticker_symbol
    FROM Company
    WHERE Name LIKE '%' || comp_name || '%';  -- Using concatenation to include wildcard characters

    -- Count contracts associated with the ticker symbol
    SELECT COUNT(*) INTO cont_count
    FROM Contract
    WHERE Company_Ticker = v_ticker_symbol;

    RETURN cont_count;
END
$$ LANGUAGE plpgsql;


-- Example use of the function (returns same result since it looks for similar names not exact)
SELECT num_contracts('Google');
SELECT num_contracts('Alphabet');



--Query #4
--	View (Active_contracts)
--	Create a view that shows the deadline for all contracts that are active
-- 	Include dealine, influencer name, company name, payment, fee, contract ID 
--	Rename column as "deadline"
CREATE OR REPLACE VIEW Active_contracts AS
SELECT 
    p.Payment_deadline AS Deadline,
    i.Name AS Influencer_Name,
    c.Name AS Company_Name,
    p.Payment,
    p.Fee,
    ct.Contract_ID
FROM 
    Pays p
JOIN 
    Contract ct ON p.Contract_ID = ct.Contract_ID
JOIN 
    Influencer i ON ct.Influencer_ID = i.ID
JOIN 
    Company c ON ct.Company_Ticker = c.Ticker_Symbol
WHERE 
    ct.Date_end > CURRENT_DATE
ORDER BY 
    p.Payment_deadline;



--Query #5
--	Defining a function that returns a count of influencers after inputting
--of a country Alpha 3 code

CREATE OR REPLACE FUNCTION Influencer_per_country(country_a3_input VARCHAR(3))
RETURNS INTEGER AS $$
DECLARE
    influencer_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO influencer_count
    FROM Influencer
    WHERE Country = country_a3_input;
    RETURN influencer_count;
END
$$ LANGUAGE plpgsql;

-- To test the function:
SELECT influencer_per_country('USA');


-- Query #6
-- Sometimes a company wants to terminate it's contract early. 
-- This function takes a company's name and closes all active contracts 
-- by updating the contract end date to the current date.
-- It then lists the details of all the affected contracts

CREATE OR REPLACE FUNCTION close_active_contracts(company_name VARCHAR)
RETURNS TABLE (
    Contract_ID VARCHAR(20),
    Influencer_ID INT,
    Company_Ticker VARCHAR(20),
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
        WHERE Company.Name ILIKE '%' || search_term || '%'
        AND Contract.Company_Ticker = Company.Ticker_Symbol
        AND Contract.Date_end > CURRENT_DATE
        RETURNING Contract.*
    )
    SELECT * FROM updated;
END;
$$ LANGUAGE plpgsql;

--Example:
SELECT * FROM close_active_contracts('Cencora');



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
    company_ticker VARCHAR(20);
    new_contract_id VARCHAR;
    payment_id VARCHAR;
    payment_deadline DATE;
    payment_amount DECIMAL;
    fee_amount DECIMAL;
BEGIN
    -- Lookup IDs
    SELECT ID INTO influencer_id FROM Influencer WHERE Name = influencer_name;
    SELECT Ticker_Symbol INTO company_ticker FROM Company WHERE Name ILIKE '%' || company_name || '%'; -- Supports partial matching for company names

    -- Generate Contract ID with underscores
    new_contract_id := UPPER(SUBSTRING(company_ticker FROM 1 FOR 3)) || '_' || 
                       TO_CHAR(NOW(), 'MONYY') || '_' || 
                       LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');

    -- Insert into Contract table
    INSERT INTO Contract (Contract_ID, Influencer_ID, Company_Ticker, Date_start, Date_end)
    VALUES (new_contract_id, influencer_id, company_ticker, start_date, end_date);

    -- Generate Payment ID and Payment Deadline
    payment_id := LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');
    payment_deadline := start_date + INTERVAL '30 days';

    -- Calculate Payment and Fee
    payment_amount := contract_value * 0.7;
    fee_amount := contract_value * 0.3;

    -- Insert into Pays table
    INSERT INTO Pays (Payment_ID, Contract_ID, Payment_deadline, Payment, Fee)
    VALUES (payment_id, new_contract_id, payment_deadline, payment_amount, fee_amount);
    
    -- Return the newly created Contract ID
    RETURN new_contract_id;
END;
$$ LANGUAGE plpgsql;

SELECT create_contract_with_payment('leomessi', 'Amazon', 93467, '2025-05-06', '2024-09-03');


--Query #8
-- Hypothetically, a company might want to see all the influencers who reside in the same country as it's headquarters
-- This function takes a company name and outputs all the influencers who reside in that country.

CREATE OR REPLACE FUNCTION get_influencers_by_company_country(company_ticker VARCHAR)
RETURNS TABLE (
    ID INT,
    Name VARCHAR(35),
    Platform VARCHAR(12),
    Country CHAR(3)
) AS $$
BEGIN
    -- Directly return all influencers from the country of the given company's headquarters
    RETURN QUERY 
    SELECT Influencer.ID, Influencer.Name, Influencer.Platform, Influencer.Country
    FROM Influencer
    JOIN Company ON Influencer.Country = Company.HQ_Location
    WHERE Company.Ticker_Symbol = company_ticker;
END;
$$ LANGUAGE plpgsql;

-- Example
SELECT * FROM get_influencers_by_company_country('AMZN');



--Query #9
-- Our marketing team is really good, just absolutely exceptional.
-- Somehow they got the companies to agree to pay a bonus given certain conditions.
-- In this case, if the influencer's followers go up by 1 million, in the company's own country.
-- The influencer's payment will go up by 3%
-- This applies only to active contracts
CREATE OR REPLACE FUNCTION update_payment_for_influencer()
RETURNS TRIGGER AS $$
DECLARE
    hq_country CHAR(3);
    follower_increase INT;
    affected_rows RECORD; -- Variable to hold the output of the RETURNING clause for debugging
BEGIN
    -- Identify the company's headquarters country for the influencer from the Contract
    SELECT HQ_Location INTO hq_country
    FROM Company
    JOIN Contract ON Company.Ticker_Symbol = Contract.Company_Ticker
    WHERE Contract.Influencer_ID = NEW.Influencer_ID
    AND Contract.Date_end > CURRENT_DATE
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE NOTICE 'No active contracts found for influencer ID %.', NEW.Influencer_ID;
        RETURN NEW;
    END IF;

    -- Directly calculate the increase in followers for the specific HQ country
    follower_increase := NEW.followers - OLD.followers;

    RAISE NOTICE 'Follower increase calculated: %', follower_increase;

    -- Check if the follower increase is at least 1 million
    IF follower_increase >= 1000000 THEN
        UPDATE Pays
        SET payment = payment * 1.03
        FROM Contract
        WHERE Pays.contract_ID = Contract.Contract_ID
        AND Contract.Influencer_ID = NEW.Influencer_ID
        AND Contract.Date_end > CURRENT_DATE
        RETURNING Pays.* INTO affected_rows;  -- Capture the debug output into the variable

        -- Optionally, raise notice to show what was updated
        RAISE NOTICE 'Payment updated: %', affected_rows;
    ELSE
        RAISE NOTICE 'Follower increase not sufficient: %', follower_increase;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER influencer_followers_update
AFTER UPDATE OF followers ON followers_by_country
FOR EACH ROW
WHEN (OLD.followers IS DISTINCT FROM NEW.followers)
EXECUTE FUNCTION update_payment_for_influencer();


-- Process for testing the trigger

-- Check payment first
SELECT * FROM Pays
WHERE contract_ID = 'PUB_OCT23_347324';

-- Update the follower count to trigger the payment update
UPDATE followers_by_country
SET followers = followers + 1000000  -- Increasing by 1,000,000
WHERE Influencer_ID = 6247 AND Country = 'USA';

-- Check payment a second time
SELECT * FROM Pays
WHERE contract_ID = 'PUB_OCT23_347324';



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
        AND Contract.Company_Ticker = NEW.Ticker_Symbol
        AND Contract.Date_end > CURRENT_DATE;
    END IF;
    
    -- Return the new record to indicate the update operation should proceed
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER company_market_cap_update
AFTER UPDATE OF Market_Cap_In_Billions ON Company
FOR EACH ROW
WHEN (OLD.Market_Cap_In_Billions IS DISTINCT FROM NEW.Market_Cap_In_Billions)
EXECUTE FUNCTION update_fee_for_company();


-- Check payment
SELECT * FROM Pays
WHERE contract_ID = 'PUB_OCT23_347324';

UPDATE Company
SET Market_Cap_In_Billions = 70 
WHERE Ticker_Symbol = 'PSA'; 

-- Check payment a second time
SELECT * FROM Pays
WHERE contract_ID = 'PUB_OCT23_347324';
