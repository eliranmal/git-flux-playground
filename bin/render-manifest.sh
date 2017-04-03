#!/usr/bin/env bash


main() {
	local source_dir="$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )"
	
	ensure_manifest_file
	ensure_output_file
	
	local commit_message="$(get_commit_message)"
	
	render_manifest_template
	publish_manifest "$commit_message"
}

ensure_manifest_file() {
	TEMPLATE_FILE="${TEMPLATE_FILE:-${source_dir}/manifest.template}"
}

ensure_output_file() {
	local git_root="$(git rev-parse --show-toplevel)"
	OUTPUT_FILE="${OUTPUT_FILE:-${git_root}/MANIFEST}"
}

get_commit_message() {
	[[ -f $OUTPUT_FILE ]] && { echo "update manifest" } || { echo "add manifest file" }
}

render_manifest_template() {
	# declare manifest properties
	local version="$(cat ${source_dir}/../VERSION)"
	# inject values into placeholders and write to output file
	render_template ${TEMPLATE_FILE} > ${OUTPUT_FILE}
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
