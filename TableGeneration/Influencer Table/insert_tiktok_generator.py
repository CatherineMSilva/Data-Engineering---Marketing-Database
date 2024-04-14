import csv

# Define the filename for TikTok data
tiktok_input_filename = 'TikTok_Data.csv'  # This will be the path where the file is located
output_filename = 'influencer_inserts.sql'  # The output file to append SQL insert statements

# Function to parse and round TikTok followers count and convert to millions
def parse_tiktok_followers(followers_str):
    # Round the value to the nearest whole number then divide by 1,000,000
    return round(float(followers_str)) / 1_000_000

# The actual Python script to read "TikTok_Data.csv" and append to the SQL file
# Since we don't have the actual CSV file, the following is a template for the script you would use.

# Read the TikTok data and append SQL insert statements to the file
with open(tiktok_input_filename, mode='r', encoding='utf-8') as infile, open(output_filename, 'a', encoding='utf-8') as outfile:
    reader = csv.reader(infile)
    next(reader)  # Skip the header row
    
    for row in reader:
        name, followers_str = row
        followers_in_millions = parse_tiktok_followers(followers_str)
        # Prepare the insert statement for each influencer
        insert_statement = f"INSERT INTO Influencer (Name, Platform, Followers_in_millions) VALUES ('{name}', 'TikTok', {followers_in_millions:.2f});\n"
        
        outfile.write(insert_statement)

# Note that the code assumes the 'TikTok_Data.csv' file is structured correctly.
# This script does not execute here, as it's intended to be run in your local environment. 
# Save it as a .py file, place it in the same directory as 'TikTok_Data.csv', and execute it.
