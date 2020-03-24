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
readonly _JSON=$(curl --silent "${_API_URL}")

declare -A _data
declare -A _countries

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
Dados referentes a ${_data[displayName]}
em ${_date}
===============================================
Número de casos: ${_data[totalConfirmed]}
Total de mortes: ${_data[totalDeaths]}
Pessoas recuperadas: ${_data[totalRecovered]}

"

}

print_countries() {
    local _countries=$(grep -o -E '"id"\:"[a-z]+"' <<<"$_JSON" | sed 's/"id"\://')

    while IFS== read -r _key _value
    do
        _countries[$_key]="$_value"
    done <<"$_countries"

    echo $_countries
}

options() {
    case "$1" in
        "--help"|"-h")
            echo -n "
Esse programa tem como objetivo fornecer dados da
pandemia do vírus SARS-COV-2 (COVID-19).
"
            exit 1
        ;;

        "--list"|"-l")
            shift
            print_countries
        ;;

        "--country"|"-c")
            shift
            json2array "$1"
            print_data
        ;;

        "--world"|"-w")
            # Mostrar informação do mundo todo
        ;;

        *)
            printf "Algo saiu errado"
            exit 1
        ;;
    esac
}

main() {
    local _regex

    _regex="\{\"id\"\:\"${1}[a-zA-Z0-9\",:]{1,}\[\][a-zA-Z0-9\",:]{1,},"

    if [[ $(jq empty <<< "$_JSON") ]]
    then
        printf "ERRO: Falha em obter os dados de $_API_URL">&2
        exit 1
    else
        options "$@"
    fi
}

main "$@"
