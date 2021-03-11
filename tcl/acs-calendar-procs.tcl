# /packages/acs-datetime/tcl/acs-calendar-procs.tcl

ad_library {

    Library for calendar display widgets

    @author  ron@arsdigita.com
    @creation-date 2000-11-21
    @cvs-id  $Id$
}

ad_proc dt_widget_month {
    {-calendar_details ""}
    {-date ""}
    {-days_of_week ""}
    {-large_calendar_p 1}
    {-master_bgcolor "black"}
    {-header_bgcolor "black"}
    {-header_text_color "white"}
    {-header_text_size "+2"}
    {-day_number_template {<!--$julian_date-->$day_number}}
    {-day_header_size 2}
    {-day_header_bgcolor "#666666"}
    {-calendar_width "100%"}
    {-day_bgcolor "#DDDDDD"}
    {-today_bgcolor "#DDDDDD"}
    {-day_text_color "white"}
    {-empty_bgcolor "white"}
    {-next_month_template ""}
    {-prev_month_template ""}
    {-prev_next_links_in_title 0}
    {-fill_all_days 0}
    {-show_calendar_name_p 1}
} {
    @return a calendar for a specific month, with details supplied by
            Julian date. Defaults to this month.

    To specify details for the individual days (if large_calendar_p is
    set) put data in an ns_set calendar_details.  The key is the
    Julian date of the day, and the value is a string (possibly with
    HTML formatting) that represents the details.
} {
    if {$days_of_week eq ""} {
        set days_of_week "[_ acs-datetime.days_of_week]"
    }

    dt_get_info $date

    set today_date [dt_sysdate]

    if {$calendar_details eq ""} {
        set calendar_details [ns_set create calendar_details]
    }

    set day_of_week $first_day_of_month
    set julian_date $first_julian_date

    set month_heading [format "%s %s" $month $year]
    set next_month_url ""
    set prev_month_url ""

    if {$prev_month_template ne ""} {
        set ansi_date      [ns_urlencode $prev_month]
        set prev_month_url [subst $prev_month_template]
    }

    if {$next_month_template ne ""} {
        set ansi_date      [ns_urlencode $next_month]
        set next_month_url [subst $next_month_template]
    }

    # We offer an option to put the links to next and previous months
    # in the title bar

    if { $prev_next_links_in_title == 0 } {
        set title [subst {
            <td colspan="7" align="center">
            <span style="font-size:$header_text_size; color:$header_text_color; background:inherit; font-weight:bold">
            $month_heading
            </span>
            </td>\n}]
    } else {
        set title [subst {
            <td class="no-border" colspan="7">
            <table width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr class="table-header">
            <td align="left">$prev_month_url</td>
            <td align="center">
            <span style="font-size:$header_text_size; color:$header_text_color; background:inherit; font-weight:bold">
            $month_heading
            </span>
            </td>
            <td align="right">$next_month_url</td>
            </tr>
            </table>
            </td>\n}]
    }

    # Write out the header and the days of the week

    append output [subst {
        <table class="table-display" style="background:$master_bgcolor; color:inherit;" cellpadding="0" cellspacing="0" border="1" width="$calendar_width">
        <tr style="background:$header_bgcolor; color:inherit;"> $title </tr>
        <tr style="background:$day_header_bgcolor; color:inherit;" class="table-header">\n}]

    foreach day_of_week $days_of_week {
        append output [subst {
            <td style="width:14%" align=center class="no-border">
            <span style="font-family: Verdana,Arial,Helvetica; font-size:$day_header_size; color:$day_text_color; background:inherit; font-weight:bold;">
            $day_of_week
            </span>
            </td>\n}]
    }

    append output "</tr>\n"

    set day_of_week 1
    set julian_date $first_julian_date
    set day_number $first_day

    set today_ansi_list [dt_ansi_to_list $today_date]
    set today_julian_date [dt_ansi_to_julian [lindex $today_ansi_list 0] [lindex $today_ansi_list 1] [lindex $today_ansi_list 2]]

    while {1} {

        if {$julian_date < $first_julian_date_of_month} {
            set before_month_p 1
            set after_month_p  0
        } elseif {$julian_date > $last_julian_date_in_month} {
            set before_month_p 0
            set after_month_p  1
        } else {
            set before_month_p 0
            set after_month_p  0
        }

        if {$julian_date == $first_julian_date_of_month} {
            set day_number 1
        } elseif {$julian_date > $last_julian_date} {
            break
        } elseif {$julian_date == $last_julian_date_in_month + 1} {
            set day_number 1
        }

        if { $day_of_week == 1} {
            append output "<tr>\n"
        }

        set skip_day 0

        if {$before_month_p || $after_month_p} {
            append output "<td class=\"no-border\" style=\"background:$empty_bgcolor; color:inherit;\" align=right valign=top>&nbsp;"
            if { $fill_all_days == 0 } {
                set skip_day 1
            } else {
                append output [subst $day_number_template] "&nbsp;"
            }
        } else {
            if {$julian_date == $today_julian_date} {
                set the_bgcolor $today_bgcolor
                set the_class "cal-month-today"
            } else {
                set the_bgcolor $day_bgcolor
                set the_class "cal-month-day"
            }

            append output [subst {<td class="$the_class" style="background:$the_bgcolor; color:inherit;" align="left" valign="top">$day_number_template}] "&nbsp;"
        }

        if { !$skip_day && $large_calendar_p == 1 } {
            append output "<div align=left>"

            set calendar_day_index [ns_set find $calendar_details $julian_date]

            while { $calendar_day_index >= 0 } {
                set calendar_day [ns_set value $calendar_details $calendar_day_index]
                ns_set delete $calendar_details $calendar_day_index
                append output "$calendar_day"
                set calendar_day_index [ns_set find $calendar_details $julian_date]
            }
            append output "</div>"
        }

        append output "</td>\n"

        incr day_of_week
        incr julian_date
        incr day_number

        if { $day_of_week > 7 } {
            set day_of_week 1
            append output "</tr>\n"
        }
    }

    # There are two ways to display previous and next month link -
    # this is the default

    if { $prev_next_links_in_title == 0 } {
        append output [subst {
            <tr style="background:white; color:inherit;">
            <td align=center colspan=7>$prev_month_url$next_month_url</td>
            </tr>\n}]
    }

    return [concat $output "</table>\n"]
}

