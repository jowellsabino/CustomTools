#! /usr/bin/ksh
########################################################################################################
# This script moves print logs from every node in the domain to the BCH sftp server.
# Shamelessly copied code chunks from the work by Curtis and Vijai on dscrnftp_runner.ksh
# Author: Jowell Sabino 
# Date: 10/23/2018
########################################################################################################

### SETUP VARS ###
##################
SOURCE_DIR=${cer_print}
SOURCE_FILE_PART="printfile.log"
DEST_DIR=${cer_temp}
DEST_FILE_PART=${SOURCE_FILE_PART}

SSH_SERVER="cisftpprd.tch.harvard.edu"
SSH_DEST_DIR="/Archive"
SSH_USER="dscrnftp"
#SSH_USER="cisftp"

log_file=$cust_reports/log/dscrnftp_printlogs.log

YESTERDAY=$(date -d "1 day ago" '+%m%d')
TODAY=$(date '+%Y%m%d%H%M%S')
PROG=$0
cerner_user="d_${environment}"
currnode=$(hostname | cut -d"." -f1)

set -A prod_nodes_array chldmaapp1 chldmaapp2 chldmaapp3

##########
## MAIN ##
##########

# Keep last 500 lines of $log_file
TMP=$(tail -n 500 $log_file 2>/dev/null) && echo "${TMP}" > ${log_file}
echo >> ${log_file}


echo "${TODAY} - Running ${PROG}..." >> ${log_file}
echo >> ${log_file}

errcopy="0"
errsftp="0"

{
# Get files from the app nodes, then move to sftp server
for node in "${prod_nodes_array[@]}"
do

   # Get only  print logs from yesterday, then format to make node copies unique.
   source_file=${SOURCE_FILE_PART}.${YESTERDAY}
   dest_file=${DEST_FILE_PART}.${YESTERDAY}.${node}_${environment}

   echo "Copying ${node}:${SOURCE_DIR}/${source_file} to ${currnode}:${DEST_DIR}/${dest_file}." >> ${log_file}
   echo >> ${log_file}
   if [[ ${node} != ${currnode} ]]
   then 

       /usr/bin/scp -p ${cerner_user}@${node}:${SOURCE_DIR}/${source_file} ${DEST_DIR}/${dest_file}

   else

       cp ${SOURCE_DIR}/${source_file} ${DEST_DIR}/${dest_file}

   fi
   errcopy=$?
		 
   #Check return status code. 0 means success aka node had files and copied them. 
   if [ ${errcopy} -eq "0" ]; 
   then 

       echo "File ${node}:${SOURCE_DIR}/${source_file} copied to ${currnode}:${DEST_DIR}/${dest_file}." >> ${log_file}  

       echo "Transfer: ${DEST_DIR}/${dest_file} to ${SSH_USER}@${SSH_SERVER}:${SSH_DEST_DIR}/${dest_file}-${TODAY}" >> ${log_file}
       echo >> ${log_file}
     
       # Append timestamp to make it RV-consumable
       /usr/bin/scp -p ${DEST_DIR}/${dest_file} ${SSH_USER}@${SSH_SERVER}:${SSH_DEST_DIR}/${dest_file}-${TODAY}
       errsftp=$?

       if [[ ${errsftp} -eq "0" ]] 
       then

           echo "File ${DEST_DIR}/${dest_file} successfully SCP-ed to server ${SSH_SERVER}, appended timestamp ${TODAY}. Removing from this node." >> ${log_file}
           [[ ! -z "${DEST_DIR}" ]] && rm ${DEST_DIR}/${dest_file}

       else

           echo "Error connecting to: ${SSH_SERVER}. ${DEST_DIR}/${dest_file} not transferred, remains in node filesystem." >> ${log_file}
       fi
       echo >> ${log_file}

   else 

       echo "File ${SOURCE_DIR}/${source_file} doesn't exist on node ${node}."  >> ${log_file}

   fi
   echo >> ${log_file}
   
done


} 2>>${log_file}

exit $((errcopy || errsftp))
