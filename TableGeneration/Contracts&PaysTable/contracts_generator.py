import random
import datetime

# Assuming the files are structured with each line as "id,name"
def load_data(filename):
    with open(filename, 'r', encoding='utf-8', errors='ignore') as file:
        return [line.strip().split(',') for line in file.readlines()]


# Loading company and influencer data
companies = load_data('company_names.txt')
influencers = load_data('influencer_names.txt')

# Helper functions
# def create_contract_id(company_name):
    # # Choose a random month and a random year between 19 and 23
    # month = random.choice(['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'])
    # year = str(random.randint(19, 23))
    # # Generate a random 6-digit number
    # number = str(random.randint(100000, 999999))
    # # Construct the Contract_ID
    # return f"{company_name[:3].upper()}_{month}{year}_{number}"

def create_contract_id(company_name):
    # Filter out any characters that are not letters or digits
    valid_chars = [c for c in company_name if c.isalnum()]
    # Take the first 3 valid characters, converting to upper case
    valid_prefix = ''.join(valid_chars[:3]).upper()
    month = random.choice(['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'])
    year = str(random.randint(19, 23))
    number = str(random.randint(100000, 999999))
    return f"{valid_prefix}_{month}{year}_{number}"


def create_random_date(month_str, year_str):
    # Generate a random date within 3 months of the specified month/year
    month = datetime.datetime.strptime(month_str, '%b').month
    year = 2000 + int(year_str)  # Assuming '19' means 2019
    start_date = datetime.datetime(year, month, 1)
    end_date = start_date + datetime.timedelta(days=90)  # Approximately 3 months later
    random_date = start_date + (end_date - start_date) * random.random()
    return random_date.date()
    
# def get_random_date(month_year):
    # month_str, year_str = month_year[:3], '20' + month_year[3:]
    # random_day = random.randint(1, 28)  # To avoid issues with different month lengths
    # date_str = f"{random_day} {month_str} {year_str}"
    # date_obj = datetime.datetime.strptime(date_str, '%d %b %Y')
    # return date_obj

def create_payment_values():
    total_value = random.uniform(10000, 999999)
    payment = round(total_value * 0.7, 2)
    fee = round(total_value - payment, 2)  # To avoid losing pennies due to division
    return payment, fee

# Writing to SQL file
with open('contracts_and_pays_inserts.sql', 'w', encoding='utf-8') as sql_file:
    for _ in range(1000):
        company_id, company_name = random.choice(companies)
        influencer_id, influencer_name = random.choice(influencers)
        
        contract_id = create_contract_id(company_name)
        month_year = contract_id.split('_')[1]  # Extract month and year from Contract_ID
        month, year = month_year[:3], month_year[3:]
        
        start_date = create_random_date(month, year)
        end_date = start_date + datetime.timedelta(days=180)  # Approximately 6 months later
        payment_id = str(random.randint(1000000, 9999999))  # Random 7-digit number
        payment_deadline = start_date + datetime.timedelta(days=30)  # Approximately 1 month after start date
        payment, fee = create_payment_values()
        
        # Contract insert statement
        contract_insert = f"INSERT INTO Contract (Contract_ID, Influencer, Company, Date_start, Date_end) VALUES ('{contract_id}', {influencer_id}, {company_id}, '{start_date}', '{end_date}');\n"
        # Pays insert statement
        pays_insert = f"INSERT INTO Pays (Payment_ID, contract_ID, Payment_deadline, payment, fee) VALUES ('{payment_id}', '{contract_id}', '{payment_deadline}', {payment}, {fee});\n"
        
        # Write the pair of insert statements to the file
        sql_file.write(contract_insert)
        sql_file.write(pays_insert)

# This script assumes the presence of 'company_names.txt' and 'influencer_names.txt' files in the same directory.
