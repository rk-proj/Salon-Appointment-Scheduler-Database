#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo "~~~~ LUXE LOCKS STUDIO ~~~~"
echo -e "\nWelcome to the salon, how can I help you today?\n"

#main menu
MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  while true; do
    read SERVICE_ID_SELECTED

    # Check if input is a valid number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      echo -e "\nI could not find that service. Please select a valid service number:\n"
      echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
      do
        echo "$SERVICE_ID) $SERVICE_NAME"
      done
    else
      # Fetch the service name, trim spaces
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      # Check if service exists
      if [[ -z $SERVICE_NAME ]]
      then
        echo -e "\nI could not find that service. Please select a valid service number:\n"
        echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
        do
          echo "$SERVICE_ID) $SERVICE_NAME"
        done
      else
        # Break the loop if a valid service is selected
        break
      fi
    fi
  done

  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL"SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_ID ]]
  then
    echo "I don't have a record for that phone number, what is your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL"SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
  else
   CUSTOMER_NAME=$($PSQL"SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  INSERT_APT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES ('$SERVICE_ID_SELECTED', '$CUSTOMER_ID', '$SERVICE_TIME')")

  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

}

MAIN_MENU