ad_proc dt_widget_month_small {
    {-calendar_details ""}
    {-date ""}
    {-days_of_week ""}
    {-large_calendar_p 0}
    {-master_bgcolor "black"}
    {-header_bgcolor "black"}
    {-header_text_color "white"}
    {-header_text_size "+1"}
    {-day_number_template {<!--$julian_date-->$day_number}}
    {-day_header_size 1}
    {-day_header_bgcolor "#666666"}
    {-calendar_width 0}
    {-day_bgcolor "#DDDDDD"}
    {-day_text_color "white"}
    {-empty_bgcolor "white"}
    {-next_month_template ""}
    {-prev_month_template ""}
} {
    @return a small calendar for a specific month. Defaults to this month.
} {
    if {$days_of_week eq ""} {
        set days_of_week [_ acs-datetime.short_days_of_week]
    }
    return [dt_widget_month \
                -calendar_details $calendar_details \
                -date $date \
                -days_of_week $days_of_week \
                -large_calendar_p $large_calendar_p \
                -master_bgcolor $master_bgcolor \
                -header_bgcolor $header_bgcolor \
                -header_text_color $header_text_color \
                -header_text_size $header_text_size \
                -day_number_template $day_number_template \
                -day_header_size $day_header_size \
                -day_header_bgcolor $day_header_bgcolor \
                -calendar_width $calendar_width \
                -day_bgcolor $day_bgcolor \
                -day_text_color $day_text_color \
                -empty_bgcolor $empty_bgcolor  \
                -next_month_template $next_month_template  \
                -prev_month_template $prev_month_template ]
}

