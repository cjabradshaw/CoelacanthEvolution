import os
import re

def search_files(directory, search_string):
    search_string = search_string.lower()  # Convert the search string to lowercase for case-insensitive search

    for root, dirs, files in os.walk(directory):
        for file in files:
            if not file.endswith('.py'):  # Skip Python script files
                file_path = os.path.join(root, file)
                with open(file_path, 'r', errors='ignore') as f:  # Ignore encoding errors
                    for line in f:
                        if re.search(search_string, line.lower()):  # Convert the line to lowercase for case-insensitive search
                            print(f"Found in {file_path}: {line.strip()}")

directory = os.getcwd() 
search_string = "gogoc"

search_files(directory, search_string)
