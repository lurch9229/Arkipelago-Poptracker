import json

locations_file = "locations.json"
dinos_file = "dinos.json"
output_file = "idloc.txt"

def find_all_entries_sections(data, current_key="root"):
    """Recursively finds all blocks containing an 'entries' list alongside any base ID metadata."""
    results = []
    if isinstance(data, dict):
        for key, value in data.items():
            if key == "entries" and isinstance(value, list):
                # Look for base ID keys (e.g. _world_item_id_base) in the parent dict
                base_id = (
                    data.get("_world_item_id_base") 
                    or data.get("_base_id") 
                    or data.get("base_id")
                )
                results.append((current_key, value, base_id))
            else:
                results.extend(find_all_entries_sections(value, current_key=key))
    elif isinstance(data, list):
        for item in data:
            results.extend(find_all_entries_sections(item, current_key))
    return results

# List to store tuples of (integer_id, formatted_string_line)
collected_entries = []

# ==========================================
# 1. PROCESS LOCATIONS.JSON
# ==========================================
try:
    with open(locations_file, "r", encoding="utf-8") as infile:
        loc_data = json.load(infile)

    sections = find_all_entries_sections(loc_data)
    loc_count = 0

    print("--- Processing locations.json ---")
    for category_name, entries, base_id in sections:
        cat_count = 0
        for index, item in enumerate(entries):
            if isinstance(item, dict):
                # Try direct ID first
                item_id = item.get("id")

                # Calculate ID from base_id + offset/index if direct ID is missing
                if item_id is None and base_id is not None:
                    offset = item.get("id_offset") or item.get("offset") or index
                    item_id = base_id + offset

                item_name = item.get("name") or item.get("ap_name")

                if item_id is not None and item_name is not None:
                    try:
                        numeric_id = int(item_id)
                        line = f'[{numeric_id}] = "{item_name}",\n'
                        collected_entries.append((numeric_id, line))
                        cat_count += 1
                        loc_count += 1
                    except ValueError:
                        pass  # Skip if ID cannot be converted to integer

        print(f"  Processed '{category_name}': {cat_count} entries (Base ID: {base_id})")

    print(f"Locations total: {loc_count} entries collected.\n")

except FileNotFoundError:
    print(f"Warning: Could not find '{locations_file}'. Skipping locations processing.\n")
except json.JSONDecodeError as e:
    print(f"JSON Error in '{locations_file}': {e}\n")

# ==========================================
# 2. PROCESS DINOS.JSON
# ==========================================
try:
    with open(dinos_file, "r", encoding="utf-8") as infile:
        dino_data = json.load(infile)

    dinos_list = dino_data.get("dinos", []) if isinstance(dino_data, dict) else []
    dino_entries_count = 0

    print("--- Processing dinos.json ---")
    for dino in dinos_list:
        if isinstance(dino, dict):
            dino_tag = dino.get("dino_tag")
            tame_loc = dino.get("tame_loc")
            kill_loc = dino.get("kill_loc")

            if dino_tag:
                # Process tame location
                if tame_loc is not None:
                    try:
                        numeric_id = int(tame_loc)
                        line = f'[{numeric_id}] = "Tame {dino_tag}",\n'
                        collected_entries.append((numeric_id, line))
                        dino_entries_count += 1
                    except ValueError:
                        pass

                # Process kill location
                if kill_loc is not None:
                    try:
                        numeric_id = int(kill_loc)
                        line = f'[{numeric_id}] = "Kill {dino_tag}",\n'
                        collected_entries.append((numeric_id, line))
                        dino_entries_count += 1
                    except ValueError:
                        pass

    print(f"Dinos total: {dino_entries_count} entries collected.\n")

except FileNotFoundError:
    print(f"Warning: Could not find '{dinos_file}'. Skipping dinos processing.\n")
except json.JSONDecodeError as e:
    print(f"JSON Error in '{dinos_file}': {e}\n")

# ==========================================
# 3. SORT AND WRITE TO OUTPUT FILE
# ==========================================
print("Sorting all entries numerically by ID...")
collected_entries.sort(key=lambda x: x[0])

try:
    with open(output_file, "w", encoding="utf-8") as outfile:
        for numeric_id, line in collected_entries:
            outfile.write(line)

    print(f"Success! Total items exported into '{output_file}': {len(collected_entries)}")

except Exception as e:
    print(f"Error writing to output file '{output_file}': {e}")

# to use this file run from cmd 
# have the locations.json from apworld and this script in the same location
# for locations