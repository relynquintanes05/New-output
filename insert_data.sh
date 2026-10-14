#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

SQL="BEGIN;"
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year == "year" ]]
  then
    continue
  fi

  SQL+=" INSERT INTO teams(name) VALUES ('$winner'), ('$opponent') ON CONFLICT (name) DO NOTHING;"
  SQL+=" INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) SELECT $year, '$round', winner.team_id, opponent.team_id, $winner_goals, $opponent_goals FROM teams AS winner, teams AS opponent WHERE winner.name = '$winner' AND opponent.name = '$opponent';"
done < games.csv
SQL+=" COMMIT;"

$PSQL "$SQL"
