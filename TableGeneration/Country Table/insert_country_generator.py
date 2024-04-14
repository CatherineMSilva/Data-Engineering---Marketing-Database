import csv

# Define the filenames
input_filename = 'combined_countries.csv'
output_filename = 'insert_countries.sql'

# Open the output file for writing
with open(output_filename, mode='w', encoding='utf-8') as output_file:
    # Open the input file and read the data
    with open(input_filename, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        
        # Loop through each row in the file
        for row in reader:
            # Extract data from each row
            country, region, alpha_2_code, alpha_3_code, population, yearly_change, density, land_area, median_age, urban_pop_percent = row
            
            # Remove the percent sign and convert to the appropriate data type
            yearly_change_rate = yearly_change.replace('%', '')  # Remove '%' and convert to DECIMAL
            urban_pop_percent = urban_pop_percent.replace('%', '')  # Remove '%' and convert to INT
            
            # Handle N.A. or empty values for Urban_Pop_Percent
            urban_pop_percent = 'NULL' if urban_pop_percent == 'N.A.' or urban_pop_percent == '' else urban_pop_percent
            
            # Generate the INSERT statement
            insert_statement = f"INSERT INTO Countries (Country, Region, Alpha_2_Code, Alpha_3_Code, Population, Yearly_Change_Rate, Density_P_Km, Land_Area_Km, Median_Age, Urban_Pop_Percent) VALUES ('{country}', '{region}', '{alpha_2_code}', '{alpha_3_code}', {population}, {yearly_change_rate}, {density}, {land_area}, {median_age}, {urban_pop_percent});\n"
            
            # Write the INSERT statement to the output file
            output_file.write(insert_statement)

print(f"Insert statements have been written to {output_filename}.")
