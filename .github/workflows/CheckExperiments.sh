#!/bin/bash
# Check if the search for experiments have been performed

cd Data/Simulations

paths=()

# Iterate over all systems
for file in `find . -name "README.yaml"`; do
 if ! [ $( grep "EXPERIMENTS" ${file} ) ]; then
  # The path to the file
  path=$( echo ${file} | rev | cut -d"/" -f2- | rev )
  paths+=(${path})
 fi
done

if [[ ${#paths[@]} -ne 0 ]]; then
 echo "### :warning: There has been no search for compatible experiments for:"
 for system in ${paths[@]}; do
  echo \`${system}\`
 done
else
 echo "### :white_check_mark: A search for compatible experiments has been performed for all systems."
fi