ad_proc dt_widget_month_centered {
    {-calendar_details ""}
    {-date ""}
    {-days_of_week ""}
    {-large_calendar_p 0}
    {-master_bgcolor "black"}
    {-header_bgcolor "black"}
    {-header_text_color "white"}
    {-header_text_size "+1"}
    {-day_number_template {<!--$julian_date-->$day_number}}
    {-day_header_size 1}
    {-day_header_bgcolor "#666666"}
    {-calendar_width 0}
    {-day_bgcolor "#DDDDDD"}
    {-day_text_color "white"}
    {-empty_bgcolor "white"}
    {-next_month_template ""}
    {-prev_month_template ""}
} {
    @return a calendar for a specific month, with details supplied by
            Julian date. Defaults to this month.
} {

    if {$days_of_week eq ""} {
        set days_of_week [_ acs-datetime.short_days_of_week]
    }
    set output ""

    dt_get_info $date

    append output "
    <table>
    <tr valign='top'>
    <td>

    [dt_widget_month_small -calendar_details $calendar_details -date $prev_month -days_of_week $days_of_week -large_calendar_p $large_calendar_p -master_bgcolor $master_bgcolor -header_bgcolor $header_bgcolor -header_text_color $header_text_color -header_text_size $header_text_size -day_number_template $day_number_template -day_header_size $day_header_size -day_header_bgcolor $day_header_bgcolor -calendar_width $calendar_width -day_bgcolor $day_bgcolor -day_text_color $day_text_color -empty_bgcolor $empty_bgcolor  -next_month_template $next_month_template   -prev_month_template $prev_month_template ]</td>

    <td>
    [dt_widget_month_small -calendar_details $calendar_details -date $date -days_of_week $days_of_week -large_calendar_p $large_calendar_p -master_bgcolor $master_bgcolor -header_bgcolor $header_bgcolor -header_text_color $header_text_color -header_text_size $header_text_size -day_number_template $day_number_template -day_header_size $day_header_size -day_header_bgcolor $day_header_bgcolor -calendar_width $calendar_width -day_bgcolor $day_bgcolor -day_text_color $day_text_color -empty_bgcolor $empty_bgcolor  -next_month_template $next_month_template   -prev_month_template $prev_month_template ]
    </td>

    <td>
    [dt_widget_month_small -calendar_details $calendar_details -date $next_month -days_of_week $days_of_week -large_calendar_p $large_calendar_p -master_bgcolor $master_bgcolor -header_bgcolor $header_bgcolor -header_text_color $header_text_color -header_text_size $header_text_size -day_number_template $day_number_template -day_header_size $day_header_size -day_header_bgcolor $day_header_bgcolor -calendar_width $calendar_width -day_bgcolor $day_bgcolor -day_text_color $day_text_color -empty_bgcolor $empty_bgcolor  -next_month_template $next_month_template   -prev_month_template $prev_month_template ]
    </td>
    </tr>
    </table>\n"

    return $output
}

