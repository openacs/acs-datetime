<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="dt_widget_week.select_week_info">      
<querytext>
select   to_char(to_date(:current_date, 'yyyy-mm-dd'), 'D') 
as day_of_the_week,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday')) 
as sunday_of_the_week,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd')-7, 'Sunday'),'J') 
as sunday_julian,
to_char(next_day(to_date(:current_date, 'yyyy-mm-dd'), 'Saturday')) 
as saturday_of_the_week
from     dual
</querytext>
</fullquery>

 
</queryset>
