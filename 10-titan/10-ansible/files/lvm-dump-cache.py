#!/usr/bin/python3
import os
import subprocess
import time

from typing import Any

TIMEOUT = 60 * 60  # 1 Hour


LVS_SEPARATOR = ";"
LVS_EXEC = "/usr/sbin/lvs"
LVS_PARAMS_BASE = ["--separator", LVS_SEPARATOR, "--unit", "m"]
LVS_PARAMS_OPTIONS_SWITCH = "-o"
LVS_OPTION_NAME = "lv_full_name"
LVS_OPTIONS_CACHE = ["writecache_free_blocks", "writecache_total_blocks", "data_percent"]

LVCHANGE_EXEC = "/usr/sbin/lvchange"
LVCHANGE_CACHESETTINGS_PARAM = "--cachesettings"
LVCHANGE_CACHESETTINGS_CLEANER = "cleaner"
LVCHANGE_CACHESETTINGS_CLEANER_ON = "1"
LVCHANGE_CACHESETTINGS_CLEANER_OFF = "0"


def get_lv_fields(fields: list[str]) -> dict[str, dict[Any]]:
    args = [LVS_EXEC, *LVS_PARAMS_BASE, LVS_PARAMS_OPTIONS_SWITCH, ",".join([LVS_OPTION_NAME, *fields])]
    print(f"Running command {' '.join(args)}")
    proc = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    rows = proc.stdout.decode("utf-8").strip().split("\n")[1:]
    
    results = {}
    for row in rows:
        values = row.split(LVS_SEPARATOR)
        values = [value.strip() for value in values]
        results[values[0]] = {}
        for field, value in zip(fields, values[1:]):
            results[values[0]][field] = value

    return results


def set_lv_cachesettings_options(lv_names: list[str], options: dict[str, str]) -> None:
    args = [LVCHANGE_EXEC, LVCHANGE_CACHESETTINGS_PARAM, ",".join([f"{name}={val}" for name, val in options.items()]), *lv_names]
    print(f"Running command {' '.join(args)}")
    proc = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    return
    

def main():
    if os.geteuid() != 0:
        exit("You need root privileges to run this script!")
    
    cache_lvs = get_lv_fields(LVS_OPTIONS_CACHE)
    cache_lvs = [name for name, values in cache_lvs.items() if values["writecache_total_blocks"] != ""]
    
    # Turn on cleaner
    print("Starting cache dump, turning on cleaner mode")
    set_lv_cachesettings_options(cache_lvs, {LVCHANGE_CACHESETTINGS_CLEANER: LVCHANGE_CACHESETTINGS_CLEANER_ON})

    # Monitor cache size
    start_time = time.time()
    end_time = start_time + TIMEOUT
    timeout = False
    while True:
        cache_values = get_lv_fields(LVS_OPTIONS_CACHE)
        
        if all([cache_values[name]["writecache_total_blocks"] == cache_values[name]["writecache_free_blocks"] for name in cache_lvs]):
            break
        
        if time.time() > end_time:
            timeout = True
            break
        
        blocks_left = sum([int(cache_values[name]["writecache_total_blocks"]) - int(cache_values[name]["writecache_free_blocks"]) for name in cache_lvs])
        print(f"Still {blocks_left} blocks of cache left, checking again in 10 seconds...")
        time.sleep(10)
    
    # Turn off cleaner
    print("Cache dump finished, turning off cleaner mode")
    set_lv_cachesettings_options(cache_lvs, {LVCHANGE_CACHESETTINGS_CLEANER: LVCHANGE_CACHESETTINGS_CLEANER_OFF})
    
    if timeout:
        cache_values = get_lv_fields(LVS_OPTIONS_CACHE)
        leftover_blocks = sum([int(cache_values[name]["writecache_total_blocks"]) - int(cache_values[name]["writecache_free_blocks"]) for name in cache_lvs])
        print(f"Could not completely dump cache, still {leftover_blocks} blocks in cache")
    else:
        print("Full cache was dumped")
        

if __name__ == "__main__":
    main()