ad_proc dt_widget_year {
    {-calendar_details ""}
    {-date ""}
    {-days_of_week ""}
    {-large_calendar_p 0}
    {-master_bgcolor "black"}
    {-header_bgcolor "black"}
    {-header_text_color "white"}
    {-header_text_size "+1"}
    {-day_number_template {<!--$julian_date-->$day_number}}
    {-day_header_size 1}
    {-day_header_bgcolor "#666666"}
    {-calendar_width 0}
    {-day_bgcolor "#DDDDDD"}
    {-day_text_color "white"}
    {-empty_bgcolor "white"}
    {-next_month_template ""}
    {-prev_month_template ""}
    {-width 2}
} {
    @return a year of small calendars given the starting month as a
            date.  Defaults to this month.  Data in calendar_details will be
            ignored.
} {
    if { $width < 1 || $width > 12 } {
        return "[_ acs-datetime.lt_Width_must_be_]"
    }

    if {$days_of_week eq ""} {
        set days_of_week "[_ acs-datetime.short_days_of_week]"
    }

    set output "<table><tr valign=top>\n"
    set current_width 0

    for { set n 1 } { $n <= 12 } { incr n } {
        dt_get_info $date

        append output "
        <td>
        [dt_widget_month_small -calendar_details $calendar_details -date $date -days_of_week $days_of_week -large_calendar_p $large_calendar_p -master_bgcolor $master_bgcolor -header_bgcolor $header_bgcolor -header_text_color $header_text_color -header_text_size $header_text_size	-day_number_template $day_number_template -day_header_size $day_header_size -day_header_bgcolor $day_header_bgcolor -calendar_width $calendar_width -day_bgcolor $day_bgcolor -day_text_color $day_text_color -empty_bgcolor $empty_bgcolor -next_month_template $next_month_template -prev_month_template $prev_month_template ]
        </td>\n"

        incr current_width

        if { $current_width == $width && $n != 12} {
            set current_width 0
            append output "</tr><tr valign=top>\n"
        }

        set date $next_month
    }

    return [concat $output "</tr></table>\n"]
}

ad_proc dt_widget_calendar_year {
    {-calendar_details ""}
    {-date ""}
    {-days_of_week ""}
    {-large_calendar_p 0}
    {-master_bgcolor "black"}
    {-header_bgcolor "black"}
    {-header_text_color "white"}
    {-header_text_size "+1"}
    {-day_number_template {<!--$julian_date-->$day_number}}
    {-day_header_size 1}
    {-day_header_bgcolor "#666666"}
    {-calendar_width 0}
    {-day_bgcolor "#DDDDDD"}
    {-day_text_color "white"}
    {-empty_bgcolor "white"}
    {-next_month_template ""}
    {-prev_month_template ""}
    {-width 2}
} {
    @return a calendar year of small calendars for the year of the
            passed in date.  Defaults to this year.
} {
    if {$days_of_week eq ""} {
        set days_of_week "[_ acs-datetime.short_days_of_week]"
    }

    dt_get_info $date

    return [dt_widget_year \
                -calendar_details $calendar_details \
                -date $beginning_of_year \
                -days_of_week $days_of_week \
                -large_calendar_p $large_calendar_p \
                -master_bgcolor $master_bgcolor \
                -header_bgcolor $header_bgcolor \
                -header_text_color $header_text_color \
                -header_text_size $header_text_size \
                -day_number_template $day_number_template \
                -day_header_size $day_header_size \
                -day_header_bgcolor $day_header_bgcolor \
                -calendar_width $calendar_width \
                -day_bgcolor $day_bgcolor \
                -day_text_color $day_text_color \
                -empty_bgcolor $empty_bgcolor  \
                -next_month_template $next_month_template \
                -prev_month_template $prev_month_template  \
                -width $width]
}

# A couple of helper procs to return the location of navigation icons.
# These will eventually be replaced with parameters or pushed into a
# template.

ad_proc -private dt_left_arrow {} {
    @return the image location for a left navigation arrow
} {
    return "/resources/acs-subsite/left.gif"
}

ad_proc -private dt_right_arrow {} {
    @return the image location for a right navigation arrow
} {
    return "/resources/acs-subsite/right.gif"
}

