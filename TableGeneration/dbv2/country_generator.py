def parse_gdp(gdp_string):
    # Remove the dollar sign, commas, and excessive trailing zeroes
    cleaned_gdp = gdp_string.replace('$', '').replace(',', '')
    # Convert to float, divide by 1 billion, and round to two decimal places
    billion_gdp = round(float(cleaned_gdp) / 1e9, 2)
    return billion_gdp

# File paths
country_filename = 'country.csv'
gdp_filename = 'country_gdp2.csv'
output_filename = 'country.sql'

# Read and process GDP data
gdp_data = {}
with open(gdp_filename, mode='r', encoding='utf-8') as file:
    for line in file:
        parts = line.strip().split('|')
        country_name = parts[1]
        gdp_value = parse_gdp(parts[2].strip('"'))  # Remove quotes and parse
        gdp_data[country_name] = gdp_value

# Prepare SQL insert statements
sql_statements = []
with open(country_filename, mode='r', encoding='utf-8') as file:
    headers = file.readline().strip().split(',')  # Read headers separately
    for line in file:
        parts = line.strip().split(',')
        # Map parts to headers ensuring lower case for SQL column names
        data_dict = {headers[i].strip().lower(): parts[i] for i in range(len(headers))}
        
        # Retrieve values with lower case keys
        alpha_3_code = data_dict['alpha_3_code']
        country = data_dict['country']
        region = data_dict['region']
        population = data_dict['population']
        yearly_change_rate = float(data_dict['yearly_change_rate'])
        density_p_km = int(data_dict['density_p_km'])
        land_area_km = int(data_dict['land_area_km'])
        median_age = int(data_dict['median_age'])
        urban_pop_percent = data_dict['urban_pop_percent']
        gdp = gdp_data.get(country, 'NULL')  # Default to NULL if no GDP data available

        # Create SQL statement
        sql = f"INSERT INTO country (alpha_3_code, country, region, gdp_in_bil, population, yearly_change_rate, density_p_km, land_area_km, median_age, urban_pop_percent) VALUES ('{alpha_3_code}', '{country}', '{region}', {gdp}, {population},  {yearly_change_rate}, {density_p_km}, {land_area_km}, {median_age}, {urban_pop_percent});"
        sql_statements.append(sql)

# Write SQL statements to a file
with open(output_filename, mode='w', encoding='utf-8') as output_file:
    for statement in sql_statements:
        output_file.write(statement + '\n')

print("SQL insert statements have been written to:", output_filename)
