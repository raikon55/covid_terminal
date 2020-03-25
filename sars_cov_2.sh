#! /usr/bin/env bash
## sars_cov_2.sh
######
##
## Busca e exibe na tela dados sobre o virus SARS-COV-2 (COVID-19)
##
## Eduardo Lopes
## Versão 0.3
#####

readonly _RED='\033[1;31m'
readonly _BLUE='\033[1;34m'
readonly _GREEN='\033[1;32m'
readonly _CLEAN='\033[0m'

readonly _API_URL='https://corona.lmao.ninja'
readonly _date=$(date +"%d/%m/%Y %H:%M")

declare -A _data

json2array() {
    readonly _JSON=$(curl --silent "${_API_URL}/$1")

    jq empty <<<"$_JSON" 2>/dev/null || return 1

    while IFS== read -r _key _value
    do
        _data[$_key]="$_value"
    done < <(jq -r '.|to_entries|.[]|.key+"="+(.value|tostring)' <<<"$_JSON")
}

print_country() {
    echo -e -n "
Dados referentes a ${_data[country]} em ${_date}
===============================================
Casos hoje:          $_BLUE${_data[todayCases]}$_CLEAN
Número de casos:     $_BLUE${_data[cases]}$_CLEAN
Mortes hoje:         $_RED${_data[todayDeaths]}$_CLEAN
Total de mortes:     $_RED${_data[deaths]}$_CLEAN
Pessoas recuperadas: $_GREEN${_data[recovered]}$_CLEAN

"
}

print_world() {
    echo -e -n "
Dados referentes ao mundo em ${_date}
===============================================
Número de casos:     $_BLUE${_data[cases]}$_CLEAN
Total de mortes :    $_RED${_data[deaths]}$_CLEAN
Pessoas recuperadas: $_GREEN${_data[recovered]}$_CLEAN

"
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

        "--world"|"-w")
            json2array "all"
            print_world
        ;;

        "--country"|"-c")
            shift
            json2array "countries/$1"
            print_country
        ;;

        *)
            printf "Algo saiu errado"
            exit 1
        ;;
    esac
}

options "$@"
