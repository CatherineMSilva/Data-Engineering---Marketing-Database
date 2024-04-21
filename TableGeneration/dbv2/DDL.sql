CREATE TABLE Country (
    Alpha_3_code 		CHAR(3) PRIMARY KEY,    
    Country 			VARCHAR(30),
    Region 				VARCHAR(30),
    GDP_in_bil 	        DECIMAL(7, 2),
    Population 			BIGINT,  
    Yearly_change_rate 	DECIMAL(5, 2),
    Density_p_km 		INT,
    Land_area_km 		INT,
    Median_age 			INT,
    Urban_pop_percent 	INT
);


CREATE TABLE Influencer (
    ID 				        SERIAL PRIMARY KEY,
    Name 			        VARCHAR(35),
    Platform 		        VARCHAR(12),
	Country					CHAR(3) REFERENCES Country(Alpha_3_Code)
);

 -- Followers_in_millions 	DECIMAL(7, 2), 

CREATE TABLE followers_by_country (
    Influencer_ID         INT REFERENCES Influencer(ID),
    Country               CHAR(3) REFERENCES Country(Alpha_3_code),
    Followers             INT,
    PRIMARY KEY (Influencer_ID, Country)
);

CREATE TABLE Company (
    ID                          SERIAL PRIMARY KEY,
    Name                        VARCHAR(50),
	Ticker_Symbol               VARCHAR(20), -- New column for the ticker symbol
    HQ_Location                 CHAR(3) REFERENCES Country(Alpha_3_Code),
    Market_Cap_In_Billions      DECIMAL(7, 2)
);

CREATE TABLE Contract (
    Contract_ID 	VARCHAR (20) PRIMARY KEY,
    Influencer 		INT REFERENCES Influencer(ID),
    Company 	    INT REFERENCES Company(ID),
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