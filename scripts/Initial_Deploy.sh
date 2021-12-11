#!/bin/sh
# Creates a new scratch org with dummy data and dependencies installed

set -e

echo "Set Alias for scratch org..."
read scratchAlias

echo "Creating the scratch org... \n"
sh ./scripts/create_scratch.sh $scratchAlias

echo "Opening new org...\n"
sfdx force:org:open 

echo "Installing dependencies... \n"
echo "Apex Rollup... \n"
sfdx force:package:install --package 04t6g000008SiaJAAS --wait 1000

echo "Pushing source metadata...\n"
sfdx force:source:push 

echo "Assign See Rollup App Permission set..."
sfdx force:user:permset:assign -n See_Rollup_App

echo "Assign Custom Apex Rollup Permission Set Permission set..."
sfdx force:user:permset:assign -n Custom_Apex_Rollup_Permission_Set

osascript -e 'display notification "Build is complete" with title "Build Status" sound name "Glass"'
