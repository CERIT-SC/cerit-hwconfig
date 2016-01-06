#!/bin/bash

#TODO: help
# arguments processing
while getopts ":h:d:u:U:p:P:" opt; do
	case "${opt}" in
	h)	HOST="${OPTARG}" ;;
	d)	DEV="${OPTARG}" ;;
	u)	D_USER="${OPTARG}" ;;
	U)	USER="${OPTARG}" ;;
	p)	D_PSWD="${OPTARG}" ;;
	P)	PSWD="${OPTARG}" ;;
	\?)
		echo "Invalid option: -${OPTARG}" >&2
		exit 1
		;;
	:)
		echo "Option -${OPTARG} requires an argument." >&2
		exit 1
		;;
	esac
done

if [ "x${HOST}" = 'x' ] && [ "x${DEV}" = 'x' ]; then
	# fallback to local device 0 if nothing specified
	DEV=0
elif [ "x${HOST}" != 'x' ] && [ "x${DEV}" != 'x' ]; then
	# fail if both host and device are specified
	echo "Default user and password required for network access." >&2
	exit 1
fi

# network access requires default user/password
if [ "x${HOST}" != 'x' ]; then
	if [ "x${D_USER}" = 'x' ] || [ "x${D_PSWD}" = 'x' ]; then
		echo "Default user and password required for network access." >&2
		exit 1
	fi
fi

if [ "x${USER}" = 'x' ] || [ "x${PSWD}" = 'x' ]; then
	echo "Missing new user and password." >&2
	exit 1
fi

# check ipmitool
type ipmitool &>/dev/null || {
	echo "ipmitool not found." >&2
	exit 1
}

###

ipmi() {
	if [ "x${HOST}" != 'x' ]; then
		ipmitool -c -U"${1}" -P"${2}" -H"${HOST}" -Ilanplus ${3}
	elif [ "x${DEV}" != 'x' ]; then
		ipmitool -c -d"${DEV}" ${3}
	fi
}

###

IPMI_C="ipmi $D_USER $D_PSWD"

# check connection
echo '* Checking IPMI connection'
$IPMI_C 'mc info' &>/dev/null || {
	IPMI_C="ipmi $USER $PSWD"
	$IPMI_C 'mc info' >/dev/null || \
		exit 1
}

# configure new user 
echo "* Checking user '${USER}'"
MY_USER_ID=`$IPMI_C "user list 1" | awk -F, "tolower(\\$2) == tolower(\"${USER}\") { print \\$1 }"`
if [ "x${MY_USER_ID}" == 'x' ]; then
	echo "  * Creating"

	set -e
	MY_USER_ID=`$IPMI_C "user list 1" | awk -F, 'BEGIN {max=0} {if ($1>max) {max=$1}} END {print max+1}'`
	$IPMI_C "user set name $MY_USER_ID $USER"
	$IPMI_C "user set password $MY_USER_ID $PSWD"
	#$IPMI_C "user priv $MY_USER_ID 4"
	$IPMI_C "channel setaccess 1 $MY_USER_ID ipmi=on link=on privilege=4"
	$IPMI_C "user enable $MY_USER_ID"
	$IPMI_C "sol payload enable 1 $MY_USER_ID"
	$IPMI_C "user test $MY_USER_ID 16 $PSWD" >/dev/null
	set +e
fi

# check (or set new password)
$IPMI_C "user test $MY_USER_ID 16 $PSWD" &>/dev/null || {
	echo '  * Setting new password'

	set -e
	$IPMI_C "user set password $MY_USER_ID $PSWD"
	set +e
}

# switch to new user and check connection
IPMI_C="ipmi $USER $PSWD"
$IPMI_C 'mc info' >/dev/null || \
	exit 1

# disable other user(s)
OTHER_USER_IDS=`$IPMI_C "user list 1" | awk -F, "tolower(\\$2) != tolower(\"${USER}\") { print \\$1 }"`
if [ "x${OTHER_USER_IDS}" != 'x' ]; then
	echo '* Disabling other IPMI users (for sure):'
	for	OTHER_USER_ID in ${OTHER_USER_IDS}; do
		echo "  * ${OTHER_USER_ID}"
		$IPMI_C "user disable ${OTHER_USER_ID}" || \
			exit 1
	done
fi

echo 'Done'
