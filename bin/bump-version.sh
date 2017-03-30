#!/usr/bin/env bash

# works with a file called VERSION in the above directory,
# the contents of which should be a semantic version number
# such as "1.2.3"

# this script will display the current version, automatically
# suggest a "minor" version update, and ask for input to use
# the suggestion, or a newly entered value.

# once the new version number is determined, the script will
# create a GIT tag.


main() {

	local source_dir="$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )"
	local version_file=${source_dir}/../VERSION

#	if [[ -f $version_file ]]; then
#		local base_string="$(cat ${version_file})"
#		local curr_ver_list=($(echo "$base_string" | tr '.' ' '))
#		local v_major=${curr_ver_list[0]}
#		local v_minor=${curr_ver_list[1]}
#		local v_patch=${curr_ver_list[2]}
#		log "current version : $base_string"
#		v_minor=$((v_minor + 1))
#		v_patch=0
#		local suggested_version="$v_major.$v_minor.$v_patch"
#		read -r -p "$(log "enter a version string [$suggested_version]: ")" input_version
#		if [[ -z $input_version ]]; then
#			input_version="$suggested_version"
#		fi
#		log "new version will be set to '$input_version'"
#		echo "$input_version" > ${version_file}
#		git add ${version_file}
#		git commit -m "version bump to $input_version"
#		git tag -a -m "tagging version $input_version" "v$input_version"
#		git push origin --tags
#	else
#		echo "could not find a VERSION file"
#		read -p "$(log "do you want to create a version file and start from scratch? [y] ")" input_create_version_file
#		if [[ $input_create_version_file = "y" ]]; then
#			echo "0.1.0" > ${version_file}
#			git add ${version_file}
#			git commit -m "add VERSION file, version bump to v0.1.0"
#			git tag -a -m "tagging version 0.1.0" "v0.1.0"
#			git push origin --tags
#		fi
#
#	fi


	local commit_message
	local new_version


	if [[ -f $version_file ]]; then
        new_version="$(prompt_new_version)"
		commit_message="version bump to $new_version"
	else
		if ! confirm_init_version; then
			exit 0
		fi
		new_version="0.1.0"
		commit_message="add VERSION file, version bump to $new_version"
	fi


	log "new version will be set to '$new_version'"

	write_new_version "$version_file" "$new_version"

	submit_new_version "$version_file" "$commit_message" "$new_version"
}

confirm_init_version() {
	log "could not find a VERSION file"
	read -p "$(log "do you want to create a version file and start from scratch? [y] ")" answer
	[[ $answer = y ]]
}

prompt_new_version() {
	local current_version="$(get_current_version ${version_file})"
	log "current version : $current_version"
	local suggested_version="$(get_suggested_version "$current_version")"
	read -r -p "$(log "enter a version string [$suggested_version]: ")" input_version
	echo "${input_version:-$suggested_version}"
}

get_current_version() {
	local version_file=${1}
	echo "$(cat ${version_file})"
}

get_suggested_version() {
	local current_version="$1"
	local curr_ver_list=($(echo "$current_version" | tr '.' ' '))
	local v_major=${curr_ver_list[0]}; local v_minor=${curr_ver_list[1]}; local v_patch=${curr_ver_list[2]}

	v_minor=$((v_minor + 1))
	v_patch=0
	
	echo "$v_major.$v_minor.$v_patch"
}

write_new_version() {
	local version_file="$1"; local new_version="$2"
	echo "$new_version" > ${version_file}
}

submit_new_version() {
	local version_file="$1"; local commit_message="$2"; local new_version="$3"
	git add ${version_file}
	git commit -m "$commit_message"
	git tag -a -m "tagging version $new_version" "v$new_version"
	git push origin --tags
}

log() {
	echo " > $1"
}


main
