#! /bin/bash

run_query() {
  psql --username=freecodecamp --dbname=salon --no-psqlrc --quiet --tuples-only --no-align -c "$1"
}

sql_escape() {
  printf '%s' "$1" | sed "s/'/''/g"
}

show_services() {
  run_query "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
}

printf '\n~~~~~ MY SALON ~~~~~\n\n'
printf 'Welcome to My Salon, how can I help you?\n\n'
show_services
read SERVICE_ID_SELECTED

while true; do
  if [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    SERVICE_NAME=$(run_query "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  else
    SERVICE_NAME=
  fi

  if [[ -n "$SERVICE_NAME" ]]; then
    break
  fi

  printf '\nI could not find that service. What would you like today?\n'
  show_services
  read SERVICE_ID_SELECTED
done

printf "\nWhat's your phone number?\n"
read CUSTOMER_PHONE

ESCAPED_PHONE=$(sql_escape "$CUSTOMER_PHONE")
CUSTOMER_ID=$(run_query "SELECT customer_id FROM customers WHERE phone = '$ESCAPED_PHONE';")

if [[ -z "$CUSTOMER_ID" ]]; then
  printf "\nI don't have a record for that phone number, what's your name?\n"
  read CUSTOMER_NAME
  ESCAPED_NAME=$(sql_escape "$CUSTOMER_NAME")
  CUSTOMER_ID=$(run_query "INSERT INTO customers (phone, name) VALUES ('$ESCAPED_PHONE', '$ESCAPED_NAME') RETURNING customer_id;")
else
  CUSTOMER_NAME=$(run_query "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

printf "\nWhat time would you like your %s, %s?\n" "$SERVICE_NAME" "$CUSTOMER_NAME"
read SERVICE_TIME

ESCAPED_TIME=$(sql_escape "$SERVICE_TIME")
run_query "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$ESCAPED_TIME');" >/dev/null

printf '\nI have put you down for a %s at %s, %s.\n' "$SERVICE_NAME" "$SERVICE_TIME" "$CUSTOMER_NAME"