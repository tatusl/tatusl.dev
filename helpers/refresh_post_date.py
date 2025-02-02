#!/usr/bin/env python3

# Generated with Claude AI

import sys
from datetime import datetime, timezone
import re

def update_post_date(file_path):
    """
    Update the date field in Hugo post front matter using only standard library.
    
    Args:
        file_path (str): Path to the Hugo markdown file
    """
    try:
        # Read the file
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
 
        # Current UTC date with Z suffix
        current_date = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
 
        # Regular expression to find the date field in front matter
        date_pattern = r'(date = \s*)["\'](.*?)["\']'
 
        # Replace the date
        new_content = re.sub(date_pattern, f'\\1"{current_date}"', content)

        # Write back to file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
 
        print(f"Updated date in {file_path} to {current_date}")

    except Exception as e:
        print(f"Error updating {file_path}: {str(e)}")
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python update_date.py <path-to-post.md>")
        sys.exit(1)
 
    update_post_date(sys.argv[1])
