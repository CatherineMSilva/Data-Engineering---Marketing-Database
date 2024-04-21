import csv
import random

# Read country weights
country_weights = {}
total_population = 0
with open('country_weights.csv', mode='r', encoding='utf-8') as file:
    reader = csv.reader(file)
    for row in reader:
        country_code = row[0]
        population = int(row[1])
        country_weights[country_code] = population
        total_population += population

# Function to distribute followers based on population weights
def distribute_followers(followers_count, country_weights, total_population):
    results = {}
    remaining_followers = followers_count
    sorted_countries = sorted(country_weights.keys(), key=lambda x: country_weights[x], reverse=True)
    
    for country in sorted_countries:
        if remaining_followers <= 0:
            break
        # Calculate followers for this country
        weight = country_weights[country]
        if total_population > 0:
            followers = int(followers_count * (weight / total_population))
        else:
            followers = 0
        followers = min(followers, remaining_followers)
        results[country] = followers
        remaining_followers -= followers
    
    # Randomly assign any remaining followers
    while remaining_followers > 0:
        country = random.choices(list(country_weights.keys()), weights=country_weights.values())[0]
        results[country] = results.get(country, 0) + 1
        remaining_followers -= 1
    
    return results

# Process influencer data and generate SQL insert statements
output_filename = 'followers_insert.sql'
with open('influencer.csv', mode='r', encoding='utf-8') as file, \
     open(output_filename, mode='w', encoding='utf-8', newline='') as output_file:
    reader = csv.reader(file)
    writer = csv.writer(output_file)
    
    for row in reader:
        id = int(row[0]) + 5000
        followers_in_millions = float(row[3])
        followers_count = int(followers_in_millions * 1_000_000)
        
        # Distribute followers
        followers_distribution = distribute_followers(followers_count, country_weights, total_population)
        
        # Write SQL statements for each country
        for country, count in followers_distribution.items():
            sql = f"INSERT INTO followers_by_country (influencer_id, country, followers) VALUES ({id}, '{country}', {count});"
            writer.writerow([sql])

print(f"SQL insert statements have been written to: {output_filename}")
