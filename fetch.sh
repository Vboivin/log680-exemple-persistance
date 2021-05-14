#!/usr/bin/env bash

readonly AUTHORIZATION_HEADER="Authorization: Bearer $TOKEN"
readonly ACCEPT_HEADER="Accept: application/vnd.github.inertia-preview+json"
readonly COLUMNS_ENDPOINT="https://api.github.com/projects/columns"
todo_num=""
in_progress_num=""
review_in_progress_num=""
review_approved_num=""
done_num=""

get_powertoys_project_id() {
  curl \
    --silent \
    --header "$AUTHORIZATION_HEADER" \
    --header "$ACCEPT_HEADER" \
    --request GET \
    --url "https://api.github.com/repos/microsoft/powertoys/projects" | jq --raw-output '.[] | select(.name=="0.39 release") | .id'
}

readonly POWERTOYS_ENDPOINT="https://api.github.com/projects/$(get_powertoys_project_id)/columns"

get_column_ids() {
  curl \
    --silent \
    --header "$AUTHORIZATION_HEADER" \
    --header "$ACCEPT_HEADER" \
    --request GET \
    --url "$POWERTOYS_ENDPOINT" | jq --raw-output '.[].id'
}

get_num_of_cards() {
  local -r column_id="$1"
  curl \
    --silent \
    --header "$AUTHORIZATION_HEADER" \
    --header "$ACCEPT_HEADER" \
    --request GET \
    --url "$COLUMNS_ENDPOINT/$column_id/cards" | jq length
}

get_column_name() {
  local -r column_id="$1"
  curl \
    --silent \
    --header "$AUTHORIZATION_HEADER" \
    --header "$ACCEPT_HEADER" \
    --request GET \
    --url "$COLUMNS_ENDPOINT/$column_id" | jq --raw-output '.name'
 }

assign_num_cards() {
  local -r column_ids=( $(get_column_ids) )
  for column_id in "${column_ids[@]}"
  do
    assign_to_column "$(get_column_name $column_id)" "$column_id"
  done
}

assign_to_column() {
  local -r column_name="$1"
  local -r id="$2"
  case "$column_name" in
    "To do")
      todo_num="$(get_num_of_cards $id)"
      ;;
    "In progress")
      in_progress_num="$(get_num_of_cards $id)"
      ;;
    "Review in progress")
      review_in_progress_num="$(get_num_of_cards $id)"
      ;;
    "Reviewer approved")
      review_approved_num="$(get_num_of_cards $id)"
      ;;
    "Done")
      done_num="$(get_num_of_cards $id)" 
      ;;
  esac
}

add_to_database() {
  local -r todo="$1"
  local -r nip="$2"
  local -r nrip="$3"
  local -r nra="$4"
  local -r nd="$5"
  psql "$DB_CONNECTION_STRING" \
    -c "INSERT INTO log680(num_to_do, \
    num_in_progress, \
    num_review_in_progress, \
    num_reviewer_approved, \
    num_done, \
    fetched_date) \
    VALUES($todo, $nip, $nrip, $nra, $nd, '$(date +%D)')" &>/dev/null
}

main() {
  echo "Fetching number of cards"
  assign_num_cards
  echo "Adding numbers to the database"
  add_to_database $todo_num $in_progress_num $review_in_progress_num $review_approved_num $done_num
} && main

