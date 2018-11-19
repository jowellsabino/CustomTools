select 
   --pr.NAME_FULL_FORMATTED as Ordering_Provider
   --  ,
	 cvms.display as  MEDSERVICE
	 , (case
	   when dtfs.prsnl_group_id is not null
	   then 'Yes'
	   else 'No'
	   end) as SERVICE_POOL_EXISTS
     , cvlnu.display as LOCATION 
	 , (case
	   when dtfl.prsnl_group_id is not null
	   then 'Yes'
	   else 'No'
	   end) as LOCATION_POOL_EXISTS
	 , count(*) as Order_Count
	 ,(case
	   when dtfs.prsnl_group_id is not null 
	        or 
			dtfl.prsnl_group_id is not null
	   then 'Yes'
	   else 'No'
	   end) as DTF_POOL_ROUTABLE
	 , max(o.ORIG_ORDER_DT_TM) as Last_Order_Entered_On
from orders o
join person p
     on p.PERSON_ID = o.PERSON_ID
	and not (p.NAME_LAST_KEY like 'SYSTEM%'
		 or 
		 p.NAME_LAST_KEY like 'TEST%'
		 or 
		 p.NAME_LAST_KEY like 'SYTEM%')
join order_action oa
     on oa.order_id = o.order_id
--join prsnl pr
--     on pr.person_id = oa.order_provider_id
--    and pr.name_last_key = 'NONSPECIFIED'
--    and pr.name_first_key = 'LAB'
join encounter e
     on e.encntr_id = o.encntr_id
	/* Hack since Netezza table not updated to reflect CR 4480 */
	and e.MED_SERVICE_CD != 407241133.00
left join code_value cvlnu
     on cvlnu.code_value = e.loc_nurse_unit_cd
   and cvlnu.code_set = 220
   and cvlnu.active_ind = 1
left join ads_v500_cust_stage..x_chb_dtf_location dtfl
     on dtfl.location_cd = e.LOC_NURSE_UNIT_CD
	 and dtfl.active_ind = 1
left join code_value cvms
     on cvms.code_value = e.med_service_cd
    and cvms.code_set = 34
    and cvms.active_ind = 1
left join ads_v500_cust_stage..x_chb_dtf_service dtfs
     on dtfs.service_resource_cd = e.MED_SERVICE_CD
	and dtfs.active_ind = 1
where o.orig_order_dt_tm > now() - 30
group by MEDSERVICE, SERVICE_POOL_EXISTS, LOCATION, LOCATION_POOL_EXISTS, DTF_POOL_ROUTABLE
having DTF_POOL_ROUTABLE = 'No'
order by Order_Count desc,MEDSERVICE,LOCATION
--group by Ordering_Provider,MEDSERVICE, SERVICE_POOL_EXISTS, LOCATION, LOCATION_POOL_EXISTS, DTF_ROUTABLE
--order by Order_Count desc,Ordering_Provider,MEDSERVICE,LOCATION
--group by Ordering_Provider,LOCATION
--order by Order_Count desc,Ordering_Provider,LOCATION
;


/* Non-specified ordering provider only*/
select 
   pr.NAME_FULL_FORMATTED as Ordering_Provider
     , cvms.display as  MEDSERVICE
	 , (case
	   when dtfs.prsnl_group_id is not null
	   then 'Yes'
	   else 'No'
	   end) as SERVICE_POOL_EXISTS
     , cvlnu.display as LOCATION 
	 , (case
	   when dtfl.prsnl_group_id is not null
	   then 'Yes'
	   else 'No'
	   end) as LOCATION_POOL_EXISTS
	 , count(*) as Order_Count
	 ,(case
	   when dtfs.prsnl_group_id is not null 
	        or 
			dtfl.prsnl_group_id is not null
	   then 'Yes'
	   else 'No'
	   end) as DTF_POOL_ROUTABLE
	 , max(o.ORIG_ORDER_DT_TM) as Last_Order_Entered_On
from orders o
join person p
     on p.PERSON_ID = o.PERSON_ID
	and not (p.NAME_LAST_KEY like 'SYSTEM%'
		 or 
		 p.NAME_LAST_KEY like 'TEST%'
		 or 
		 p.NAME_LAST_KEY like 'SYTEM%')
join order_action oa
     on oa.order_id = o.order_id
join prsnl pr
     on pr.person_id = oa.order_provider_id
    and pr.name_last_key = 'NONSPECIFIED'
    and pr.name_first_key = 'LAB'
join encounter e
     on e.encntr_id = o.encntr_id
	/* Hack since Netezza table not updated to reflect CR 4480 */
	and e.MED_SERVICE_CD != 407241133.00
left join code_value cvlnu
     on cvlnu.code_value = e.loc_nurse_unit_cd
   and cvlnu.code_set = 220
   and cvlnu.active_ind = 1
left join ads_v500_cust_stage..x_chb_dtf_location dtfl
     on dtfl.location_cd = e.LOC_NURSE_UNIT_CD
	 and dtfl.active_ind = 1
left join code_value cvms
     on cvms.code_value = e.med_service_cd
    and cvms.code_set = 34
    and cvms.active_ind = 1
left join ads_v500_cust_stage..x_chb_dtf_service dtfs
     on dtfs.service_resource_cd = e.MED_SERVICE_CD
	and dtfs.active_ind = 1
where o.orig_order_dt_tm > now() - 30
group by Ordering_Provider,MEDSERVICE, SERVICE_POOL_EXISTS, LOCATION, LOCATION_POOL_EXISTS, DTF_POOL_ROUTABLE
--having DTF_POOL_ROUTABLE = 'No'
order by Order_Count desc,Ordering_Provider,MEDSERVICE,LOCATION
;
 
