<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="dt_get_info_from_db.dt_get_information">      
      <querytext>
      
select 	to_char(to_date(:the_date,'yyyy-mm-dd'), 'J') as julian_date_today,
	to_char(to_date(:the_date, 'yyyy-mm-dd'), 'fmMonth') as month,
	to_char(to_date(:the_date, 'yyyy-mm-dd'), 'YYYY') as year, 
	to_char(date_trunc('month', to_date(:the_date, 'yyyy-mm-dd')),  'J') as first_julian_date_of_month, 
	to_char(last_day(to_date(:the_date, 'yyyy-mm-dd')), 'DD') as num_days_in_month,
	to_char(date_trunc('month', to_date(:the_date, 'yyyy-mm-dd')), 'D') as first_day_of_month,
	to_char(last_day(to_date(:the_date, 'yyyy-mm-dd')), 'DD') as last_day,
	to_char(to_date(:the_date, 'yyyy-mm-dd') + '1 month'::interval, 'yyyy-mm-dd')  as next_month,
	to_char(to_date(:the_date, 'yyyy-mm-dd') - '1 month'::interval, 'yyyy-mm-dd')  as prev_month,
	to_char(date_trunc('year', to_date(:the_date, 'yyyy-mm-dd')), 'yyyy-mm-dd') as beginning_of_year, 
	to_char(last_day(to_date(:the_date, 'yyyy-mm-dd') - '1 month'::interval), 'DD') as days_in_last_month,
	to_char(to_date(:the_date, 'yyyy-mm-dd') + '1 month'::interval, 'fmMonth') as next_month_name,
	to_char(to_date(:the_date, 'yyyy-mm-dd') - '1 month'::interval, 'fmMonth') as prev_month_name;

      </querytext>
</fullquery>

</queryset>
