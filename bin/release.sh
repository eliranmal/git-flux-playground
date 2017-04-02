#!/usr/bin/env bash


main() {
	local source_dir="$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )"
	env VERSION_FILE=${source_dir}/../git-flux-playground-version \
		REPLACE_FILES="$(git rev-parse --show-toplevel)/stuff-* $(git rev-parse --show-toplevel)/stuff" \
		${source_dir}/bump-version.sh
}


main
