import csv

# Define the input and output file paths
input_filename = 'influencer.csv'
output_filename = 'influencer_inserts.sql'

# Open the input CSV file and the output SQL file
with open(input_filename, mode='r', encoding='utf-8') as infile, \
     open(output_filename, mode='w', encoding='utf-8') as outfile:

    reader = csv.reader(infile)
    for row in reader:
        # Process each row of the CSV file
        id = int(row[0]) + 5000  # Increment the ID by 5000
        name = row[1]            # Get the name
        platform = row[2]        # Get the platform
        country = row[4]         # Get the country code

        # Create the SQL insert statement
        sql = f"INSERT INTO Influencer (ID, Name, Platform, Country) VALUES ({id}, '{name}', '{platform}', '{country}');\n"
        
        # Write the SQL statement to the output file
        outfile.write(sql)

print(f"SQL insert statements have been written to: {output_filename}")