ad_proc -private dt_navbar_view {
    view
    base_url
    date
} {
    @return a navbar for the mini_calendar_widget
} {
    set date [ns_urlencode $date]

    # Note: use append so that all of the strings are joined together
    # properly

    append result "
    <tr align=center class=\"table-header\">"

    # ben: taking out year for now, since it doesn't work
    foreach {viewname viewlink viewdesc} [list "list" [_ acs-datetime.List] [_ acs-datetime.view_calendar_day] "day" [_ acs-datetime.Day] [_ acs-datetime.view_calendar_list] "week" [_ acs-datetime.Week] [_ acs-datetime.view_calendar_week] "month" [_ acs-datetime.Month] [_ acs-datetime.view_calendar_month]] {
        set text [string toupper $viewlink 0]
        if { $viewname == $view } {
            # current view
            append result [subst {<td class="selected">
                <span style="font-size: smaller; font-weight: bold">$text</span>
                </td>
            }]
        } else {
            append result [subst {<td class="no-border">
                <a href="[ns_quotehtml ${base_url}view=$viewname&date=$date]" title="$viewdesc">
                <span style="font-size: smaller; font-weight: bold">$text</span></a>
                </td>
            }]
        }
    }

    append result "
    </tr>
    "

    return $result
}

ad_proc -private dt_navbar_year {
    view
    base_url
    date
} {
    If this is a month or year view, returns the current year with
    links to previous and next.  Otherwise it just returns the empty
    string.
} {
    # Return immediately of the current view isn't month or year
    if {$view ni [list month year]} {
        return ""
    }

    # Convert the given data into current calendar time
    set now [clock scan $date]

    # Compute formatted strings for curr, prev, and next

    # Check that links to prev/next year don't lead to illegal dates that would bomb
    if {[catch {set prev_year [clock format [clock scan "1 year ago" -base $now] -format "%Y-%m-%d"]} err]} {
        set prev_year_legal_p 0
    } else {
        if {[catch {clock scan $prev_year}]} {
            set prev_year_legal_p 0
        } else {
            set prev_year_legal_p 1
        }
    }

    if {[catch {set next_year [clock format [clock scan "1 year" -base $now] -format "%Y-%m-%d"]} err]} {
        set next_year_legal_p 0
    } else {
        if {[catch {clock scan $next_year}]} {
            set next_year_legal_p 0
        } else {
            set next_year_legal_p 1
        }
    }

    set curr_year [clock format $now -format "%Y"]

    append result [subst {
    <tr>
    <td nowrap align="center" colspan="5" class="no-border">
    <table cellspacing="0" cellpadding="1" border="0">
    <tr><td nowrap valign="middle">
    }]

    # Serve arrow link to prev year if it leads to legal date
    if {$prev_year_legal_p != 0} {
        append result [subst {
            <a href="[ns_quotehtml ${base_url}view=$view&date=[ns_urlencode $prev_year]]">
            <img alt="left arrow" src="[dt_left_arrow]"></a>
        }]
    }

    append result "
    <b>$curr_year</b>"

    # Serve arrow to next year if it leads to a legal date
    if {$next_year_legal_p != 0} {
        append result [subst {
            <a href="[ns_quotehtml ${base_url}view=$view&date=[ns_urlencode $next_year]]">
            <img alt="right arrow" src="[dt_right_arrow]"></a>
        }]
    }

    append result "
        </td>
        </tr>
        </table>
        </td>
        </tr>\n"

    return $result
}

