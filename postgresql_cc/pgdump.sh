#!/bin/bash


# ===================================================
# =====               VARIABLES                 =====
# ===================================================

VERBOSE=false
EXEC_LIST=false
EXEC_ENV=false
EXEC_DUMP=false
EXEC_DUMP_AUTO=false
EXEC_SIZE=false
EXEC_EXECUTE=false

FILES=
ORGANISATION="ANSSI"
REBOUND_INSTANCE="anssi-mss-prod"
IDENTITY_FILE="~/.ssh/clever-cloud.admin"
OUTPUT_DIR="/tmp/"


# ===================================================
# =====              FUNCTIONS                  =====
# ===================================================

function execute() {
	clever ssh \
		-i "${IDENTITY_FILE}" \
		--app "${REBOUND_INSTANCE}" \
		--instance 0 \
		-c "$*"
}
function list() {
	clever addon list \
		--org ${ORGANISATION} \
		--format json \
		| jq -r '.[] | select(.providerId == "postgresql-addon") | "\(.realId)\t\t\(.name)"'
}
function read_file() {
	local filename="$1"
	grep -vE '^[[:space:]]*(#|$)' ${filename} | while read id db; do
		printf "%s  %s\n" "${id}" "${db}"
	done
}
function get_env() {
	ID="${1}"
	eval $(clever addon env ${ID} | grep "^POSTGRESQL.*=.*")
}

function get_instances_from_cmdline() {
	FILES="$*"
	if [[ "${FILES}" == postgresql_* ]]; then
		INSTANCES="${FILES}"
	else
		INSTANCES=$(read_file "${FILES}")
	fi
	echo -ne "${INSTANCES}"
}



# ===================================================
# =====              ARGUMENTS                  =====
# ===================================================

while (($#)); do
        case "$1" in

		# help: optional
		--org)
			shift
			ORGANISATION="$1"
			shift
			;;
		# help: optional
		--rebound-instance)
			shift
			REBOUND_INSTANCE="$1"
			shift
			;;
		# help: optional
		--identity-file)
			shift
			IDENTITY_FILE="$1"
			shift
			;;

		# help: optional
		--output-dir)
			shift
			OUTPUT_DIR="$1"
			shift
			;;

		# help: get list from clever cloud
		--list)
			EXEC_LIST=true
			shift
			;;

		# help: get env
		--env)
			EXEC_ENV=true; shift
			EXEC_ID="$1"; shift
			;;

		# help: size all databases: --size files.txt
		--size)
			EXEC_SIZE=true; shift
			while (($#)) && [[ "$1" != -* ]]; do
				FILES+="$1 "; shift
			done
			((${#FILES})) || FILES="database.txt"
			;;

		# help: dump all databases: --dump files.txt
		--dump)
			EXEC_DUMP=true; shift
			while (($#)) && [[ "$1" != -* ]]; do
				FILES+="$1 "; shift
			done
			((${#FILES})) || FILES="database.txt"
			;;

		# help: get all database and dump them
		--dump-auto)
			EXEC_DUMP_AUTO=true
			shift
			;;


		# help: execute in specific db: --execute <instance_id> "<sqlcmd>"
		--execute)
			EXEC_EXECUTE=true; shift
			EXEC_ID="$1"; shift
			EXEC_CMD="$1"; shift
			;;

		# help: More blahblah:
		-v|--verbose)
			VERBOSE=true
			shift
			;;

		# help: Myself :-D
		-h|--help)
			# quick & dirty usage generator
			printf "Usage: $0 <options>\n"
			grep '#.*[h]elp:.*' -A1 --no-group-separator "$0" \
				| tr -d '#)\t' \
				| sed -e "s/^\s//g" \
				| sed -e "s/help:/*/"
			exit 253
			;;
                -*)
                        echo "Unknown parameter: $1"
                        exit 254
                        ;;
        esac
done




# ===================================================
# =====                  MAIN                   =====
# ===================================================

if $VERBOSE; then
	echo "FILES=${FILES}"
	echo "ORGANISATION=${ORGANISATION}"
	echo "REBOUND_INSTANCE=${REBOUND_INSTANCE}"
	echo "IDENTITY_FILE=${IDENTITY_FILE}"
	echo "OUTPUT_DIR=${OUTPUT_DIR}"
fi

if $EXEC_LIST; then
	list
fi

if $EXEC_DUMP_AUTO; then
	FILES=/tmp/dump.txt
	list > ${FILES}
	printf "%d databases\n" "$(wc -l < ${FILES})"
	EXEC_DUMP=true
fi

if $EXEC_ENV; then
	get_env "${EXEC_ID}"
	set | grep "^POSTGRESQL"
fi

if $EXEC_SIZE; then
	INSTANCES=$(get_instances_from_cmdline "${FILES}")
	[[ -z ${INSTANCES} ]] && exit 1

	echo "${INSTANCES}" | while read id db; do
		get_env "${id}"
		printf "[%s] %-40s %s@%s:%s/%s\n" "${id}" "${db:0:40}" \
			"${POSTGRESQL_ADDON_USER}" "$POSTGRESQL_ADDON_HOST" \
			"$POSTGRESQL_ADDON_PORT" "$POSTGRESQL_ADDON_DB"
		execute \
			"PGPASSWORD=${POSTGRESQL_ADDON_PASSWORD} \
			    psql -h ${POSTGRESQL_ADDON_HOST} \
				 -p ${POSTGRESQL_ADDON_PORT} \
				 -U ${POSTGRESQL_ADDON_USER} \
				 -d ${POSTGRESQL_ADDON_DB} \
				 -t -A \
				 -c 'SELECT pg_size_pretty(pg_database_size(current_database()));'"
	done;
fi

if $EXEC_DUMP; then
	INSTANCES=$(get_instances_from_cmdline "${FILES}")
	[[ -z ${INSTANCES} ]] && exit 1

	echo "${INSTANCES}" | while read id db; do
		get_env "${id}"
		printf "[%s] %-40s %s@%s:%s/%s\n" "${id}" "${db:0:40}" \
			"${POSTGRESQL_ADDON_USER}" "$POSTGRESQL_ADDON_HOST" \
			"$POSTGRESQL_ADDON_PORT" "$POSTGRESQL_ADDON_DB"
		execute \
			"PGPASSWORD=${POSTGRESQL_ADDON_PASSWORD} \
			 pg_dump -h ${POSTGRESQL_ADDON_HOST} \
				 -p ${POSTGRESQL_ADDON_PORT} \
				 -U ${POSTGRESQL_ADDON_USER} \
				 -d ${POSTGRESQL_ADDON_DB}" \
			> "${OUTPUT_DIR}/dump_${db}_${id}.sql" \
			&& echo "saved into ${OUTPUT_DIR}/dump_${db}_${id}.sql"
	done;
fi

if $EXEC_EXECUTE; then
	get_env "${EXEC_ID}"
	execute \
		"PGPASSWORD=${POSTGRESQL_ADDON_PASSWORD} \
		    psql -h ${POSTGRESQL_ADDON_HOST} \
			 -p ${POSTGRESQL_ADDON_PORT} \
			 -U ${POSTGRESQL_ADDON_USER} \
			 -d ${POSTGRESQL_ADDON_DB} \
			 -t -A \
			 -c '${EXEC_CMD};'"
fi

