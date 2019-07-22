#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

install_docker_test() {
    local PREPROMPT=${PROMPT:-}
    if [[ ${CI:-} != true ]] && [[ ${PROMPT:-} != "GUI" ]]; then
        PROMPT="CLI"
    fi
    if [[ ${CI:-} == true ]] || run_script 'question_prompt' "${PROMPT:-}" N "Failed to install docker. Would you like to attempt to install a docker test build?"; then
        # https://github.com/docker/docker-install
        info "Installing latest docker test build. Please be patient, this can take a while."
        local GET_DOCKER
        GET_DOCKER=$(mktemp) || fatal "Failed to create temporary storage for docker test build install."
        curl -fsSL test.docker.com -o "${GET_DOCKER}" > /dev/null 2>&1 || fatal "Failed to get docker test build install script."
        sh "${GET_DOCKER}" > /dev/null 2>&1 || fatal "Failed to install docker test build."
        rm -f "${GET_DOCKER}" || warning "Temporary test.docker.com file could not be removed."
        local UPDATED_DOCKER
        UPDATED_DOCKER=$( (docker --version 2> /dev/null || echo "0") | sed -E 's/.* version ([^,]*)(, build .*)?/\1/')
    fi
    PROMPT=${PREPROMPT:-}
}

test_install_docker_test() {
    run_script 'install_docker_test'
    docker --version || fatal "Failed to determine docker version."
}
