import csv

# Define the filenames
input_filename = 'YouTube_Data.csv'  # This will be the path where the file is located
output_filename = 'influencer_inserts.sql'  # The output file where SQL insert statements will be written

# Function to parse followers count and convert it into millions
def parse_followers(followers_str):
    # Remove quotes and commas, then convert the string to a float and divide by 1,000,000
    return float(followers_str.replace('"', '').replace(',', '')) / 1_000_000

# Here is the Python script that you would run where the YouTube_Data.csv file is located
with open(input_filename, mode='r', encoding='utf-8') as infile, open(output_filename, 'w', encoding='utf-8') as outfile:
    reader = csv.reader(infile)
    next(reader)  # Skip the header row
    
    # Writing the beginning of the SQL insert statements file
    outfile.write("INSERT INTO Influencer (Name, Platform, Followers_in_millions) VALUES\n")
    
    for index, row in enumerate(reader):
        name, followers_str = row
        followers_in_millions = parse_followers(followers_str)
        # Prepare the insert statement for each influencer
        insert_statement = f"('{name}', 'YouTube', {followers_in_millions:.2f})"
        
        # # Add a comma after each insert statement except the last one
        # if index < 499:  # Assuming the file always contains exactly 500 influencers
            # insert_statement += ',\n'
        # else:  # The last statement should end with a semicolon instead of a comma
            # insert_statement += ';\n'
        
        insert_statement += ',\n'
        outfile.write(insert_statement)
		
    insert_statement += ';\n'   

# The code assumes that 'YouTube_Data.csv' contains exactly 500 influencers.
# If the number may vary, additional logic is needed to properly format the SQL. 

# This script does not execute here, as it's intended to be run in your local environment. 
# Save it as a .py file, place it in the same directory as 'YouTube_Data.csv', and execute it.