<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="dt_widget_day.select_day_info">      
<querytext>
select   to_char(to_date(:current_date, 'yyyy-mm-dd')-1, 'yyyy-mm-dd')
as yesterday,
to_char(to_date(:current_date, 'yyyy-mm-dd')+1, 'yyyy-mm-dd')
as tomorrow
from     dual
</querytext>
</fullquery>

 
</queryset>