ad_proc -private dt_navbar_month {
    view
    base_url
    date
} {
    @return the monthly navbar
} {
    set now        [clock scan $date]
    set curr_month [clock format $now -format "%B"]

    # Check that the arrows to prev/next months don't go to illegal dates and bomb
    if {[catch {set prev_month [clock format [clock scan "1 month ago" -base $now] -format "%Y-%m-%d"]} err ]} {
        set prev_month_legal_p 0
    } else {
        if {[catch {clock scan $prev_month}]} {
            set prev_month_legal_p 0
        } else {
            set prev_month_legal_p 1
        }
    }

    if {[catch {set next_month [clock format [clock scan "1 month" -base $now] -format "%Y-%m-%d"]} err]} {
        set next_month_legal_p 0
    } else {
        if {[catch {clock scan $next_month}]} {
            set next_month_legal_p 0
        } else {
            set next_month_legal_p 1
        }
    }

    append results [subst {
        <tr><td class="bottom-border" nowrap align="center" colspan="5">
        <table cellspacing="0" cellpadding="1" border="0">
        <tr><td nowrap valign="middle">
    }]

    # Output link to previous month only if it's legal
    if {$prev_month_legal_p != 0} {
        append results [subst {
            <a href="[ns_quotehtml ${base_url}view=$view&date=[ns_urlencode $prev_month]]">
            <img alt="left arrow" src="[dt_left_arrow]"></a>
        }]
    }

    append results "
    <span style=\"font-size: smaller; font-weight: bold\">$curr_month</span>"

    # Output link to next month only if it's a legal month
    if {$next_month_legal_p != 0} {
        append results [subst {
            <a href="[ns_quotehtml ${base_url}view=$view&date=[ns_urlencode $next_month]]">
            <img border="0" src="[dt_right_arrow]"></a>
        }]
    }

    append results "
    </td>
    </tr>\n"

    return $results
}


