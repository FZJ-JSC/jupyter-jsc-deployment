import sys
import os
from ruamel.yaml import YAML

yaml = YAML()
yaml.preserve_quotes = True
yaml.explicit_start = False
yaml.indent(mapping=2, sequence=4, offset=2)

def format_yaml_file(file_path):
    try:
        with open(file_path, 'r') as f:
            data = yaml.load(f)
        with open(file_path, 'w') as f:
            yaml.dump(data, f)

        # Remove trailing spaces in file (lines ending with spaces/tabs)
        with open(file_path, 'r') as f:
            lines = f.readlines()
            # Strip trailing spaces
        lines = [line.rstrip() + '\n' for line in lines]

        # Remove multiple empty lines
        cleaned_lines = []
        blank_line = False
        for line in lines:
            if line.strip() == '':
                if not blank_line:
                    cleaned_lines.append('\n')
                blank_line = True
            else:
                cleaned_lines.append(line)
                blank_line = False

        with open(file_path, 'w') as f:
            f.writelines(cleaned_lines)
        print(f"Formatted: {file_path}")
    except Exception as e:
        print(f"Failed to format {file_path}: {e}")

def format_yaml_in_dir(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(('.yaml', '.yml')):
                if not "specific-secrets" in root:
                    format_yaml_file(os.path.join(root, file))

if __name__ == "__main__":
    target_dir = sys.argv[1] if len(sys.argv) > 1 else '.'
    format_yaml_in_dir(target_dir)
