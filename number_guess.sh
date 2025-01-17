#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$($PSQL "select floor(random() * 1000 + 1)")

echo Enter your username: 
read USERNAME
PLAYER_ID=$($PSQL "SELECT player_id from players where player = '$USERNAME'")
if [[ -z $PLAYER_ID ]]
then
  INSERT_PLAYER_RESULT=$($PSQL "INSERT into players(player) VALUES('$USERNAME')")
  echo Welcome, $USERNAME! It looks like this is your first time here.
  PLAYER_ID=$($PSQL "SELECT player_id from players where player = '$USERNAME'")
else
  GAMES=$($PSQL "select number_of_games from players where player_id = $PLAYER_ID")
  BEST=$($PSQL "select best_game from players where player_id = $PLAYER_ID")
  echo Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses.
fi

NUMBER_OF_GUESSES=0

# Number guessing loop
echo Guess the secret number between 1 and 1000:
while true
do
  read NUMBER_GUESS
  # check if it's a valid number
  if ! [[ "$NUMBER_GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  let NUMBER_OF_GUESSES=$NUMBER_OF_GUESSES+1
  # number comparisons
  if [[ $NUMBER_GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $NUMBER_GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    INSERT_INTO_RESULT=$($PSQL "INSERT INTO games(player_id, number_of_guesses) values($PLAYER_ID,$NUMBER_OF_GUESSES)")
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) from games GROUP BY player_id HAVING player_id=$PLAYER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) from games GROUP by player_id HAVING player_id=$PLAYER_ID")
    INSERT_INTO_RESULT=$($PSQL "UPDATE players set number_of_games = $GAMES_PLAYED, best_game = $BEST_GAME WHERE player_id = $PLAYER_ID")
    echo  "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    break
  fi
done
