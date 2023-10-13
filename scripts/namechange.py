import os
import fileinput
import codecs

directory = os.getcwd() 

# Function to convert a file to UTF-8 encoding
def convert_to_utf8(file_path):
    try:
        with codecs.open(file_path, 'r', encoding='utf-8', errors='replace') as file:
            content = file.read()
        with codecs.open(file_path, 'w', encoding='utf-8') as file:
            file.write(content)
        print(f"Converted: {file_path}")
    except Exception as e:
        print(f"Error converting: {file_path} - {str(e)}")

# Walk through the directory and its subdirectories
for root, _, files in os.walk(directory):
    for file in files:
        file_path = os.path.join(root, file)
        convert_to_utf8(file_path)

print("Conversion to UTF-8 complete.")


# Set the string to find and the replacement string
string_to_find = "Gogocoelacanthus_zhumini"
replacement_string = "Namugawi_wirngarri"

# Walk through the directory and its subdirectories
for root, _, files in os.walk(directory):
    for file in files:
        file_path = os.path.join(root, file)

        # Skip the script file itself
        if file_path == os.path.realpath(__file__):
            continue

        with fileinput.FileInput(file_path, inplace=True) as file:
            for line in file:
                # Replace the string in the line
                line = line.replace(string_to_find, replacement_string)
                print(line, end='')



# Set the string to find and the replacement string
string_to_find = "Gogocoelacanthus zhumini"
replacement_string = "Namugawi wirngarri"

# Walk through the directory and its subdirectories
for root, _, files in os.walk(directory):
    for file in files:
        file_path = os.path.join(root, file)

        # Skip the script file itself
        if file_path == os.path.realpath(__file__):
            continue

        with fileinput.FileInput(file_path, inplace=True) as file:
            for line in file:
                # Replace the string in the line
                line = line.replace(string_to_find, replacement_string)
                print(line, end='')


print("Replacement complete.")