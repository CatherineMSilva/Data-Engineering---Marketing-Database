import csv

# Function to convert market cap string to numerical value in billions
def parse_market_cap(market_cap_str):
    # Remove the dollar sign and split the value from its magnitude indicator (T or B)
    value, magnitude = market_cap_str.replace('$', '').split(' ')
    value = float(value)  # Convert the string to a float
    
    # If the magnitude is 'T', multiply by 1000 to convert to billions
    if magnitude == 'T':
        return value * 1000
    # If the magnitude is 'B', it's already in billions
    elif magnitude == 'B':
        return value
    else:
        return 0  # Return 0 if the format is unrecognized

# Read countries and map country names to their Alpha_3 codes
country_alpha_3_map = {}
with open('countries.csv', mode='r', encoding='utf-8') as countries_file:
    reader = csv.reader(countries_file)
    next(reader)  # Skip header
    for row in reader:
        country_name, _, _, alpha_3_code = row
        country_alpha_3_map[country_name] = alpha_3_code

# Initialize a list to hold insert statements
insert_statements = []

# Process companies file
with open('companies500.csv', mode='r', encoding='utf-8') as companies_file:
    lines = companies_file.readlines()

# Iterate over lines, considering each company's data spans 3 lines
for i in range(0, len(lines), 3):
    name_market_cap_country = lines[i].strip().split(',')
    ticker_symbol = lines[i+1].strip()

    if len(name_market_cap_country) < 3:
        continue  # Skip malformed entries

    name, market_cap_str, country = name_market_cap_country
    market_cap_in_billions = parse_market_cap(market_cap_str)

    alpha_3_code = country_alpha_3_map.get(country, None)

    # Prepare insert statement
    if alpha_3_code:
        insert_statement = f"INSERT INTO Companies (Name, Ticker_Symbol, HQ_Location, Market_Cap_In_Billions) VALUES ('{name.replace("'", "''")}', '{ticker_symbol}', '{alpha_3_code}', {market_cap_in_billions});"
    else:
        # Use full country name if Alpha_3 code not found
        insert_statement = f"INSERT INTO Companies (Name, Ticker_Symbol, HQ_Location, Market_Cap_In_Billions) VALUES ('{name.replace("'", "''")}', '{ticker_symbol}', '{country.replace("'", "''")}', {market_cap_in_billions});"
    
    insert_statements.append(insert_statement)

# Write the insert statements to "insert_companies.sql"
with open('insert_companies.sql', 'w', encoding='utf-8') as output_file:
    for statement in insert_statements:
        output_file.write(statement + "\n")

print(f"Insert statements have been written to 'insert_companies.sql'.")
