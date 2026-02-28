#!/bin/bash

BACKUP_DIR=/up
OS_EXCLUDE="{'/dev/*','/content/media','/lost+found','/media','/mnt/*','/proc/*','/run/*','/sys/*','/tmp/*','/var/tmp/*','/var/log/*','/var/lib/lxc*','/var/lib/incus'}"

function clean_old(){
	find ${1} -mindepth 0 -maxdepth 2 -mtime +${2} -exec rm -rf {} \;
}

function rsync_os(){
	# Config
	LOG=${1}/rsync.log
	AP="" && [ $(date +%w) -eq 0 ] && AP="_week"
	DEST=${1}/$(echo ${1}|awk -v FS="/" '{print $NF}')${AP}_$(date +"%Y%m%d_%H%M%S") 
	LATEST=${1}/latest

	# Execute
	mkdir -p ${DEST} || exit 1
	[ ! -L ${LATEST} ] && ln -s ${DEST} ${LATEST}
	echo -e $(date +"%Y-%m-%d %H:%M:%S") "Info:" "Begin rsync " \"$(uname -nr)\" "to \"${DEST}\"" >> ${LOG}
	# "*" may cause error, use "bash -c" is safe
 	bash -c "rsync -aP --delete --relative --link-dest=${LATEST} --exclude=${BACKUP_DIR} --exclude=${OS_EXCLUDE} / ${DEST}"
	echo $DEST
	rm ${LATEST} && ln -s ${DEST} ${LATEST}
	echo -e $(date +"%Y-%m-%d %H:%M:%S") "Info:" "End rsync " \"$(uname -nr)\" "to \"${DEST}\"" >> ${LOG}

}

function main(){
	MAIN_DIR=$BACKUP_DIR/$1/$HOSTNAME
	[[ $1 == "cold" || $1 == "hot" ]] && rsync_os $MAIN_DIR && clean_old $MAIN_DIR 90
	sync
}

main $1
