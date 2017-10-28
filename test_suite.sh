#!/bin/sh

NC="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[1;36m"

check_basics()
{
    echo "${RED} [*] check authors readme and todo [*] ${NC}"
    if [ -e "AUTHORS" ]; then
	echo "${GREEN}AUTHORS ${NC}"
	res=$(grep  '* caradi_c$' AUTHORS)
	if [ $? -ne 0 ]; then
	    cat -e "AUTHORS"
	    echo "\t[ ${RED}KO${NC} ]"
	fi
    else
	echo "${GREEN}creating AUTHORS ${NC}"
	echo "* caradi_c" > AUTHORS
    fi
    
    if [ -e "README" ] ; then
	echo "${GREEN}README ${NC}"
	grep -n '.\{80\}' README
    else
	echo "${GREEN}creating README ${NC}"
	echo "README" > README
    fi
    
    if [ ! -e "TODO" ] ; then
	echo "${GREEN}creating TODO ${NC}"
    fi
}

check_include()
{
    echo "${RED} [*] include check and cs check [*]${NC}"
    echo "${BLUE} searching headers${NC}"
    grep "include <" $1
    echo "${BLUE} searching TODO${NC}"
    grep "TODO" $1
    echo "${BLUE} searching DEAD CODE${NC}"    
    grep "DEAD CODE" $1
    echo "${BLUE} searching FUNCTION${NC}"
    grep "FUNCTION" $1

}

check_80_cols()
{
    echo "${BLUE} 80 columns ${NC}"
    for i in $1 "README"
    do
	grep '.\{79\}' $i > /dev/null
	res=$?
	if [ $i != "src/main.h" ] && [ $res -eq 0 ] ; then
	    echo "${GREEN}$i${NC}"
	    grep -n '.\{79\}' $i
	fi
    done
}

check_unauto()
{
    echo "\n${BLUE} searching for unauthorized functions${NC}"
    for i in $1
    do
	echo "\n${GREEN}     :$i: ${NC}"
	grep $i src/*
    done
}

check_in()
{
    echo "${RED} [*] checking formula-one [*]${NC}"
    for i in $1
    do    
	g_res=$(./check $i | grep "Crash")
	res=$?
	if [ $res -ne 0 ]; then
	    echo $i "${GREEN}success${NC}\t[${GREEN} OK ${NC}]"
	else
	    echo -n $i "${RED}fail${NC}\t[${RED} KO ${NC}]"
	    echo "\t"$g_res
	fi
    done    
}

check_ws_tab()
{
    echo "${RED} [*] checking white spaces and tabs [*]${NC}"
    echo "${BLUE} searching tabs ${NC}"
    grep -P '\t' $1
    echo "${BLUE} searching white spaces ${NC}"
    grep '.\s$' $1
}

check_make()
{
    res=$(make check 2> /dev/null)
    r=$?
    if [ $r -ne 0 ]; then
	echo "${RED}COMPILATION FAILED${NC}"
	make check
    else
	echo "${GREEN}COMPILATION IS OK${NC}"
    fi
    return $r
}

check_make
if [ $? -eq 0 ]; then
    
    check_basics
    check_include "src/*"
    check_80_cols "src/*"
    check_ws_tab "src/*"
    check_unauto "printf write print memcpy"
    check_in "maps/* tests/maps/*"
fi
