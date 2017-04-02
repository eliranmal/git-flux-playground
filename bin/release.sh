#!/usr/bin/env bash


main() {
	local source_dir="$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )"
	env VERSION_FILE=${source_dir}/../git-flux-playground-version ${source_dir}/bump-version.sh
#	sed -i 's,@@VERSION@@,'"$new_version"',g' stuff*
}


main "$@"
