#!/bin/bash

mysql_command="mysql -h localhost -u root -proot bikes"

echo -e "\n~~~~~ Bike Rental Shop ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "How may I help you?" 
  echo -e "\n1. Rent a bike\n2. Return a bike\n3. Exit"
  read MAIN_MENU_SELECTION

  case $MAIN_MENU_SELECTION in
    1) RENT_MENU ;;
    2) RETURN_MENU ;;
    3) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

RENT_MENU() {
  # get available bikes
  AVAILABLE_BIKES=$($mysql_command -e "SELECT bike_id, size, type FROM bikes WHERE available = 1")

  # if no bikes available
  if [[ -z $AVAILABLE_BIKES ]]
  then
    # send to main menu
    MAIN_MENU "Sorry, we don't have any bikes available right now."
  else
    # Display available bikes
    echo -e "\nHere are the bikes we have available:"
    echo "$AVAILABLE_BIKES" | sed '1,2d' | sed '/^[[:space:]]*$/d' | sed 's/^[[:space:]]*//' | sed 's/)\s*/) /' |  while read BIKE_ID TYPE SIZE
    do
      echo "$BIKE_ID) $TYPE\" $SIZE"
    done

    # ask for bike to rent
    echo -e "\nWhich one would you like to rent?"
    read BIKE_ID_TO_RENT

    # if input is not a number
    if [[ ! $BIKE_ID_TO_RENT =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid bike number."
    else
      # get bike availability
      BIKE_AVAILABILITY=$($mysql_command -e "SELECT available FROM bikes WHERE bike_id = $BIKE_ID_TO_RENT AND available = 1")

      # if not available
      if [[ -z $BIKE_AVAILABILITY ]]
      then
        # send to main menu
        MAIN_MENU "That bike is not available."
      else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read PHONE_NUMBER

        CUSTOMER_NAME=$($mysql_command -N -e "SELECT name FROM customers WHERE phone = '$PHONE_NUMBER'")

        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME

          # insert new customer
          INSERT_CUSTOMER_RESULT=$($mysql_command -e "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$PHONE_NUMBER')") 
        fi

        # get customer_id
        CUSTOMER_ID=$($mysql_command -N -e "SELECT customer_id FROM customers WHERE phone='$PHONE_NUMBER'")

        # insert bike rental
        INSERT_RENTAL_RESULT=$($mysql_command -N -e "INSERT INTO rentals(customer_id, bike_id) VALUES($CUSTOMER_ID, $BIKE_ID_TO_RENT)") 

        # set bike availability to false
        SET_TO_FALSE_RESULT=$($mysql_command -e "UPDATE bikes SET available = 0 WHERE bike_id = $BIKE_ID_TO_RENT")

        # get bike info
        BIKE_INFO=$($mysql_command -e "SELECT CONCAT_WS(' ', size, type) FROM bikes WHERE bike_id = $BIKE_ID_TO_RENT")
        FORMATTED_INFO=$(echo "$BIKE_INFO" | tail -n 1)
        
        # send to main menu
        MAIN_MENU "I have put you down for the $FORMATTED_INFO Bike, $CUSTOMER_NAME.\n"
      fi
    fi
  fi
}

RETURN_MENU() {
  # get customer info
  echo -e "\nWhat's your phone number?"
  read PHONE_NUMBER

  CUSTOMER_ID=$($mysql_command -e "SELECT customer_id FROM customers WHERE phone = '$PHONE_NUMBER'")

  # if not found
  if [[ -z $CUSTOMER_ID  ]]
  then
    # send to main menu
    MAIN_MENU "I could not find a record for that phone number."
  else
    # get customer's rentals
    CUSTOMER_RENTALS=$($mysql_command -e "SELECT b.bike_id, b.type, b.size
                                            FROM bikes b
                                            INNER JOIN rentals r ON b.bike_id = r.bike_id
                                            INNER JOIN customers c ON r.customer_id = c.customer_id
                                            WHERE c.phone = '$PHONE_NUMBER' AND r.date_returned IS NULL")

    # if no rentals
    if [[ -z $CUSTOMER_RENTALS  ]]
    then
      # send to main menu
      MAIN_MENU "You do not have any bikes rented."
    else
      # display rented bikes
      echo -e "\nHere are your rentals:"
      echo "$CUSTOMER_RENTALS"  | awk 'NR > 1 { print }' |   while read BIKE_ID SIZE TYPE
      do
        echo "$BIKE_ID) $SIZE $TYPE\" Bike"
      done
      # ask for bike to return
      echo -e "\nWhich one would you like to return?"
      read BIKE_ID_TO_RETURN
      # if not a number
      if [[ ! $BIKE_ID_TO_RETURN =~ ^[0-9]+$ ]]
      then
        # send to main menu
        MAIN_MENU "That is not a valid bike number."
        else
        # check if input is rented
        RENTAL_ID=$($mysql_command -N -e "SELECT r.rental_id
                                        FROM rentals r
                                        INNER JOIN customers c ON r.customer_id = c.customer_id
                                        WHERE r.bike_id = $BIKE_ID_TO_RETURN AND r.date_returned IS NULL")

        # if input not rented
        if [[ -z $RENTAL_ID ]]
        then
        # send to main menu
        MAIN_MENU "You do not have that bike rented."
        else
          # update date_returned
          RETURN_BIKE_RESULT=$($mysql_command -e "UPDATE rentals SET date_returned = NOW() WHERE rental_id = $RENTAL_ID")
          # set bike availability to true
          SET_TO_TRUE_RESULT=$($mysql_command -e "UPDATE bikes SET available = 1 WHERE bike_id = $BIKE_ID_TO_RETURN")
          # send to main menu
          MAIN_MENU "Thank you for returning your bike.\n"
        fi
      fi
    fi
  fi
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU