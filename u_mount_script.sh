#!/bin/bash

	###  About File Original Mounts :--> omounts
	###  A file named omounts should be created in the directory ~/omounts
	###  Have created the omounts file in ~/ directory
	###  This File stores the mount points info :--> mount point,space used,total space
	###  This File is Auto updated in the END of the Script
	###  So that after sending the Mail regarding mount point Chnages(Addded or Removed)
  	###  This file is also updated so that then
	###  Alert is not send twice or more than onces


	###----------START HERE---------



	###  Insering Realtime Data inserted in a temp file
	###  Inserting mount point,space used,total space into a temporary file --> omounts.tmp
	###  This file is located inside /root/practise directory
	###  Have used df command to store all the CURRENT mount points info

	insert_into_mount="$(df -h | sed 1d | awk '{print $6,$3,$2}' > ~/omounts.tmp )"
	echo "${insert_into_mount}"

	##Realtime Data inserted in a temp file.... is done

	###  If New mount point is added Then the 
	###  No of mount point added i.e count 
	###  and the
	###  Mount point is stored in the below variables
	###  added_changes_display ---> Stores the ADDED Mount Point details 
	###  added_changes_display_count ---> Stores the No of ADDED Mount Points


	
	###  Have calculated the difference of both the moount points
	###
	###  i.e All the mount points that previously exists in the system AND the New one's that were Calculated when the above command executes.
	###


	###  This <(cat ~/omounts | awk {print 1}) will extract the First Word of the File --> omounts
	###  As the omounts file contains 3 Space Seperated values --> mount point,space used,total space
	###  It will match the First Word of both the files omounts and omounts.tmp to check for changes


	###  This Variabe added_changes_display will only store 
	###  The ADDED mount point values
	###  
	
	added_changes_display="$(diff -u <(cat ~/omounts | awk '{print $1}') <(cat ~/omounts.tmp | awk '{print $1}') | grep -e "^\+" | sed 1d | awk '{print substr($1,2)}')"

	
	###  This Variabe added_changes_display_count will only store 
	###  The ADDED mount point COunt i.e the No of mount point added 
  
	added_changes_display_count="$( diff -u <(cat ~/omounts | awk '{print $1}') <(cat ~/omounts.tmp | awk '{print $1}') | grep -e "^\+" | sed 1d | awk '{print substr($1,2)}' | wc -l)"

	#if [[ added_changes_display_count -gt   ]]; then
	#statement

	
	###  echo Few mount points are added to the system. The Count is :-  ${added_changes_display_count}
	###  echo ...................added_changes_display....................
	###  echo added details with usage:-
	###  Storing added_changes_display_count variable value in a for Processing

	a="${added_changes_display_count}"

	###  Getting the details of All the Mpunt Points that were ADDED to the Linux System

	while [ ${a} -gt  0 ]

		do
					#----send single data in a mail

					#echo added_mount_display value :--> added_changes_display  

					### Getting the Single ADDED Mount Point from all the ADDED Mount points
					
					mount_details="$( echo ${added_changes_display} | awk '{print $'${a}'}')"

					###  Since the Mount point is Newly ADDED it will be Present in the omounts.tmp file
					###  Which is updated with mount point info 
					###  Every time this Script runs
					###  That Mount point is Searched in the omounts.tmp
					###  And the Details with respect to that mount point is Obtained
					
					mount_detail="$( cat ~/omounts.tmp | grep ${mount_details} )"

					###  echo mount details at line ${a} is : ${mount_detail}

					m_p="$( echo ${mount_detail} | awk '{print $1}')"
					used="$( echo ${mount_detail} | awk '{print $2}')"
					total="$( echo ${mount_detail}  | awk '{print $3}')"

					$( echo "Changes detected on mount point ${m_p} it is newly added mount point with current usage of ${used}B out of allocated ${total}B" | sendmail -t ashish -s "Alerts RE: Mount Points" )
					
					$( echo "Changes detected on mount point ${m_p} it is newly added mount point with current usage of ${used}B out of allocated ${total}B" | mail -s "Alerts RE: Mount Points" ashish  )

					###  Now we have the data of the Newly ADDED Mount point  
					###  Which can be send on the Mail as an ALERT
					
					###  echo "Check  this mount point ${m_p} with usage ${used} out of ${total} was recently added.   "

					a=$(( a -1  ))

		done
		#while loop closes here

#-----------------old mount points removed from the system ------------------

		###  If a previously mounted, mount point is REMOVED from the Linux system
		###  Then the 
		###  No of mount point Removed i.e count 
		###  and the
		###  Mount point is stored in the below variables
		###  deleted_changes_display ---> Stores the DELETED Mount Point Details
		###  deleted_changes_display_count ---> Stores the No of DELETED Mount Points



		###  Have calculated the difference of both the moount points
		###
		###  i.e All the mount points that previously exists in the system AND the New one's that were Calculated when the above command executes.
		###


		###  This <(cat ~/omounts | awk '{print $1}') will extract the First Word of the File --> omounts
		###  As the omounts file contains 3 Space Seperated values --> mount point,space used,total space
		###  It will match the First Word of both the files "omounts" and "omounts.tmp" to check for changes

		
deleted_changes_display="$(diff -u <(cat ~/omounts | awk '{print $1}') <(cat ~/omounts.tmp | awk '{print $1}') | grep -e "^\-" | sed 1d | awk '{print substr($1,2)}')"

deleted_changes_display_count="$( diff -u <(cat ~/omounts | awk '{print $1}') <(cat ~/omounts.tmp | awk '{print $1}') | grep -e "^\-" | sed 1d | awk '{print substr($1,2)}' | wc -l)"

###  echo Few mount points are removed from the system. The Count is :-  ${deleted_changes_display_count}

###  echo Details are listed :
###  ********************************
###  deleted_changes_display
###  ********************************

###  -----------custoemize

###  Storing deleted_changes_display_count variable value in d for Processing

d=${deleted_changes_display_count}

###  Getting the details of All the Mpunt Points that were REMOVED from the Linux System

	while [ ${d} -gt  0 ]
		do

			#----send single data in mail

			mount_details="$( echo ${deleted_changes_display} | awk '{print $'${d}'}')"


			mount_detail="$( cat ~/omounts | grep ${mount_details} )"

			m_p="$( echo ${mount_detail} | awk '{print $1}')"
			used="$( echo ${mount_detail} | awk '{print $2}')"
			total="$( echo ${mount_detail}  | awk '{print $3}')"
			
			###  Using sendmail
			$( echo "Changes detected on mount point ${m_p}, it was mounted earlier with usage of ${used}B and total allocated space of ${total}B however it is not mounted now." | sendmail -t "Alert RE: Mount Points" ashish )	
			
			###  Using mail 
			$( echo "Changes detected on mount point ${m_p}, it was mounted earlier with usage of ${used}B and total allocated space of ${total}B however it is not mounted now." | mail -s "Alert RE: Mount Points" ashish )
			d=$(( d -1  ))

		done


###  Updating the omounts file
###  So that the Alert is not Genetrated Again
###  And 
### Also the Space Details that are Calculated when this Script is Executed


cat ~/omounts.tmp > ~/omounts

 ###  echo .....................

### -----------ENDS HERE-----------------------
