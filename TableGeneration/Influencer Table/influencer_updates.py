import csv
import random

def load_weighted_countries(filename):
    countries = []
    weights = []
    with open(filename, 'r', encoding='utf-8') as file:
        reader = csv.reader(file)
        for row in reader:
            country, population = row
            countries.append(country)
            weights.append(int(population))
    total_population = sum(weights)
    weights = [w / total_population for w in weights]  # Normalize weights
    return countries, weights

# def load_influencers(filename):
    # influencers = []
    # with open(filename, 'r', encoding='utf-8') as file:
        # reader = csv.reader(file)
        # for row in reader:
            # influencer_id, _ = row
            # influencers.append(influencer_id)
    # return influencers

# Load country weights and influencer IDs
countries, weights = load_weighted_countries('country_weights.csv')
#influencers = load_influencers('Influencer_list.csv')

# Generate and print SQL UPDATE statements
update_statements = []
for id in range(3000):
    # Randomly choose a country based on population weights
    chosen_country = random.choices(countries, weights, k=1)[0]
    statement = f"UPDATE Influencer SET Country = '{chosen_country}' WHERE ID = {id+1};"
    update_statements.append(statement)

# Optionally, write the UPDATE statements to a file
with open('update_influencer_countries.sql', 'w', encoding='utf-8') as file:
    for statement in update_statements:
        file.write(statement + "\n")

print(f"Generated {len(update_statements)} UPDATE statements.")
