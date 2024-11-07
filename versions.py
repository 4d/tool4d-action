import json
import sys
from pathlib import Path
import git
import re

buildchain_dir=""
if len(sys.argv)>1: 
    buildchain_dir=sys.argv[1] 

if not buildchain_dir:
    buildchain_dir="../buildchain" # check in parent folder
    if(not Path(buildchain_dir).is_dir()):
        buildchain_dir="buildchain" # check inside

if(not Path(buildchain_dir).is_dir()):
    print("🔴 buildChain directory not found", file=sys.stderr)
    exit(1)
    
repo = git.Repo(buildchain_dir)

filename = 'versions.json'
with open(filename, 'r') as file:
    data = json.load(file)
if not data:
    print("🔴 cannot read version file", file=sys.stderr)
    exit(2)
    
from subprocess import PIPE

official=data["official"]

has_change = False

for product_line in official:
    if (product_line == "20.x"):
        # print(f"skip product_line {product_line}")
        continue

    for version in official[product_line]:
        if (product_line == "20Rx") and int(version.replace("R", ""))<207:
            # print(f"skip version {version}")
            continue

    print(f"Manage product_line {product_line}, version {version}")
    
    res =repo.git.execute(f"git log --first-parent origin/{version} --pretty=format:%s -n1  --  mac/bin/tool4d_arm64.tar.xz", shell=True, istream=PIPE, with_stdout=True)
    matches = re.search(".*-(\d\d\d\d\d\d)-.*", res)
    if matches:
        match = matches.group(1)
        change_list=official[product_line][version]
        
        if isinstance(change_list, dict):
            alt_change_list = change_list["product_line"]
            alt_version = change_list["version"]
            change_list = change_list["build"]

        if change_list != match:
            print(f"  ➡️ update from {change_list} {match}")
            if version in res:
                official[product_line][version] = match
                has_change = True
            else:
                if "main" in res:
                    official[product_line][version] = {product_line: "main", version: "main", change_list: change_list}
                    has_change = True
                else:
                    print(f"  🔴 not managed other branch in commit message {res}")
                    # TODO: must extract product_line
        else:
            print(f"  ✅ up to date {change_list}")
    else:
        print(f"  🔴 not found in commit message {res}")
    print("")

if has_change:
    with open(filename, "w") as outfile:
        json.dump(data, outfile, indent=2)