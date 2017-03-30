#!/usr/bin/env bash

# works with a file called VERSION in the current directory,
# the contents of which should be a semantic version number
# such as "1.2.3"

# this script will display the current version, automatically
# suggest a "minor" version update, and ask for input to use
# the suggestion, or a newly entered value.

# once the new version number is determined, the script will
# pull a list of changes from git history, prepend this to
# a file called CHANGES (under the title of the new version
# number) and create a GIT tag.


main() {

	local source_dir="$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )"
	local version_file=${source_dir}/../VERSION

	if [[ -f $version_file ]]; then
		local base_string=$(cat ${version_file})
		local base_list=($(echo "$base_string" | tr '.' ' '))
		local v_major=${base_list[0]}
		local v_minor=${base_list[1]}
		local v_patch=${base_list[2]}
		echo "Current version : $base_string"
		v_minor=$((v_minor + 1))
		v_patch=0
		local suggested_version="$v_major.$v_minor.$v_patch"
		read -p "Enter a version number [$suggested_version]: " input_version
		if [[ -z $input_version ]]; then
			input_version="$suggested_version"
		fi
		echo "Will set new version to be $input_version"
		echo "$input_version" > ${version_file}
		echo "Version $input_version:" > tmpfile
		git log --pretty=format:" - %s" "v$base_string"...HEAD >> tmpfile
		echo "" >> tmpfile
		echo "" >> tmpfile
		cat CHANGES >> tmpfile
		mv tmpfile CHANGES
		git add CHANGES ${version_file}
		git commit -m "Version bump to $input_version"
		git tag -a -m "Tagging version $input_version" "v$input_version"
		git push origin --tags
	else
		echo "Could not find a VERSION file"
		read -p "Do you want to create a version file and start from scratch? [y]" input_create_version_file
		if [ "$input_create_version_file" = "y" ]; then
			echo "0.1.0" > ${version_file}
			echo "Version 0.1.0" > CHANGES
			git log --pretty=format:" - %s" >> CHANGES
			echo "" >> CHANGES
			echo "" >> CHANGES
			git add ${version_file} CHANGES
			git commit -m "Added VERSION and CHANGES files, Version bump to v0.1.0"
			git tag -a -m "Tagging version 0.1.0" "v0.1.0"
			git push origin --tags
		fi

	fi
}


main
