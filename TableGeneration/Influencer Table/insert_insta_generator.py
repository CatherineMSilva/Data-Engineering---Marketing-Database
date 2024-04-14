import csv

# Function to parse Instagram followers count and remove the 'M'
def parse_instagram_followers(followers_str):
    return followers_str.replace('M', '')

# Define the filenames
instagram_input_filename = 'Instagram_Data.csv'  # This will be the path where the file is located
output_filename = 'influencer_inserts.sql'  # The output file to append SQL insert statements

# Read the Instagram data and append SQL insert statements to the file
with open(instagram_input_filename, mode='r', encoding='utf-8') as infile, open(output_filename, 'a', encoding='utf-8') as outfile:
    reader = csv.reader(infile)
    next(reader)  # Skip the header row
    
    for row in reader:
        name, followers_str = row
        followers_in_millions = parse_instagram_followers(followers_str)
        # Prepare the insert statement for each influencer
        insert_statement = f"INSERT INTO Influencer (Name, Platform, Followers_in_millions) VALUES ('{name}', 'Instagram', {followers_in_millions});\n"
        
        outfile.write(insert_statement)

# Note that the code assumes the 'Instagram_Data.csv' file is structured correctly.
# This script does not execute here, as it's intended to be run in your local environment. 
# Save it as a .py file, place it in the same directory as 'Instagram_Data.csv', and execute it.
