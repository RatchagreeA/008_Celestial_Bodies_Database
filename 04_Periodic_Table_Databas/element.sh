#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
# check empty input arg
if [[ -z $1 ]]
then
  # display require input arg text
  echo -e "Please provide an element as an argument."

else
  # check type input
  if [[ "$1" =~ ^[0-9]+$ ]]
  then
    CONDITION="atomic_number=$1"
  else
    CONDITION="symbol='$1' OR name='$1'"
  fi
  # check info database
  ELEMENT_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE $CONDITION")
  # if not found
  if [[ -z $ELEMENT_RESULT ]]
  then
    # display not found text
    echo -e "I could not find that element in the database."
  else
    # display element info
    echo $ELEMENT_RESULT | while IFS=" | " read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
    do
      echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi

fi

