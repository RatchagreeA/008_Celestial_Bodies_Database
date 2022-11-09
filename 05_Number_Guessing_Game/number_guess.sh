#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# get username
echo "Enter your username:"
read USERNAME

# get player info
PLAYER_INFO=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username='$USERNAME'")
# if not found
if [[ -z $PLAYER_INFO ]]
then
  # add new player to database
  ADD_PLAYER_RESULT=$($PSQL "INSERT INTO players(username) VALUES ('$USERNAME')")
  # display welcome text
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo $PLAYER_INFO | while IFS=" | " read USERNAME GAMES_PLAYED BEST_GAME
  do
      # display player info
    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# generate secret number 1:1000
SECRET_NUMBER=$(($RANDOM%1000))

# get guessed number
echo -e "Guess the secret number between 1 and 1000:"
read GUESSED_NUMBER
# check input type integer
while [[ ! "$GUESSED_NUMBER" =~ ^[0-9]+$ ]]
do
  # get guessed number again
  echo -e "That is not an integer, guess again:"
  read GUESSED_NUMBER
done

GUESS_CNT=1
# compare guessed number
while (( $GUESSED_NUMBER != $SECRET_NUMBER ))
do
  # if more than secret number
  if (( $GUESSED_NUMBER < $SECRET_NUMBER))
  then
    echo -e "It's lower than that, guess again:"
  # if less than secret number 
  else 
    echo -e "It's higher than that, guess again:" 
  fi
  # get guessed number again
  GUESS_CNT=$(( $GUESS_CNT + 1 ))
  read GUESSED_NUMBER
done

echo -e "You guessed it in $GUESS_CNT tries. The secret number was $SECRET_NUMBER. Nice job!"

PLAYER_INFO=$($PSQL "SELECT games_played, best_game FROM players WHERE username='$USERNAME'")
echo $PLAYER_INFO | while IFS=" | " read GAMES_PLAYED BEST_GAME
do  
    GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
    BEST_GAME=$(( $GUESS_CNT < $BEST_GAME ? $GUESS_CNT : $BEST_GAME ))
    UPDATE_RESULT=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
done


