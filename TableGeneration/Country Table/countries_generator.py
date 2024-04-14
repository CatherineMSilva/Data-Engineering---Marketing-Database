import csv

# Define the filenames
countries_filename = 'countries.csv'
population_filename = 'WorldPopulation2023.csv'
output_filename = 'combined_countries.csv'

# Read the list of selected countries into a dictionary for easy lookup
selected_countries = {}
with open(countries_filename, mode='r', encoding='utf-8') as file:
    reader = csv.reader(file)
    next(reader)  # Skip header row
    for row in reader:
        country_name = row[0]
        selected_countries[country_name] = row[1:]  # Region, 2-letter code, 3-letter code

# Open the output file
with open(output_filename, mode='w', encoding='utf-8', newline='') as output_file:
    writer = csv.writer(output_file)
    # Write the header
    writer.writerow(['Country', 'Region', '2_letter_code', '3_letter_code', 'Population', 'Yearly_Change', 'Density(P/Km)', 'Land Area(Km)', 'MedianAge', 'UrbanPop%'])

    # Read the world population file and write the combined data to the output file
    with open(population_filename, mode='r', encoding='utf-8') as population_file:
        reader = csv.reader(population_file)
        next(reader)  # Skip header row
        for row in reader:
            country_name = row[0]
            if country_name in selected_countries:
                # Combine data from both lists
                combined_row = [country_name] + selected_countries[country_name] + row[1:]
                writer.writerow(combined_row)

print("Data combining process completed. Output file created:", output_filename)
