<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="dt_get_info_from_db.dt_get_information">      
      <querytext>
      
	select to_char(to_date(:the_date,'yyyy-mm-dd'),'J') as julian_date_today,
               to_char(trunc(to_date(:the_date, 'yyyy-mm-dd'), 'Month'), 'fmMonth') as month, 
               to_char(trunc(to_date(:the_date, 'yyyy-mm-dd'), 'Month'), 'YYYY') as year, 
               to_char(trunc(to_date(:the_date, 'yyyy-mm-dd'), 'Month'), 'J') as first_julian_date_of_month, 
               to_char(last_day(to_date(:the_date, 'yyyy-mm-dd')), 'DD') as num_days_in_month,
               to_char(trunc(to_date(:the_date, 'yyyy-mm-dd'), 'Month'), 'D') as first_day_of_month, 
               to_char(last_day(to_date(:the_date, 'yyyy-mm-dd')), 'DD') as last_day,
               trunc(add_months(to_date(:the_date, 'yyyy-mm-dd'), 1)) as next_month,
               trunc(add_months(to_date(:the_date, 'yyyy-mm-dd'), -1)) as prev_month,
               trunc(to_date(:the_date, 'yyyy-mm-dd'), 'yyyy') as beginning_of_year,
               to_char(last_day(add_months(to_date(:the_date, 'yyyy-mm-dd'), -1)), 'DD') as days_in_last_month,
               to_char(add_months(to_date(:the_date, 'yyyy-mm-dd'), 1), 'fmMonth') as next_month_name,
               to_char(add_months(to_date(:the_date, 'yyyy-mm-dd'), -1), 'fmMonth') as prev_month_name
	from   dual
    
      </querytext>
</fullquery>

 
</queryset>
