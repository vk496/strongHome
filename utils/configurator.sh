#!/bin/bash

trap 'clear' EXIT

eval `resize`
if [[ -f /remote/config/strongHome-schema.yaml ]]; then
  STRONGHOME_SCHEMA_PREFIX=/remote
else
  STRONGHOME_SCHEMA_PREFIX=.
fi

my_dir="$(dirname "$0")"
source $my_dir/configurator_libs.sh

function create_password() {
  if [[ $2 ]] && [[ $2 == "admin" ]]; then
    prompt="your administrator"
  else
    prompt="'${1}'"
  fi

  while true; do
    PASSWORD=$(whiptail --passwordbox "Please enter $prompt password" \
           8 78 \
           --title "Password setup" \
           --cancel-button "Exit" \
           --backtitle "StrongHome Configurator" \
           3>&1 1>&2 2>&3)

     [[ $? -ne 0 ]] && exit 1

    PASSWORD_STRENGTH="$(echo "$PASSWORD" | valid_pw)"

    if [[ $? -ne 0 ]]; then
      whiptail --title "Password setup" \
       --backtitle "StrongHome Configurator" \
       --msgbox "${PASSWORD_STRENGTH^}" 8 78 \
       3>&1 1>&2 2>&3
    else
      break
    fi
  done

  PASSWORD=$(echo "$PASSWORD" | generate_pw)
  echo "{CRYPT}$PASSWORD"
  unset PASSWORD
  return 0
}

function list_services() {

  LIST_SERVICES=()
  for service in $(cat ${STRONGHOME_SCHEMA_PREFIX}/config/strongHome-schema.yaml | yq -r ".mapping.strongHome.mapping.list_services.sequence[].enum[]"); do

    desc=""
    case $service in
      Radius)
        desc="Access to WPA/2 Enterprise wifi login"
        ;;
      VoIP)
        desc="Access to internal calls"
        ;;
      Email)
        desc="Access to personal email account"
        ;;
      *)
        desc="No service description"
        ;;
    esac
    #https://stackoverflow.com/questions/16897697/bash-spaces-in-whiptail-dialog-menu-items
    LIST_SERVICES+=("$service" "$desc" "ON")
  done

  whiptail --title "Services" \
          --cancel-button "Exit" \
          --backtitle "StrongHome Configurator" \
          --checklist "Select authorized services for asd" 12 62 4 \
          "${LIST_SERVICES[@]}" 3>&1 1>&2 2>&3

  [[ $? -ne 0 ]] && exit 1
  return 0
}

function create_username() {
  while [[ ! $STRONGHOME_NEW_USER ]] || ([[ $STRONGHOME_NEW_USER ]] && user_exists $STRONGHOME_NEW_USER ); do
    STRONGHOME_NEW_USER=$(whiptail \
              --inputbox "Enter a new username. It must be unique!" \
              8 78 \
              --title "User name" \
              --cancel-button "Exit" \
              --backtitle "StrongHome Configurator" \
               3>&1 1>&2 2>&3)

     [[ $? -ne 0 ]] && exit 1
  done

  add_user $STRONGHOME_NEW_USER
  [[ $? -ne 0 ]] && exit 1

  res="$(configure_user $STRONGHOME_NEW_USER)"
  [[ $? -ne 0 ]] && exit 1

  fill_user $STRONGHOME_NEW_USER "$res"
  [[ $? -ne 0 ]] && exit 1

  return 0
}


function configure_user() {
  NEW_USERNAME=$1
  NEW_ENCRYPTED_PW=$(create_password $NEW_USERNAME)
  [[ $? -ne 0 ]] && exit 1

  NEW_SERVICES=($(list_services))
  [[ $? -ne 0 ]] && exit 1

  echo -n "$NEW_ENCRYPTED_PW"
  echo -n ":$NEW_FN"
  echo -n ":$NEW_LN"
  for ser in ${NEW_SERVICES[@]};do
    echo -n ":$(echo "$ser" | cut -d\" -f2)"
  done

  return 0
}
#ADMIN_PWD_ENCRYPTED="{CRYPT}\$ajsdjiaiadiajia"
#generate_config

TERM=ansi whiptail --backtitle "StrongHome Configurator" --title "StrongHome" --infobox "Processing. Please, be patient :)" 8 38 3>&1 1>&2 2>&3

ADMIN_PWD_ENCRYPTED=$(create_password admin admin)
[[ $? -ne 0 ]] && exit 1
#

while [[ ! $ADVSEL ]] || ([[ $ADVSEL ]] && [[ $ADVSEL -ne 0 ]]); do
  ADVSEL=$(whiptail --backtitle "StrongHome Configurator" --cancel-button "Exit" --title "Users menu" --menu "Choose an option" 15 58 6 \
  "1" "Add a StrongHome user." \
  "2" "List all StrongHome users." \
  "3" "Remove an StrongHome user." \
  "0" "Save config and EXIT" 3>&1 1>&2 2>&3)

  case $ADVSEL in
      1) create_username
        [[ $? -ne 0 ]] && exit 1
      ;;
      2)
          # whiptail --title "Option 1" --msgbox "You chose option 2. Exit status $?" 8 45
          #get_usernames
          YLIST=`for x in $(get_usernames); do echo $x "-"; done`
          whiptail --title "List of users" --backtitle "StrongHome Configurator" --cancel-button "Exit" --menu "Choose an option" 15 58 6 \
          $YLIST 3>&1 1>&2 2>&3
          [[ $? -ne 0 ]] && exit 1
      ;;
      3)
          whiptail --backtitle "StrongHome Configurator" --title "Option 1" --msgbox "Sorry, not implemented yet" 8 45
      ;;

      0) generate_config | yq -y . > strongHome-config.yaml
      ;;

      *) exit 1;
      ;;
  esac
done


pykwalify -s ${STRONGHOME_SCHEMA_PREFIX}/config/strongHome-schema.yaml -d strongHome-config.yaml

if [[ $? -eq 0 ]]; then
  cp strongHome-config.yaml ${STRONGHOME_SCHEMA_PREFIX}/config/strongHome-config.yaml
  echo "File saved at ./config/strongHome-config.yaml"
else
  echo "Critical error. Please, report to maintainer"
  exit 3
fi
