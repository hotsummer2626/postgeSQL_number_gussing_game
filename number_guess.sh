#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_TO_BE_GUESSED=$(( RANDOM % 999 + 1 ))

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "select username,games_played,best_game from users where username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  INSERT_USER_RESULT=$($PSQL "insert into users(username) values('$USERNAME')")
  if [[ $INSERT_USER_RESULT == 'INSERT 0 1' ]]
  then
    echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  fi

else
  echo $USER_INFO | sed 's/|/ /g' | while read USERNAME GAMES_PLAYED BEST_GAME
  do
    INSERT_GAMES_PLAYED_RESULT=$($PSQL "update users set games_played=$(( GAMES_PLAYED + 1)) where username='$USERNAME'")
    echo -e "Welcome back, $USERNAME! You have played $(( GAMES_PLAYED + 1 )) games, and your best game took $BEST_GAME guesses."
  done
fi

echo -e "Guess the secret number between 1 and 1000:"
read NUMBER_GUESSED

INTEGER_CHECK(){
  if [[ ! $1 =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read NUMBER_GUESSED
    INTEGER_CHECK $NUMBER_GUESSED
  else
    GUESS_NUMBER_CHECK $NUMBER_GUESSED
  fi
}

NUMBER_OF_GUESSES=0

GUESS_NUMBER_CHECK(){
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
  if [[ $1 -lt $NUMBER_TO_BE_GUESSED ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    read NUMBER_GUESSED
    INTEGER_CHECK $NUMBER_GUESSED
  elif [[ $1 -gt $NUMBER_TO_BE_GUESSED ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    read NUMBER_GUESSED
    INTEGER_CHECK $NUMBER_GUESSED
  else

    echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_BE_GUESSED. Nice job!"
    BEST_GAME=$($PSQL "select best_game from users where username='$USERNAME'")
    
    if [[ -z $BEST_GAME ]]
    then
      UPDATE_REAULT=$($PSQL "update users set best_game=$NUMBER_OF_GUESSES where username='$USERNAME'")
    fi
    
    if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
    then
      UPDATE_REAULT=$($PSQL "update users set best_game=$NUMBER_OF_GUESSES where username='$USERNAME'")
    fi 
  fi
}

INTEGER_CHECK $NUMBER_GUESSED



