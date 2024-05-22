#!/bin/bash
# Check if simulation IDs are missing or duplicated

cd Data/Simulations

paths=()
ids=()

# Iterate over all systems
for file in `find . -name "README.yaml"`; do
 # The path to the file
 path=$( echo ${file} | rev | cut -d"/" -f2- | rev )
 paths+=(${path})
 # The ID of the file
 file_ID=$( grep '^ID:' ${file} | cut -d" " -f2 )
 # If the file does not contain an ID
 if ! [ $file_ID ]; then
  ids+=(0)
 else
  ids+=(${file_ID})
 fi
done

# The list on unique IDs in the databank
idlist=($(printf '%s\n' "${ids[@]}" | sort -u | sort -n ))

# The last ID used
max_id=$( cat COUNTER_ID )

# Find duplicates in the array of IDs; from https://stackoverflow.com/questions/22055238/search-duplicate-element-array
duplicates=($( printf '%s\n' "${ids[@]}"|awk '!($0 in seen){seen[$0];next} 1' ))

if [[ ${#duplicates[@]} -eq 0 ]] && [[ ${idlist[0]} -ne 0 ]]; then
 echo "### :white_check_mark: All systems have an unique ID associated" >> $GITHUB_STEP_SUMMARY

 # No IDs were generated
 echo "newids=false" >> $GITHUB_OUTPUT

else
 echo "### :warning: Duplicates and/or missing IDs have been found" >> $GITHUB_STEP_SUMMARY
 echo " " >> $GITHUB_STEP_SUMMARY

 fixlist=()
 unique_ids=()

 # Repeated IDs
 if [[ ${#duplicates[@]} -ne 0 ]]; then
  unique_ids=($( printf "%s\n" "${duplicates[@]}" | sort -u ))
 fi

 # No ID assigned
 if [[ ${idlist[0]} -eq 0 ]] && ( [[ ${unique_ids[0]} -ne 0 ]] || ! [[ ${unique_ids[0]} ]] ) ; then
  unique_ids=(0 ${unique_ids[@]})
 fi

 # Find all duplicated and missing IDs; ID matches the index of the array
 for j in $( seq ${#paths[@]} ); do
  for u in ${unique_ids[@]}; do
   if [[ ${ids[$((${j}-1))]} -eq ${u} ]]; then
    fixlist[${u}]+=${paths[$((${j}-1))]}" "
    break
   fi
  done
 done

 # Print the results
 counter=0
 for u in $( printf '%s\n' "${unique_ids[@]}" | sort -r  ); do
  list=(${fixlist[${u}]})
  if [[ ${u} -eq 0 ]]; then
   echo "#### Systems with no ID assigned:" >> $GITHUB_STEP_SUMMARY
   for item in ${list[@]}; do
    echo \`${list[@]}\` >> $GITHUB_STEP_SUMMARY
   done
   counter=$((${counter}+${#list[@]}))
  else
   echo "#### Systems with duplicated index ${u}": 
   for item in ${list[@]}; do
    echo \`${list[@]}\` >> $GITHUB_STEP_SUMMARY
   done
   counter=$((${counter}+${#list[@]}-1))
  fi
 done
 echo "#### Number of systems to be fixed: "${counter} >> $GITHUB_STEP_SUMMARY
 echo " " >> $GITHUB_STEP_SUMMARY

fi
