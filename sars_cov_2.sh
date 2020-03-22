#! /usr/bin/env bash
## sars_cov_2.sh
######
##
## Busca e exibe na tela dados sobre o virus SARS-COV-2 (COVID-19)
##
## Eduardo Lopes
## Versão 0.1
#####

readonly _API_URL='https://www.bing.com/covid/data?IG=56334BDE95D545AFAA8E6066C8AA674F'

declare -A _data

json2array() {
    local _json_data="${1%%,}}"

    jq empty <<<"$_json_data" 2>/dev/null || return 1

    while IFS== read -r _key _value
    do
        _data[$_key]="$_value"
    done < <(jq -r '.|to_entries|.[]|.key+"="+(.value|tostring)' <<<"$_json_data")
}

print_data() {
    local _date=$(date +"%d/%m/%Y %H:%M")
    echo -n "
Dados referentes ao país ${_data[displayName]}
em ${_date}:
===============================================
Número de casos: ${_data[totalConfirmed]}
Total de mortes: ${_data[totalDeaths]}
Pessoas recuperadas: ${_data[totalRecovered]}

"

}

main() {
    local _json _regex

    _regex="\{\"id\"\:\"${1}[a-zA-Z0-9\",:]{1,}\[\][a-zA-Z0-9\",:]{1,},"

    _json=$(curl --silent "${_API_URL}" | grep -o -E "$_regex")

    if ! json2array "$_json"
    then
        printf "ERRO: Falha em obter os dados de $_API_URL">&2
        exit 1
    fi

    print_data
}

main "$1"