ad_proc dt_widget_calendar_navigation {
    {base_url ""}
    {view "week"}
    {date ""}
    {pass_in_vars ""}
} {
    This proc creates a mini calendar useful for navigating various
    calendar views.  It takes a base url, which is the url to which
    this mini calendar will navigate.  pass_in_vars, if defined, can
    be url variables to be set in base_url.  They should be in the
    format returned by export_url_vars This proc will set 2 variables
    in that url's environment: the view and the date.

    Valid views are list, day, week, month, and year.
    (ben) for now I am disabling year, which doesn't work.

    The date must be formatted YYYY-MM-DD.
} {

    # valid views are "list" "day" "week" "month" "year"

    if {$base_url eq ""} {
        set base_url [ns_conn url]
    }

    if {$pass_in_vars ne ""} {
        append base_url "?$pass_in_vars&"
    } else {
        append base_url "?"
    }

    if {$date eq ""} {
        set date [dt_sysdate]
    }

    set list_of_vars [list]

    # Ben: some annoying stuff to do here since we are passing in things in GET format already
    foreach {key value} [ns_set array [ns_parsequery $pass_in_vars]] {
        lappend list_of_vars [list $key $value]
    }

    # Get the current month, day, and the first day of the month

    dt_get_info $date

    set output "
    <center><table class=\"table-display\" border='1' cellpadding='1' cellspacing='0' width='160'>

    [dt_navbar_view $view $base_url $date]

    [dt_navbar_year $view $base_url $date]\n"

    if {$view eq "month"} {
        # month view
        append output [subst {
            <tr>
            <td class="no-borders" colspan="5">
            <table bgcolor="ffffff" cellspacing="3" cellpadding="1" border="0">
            <tr>
        }]

        set months_list [dt_month_names]
        set now         [clock scan $date]
        set curr_month  [expr {[util::trim_leading_zeros [clock format $now -format "%m"]] - 1}]

        for {set i 0} {$i < 12} {incr i} {

            set month [lindex $months_list $i]

            # show 3 months in a row

            if {$i != 0 && $i % 3 == 0} {
                append output "</tr><tr>"
            }

            if {$i == $curr_month} {
                append output "
                <td>
                <span style=\"font-size: smaller; color: red\">$month</span>
                </td>\n"
            } else {
                set target_date [clock format \
                    [clock scan "[expr {$i-$curr_month}] month" -base $now] \
                    -format "%Y-%m-%d"]

                append output [subst {
                    <td>
                    <a href="[ns_quotehtml ${base_url}view=month&date=[ns_urlencode $target_date]]">
                    <span style="font-size: smaller; color: blue;">$month</span></a>
                    </td>
                }]
            }
        }

        append output "</tr>"

    } elseif {$view eq "year"} {

    # year view

        append output "
        <tr>
        <td colspan='5'>
        <table bgcolor='ffffff' cellspacing='3' cellpadding='1' border='0'>
        <tr>\n"

        set now       [clock scan $date]
        set curr_year $year
        set end_year  [expr {$year + 2}]
        set monthday  [clock format $now -format "%m-%d"]

        for {set year [expr {$curr_year - 2}]} {$year <= $end_year} {incr year} {
            if {$year == $curr_year} {
                append output "
                <td><span style=\"font-size: smaller; color: red\">$year</span></td>\n"
            } else {
                append output [subst {
                    <td>
                    <a href="[ns_quotehtml ${base_url}view=year&date=[ns_urlencode $year-$monthday]]">
                    <span style="font-size: smaller; color: blue;">$year</span></a>
                    </td>
                }]
            }
        }

        append output "</tr>"

    } else {

        append output "
            [dt_navbar_month $view $base_url $date]
            </table>
            </td>
            </tr>

            <tr><td class='bottom-border' colspan='5'>
            <table cellspacing='3' cellpadding='1'>
            <tr>
        "

        set days_of_week [list S M T W T F S]

        foreach day_of_week $days_of_week {
            append output [subst {
                <td align="right"><span style="font-size: smaller; font-weight: bold;">$day_of_week</span>
                </td>
            }]
        }
        append output "</tr><tr><td colspan='7'><hr></td></tr>"

        set day_of_week 1
        set julian_date $first_julian_date
        set day_number  $first_day

        while {1} {

            if {$julian_date < $first_julian_date_of_month} {
                set before_month_p 1
                set after_month_p  0
            } elseif {$julian_date > $last_julian_date_in_month} {
                set before_month_p 0
                set after_month_p  1
            } else {
                set before_month_p 0
                set after_month_p  0
            }

            set ansi_date [dt_julian_to_ansi $julian_date]

            if {$julian_date == $first_julian_date_of_month} {
                set day_number 1
            } elseif {$julian_date > $last_julian_date} {
                break
            } elseif {$julian_date == $last_julian_date_in_month + 1} {
                set day_number 1
            }

            if { $day_of_week == 1} {
                append output "<tr>\n"
            }

            if {$before_month_p || $after_month_p} {
                append output [subst {
                    <td align="right">
                    <a href="[ns_quotehtml ${base_url}view=$view&date=[ns_urlencode $ansi_date]]">
                    <span style="color: gray">$day_number</span></a>
                    </td>
                }]
            } elseif {$julian_date == $julian_date_today} {
                append output "
                <td align='right'>
                <strong>$day_number</strong>
                </td>"
            } else {
                append output [subst {
                    <td align="right">
                    <a href="[ns_quotehtml ${base_url}view=$view&date=[ns_urlencode $ansi_date]]">
                    <span style="color: blue">$day_number</span></a>
                    </td>
                }]
            }

            incr day_of_week
            incr julian_date
            incr day_number

            if { $day_of_week > 7 } {
                set day_of_week 1
                append output "</tr>\n"
            }
        }
    }

    append today_url "$base_url" "view=day&date=[ns_urlencode [dt_sysdate]]"

    append output "
        <tr><td align='center' colspan='7'>
        <table cellspacing='0' cellpadding='1' border='0'>
        <tr><td></td></tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        <tr class=\"table-header\"><td align='center' colspan='5'>
        <table cellspacing='0' cellpadding='0' border='0'>
        <tr><td nowrap>
        <span style=\"font-size: smaller\">"

    if { $view eq "day" && [dt_sysdate] == $date } {
        append output "<strong>Today</strong>"
    } else {
        append output [subst {<a href="[ns_quotehtml $today_url]"><strong>Today</strong></a> }]
    }

    append output [subst {
        is [dt_ansi_to_pretty]</span></td></tr>
        <tr><td align="center"><br>
        <form method='get' action="[ns_quotehtml $base_url]">
        <div>
        <input type="text" name="date" size="10">
        <input type="image" src="/resources/acs-subsite/go.gif" alt="Go" border="0"><br>
        <span style="font-size:smaller">Date as YYYYMMDD</span>
        <input type="hidden" name="view" value="day">
            </div>
    }]

    foreach var $list_of_vars {
        append output "<input type='hidden' name='[lindex $var 0]' value='[lindex $var 1]'>"
    }

    append output "
        </form>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>\n"

    return $output
}

