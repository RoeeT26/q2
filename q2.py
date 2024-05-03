#!/bin/python3

from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route('/', methods=['GET'])
def get():
    return str("Options:\n1) Top Selling Books by Genre\n2) Authors with Multiple Best-Sellers\n3) Sales Trends Over Year \n\n") #Displays instructions after performing a GET request.

@app.route('/', methods=['POST'])
def post():
    received_value = str(request.get_data(as_text=True)) #Gets the data from the POST request
    answer = calculate_answer(received_value)
    return str(answer) #Returns the data to the user

# Top Selling Books by Genre
# A query to find the top 5 selling books in a specific genre, such as 'Fiction'.
q1 = '''
SELECT Book_Name, Authors, Sales
FROM roee_books
WHERE Genre = 'Fiction'
ORDER BY Sales DESC
LIMIT 5;
'''

# Authors with Multiple Best-Sellers
# A query to find authors who have more than one best-selling book.
q2 = '''
SELECT DISTINCT Authors
FROM roee_books AS r1
WHERE EXISTS (
    SELECT 1
    FROM roee_books AS r2
    WHERE r1.Authors = r2.Authors
    GROUP BY r2.Authors
    HAVING COUNT(*) > 1
);
'''

# Sales Trends Over Years
# A query to examine how book sales have trended over the years.
q3 = '''
SELECT First_Published, SUM(Sales) AS Total_Sales
FROM roee_books
GROUP BY First_Published
ORDER BY First_Published;
'''

def calculate_answer(received_value):
    value = None
    match received_value:
        case "1": value = subprocess.run([f'sudo -u postgres psql -d books --command="{q1}"'], shell=True, capture_output=True, text=True)
        case "2": value = subprocess.run([f'sudo -u postgres psql -d books --command="{q2}"'], shell=True, capture_output=True, text=True)
        case "3": value = subprocess.run([f'sudo -u postgres psql -d books --command="{q3}"'], shell=True, capture_output=True, text=True)
    return value.stdout

if __name__ == "__main__":
    app.run(host='0.0.0.0')
