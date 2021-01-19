#!/bin/sh
set -e

echo "[Entrypoint] Tibero Docker Image ..." # TODO: label version

# _get_config() {
# 	local conf="$1"; shift
# 	"$@" --verbose --help 2>/dev/null | grep "^$conf" | awk '$1 == "'"$conf"'" { print $2; exit }'
# }

# PREBOOT:  Configure tibero.tip after it's initialized
if [ ! -f "$TB_CONFIG/tibero.tip" ]; then
	echo "[Entrypoint] Executing TB_CONFIG/gen_tip.sh"
	$TB_CONFIG/gen_tip.sh
fi

if [ ! -z "$TB_MAX_SESSION_COUNT" ]; then
	sed -i "/MAX_SESSION_COUNT/d" $TB_CONFIG/tibero.tip
	echo "MAX_SESSION_COUNT=$TB_MAX_SESSION_COUNT" >> $TB_CONFIG/tibero.tip
	echo "[Entrypoint] MAX_SESSION_COUNT set to $TB_MAX_SESSION_COUNT" 
fi

if [ ! -z "$TB_MEMORY_TARGET" ]; then
	sed -i "/MEMORY_TARGET/d" $TB_CONFIG/tibero.tip
	echo "MEMORY_TARGET=$TB_MEMORY_TARGET" >> $TB_CONFIG/tibero.tip
	echo "[Entrypoint] MEMORY_TARGET set to $TB_MEMORY_TARGET"
fi

if [ ! -z "$TB_TOTAL_SHM_SIZE" ]; then
	sed -i "/TOTAL_SHM_SIZE/d" $TB_CONFIG/tibero.tip
	echo "TOTAL_SHM_SIZE=$TB_TOTAL_SHM_SIZE" >> $TB_CONFIG/tibero.tip
	echo "[Entrypoint] TOTAL_SHM_SIZE set to $TB_TOTAL_SHM_SIZE"
fi

# PREBOOT:  Examining tibero's hostname and license.xml file
if [ $(hostname) != 'dummy' ]; then
	echo "[Entrypoint] hostname mismatch." 
	echo "[Entrypoint] <INFO> Current Hostname : $(hostname) "
	echo "[Entrypoint] <INFO> Hostname Required : $TB_HOSTNAME"

	if [ "$(ls -A /opt/tibero/license/)" ]; then
		TB_NEW_LICENSE_PATH=/opt/tibero/license
		echo "[Entrypoint] New license found in $TB_NEW_LICENSE_PATH! Examining license status ..."  	
		TB_HOSTNAME_TMP=$(cat $TB_NEW_LICENSE_PATH/license.xml | grep -oP '(?<=<licensee>).*?(?=</licensee>)')
		echo "[Entrypoint] <INFO> license.xml - hostname recorded : $TB_HOSTNAME_TMP" 
		
		if [ $(hostname) != $TB_HOSTNAME_TMP ]; then
			echo "[Entrypoint] <ERROR:301> invalid hostname: hostname mismatch."
			echo ""
			echo "[Entrypoint] <TIP> Do either of the followings."
			echo "[Entrypoint] - correct the hostname."
			echo "[Entrypoint] - correct the license.xml."
			exit 0
		fi

		TB_TYPE=$(cat $TB_NEW_LICENSE_PATH/license.xml | grep -oP '(?<=<type>).*?(?=</type>)')
		echo "[Entrypoint] <INFO> license.xml - type : $TB_TYPE"

		TB_DATE_ISSUED=$(cat $TB_NEW_LICENSE_PATH/license.xml | grep -oP '(?<=<issue_date>).*?(?=</issue_date>)')
		echo "[Entrypoint] <INFO> license.xml - issued date : $TB_DATE_ISSUED" 

		TB_DEMO_DUR=$(cat $TB_NEW_LICENSE_PATH/license.xml | grep -oP '(?<=<demo_duration>).*?(?=</demo_duration>)')
		TB_DATE_EXP=$(date -d "$TB_DATE_ISSUED + $TB_DEMO_DUR days" +%Y/%m/%d)
		echo "[Entrypoint] <INFO> license.xml - expiration date : $TB_DATE_EXP"

		echo "[Entrypoint] Proceed to replace license.xml file ..."
		cp $TB_NEW_LICENSE_PATH/license.xml $TB_HOME/license/license.xml
	else
		echo "[Entrypoint] <ERROR:302> invalid hostname: no license found."
		echo ""
			echo "[Entrypoint] <TIP> Do either of the followings."
			echo "[Entrypoint] - correct the hostname."
			echo "[Entrypoint] - correct the license.xml."
		exit 0
	fi
else
	echo "[Entrypoint] hostname match !!! staying with the old license." 
	echo "[Entrypoint] <INFo> Current Hostname : $(hostname) "	
fi


# Configure Tibero database
if [ "$(ls -A $TB_HOME/database)" ]; then
	echo "[Entrypoint] Database found... skip the process"
	tbboot 
else 
	echo '[Entrypoint] Initializing database with TB_HOME/bin/tb_create_db.sh (for the first time)'
	$TB_HOME/bin/tb_create_db.sh
fi

# POSTBOOT: execute tbimport if any
if [ "$(ls -A /opt/tibero/dump)" ]; then
	echo "[Entrypoint] Dump file found! tbimport has started ... "
	for f in /opt/tibero/dump/*; do
		case "$f" in
			# *.dat)  echo "[Entrypoint] importing $f"; tbimport "$f" ;;
			*)     echo "[Entrypoint] ignoring $f"; # ;
		esac
		echo
	done
fi

echo ''
echo '[Entrypoint] Tibero SQL init process done. Ready for start up.'
echo ''

echo "[Entrypoint] Starting Tibero SQL Database ..."
exec "$@";
