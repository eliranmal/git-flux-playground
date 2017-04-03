#!/usr/bin/env bash


main() {
	local source_dir="$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )"
	local root_dir=${source_dir}/..
	
	
	ensure_output_file

	local commit_message="$(get_commit_message)"
	echo "commit message: $commit_message"

	render_manifest_template
	
	publish_manifest "$commit_message"

}

ensure_output_file() {
	OUTPUT_FILE="${OUTPUT_FILE:-${source_dir}/../MANIFEST}"
}

get_commit_message() {
	local commit_message
	if [[ ! -f $OUTPUT_FILE ]]; then
		commit_message="add manifest file"
	else
		commit_message="update manifest"
	fi
	printf "%s" "$commit_message"
}

render_manifest_template() {
	local template_file=${source_dir}/manifest.tmpl
	# declare manifest properties
	local version="$(cat ${source_dir}/../VERSION)"
	# inject values into placeholders and write to output file
	sed -e 's,@@VERSION@@,'"$version"',g' ${template_file} > ${OUTPUT_FILE}
}

publish_manifest() {
	local commit_message="$1"
	git add ${OUTPUT_FILE}
	git commit --only -m "$commit_message" -- ${OUTPUT_FILE}
	git push origin
#	if [[ $(has_changed "$OUTPUT_FILE") ]]; then
#	fi
}

has_changed() {
	git diff --name-only | grep "$(basename "$1")"
}


main
