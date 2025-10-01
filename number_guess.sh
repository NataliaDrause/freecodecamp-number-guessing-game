#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo 'Enter your username:'
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
      # insert user
      INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
      if [[ $INSERT_USER_RESULT == "INSERT 0 1" ]]
        then
          USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
      fi
      # get new user_id
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id='$USER_ID'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id='$USER_ID'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took <best_game> guesses."
fi

echo 'Guess the secret number between 1 and 1000:'

GUESS_NUMBER() {
  read NUMBER
  # if input is not a number
    if [[ ! $NUMBER =~ ^[0-9]+$ ]]
      then
      echo 'That is not an integer, guess again:'
      GUESS_NUMBER
    fi
}

GUESS_NUMBER