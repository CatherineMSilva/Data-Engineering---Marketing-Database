CREATE TABLE Country (
    Country 			VARCHAR(30) PRIMARY KEY,
    Region 				VARCHAR(30),
    Alpha_2_code 		CHAR(2) UNIQUE, -- Changed to CHAR(2) as country codes are 2 letters
    Alpha_3_code 		CHAR(3) UNIQUE, -- Changed to CHAR(3) as country codes are 3 letters
    Population 			BIGINT,
    Yearly_change_rate 	DECIMAL(5, 2), -- Renamed and specified for clarity
    Density_p_km 		INT, -- Removed special characters
    Land_area_km 		INT, -- Removed special characters
    Median_age 			INT,
    Urban_pop_percent 	INT NULL -- Renamed, allowed for NULL
);


CREATE TABLE Influencer (
    ID 				        SERIAL PRIMARY KEY,
    Name 			        VARCHAR(35),
    Platform 		        VARCHAR(12),
    Followers_in_millions 	DECIMAL(7, 2), 
	Country					CHAR(3) REFERENCES Country(Alpha_3_Code)
);


CREATE TABLE Company (
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(50),
	Ticker_Symbol VARCHAR(20), -- New column for the ticker symbol
    HQ_Location CHAR(3) REFERENCES Country(Alpha_3_Code),
    Market_Cap_In_Billions  DECIMAL(7, 2)
);

CREATE TABLE Contract (
    Contract_ID 	VARCHAR (20) PRIMARY KEY,
    Influencer 		INT REFERENCES Influencer(ID),
    Company 	INT REFERENCES Company(ID),
    Date_start 		DATE,
    Date_end 		DATE
);

CREATE TABLE Pays (
	Payment_ID		 VARCHAR(20) PRIMARY KEY,
	contract_ID 	 VARCHAR(20) REFERENCES contract(contract_ID), 
	Payment_deadline DATE,
	payment	         DECIMAL (10,2),
	fee				 DECIMAL (10,2)
);