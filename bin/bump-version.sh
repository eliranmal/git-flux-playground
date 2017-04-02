#!/usr/bin/env bash


main() {

	ensure_version_file

	case "$1" in
		help|-h)
			usage
			;;
	esac

	local current_version="$(get_current_version)"
	log "current version: ${current_version:-[none]}"

	local commit_message_template="$(get_commit_message_template "$current_version")"
	local suggested_version="$(get_suggested_version "$current_version")"

	local new_version="$(prompt_new_version "$suggested_version")"
	local commit_message="$(printf "$commit_message_template" "$new_version")"

	log "new version will be set to '$new_version'"
	sed -i '' 's,@@VERSION@@,'"$new_version"',g' $(git rev-parse --show-toplevel)/stuff*

#	write_version_file "$new_version"
#	publish_version "$commit_message" "$new_version"
}

usage() {
	echo "
usage: [environment] bump-version.sh
environment:
   VERSION_FILE=$VERSION_FILE
"
exit 0
}

ensure_version_file() {
	local git_root="$(git rev-parse --show-toplevel)"
	VERSION_FILE="${VERSION_FILE:-$git_root/VERSION}"
}

get_current_version() {
	local current_tag="$(git describe --abbrev=0 --tags 2>/dev/null)"
	local current_version="${current_tag#v}" # assume a tag format of "vX.X.X"
	printf "%s" "$current_version"
}

get_commit_message_template() {
	local current_version="$1"
	local template
	if [[ $current_version ]]; then
		template="bump version to %s"
	else
		template="initialize version to %s"
	fi
	if [[ ! -f $VERSION_FILE ]]; then
		template="add version file, $template"
	fi
	printf "%s" "$template"
}

get_suggested_version() {
	local current_version="$1"
	local suggested_version
	if [[ $current_version ]]; then
		suggested_version="$(increment_version "$current_version")"
	else
		suggested_version="0.1.0"
	fi
	printf "%s" "$suggested_version"
}

prompt_new_version() {
	local suggested_version="$1"
	read -r -p "$(log "enter the new version [$suggested_version]: ")" answer
	echo "${answer:-$suggested_version}"
}

increment_version() {
	local current_version="$1"; local segment="${2:-minor}"
	local v_segments=($(echo "$current_version" | tr '.' ' '))
	local v_major=${v_segments[0]}; local v_minor=${v_segments[1]}; local v_patch=${v_segments[2]}

	let "v_$segment += 1"
	if [[ $segment = minor || $segment = major ]]; then
		v_patch=0
	fi
	if [[ $segment = major ]]; then
		v_minor=0
	fi
	
	echo "$v_major.$v_minor.$v_patch"
}

publish_version() {
	local commit_message="$1"; local version="$2"
	git add ${VERSION_FILE}
	git commit --only -m "$commit_message" -- ${VERSION_FILE}
	git tag -a -m "tagging version $version" "v$version"
	git push origin --tags
}

write_version_file() {
	echo "$1" > ${VERSION_FILE}
}

log() {
	echo " > $1"
}


main "$@"
