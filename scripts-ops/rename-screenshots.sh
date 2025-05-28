#!/bin/bash

#count
count=1

# Loop for every file 'Screenshot ' that end with '.png'
for file in Screenshot\ *.png; do
  # New name 
  new_name="Screenshot_${count}.png"
  
  # Rename file 
  mv "$file" "$new_name"
  
  echo "Renomeado: $file -> $new_name"
  
  # Increment 
  ((count++))
done

