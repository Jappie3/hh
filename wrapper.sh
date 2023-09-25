#!/usr/bin/env bash

HETZNER_SERVER_TYPES=("CX11  - 1vcpu 2GB (Intel)" "CPX11 - 2vcpu 2GB (AMD)" "CX21  - 2vcpu 4GB (Intel)" "CPX21 - 3vcpu 4GB (AMD)" "CX31  - 2vcpu 8GB (Intel)" "CPX31 - 4vcpu 8GB (AMD)" "CX41  - 4vcpu 16GB (Intel)" "CPX41 - 8vcpu 16GB (AMD)" "CX51  - 8vcpu 32GB (Intel)" "CPX51 - 16vcpu 32GB (AMD)" "CAX11 - 2vcpu 4GB (Ampere)" "CAX21 - 4vcpu 8GB (Ampere)" "CAX31 - 8vcpu 16GB (Ampere)" "CAX41 - 16vcpu 32GB (Ampere)" "CCX13 - 2vcpu 8GB (AMD)" "CCX12 - 2vcpu 8GB (AMD)" "CCX23 - 4vcpu 16GB (AMD)" "CCX22 - 4vcpu 16GB (AMD)" "CCX33 - 8vcpu 32GB (AMD)" "CCX32 - 8vcpu 32GB (AMD)" "CCX43 - 16vcpu 64GB (AMD)" "CCX42 - 16vcpu 64GB (AMD)" "CCX53 - 32vcpu 128GB (AMD)" "CCX63 - 48vcpu 192GB (AMD)" "CCX52 - 32vcpu 128GB (AMD)" "CCX62 - 48vcpu 192GB (AMD)")
HETZNER_IMAGES=("ubuntu-22.04" "fedora-38" "debian-12" "centos-9" "rockylinux-9" "almalinux-9")

# check if token is present
if [[ -e ".token" && -s ".token" ]]; then
    export HETZNER_API_TOKEN="$(cat ./.token)"
else
    echo "No token found, make sure the '.token' file is present - exiting..."
    exit 1
fi

if [[ "$1" == "create" ]]; then

    # assume the default key on Hetzner is currentUser@currentHost
    export SSH_KEY=""$(whoami)"@"$(hostname)""
    
    echo

    read -p "Enter server name: " server_name
    export SERVER_NAME="$server_name"

    echo

    while read -p "Add an IPv4 address? (IPv6 is free, IPv4 not) (y/n) " answer; do
        if [[ "$answer" == "y" ]]; then
            export IPv4="true"
            break
        elif [[ "$answer" == "n" ]]; then
            export IPv4="false"
            break
        else
            echo "Answer with 'y' or 'n' - try again"
        fi
    done

    echo

    echo "Select the server image (enter a number):"
    select image in "${HETZNER_IMAGES[@]}"; do
        case "$REPLY" in
            ''|*[!0-9]* )
                echo "Invalid option - try again"
            ;;
            * )
                if [[ $REPLY -gt ${#HETZNER_IMAGES[@]} || $REPLY -le 0 ]]; then
                    echo "Invalid option - try again"
                    continue
                fi
                export IMAGE="$image"
                break
            ;;
        esac
    done

    echo

    echo "Select the server type (enter a number):"
    select server_type in "${HETZNER_SERVER_TYPES[@]}"; do
        case "$REPLY" in
            ''|*[!0-9]* )
                echo "Invalid option - try again"
            ;;
            * )
                if [[ $REPLY -gt ${#HETZNER_SERVER_TYPES[@]} || $REPLY -le 0 ]]; then
                    echo "Invalid option - try again"
                    continue
                fi
                # strip server info (vcpu, ram, arch)
                export SERVER_TYPE="$(echo "$server_type" | awk '{ print $1 }')"
                break
            ;;
        esac
    done

    echo -e "\n\nYou selected the following:\n\tServer name: $SERVER_NAME\n\tImage: $IMAGE\n\tServer type: $SERVER_TYPE\n\tName of SSH key: $SSH_KEY\n\tIPv4 address: $IPv4\n\nPress enter to continue with the server creation, ctrl+C to abort."
    read

    ansible-playbook ./playbook.yaml

    # exit 1 if playbook exited with error code != 0
    if [[ "$?" != 0 ]]; then
        exit 1
    fi

    # get IP returned by playbook
    echo "IP(s) of server: $(cat .ip)"
    rm .ip

elif [[ "$1" == "remove" ]]; then

    # TODO
    :

else
    echo "Specify 'create' or 'remove'"
    exit 1
fi
