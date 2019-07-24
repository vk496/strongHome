#!/bin/bash


my_dir="$(dirname "$0")"
source $my_dir/configurator_libs.sh

function create_password() {
  if [[ $2 ]] && [[ $2 == "admin" ]]; then
    local prompt="your administrator"
  else
    local prompt="${1}"
  fi

  while true; do
    PASSWORD=$(whiptail --passwordbox "Please enter '$prompt' password" \
           8 78 \
           --title "Password setup" \
           --backtitle "StrongHome Configurator" \
           3>&1 1>&2 2>&3)

    PASSWORD_STRENGTH="$(echo "$PASSWORD" | valid_pw)"

    if [[ $? -ne 0 ]]; then
      whiptail --title "Password setup" --backtitle "StrongHome Configurator" --msgbox "${PASSWORD_STRENGTH^}" 8 78
    else
      break
    fi
  done

  PASSWORD=$(echo "$PASSWORD" | generate_pw)
  echo $PASSWORD
}

function generic_inputbox() {
  whiptail \
      --inputbox "$1" \
      8 78 \
      --title "User attributes" \
      --backtitle "StrongHome Configurator" \
       3>&1 1>&2 2>&3
}

function list_services() {

  LIST_SERVICES=()
  for service in $(cat config/strongHome-schema.yaml | yq -r ".mapping.strongHome.mapping.list_services.sequence[].enum[]"); do

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

  whiptail --title "Check list example" --checklist \
      "Select authorized services for asd" 12 62 4 \
      "${LIST_SERVICES[@]}"
}

function configure_user() {
  local NEW_USERNAME=$1
  local NEW_ENCRYPTED_PW=$(create_password $NEW_USERNAME)
  local NEW_FN=$(generic_inputbox "Enter the first name of '$NEW_USERNAME'")
  local NEW_LN=$(generic_inputbox "Enter the last name of '$NEW_USERNAME'")
}

list_services
# add_user asd
# configure_user asd
exit

# Ask for domain
#
# while [[ ! $STRONGHOME_DOMAIN ]] || ([[ $STRONGHOME_DOMAIN ]] && ! valid_domain $STRONGHOME_DOMAIN); do
#   STRONGHOME_DOMAIN=$(whiptail \
#             --inputbox "Enter a valid domain name that will be used in the StrongHome components" \
#             8 78 \
#             example.lan \
#             --title "Domain name" \
#             --backtitle "StrongHome Configurator" \
#              3>&1 1>&2 2>&3)
# done


# Admin password
# while true; do
#   PASSWORD=$(whiptail --passwordbox "Please enter your administrator password" 8 78 --title "Admin Password" --backtitle "StrongHome Configurator" 3>&1 1>&2 2>&3)
#
#   PASSWORD_STRENGTH="$(echo "$PASSWORD" | valid_pw)"
#
#   if [[ $? -ne 0 ]]; then
#     whiptail --title "Admin Password" --backtitle "StrongHome Configurator" --msgbox "${PASSWORD_STRENGTH^}" 8 78
#   else
#     break
#   fi
# done
#
# ADMIN_PASSWORD=$(echo "$PASSWORD" | generate_pw)
#
# unset PASSWORD

#

while [[ ! $ADVSEL ]] || ([[ $ADVSEL ]] && [[ $ADVSEL -ne 0 ]]); do
  ADVSEL=$(whiptail --title "Users menu" --menu "Choose an option" 15 58 6 \
  "1" "Add a StrongHome user." \
  "2" "List all StrongHome users." \
  "3" "Remove an StrongHome user." \
  "0" "EXIT" 3>&1 1>&2 2>&3)

  case $ADVSEL in
      1)

        while [[ ! $STRONGHOME_NEW_USER ]] || ([[ $STRONGHOME_NEW_USER ]] && user_exists $STRONGHOME_NEW_USER ); do
          STRONGHOME_NEW_USER=$(whiptail \
                    --inputbox "Enter a new username. It must be unique!" \
                    8 78 \
                    --title "User name" \
                    --backtitle "StrongHome Configurator" \
                     3>&1 1>&2 2>&3)
        done

        add_user $STRONGHOME_NEW_USER
        configure_user $STRONGHOME_NEW_USER

      ;;
      2)
          # whiptail --title "Option 1" --msgbox "You chose option 2. Exit status $?" 8 45
          #get_usernames
          YLIST=`for x in $(get_usernames); do echo $x "-"; done`
          whiptail --title "List of users" --menu "Choose an option" 15 58 6 \
          $YLIST 3>&1 1>&2 2>&3
      ;;
      3)
          echo "Option 3"
          whiptail --title "Option 1" --msgbox "You chose option 3. Exit status $?" 8 45
      ;;
  esac
done
