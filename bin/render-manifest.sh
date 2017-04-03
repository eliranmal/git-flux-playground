#!/usr/bin/env bash


main() {
	local source_dir="$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )"
	local root_dir=${source_dir}/..
	
	local manifest_file=${root_dir}/git-flux-playground-manifest
	local version="$(cat ${root_dir}/VERSION)"

	local commit_message="$(get_commit_message "$manifest_file")"

	render_manifest_template "${source_dir}/manifest.tmpl" "$manifest_file" "$version"
	
	if [[ $(has_changed "$manifest_file") ]]; then
		publish_manifest "$manifest_file" "$commit_message"
	fi

}

get_commit_message() {
	local manifest_file="$1"
	local commit_message
	if [[ ! -f $manifest_file ]]; then
		commit_message="add manifest file"
	else
		commit_message="update manifest"
	fi
	printf "%s" "$commit_message"
}

render_manifest_template() {
	local template_file="$1"; local output_file="$2"; local version="$3"
	sed -e 's,@@VERSION@@,'"$version"',g' ${template_file} > ${output_file}
}

publish_manifest() {
	local manifest_file="$1"; local commit_message="$2"
	git add ${manifest_file}
	git commit --only -m "$commit_message" -- ${manifest_file}
	git push origin
}

has_changed() {
	git diff --name-only | grep "$(basename "$1")"
}


main
