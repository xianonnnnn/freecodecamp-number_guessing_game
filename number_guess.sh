#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ NUMBER GUESSING GAME ~~~~~\n"

# Ask username
echo "Enter your username: "
read USERNAME

# Get username and user_id from the database
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username=INITCAP('$USERNAME')")
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username=INITCAP('$USERNAME')")

# If username is not on the database
if [[ -z $USERNAME_RESULT ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"

  # Insert new user
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")

else
  # Get total number of games played by the user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")
  
  # Get the fewest number of guesses 
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")
  
  echo -e "\nWelcome back, $USERNAME_RESULT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

# Generate random number to be guessed
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

# Guess counter
GUESSES=0

# Initial guess
echo "Guess the secret number between 1 and 1000: "
read GUESS

# Loop to iterate the guesses

until [[ $GUESS == $SECRET_NUMBER ]]
do
  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    (( GUESSESS++ ))  # Increment number of guesses

  # Check inequalities
  else
  # If input is lower
    if [[ $GUESS < $SECRET_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      read GUESS
      (( GUESSES++ ))

    # If input is higher
    else
      echo -e "\nIt's lower than that, guess again:"
      read GUESS
      (( GUESSES++ ))
    fi
  fi
done

# Increment GUESSES again since the user guessed the secret number.
(( GUESSES++ ))

# Get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
# Add result to database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES ($USER_ID_RESULT, $GUESSES)")

echo -e "\nYou guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!\n"
