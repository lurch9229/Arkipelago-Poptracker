import json

input_file = "engrams.json"
output_file = "iditems.txt"

try:
    with open(input_file, "r", encoding="utf-8") as infile:
        data = json.load(infile)

    # Access the "engrams" list directly
    engrams_list = data.get("engrams", []) if isinstance(data, dict) else []

    with open(output_file, "w", encoding="utf-8") as outfile:
        count = 0
        for item in engrams_list:
            if isinstance(item, dict):
                item_id = item.get("id")
                item_name = item.get("ap_name")

                if item_id is not None and item_name is not None:
                    # Added a comma right before the newline character
                    outfile.write(f'[{item_id}] = "{item_name}",\n')
                    count += 1

    print(f"Success! Processed {count} engrams with commas into {output_file}.")

except FileNotFoundError:
    print(f"Error: Could not find '{input_file}'.")
except json.JSONDecodeError as e:
    print(f"JSON Error: {e}")

# to use this file run from cmd 
# have the engrams.json from apworld and this script in the same location
# for engrams