
ad_proc dt_widget_week { 
    {
	-calendar_details "" 
	-date "" 
	-days_of_week "Sunday Monday Tuesday Wednesday Thursday Friday Saturday" 
	-large_calendar_p 1 
	-master_bgcolor "black" 
	-header_bgcolor "black" 
	-header_text_color "white" 
	-header_text_size "+2" 
	-day_template {<!--$julian-->$day} 
	-day_header_size 2 
	-day_header_bgcolor "#666666" 
	-calendar_width "100%" 
	-day_bgcolor "#DDDDDD" 
	-today_bgcolor "#DDDDDD" 
	-day_text_color "white" 
	-empty_bgcolor "white"  
	-next_week_template ""   
	-prev_week_template "" 
	-prev_next_links_in_title 0 
	-fill_all_days 0 
    }
} {
    Returns a calendar for a specific week, with details supplied by
    Julian date. Defaults to this week. 

    To specify details for the individual days (if large_calendar_p is
    set) put data in an ns_set calendar_details.  The key is the
    Julian date of the day, and the value is a string (possibly with
    HTML formatting) that represents the details. 
} {

    if {[empty_string_p $date]} {
        set date [dt_sysdate]
    }

    set current_date $date

    # Get information for the week
    db_1row select_week_info {}
    
    # Initialize the ns_set
    if [empty_string_p $calendar_details] {
	set calendar_details [ns_set create calendar_details]
    }

    # Loop through the days of the week
    set julian $sunday_julian
    set return_html "<table cellpadding=2 border=1 width=$calendar_width>\n"

    foreach day $days_of_week {

        set day_html [subst $day_template]

        append return_html "<tr bgcolor=#cccccc><td>$day_html</td></tr>
        <tr><td>&nbsp;"
        
        # Go through events
        while {1} {
            set index [ns_set find $calendar_details $julian]
            if {$index == -1} {
                break
            }

            append return_html "[ns_set value $calendar_details $index]<br>\n"

            ns_set delete $calendar_details $index
        }

        append return_html "</td></tr>\n"
        incr julian
    }

    append return_html "</table>"
    
    return $return_html
}



ad_proc dt_widget_day { 
    {
	-calendar_details "" 
	-date "" 
	-hours_of_day {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23}
	-master_bgcolor "black" 
	-header_bgcolor "black" 
	-header_text_color "white" 
	-header_text_size "+2" 
	-calendar_width "100%" 
	-day_bgcolor "#DDDDDD" 
	-today_bgcolor "#DDDDDD" 
	-day_text_color "white" 
	-empty_bgcolor "white"  
    }
} {
    Returns a calendar for a specific day, with details supplied by
    hour. Defaults to today.

} {

    if {[empty_string_p $date]} {
        set date [dt_sysdate]
    }

    set current_date $date

    # Initialize the ns_set
    if [empty_string_p $calendar_details] {
	set calendar_details [ns_set create calendar_details]
    }

    # Loop through the hours of the day
    set return_html "<table cellpadding=2 border=1 width=$calendar_width>\n"

    foreach hour $hours_of_day {

        # display stuff
        if {$hour >= 12} {
            set ampm_hour [expr $hour - 12]
            set pm 1
        } else {
            set ampm_hour $hour
            set pm 0
        }

        if {$ampm_hour == 0} {
            set ampm_hour 12
        }

        if {$ampm_hour < 10} {
            set display_hour "0$ampm_hour"
        } else {
            set display_hour "$ampm_hour"
        }

        append display_hour ":00 "

        if {$pm} {
            append display_hour "pm"
        } else {
            append display_hour "am"
        }

        append return_html "<tr bgcolor=#cccccc><td>$display_hour</td><td>\n"
        
        # Go through events
        while {1} {
            set index [ns_set find $calendar_details $hour]
            if {$index == -1} {
                break
            }

            append return_html "[ns_set value $calendar_details $index]<br>\n"

            ns_set delete $calendar_details $index
        }

        append return_html "</td></tr>\n"
    }

    append return_html "</table>"
    
    return $return_html
}
