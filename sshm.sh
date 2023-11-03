#!/bin/bash
# Script sshm

# default settings
MOUNT_OPTIONS=
MOUNT_POINT=
BASE_MOUNT_POINT="/home/seror/sshfs"
MOUNT_PATH=
MOUNT_USER_AT_HOST=
MOUNT_PASSWORD=
MOUNT_COMMAND=mount

# array to hold arguments without options
ARGV=()

PACKAGE=`basename $0`

# display usage help
function Usage()
{
    cat <<-ENDOFMESSAGE
$PACKAGE - mount or umount filesystem over ssh on /home/seror/user@host
$PACKAGE [command] [user@host[:mount_path]] [options]
arguments:
command - the command to execute, mount / m or unmount / u
user@host:mount_path - the user, the host and the path on the remote server to mount

options:
-h, --help show brief help
-m, --mountpoint MOUNT_POINT the local mount point
-p, --password MOUNT_PASSWORD the password for the ssh login
-o, --options MOUNT_OPTIONS the options string to pass to fusermount

Examples :
$PACKAGE m r_pse@cbs_app_dev:/home/r_pse
$PACKAGE u r_pse@cbs_app_dev

NOTE: 
This command requires the fuse-sshfs package.
The 'allow_other' option string value will require the /etc/fuse.conf option of 'user_allow_other'.
ENDOFMESSAGE
exit
}


# die with message
function Die()
{
    echo "$* Use -h option to display help."
    exit 1
}


# process command line arguments into values to use
function ProcessArguments() {
    # separate options from arguments
    while [ $# -gt 0 ]
    do
        opt=$1
        shift
        case ${opt} in
            -m|--mountpoint)
                if [ $# -eq 0 -o "${1:0:1}" = "-" ]; then
                    Die "The ${opt} option requires an argument."
                fi
                export MOUNT_POINT=$1
                shift
                ;;
            -p|--password)
                if [ $# -eq 0 -o "${1:0:1}" = "-" ]; then
                    # read password input
                    echo -n Password: 
                    read -s password
                    echo
                    export MOUNT_PASSWORD=$password
                else
                    export MOUNT_PASSWORD=$1
                fi
                shift
                ;;
            -o|--options)
                if [ $# -eq 0 -o "${1:0:1}" = "-" ]; then
                    export MOUNT_OPTIONS=""
                else
                    export MOUNT_OPTIONS=$1
                fi
                shift
                ;;
            -h|--help)
                Usage;;
            *)
                if [ "${opt:0:1}" = "-" ]; then
                    Die "${opt}: unknown option."
                fi
                ARGV+=(${opt});;
        esac
    done
    
    export MOUNT_COMMAND=${ARGV[0]}
    if [[ ${ARGV[1]} == *:* ]]; then
        argument1=${ARGV[1]}
        export MOUNT_USER_AT_HOST=${argument1%%:*}
        export MOUNT_PATH=${argument1#*:}
        export MOUNT_POINT="$BASE_MOUNT_POINT/${MOUNT_USER_AT_HOST}"
        echo "variable : $argument1"
        echo "Mount_user_at_host : $MOUNT_USER_AT_HOST"
        echo "Mount_path : $MOUNT_PATH"
    else
    export MOUNT_POINT="$BASE_MOUNT_POINT/${ARGV[1]}"
    fi
}


# process command line arguments
ProcessArguments $*

#process command
case ${MOUNT_COMMAND} in
    m|mount)
        if [ -z "$MOUNT_OPTIONS" ]; then
            echo ${MOUNT_PASSWORD} | sshfs ${MOUNT_USER_AT_HOST}:${MOUNT_PATH} ${MOUNT_POINT} -o password_stdin
        else
            echo ${MOUNT_PASSWORD} | sshfs ${MOUNT_USER_AT_HOST}:${MOUNT_PATH} ${MOUNT_POINT} -o password_stdin,${MOUNT_OPTIONS}
        fi
        ;;
    u|unmount)
        fusermount -u ${MOUNT_POINT}
        ;;
    *)
        Die "${MOUNT_COMMAND} is an unknown command."
        ;;
esac

#################################################

# export USER_AT_HOST=$1
# export USER_PATH=$2
# Make the directory where the remote filesystem will be mounted
# mkdir -p "$HOME/sshfs/$USER_AT_HOST"
# Mount the remote filesystem
# echo sshfs "$USER_AT_HOST:$USER_PATH" "$HOME/sshfs/$USER_AT_HOST" -p 22 -o transform_symlinks -o idmap=user -C
# sshfs "$USER_AT_HOST:$USER_PATH" "$HOME/sshfs/$USER_AT_HOST" -p 22 -o transform_symlinks -o idmap=user -C
