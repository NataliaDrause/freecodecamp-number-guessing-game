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
          GAMES_PLAYED=0
          BEST_GAME=9999
      fi
      # get new user_id
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER_OF_GUESSES=0
GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo 'Guess the secret number between 1 and 1000:'

GUESS_NUMBER() {
  read NUMBER
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
  # if input is not a number
    if [[ ! $NUMBER =~ ^[0-9]+$ ]]
      then
        echo 'That is not an integer, guess again:'
        GUESS_NUMBER
    elif (( $NUMBER > $SECRET_NUMBER ))
      then
        echo "It's lower than that, guess again:"
        GUESS_NUMBER
    elif (( $NUMBER < $SECRET_NUMBER ))
      then
        echo "It's higher than that, guess again:"
        GUESS_NUMBER
    else
        # check the number
        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
        if (( $NUMBER_OF_GUESSES < $BEST_GAME ))
          then
            UPDATE_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES, games_played=$GAMES_PLAYED WHERE user_id=$USER_ID")
          else
            UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID")
          fi
    fi
}

GUESS_NUMBER