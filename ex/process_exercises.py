#!/usr/bin/env python3

"""
This script takes your exercises JSON data and performs the following operations:
1. Splits the "Arms" category into "Biceps" and "Triceps" categories
2. Recategorizes neck exercises from "Shoulders" to "Neck"
3. Outputs the updated JSON file

Place your exercise JSON in 'exercises.json' in the same directory as this script,
or provide the path to your JSON file as a command line argument.
"""

import json
import sys
import os

def categorize_exercises(exercises_data):
    """
    Recategorize exercises based on their primary muscles and names.
    - Split Arms into Biceps, Triceps, and Forearms
    - Move neck exercises from Shoulders to Neck
    """
    updated_exercises = []
    changes = []

    for exercise in exercises_data:
        # Create a copy to avoid modifying the original
        new_exercise = exercise.copy()
        original_category = exercise["category"]

        # Handle Arms category - split into Biceps, Triceps, Forearms
        if original_category == "Arms":
            primary_muscles_str = " ".join(exercise["primaryMuscles"]).lower()

            # Check for bicep-related exercises
            if ("biceps" in primary_muscles_str or
                "brachialis" in primary_muscles_str or
                "brachioradialis" in primary_muscles_str):
                new_exercise["category"] = "Biceps"

            # Check for tricep-related exercises
            elif "triceps" in primary_muscles_str:
                new_exercise["category"] = "Triceps"

            # Check for forearm-related exercises
            elif ("forearm" in primary_muscles_str or
                 "flexor" in primary_muscles_str or
                 "extensor" in primary_muscles_str or
                 "carpi" in primary_muscles_str or
                 "pronator" in primary_muscles_str or
                 "supinator" in primary_muscles_str or
                 "wrist" in exercise["name"].lower() or
                 "grip" in exercise["name"].lower()):
                new_exercise["category"] = "Forearms"

        # Handle Shoulders category - identify neck exercises
        elif original_category == "Shoulders":
            exercise_name = exercise["name"].lower()
            primary_muscles_str = " ".join(exercise["primaryMuscles"]).lower()

            # Check for neck-related identifiers
            is_neck_exercise = (
                "neck" in exercise_name or
                "cervical" in primary_muscles_str or
                "sternocleidomastoid" in primary_muscles_str or
                "scalenes" in primary_muscles_str or
                "splenius" in primary_muscles_str or
                "levator scapulae" in primary_muscles_str
            )

            if is_neck_exercise:
                new_exercise["category"] = "Neck"

        # Add to the updated list
        updated_exercises.append(new_exercise)

        # Track changes for reporting
        if new_exercise["category"] != original_category:
            changes.append({
                "id": exercise["id"],
                "name": exercise["name"],
                "from": original_category,
                "to": new_exercise["category"]
            })

    return updated_exercises, changes

def main():
    # Determine input file - either from command line or default
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    else:
        input_file = "exercises.json"

    # Determine output file
    output_file = "updated_exercises.json"

    print(f"Processing exercises from: {input_file}")

    try:
        # Load the JSON data
        with open(input_file, 'r') as f:
            exercises_data = json.load(f)

        # Count original categories
        original_categories = {}
        for exercise in exercises_data:
            category = exercise["category"]
            if category not in original_categories:
                original_categories[category] = 0
            original_categories[category] += 1

        print("\nOriginal Category Distribution:")
        for category, count in sorted(original_categories.items()):
            print(f"  {category}: {count} exercises")

        # Process the exercises
        updated_exercises, changes = categorize_exercises(exercises_data)

        # Count new categories
        new_categories = {}
        for exercise in updated_exercises:
            category = exercise["category"]
            if category not in new_categories:
                new_categories[category] = 0
            new_categories[category] += 1

        print("\nNew Category Distribution:")
        for category, count in sorted(new_categories.items()):
            print(f"  {category}: {count} exercises")

        # Print changes
        print(f"\nTotal changes: {len(changes)}")
        if changes:
            print("\nSample of changes:")
            for change in changes[:10]:  # Show up to 10 changes
                print(f"  {change['name']}: {change['from']} → {change['to']}")

            if len(changes) > 10:
                print(f"  ... and {len(changes) - 10} more changes")

        # Save the updated JSON
        with open(output_file, 'w') as f:
            json.dump(updated_exercises, f, indent=2)

        print(f"\nSaved updated exercises to: {output_file}")

    except FileNotFoundError:
        print(f"Error: Could not find file {input_file}")
        print("Make sure the file exists and the path is correct.")
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {input_file}")
        print("Check that the file contains valid JSON data.")
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    main()
