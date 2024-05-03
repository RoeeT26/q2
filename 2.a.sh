#!/bin/bash
#q2.a for PostgreSQL

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
echo "This script must be run as root"
exit 1
fi

# Check if PostgreSQL is installed and install if not
if ! command -v psql &> /dev/null; then
echo "PostgreSQL is not installed. Installing..."
apt update
apt install -y postgresql postgresql-contrib
systemctl start postgresql
systemctl enable postgresql
echo "PostgreSQL has been installed and started."
fi

# Paths to csv and zip files
# Copy CSV file to /tmp
cp /home/roeetsahi/final_project/q3_project/best-selling-books.csv /tmp/

# Modify the script to use the CSV file from /tmp
csv_file="/tmp/best-selling-books.csv"

# Remove commas from numeric fields to prevent format issues
awk -F '"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' "$csv_file" > temp.csv
mv temp.csv "$csv_file"

# Credentials
User="roee"
Password="pass1234"
# Database name
Database_Name="books"
# Set table name
table_name="roee_books"

# Change to a directory where postgres has access
cd /tmp

# Switch to the postgres user and run the commands
sudo -u postgres bash <<EOF

# Check if the user exists, if not, create it
if ! psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$User'" | grep -q 1; then
echo "Creating PostgreSQL user: $User"
psql -c "CREATE USER $User WITH PASSWORD '$Password' CREATEDB;"
fi

# Grant all privileges to the created user
echo "Granting all privileges to PostgreSQL user: $User"
psql -c "ALTER USER $User WITH SUPERUSER;"

# Check if database exists, create if not
if ! psql -lqt | cut -d \| -f 1 | grep -qw $Database_Name; then
psql -c "CREATE DATABASE $Database_Name;"
fi

# Create the table
psql -d $Database_Name -c "DROP TABLE IF EXISTS $table_name;
CREATE TABLE $table_name (
    Book_Name VARCHAR(200),
Authors VARCHAR(200),
Language VARCHAR(200),
First_Published INT,
Sales FLOAT,
Genre VARCHAR(200)
);"

# Import data into the table from the CSV file using COPY
psql -d $Database_Name -c "\\COPY $table_name FROM '$csv_file' CSV HEADER DELIMITER ',' QUOTE '\"';"

EOF

# Check the exit status
if [ $? -eq 0 ]; then
echo "Script ran successfully. Table '$table_name' has been created and data from '$csv_file' has been inserted."
else
echo "Error: Script encountered an issue."
fi

# Install flask
sudo apt-get install python3-flask
