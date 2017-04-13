#!/usr/bin/env bash


main() {
	local source_dir="$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )"
	local root_dir=${source_dir}/..
	local install_dir=${root_dir}/ext

	env OUTPUT_FILE=${root_dir}/gitflux-playground-manifest ${source_dir}/render-manifest.sh

	rm ${install_dir}/*
	cp ${root_dir}/gitflux-playground* ${install_dir}
	cp ${root_dir}/git-flux-playground* ${install_dir}
	
}


main
