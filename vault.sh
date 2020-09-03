#!/usr/bin/env bash
#
# Vault, organize and secrets with password
#
#/ Usage:
#/   ./vault.sh [-s <string>|-k <key>]
#/
#/ Options:
#/   -s <encrypted_string>    optional, decrypt secret
#/   -k <key>                 optional, decrypt secret paired with key
#/   -h | --help              display this help message

set -e
set -u

usage() {
    printf "%b\n" "$(grep '^#/' "$0" | cut -c4-)" >&2 && exit 1
}

set_var() {
    _VAULT_FILE="./secret.vault"
    _OPENSSL="$(command -v openssl)" || command_not_found "openssl"
}

set_args() {
    expr "$*" : ".*--help" > /dev/null && usage
    _SECRET_KEY=""
    _SECRET_STRING=""
    while getopts ":hk:s:" opt; do
        case $opt in
            k)
                _SECRET_KEY="$OPTARG"
                ;;
            s)
                _SECRET_STRING="$OPTARG"
                ;;
            h)
                usage
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
        esac
    done
}

print_info() {
    # $1: info message
    printf "%b\n" "\033[32m[INFO]\033[0m $1" >&2
}

print_warning() {
    # $1: warning message
    printf "%b\n" "\033[33m[WARNING]\033[0m $1" >&2
}

print_error() {
    # $1: error message
    printf "%b\n" "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

command_not_found() {
    # $1: command name
    print_error "$1 command not found!"
}

check_command_status() {
    # $1: command execution status code
    if [[ "$1" == "1" ]]; then
        print_error "Execution aborted!"
    fi
}

encrypt() {
    #1: secret string
    $_OPENSSL enc -aes-128-cbc -pbkdf2 -a -A -salt <<< "$1"
    check_command_status "$?"
}

decrypt() {
    #1: encrypted string
    $_OPENSSL enc -aes-128-cbc -pbkdf2 -a -d -salt <<< "$1"
    check_command_status "$?"
}

input_key() {
    local k=""
    read -rp "Enter key name: " k
    [[ -z "$k" ]] && print_warning "Empty key name, Enter again!"
    echo "${k// /_}"
}

input_secret() {
    local s=""
    read -rp "Enter secret string: " s
    [[ -z "$s" ]] && print_warning "Empty string, Enter again!"
    echo "$s"
}

save_secret() {
    # $1: key value
    # $2: encrypted secret string
    print_info "Saving secret in $_VAULT_FILE"
    echo "$1: $2" >> "$_VAULT_FILE"
}

read_secret() {
    # $1: key value
    local s
    s=$(grep -E "^${1}: " "$_VAULT_FILE" \
        | tail -1 \
        | awk -F ': ' '{print $2}')

    if [[ -z "$s" ]]; then
        print_error "Key $1 not found in $_VAULT_FILE"
    else
        echo "$s"
    fi
}

main() {
    set_args "$@"
    set_var

    local key=""
    local string=""

    [[ -n "$_SECRET_KEY" ]] && _SECRET_STRING=$(read_secret "$_SECRET_KEY")

    if [[ -z "$_SECRET_STRING" ]]; then
        while [[ -z "$key" ]]; do key=$(input_key); done
        while [[ -z "$string" ]]; do string=$(input_secret); done
        save_secret "$key" "$(encrypt "$string")"
    else
        decrypt "$_SECRET_STRING"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
