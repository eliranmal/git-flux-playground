#!/usr/bin/env bash


main() {
	local source_dir="$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )"
	ensure_output_file
	local commit_message="$(get_commit_message)"
	render_manifest_template
	publish_manifest "$commit_message"
}

ensure_output_file() {
	local git_root="$(git rev-parse --show-toplevel)"
	OUTPUT_FILE="${OUTPUT_FILE:-${git_root}MANIFEST}"
}

get_commit_message() {
	local message
	if [[ ! -f $OUTPUT_FILE ]]; then
		message="add manifest file"
	else
		message="update manifest"
	fi
	printf "%s" "$message"
}

render_manifest_template() {
	local template_file=${source_dir}/manifest.template
	# declare manifest properties
	local version="$(cat ${source_dir}/../VERSION)"
	# inject values into placeholders and write to output file
	render_template ${template_file} > ${OUTPUT_FILE}
}

render_template() {
	eval "echo \"$(cat $1)\""
}

publish_manifest() {
	local commit_message="$1"
	git add ${OUTPUT_FILE}
	git commit --only -m "$commit_message" -- ${OUTPUT_FILE}
	git push origin
}


main
