select pg.prsnl_group_name
     , pr.name_full_formatted as TEAM_LEAD
     , pgr.updt_dt_tm as LAST_UPDATED
     , cvpos.display as POSITION_User
     , (case 
	     when pr.active_ind = 1
              and
              pr.end_effective_dt_tm > now()
              and 
			  pr.username != ''
              and 
			  pr.position_cd > 0.0
          then 'Yes'
          else 'No'
          end) as USER_ABLE_TO_LOGIN
from prsnl_group_reltn pgr
    -- we do not include active_ind = 1 and end_eff_dt_tm > sysdate
    -- sine some team leaders we want to eliminate are not employees anymore
join prsnl pr
     on pr.person_id = pgr.person_id
left join code_value cvpos
     on cvpos.code_value = pr.POSITION_CD 
   and cvpos.code_set = 88
   and cvpos.active_ind = 1
join prsnl_group pg
     on pg.prsnl_group_id = pgr.prsnl_group_id
    and pg.active_ind = 1 
where pgr.primary_ind = 1
  and pgr.active_ind = 1
order by pg.prsnl_group_name
;
