#! /usr/bin/env bash
## sars_cov_2.sh
######
##
## Busca e exibe na tela dados sobre o virus SARS-COV-2 (COVID-19)
##
## Eduardo Lopes
## Versão 0.4.1
#####

readonly _RED='\033[1;31m'
readonly _BLUE='\033[1;34m'
readonly _GREEN='\033[1;32m'
readonly _CLEAN='\033[0m'

readonly _API_URL='https://disease.sh/v3/covid-19'
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

list_countries() {
    local readonly _countries=$(curl --silent "${_API_URL}/countries" | jq ".|.[]|.country" | grep -o -E "[^\"]+")

    echo "$_countries"
}

help() {
    echo -n -e "
Esse script tem o objetivo informar sobre o a pandemia da COVID-19,
causada pelo coronavirus Sars-Cov-2, que surgiu em 12/2019 na China.
Para informações sobre o a fammília de vírus coronavírus, consulte: https://bit.ly/2V1sMnE

Modo de uso:
    sars_cov_2 <opções> [parametros]

    -h | --help -> Exibe esse menu com informações sobre o programa
    -c | --country <país> -> Exibe informações sobre um país especifíco
    -w | --world -> Exibe informações globais
    -l | --list -> Lista os países que é possível consultar
"
}

options() {

    [[ -z "$1" ]] && { help; exit 1; }

    case "$1" in
        "--help"|"-h")
            help
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

        "--list"|"-l")
            list_countries
        ;;

        *)
            printf "${_RED}É necessário informar argumentos válidos${_CLEAN}"
            help
            exit 1
        ;;
    esac
}

options "$@"
