#!/bin/sh

# which files do you want to process?
files="*/*.html"
output_format="markdown"
output_extension="md"



# define our regex's
title_regex="<title>([^<]+)</title>"
created_date_regex="<meta name=\"created\" content=\"([^\"]+)\"/>"
modified_regex="<meta name=\"updated\" content=\"([^\"]+)\"/>"
altitude_regex="<meta name=\"altitude\" content=\"([^\"]+)\"/>"
latitude_regex="<meta name=\"latitude\" content=\"([^\"]+)\"/>"
longitude_regex="<meta name=\"longitude\" content=\"([^\"]+)\"/>"
time_regex="([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+)"

for f in $files
do
    echo "Processing $f"
    
    # grab contents and set new name
    file_contents=`cat "$f"`
    basename="${f%.html}"
    target_file="$basename.$output_extension"
    
    # grab metadata
    [[ $file_contents =~ $title_regex ]]
    title="${BASH_REMATCH[1]}"
    [[ $file_contents =~ $created_date_regex ]]
    created_date="${BASH_REMATCH[1]}"
    [[ $file_contents =~ $modified_regex ]]
    modified="${BASH_REMATCH[1]}"
    [[ $file_contents =~ $altitude_regex ]]
    altitude="${BASH_REMATCH[1]}"
    [[ $file_contents =~ $latitude_regex ]]
    latitude="${BASH_REMATCH[1]}"
    [[ $file_contents =~ $longitude_regex ]]
    longitude="${BASH_REMATCH[1]}"

    # convert file
    pandoc -f html -t $output_format -o "$target_file" "$f"
    
    # add metadata
    metadata="title: $title\ncreated: $created_date\nupdated: $modified\nlatitude: $latitude\nlongitude: $longitude\naltitude: $altitude\n\n"
    echo "$metadata" | cat - "$target_file" > /tmp/out && mv /tmp/out "$target_file"

    # set the file's created and modified dates
    [[ $created_date =~ $time_regex ]]
    touch -t "${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}${BASH_REMATCH[4]}${BASH_REMATCH[5]}" "$target_file"
    
    [[ $modified =~ $time_regex ]]
    touch -mt "${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}${BASH_REMATCH[4]}${BASH_REMATCH[5]}" "$target_file"
done