ad_proc -private dt_get_info {
    {the_date ""}
} {
    Calculates various dates required by the dt_widget_month
    procedure. Defines, in the caller's environment, a whole set of
    variables needed for calendar display.

    Returns the following (example for the_date = 2000-12-08):

    julian_date_today           2451887
    month                       December
    year                        2000
    first_julian_date           2451875
    first_julian_date_of_month  2451880
    num_days_in_month           31
    last_julian_date_in_month   2451910
    last_julian_date            2451916
    first_day                   26
    first_day_of_month          6
    last_day                    31
    next_month                  2001-01-08
    prev_month                  2000-11-08
    beginning_of_year           2000-01-01
    days_in_last_month          30
    next_month_name             January
    prev_month_name             November

    Input:

    the_day      ANSI formatted date string (yyyy-mm-dd).  If not
                 specified this procedure will default to today's
                 date.
} {
    # If no date was passed in, let's set it to today

    if {$the_date eq ""} {
        set the_date [dt_sysdate]
    }

    # get year, month, day
    set date_list [dt_ansi_to_list $the_date]
    set year [util::trim_leading_zeros [lindex $date_list 0]]
    set month [util::trim_leading_zeros [lindex $date_list 1]]
    set day [util::trim_leading_zeros [lindex $date_list 2]]

    # We put all the data into dt_info_set and return it later
    set dt_info_set [ns_set create]

    ns_set put $dt_info_set julian_date_today \
        [dt_ansi_to_julian $year $month $day]
    ns_set put $dt_info_set month \
        [lc_time_fmt $the_date "%B"]
    ns_set put $dt_info_set year \
        [clock format [clock scan $the_date] -format %Y]
    ns_set put $dt_info_set first_julian_date_of_month \
        [dt_ansi_to_julian $year $month 1]
    ns_set put $dt_info_set num_days_in_month \
        [dt_num_days_in_month $year $month]
    ns_set put $dt_info_set first_day_of_month \
        [dt_first_day_of_month $year $month]
    ns_set put $dt_info_set last_day \
        [dt_num_days_in_month $year $month]
    ns_set put $dt_info_set next_month \
        [dt_next_month $year $month]
    ns_set put $dt_info_set prev_month \
        [dt_prev_month $year $month]
    ns_set put $dt_info_set beginning_of_year \
        $year-01-01
    ns_set put $dt_info_set days_in_last_month \
        [dt_num_days_in_month $year [expr {$month - 1}]]
    ns_set put $dt_info_set next_month_name \
        [dt_next_month_name $year $month]
    ns_set put $dt_info_set prev_month_name \
        [dt_prev_month_name $year $month]

    # We need the variables from the ns_set
    ad_ns_set_to_tcl_vars $dt_info_set

    ns_set put $dt_info_set first_julian_date \
        [expr {$first_julian_date_of_month + 1 - $first_day_of_month}]
    ns_set put $dt_info_set first_day \
        [expr {$days_in_last_month + 2 - $first_day_of_month}]
    ns_set put $dt_info_set last_julian_date_in_month \
        [expr {$first_julian_date_of_month + $num_days_in_month - 1}]

    set days_in_next_month \
        [expr {(7-(($num_days_in_month + $first_day_of_month - 1) % 7)) % 7}]

    ns_set put $dt_info_set last_julian_date \
        [expr {$first_julian_date_of_month + $num_days_in_month - 1 + $days_in_next_month}]

    # Now, set the variables in the caller's environment

    ad_ns_set_to_tcl_vars -level 2 $dt_info_set
    ns_set free $dt_info_set
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
