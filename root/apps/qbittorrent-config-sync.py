#!/usr/bin/env python3
import configparser
import os
import datetime
import re

# Define file paths
QBITTORRENT_CONFIG = "/data/qBittorrent/qBittorrent.conf"
SOURCE_CONFIG = "/src/check"
LOG_FILE = "/data/config_update.log"

def log_message(message):
    """Write a message to the log file with timestamp."""
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as log:
        log.write(f"[{timestamp}] {message}\n")

def get_raw_config(file_path):
    """
    Read a config file and return its raw content as a dictionary of sections
    with lists of lines for each section.
    """
    if not os.path.exists(file_path):
        log_message(f"Error: {file_path} does not exist.")
        return None
        
    raw_config = {}
    current_section = None
    
    with open(file_path, 'r') as file:
        for line in file:
            line = line.rstrip('\n')  # Remove newline but preserve spaces
            if line.startswith('[') and line.endswith(']'):
                current_section = line
                raw_config[current_section] = []
            elif current_section is not None:
                raw_config[current_section].append(line)
    
    return raw_config

def parse_config_line(line):
    """
    Parse a config line to separate key and value,
    preserving the exact format with spaces.
    """
    if '=' not in line:
        return line, None, None
    
    # Find the first equals sign
    equals_pos = line.find('=')
    key = line[:equals_pos].rstrip()  # Keep only trailing spaces
    value = line[equals_pos+1:]       # Keep all spaces after equals
    
    # Also return the exact format of the equals sign with surrounding spaces
    equals_format = line[len(key):equals_pos+1]
    
    return key, value, equals_format

def compare_config_values(qbt_value, source_value):
    """
    Compare configuration values, ignoring only differences in whitespace
    around the equals sign.
    """
    # Normalize both values by stripping whitespace at start/end
    qbt_norm = qbt_value.strip()
    source_norm = source_value.strip()
    
    return qbt_norm == source_norm

def sync_configs():
    """
    Synchronize qBittorrent config with source config:
    - Add missing sections
    - Add missing parameters
    - Update parameters with different values
    - Preserve formatting and spacing around equals signs
    """
    # Get raw configurations to handle special characters correctly
    qbt_raw = get_raw_config(QBITTORRENT_CONFIG)
    source_raw = get_raw_config(SOURCE_CONFIG)
    
    if not qbt_raw or not source_raw:
        log_message("Error: Could not read one of the configuration files.")
        return
    
    # Track changes
    changes_made = False
    
    # Process each section in source config
    for section in source_raw:
        if section not in qbt_raw:
            # Add missing section
            log_message(f"Adding missing section: {section}")
            qbt_raw[section] = source_raw[section].copy()
            changes_made = True
        else:
            # Check parameters in this section
            source_params = {}
            for line in source_raw[section]:
                if not line.strip():  # Skip empty lines
                    continue
                    
                key, value, equals_format = parse_config_line(line)
                if key and value is not None:  # Skip comments and non-parameter lines
                    source_params[key] = (value, line, equals_format)
            
            qbt_params = {}
            for i, line in enumerate(qbt_raw[section]):
                if not line.strip():  # Skip empty lines
                    continue
                    
                key, value, equals_format = parse_config_line(line)
                if key and value is not None:
                    qbt_params[key] = (value, line, equals_format, i)
            
            # Find parameters to add or update
            for key, (source_value, source_line, source_equals) in source_params.items():
                if key not in qbt_params:
                    # Add missing parameter
                    log_message(f"Adding parameter {key} in section {section}")
                    qbt_raw[section].append(source_line)
                    changes_made = True
                else:
                    qbt_value, qbt_line, qbt_equals, qbt_idx = qbt_params[key]
                    
                    # Check if values are exactly the same (ignoring spacing around equals)
                    if not compare_config_values(qbt_value, source_value):
                        # Update parameter value but preserve spacing format
                        log_message(f"Updating parameter {key} in section {section}")
                        log_message(f"  From: {qbt_line}")
                        log_message(f"  To:   {key}{qbt_equals}{source_value.strip()}")
                        
                        # Construct new line with original spacing around equals sign
                        new_line = f"{key}{qbt_equals}{source_value.strip()}"
                        
                        # Replace the line
                        qbt_raw[section][qbt_idx] = new_line
                        changes_made = True
    
    # Write back the updated configuration if changes were made
    if changes_made:
        with open(QBITTORRENT_CONFIG, 'w') as file:
            for section in qbt_raw:
                file.write(f"{section}\n")
                for line in qbt_raw[section]:
                    file.write(f"{line}\n")
                file.write("\n")  # Empty line between sections
        log_message("Configuration updated successfully.")
    else:
        log_message("No changes needed, configurations are in sync.")

if __name__ == "__main__":
    log_message("Starting qBittorrent config synchronization")
    sync_configs()
    log_message("Synchronization completed")
