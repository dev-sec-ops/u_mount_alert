#!/bin/bash

	insert_into_mount="$(df -h | sed 1d | awk '{print $6,$3,$2}' > ~/omounts.tmp )"
	echo "${insert_into_mount}"
	added_changes_display="$(diff -u <(cat ~/omounts | awk '{print $1}') <(cat ~/omounts.tmp | awk '{print $1}') | grep -e "^\+" | sed 1d | awk '{print substr($1,2)}')"
	added_changes_display_count="$( diff -u <(cat ~/omounts | awk '{print $1}') <(cat ~/omounts.tmp | awk '{print $1}') | grep -e "^\+" | sed 1d | awk '{print substr($1,2)}' | wc -l)"
	a="${added_changes_display_count}"
	
	while [ ${a} -gt  0 ]
		do
			mount_details="$( echo ${added_changes_display} | awk '{print $'${a}'}')"
			mount_detail="$( cat ~/omounts.tmp | grep ${mount_details} )"
			m_p="$( echo ${mount_detail} | awk '{print $1}')"
			used="$( echo ${mount_detail} | awk '{print $2}')"
			total="$( echo ${mount_detail}  | awk '{print $3}')"
			## send mail using sendmail utility ### 
			$( echo "Changes detected on mount point ${m_p} it is newly added mount point with current usage of ${used}B out of allocated ${total}B" | sendmail -t ashish -s "Alerts RE: Mount Points" )		
			## send mail using mailx utility ### 
			$( echo "Changes detected on mount point ${m_p} it is newly added mount point with current usage of ${used}B out of allocated ${total}B" | mail -s "Alerts RE: Mount Points" ashish  )					
			a=$(( a -1  ))
		done
	
	deleted_changes_display="$(diff -u <(cat ~/omounts | awk '{print $1}') <(cat ~/omounts.tmp | awk '{print $1}') | grep -e "^\-" | sed 1d | awk '{print substr($1,2)}')"
	deleted_changes_display_count="$( diff -u <(cat ~/omounts | awk '{print $1}') <(cat ~/omounts.tmp | awk '{print $1}') | grep -e "^\-" | sed 1d | awk '{print substr($1,2)}' | wc -l)"

	d=${deleted_changes_display_count}

	while [ ${d} -gt  0 ]
		do
			mount_details="$( echo ${deleted_changes_display} | awk '{print $'${d}'}')"
			mount_detail="$( cat ~/omounts | grep ${mount_details} )"
			m_p="$( echo ${mount_detail} | awk '{print $1}')"
			used="$( echo ${mount_detail} | awk '{print $2}')"
			total="$( echo ${mount_detail}  | awk '{print $3}')"
			## send mail using sendmail utility ###
			$( echo "Changes detected on mount point ${m_p}, it was mounted earlier with usage of ${used}B and total allocated space of ${total}B however it is not mounted now." | sendmail -t "Alert RE: Mount Points" ashish )	
			## send mail using mailx utility ###
			$( echo "Changes detected on mount point ${m_p}, it was mounted earlier with usage of ${used}B and total allocated space of ${total}B however it is not mounted now." | mail -s "Alert RE: Mount Points" ashish )
			d=$(( d -1  ))
		done
		
	cat ~/omounts.tmp > ~/omounts
