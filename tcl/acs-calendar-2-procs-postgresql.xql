<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="dt_widget_week.select_week_info">      
<querytext>
select   to_char(to_date(:current_date, 'yyyy-mm-dd'), 'D') 
as day_of_the_week,
next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday')
as sunday_of_the_week,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday'),'J') 
as sunday_julian,
next_day(to_date(:current_date, 'yyyy-mm-dd'), 'Saturday')
as saturday_of_the_week
from     dual
</querytext>
</fullquery>

<fullquery name="dt_widget_day.select_day_info">      
<querytext>
select   to_char(to_date(:current_date, 'yyyy-mm-dd'), 'Day, DD Month YYYY') 
as day_of_the_week,
to_char(to_date(:current_date, 'yyyy-mm-dd')-1, 'yyyy-mm-dd')
as yesterday,
to_char(to_date(:current_date, 'yyyy-mm-dd')+1, 'yyyy-mm-dd')
as tomorrow
from     dual
</querytext>
</fullquery>

 
</queryset>
