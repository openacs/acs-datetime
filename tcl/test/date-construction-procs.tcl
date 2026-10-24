ad_library {Regression tests for decimal ISO date construction.}

aa_register_case -procs {
    dt_ansi_to_julian dt_ansi_to_list dt_num_days_in_month
    dt_first_day_of_month dt_next_month dt_prev_month dt_get_info
} -cats {api production_safe} dt_early_years {
    Preserve early years throughout calendar date calculations.
} {
    foreach year {0001 0009 0099 0999 1000 2000} {
        foreach month {01 02 08 09 12} {
            set iso $year-$month-14
            set seconds [clock scan $iso -format %Y-%m-%d]
            set julian [clock format $seconds -format %J]
            set info [dt_get_info -dict $iso]
            aa_equals "$iso Julian day" [dict get $info julian_date_today] $julian
            aa_equals "$iso year" [dict get $info year] $year
            aa_equals "$iso beginning of year" [dict get $info beginning_of_year] $year-01-01
            set first [clock scan $year-$month-01 -format %Y-%m-%d]
            aa_equals "$iso weekday" [dict get $info first_day_of_month] \
                [expr {[clock format $first -format %w] + 1}]
            foreach {key delta} {next_month 1 prev_month -1} {
                aa_equals "$iso $key" [dict get $info $key] \
                    [clock format [clock add $first $delta month] -format %Y-%m-%d]
            }
            aa_equals "$iso month length" [dict get $info num_days_in_month] \
                [clock format [clock add [clock add $first 1 month] -1 day] -format %d]
            set start [dict get $info first_julian_date_of_month]
            set weekday [dict get $info first_day_of_month]
            set length [dict get $info num_days_in_month]
            aa_equals "$iso first Julian day" $start [clock format $first -format %J]
            aa_equals "$iso grid start" [dict get $info first_julian_date] [expr {$start + 1 - $weekday}]
            aa_equals "$iso last month day" [dict get $info last_day] $length
            aa_equals "$iso last Julian day in month" [dict get $info last_julian_date_in_month] [expr {$start + $length - 1}]
            aa_equals "$iso grid end" [dict get $info last_julian_date] \
                [expr {$start + $length - 1 + (7 - (($length + $weekday - 1) % 7)) % 7}]
            aa_equals "$iso preceding month length" [dict get $info days_in_last_month] \
                [clock format [clock add $first -1 day] -format %d]
            aa_equals "$iso first displayed day" [dict get $info first_day] \
                [expr {[dict get $info days_in_last_month] + 2 - $weekday}]
            aa_equals "$iso month name" [dict get $info month] [lc_time_fmt $iso %B]
            aa_equals "$iso next month name" [dict get $info next_month_name] \
                [lc_time_fmt [dict get $info next_month] %B]
            aa_equals "$iso previous month name" [dict get $info prev_month_name] \
                [lc_time_fmt [dict get $info prev_month] %B]
            lassign [dt_ansi_to_list "$iso 08:09:01"] y m d h mi s
            scan $year %d expected_year
            aa_equals "$iso datetime year" $y $expected_year
            aa_equals "$iso datetime time" [list $h $mi $s] {8 9 1}
            # Exercise the caller-variable interface used by older widgets too.
            dt_get_info $iso
            aa_equals "$iso caller Julian day" $julian_date_today $julian
        }
    }
    aa_equals "unpadded year" [dt_ansi_to_julian 999 9 14] \
        [dt_ansi_to_julian 0999 09 14]
}

aa_register_case -procs {
    dt_ansi_to_julian dt_ansi_to_list dt_num_days_in_month
    dt_first_day_of_month dt_next_month dt_prev_month
} -cats {api production_safe} dt_date_rollover_errors {
    Keep Tcl rollover and the public procedures' error-return conventions.
} {
    foreach {year month day expected} {
        2020 0 1 2019-12-01
        2020 13 1 2021-01-01
        2020 14 1 2021-02-01
        2020 2 30 2020-03-01
        2020 9 0 2020-08-31
        2020 9 32 2020-10-02
        0999 12 32 1000-01-01
    } {
        aa_equals "rollover $year-$month-$day" \
            [dt_julian_to_ansi [dt_ansi_to_julian $year $month $day]] $expected
    }
    foreach {month days} {0 31 13 31 08 31 09 30} {
        aa_equals "month length $month" [dt_num_days_in_month 0999 $month] $days
    }
    foreach components {{bad 1 1} {2020 bad 1} {2020 1 bad} {0 1 1} {00 1 1} {000 1 1} {10000 1 1}} {
        aa_equals "invalid Julian components $components" [dt_ansi_to_julian {*}$components] -1
    }
    foreach proc {dt_next_month dt_prev_month dt_next_month_name dt_prev_month_name} {
        aa_equals "$proc invalid input" [$proc invalid 1] ""
    }
    foreach proc {dt_first_day_of_month dt_num_days_in_month} {
        aa_true "$proc propagates invalid input" [catch {$proc invalid 1}]
    }
    aa_true "invalid ANSI input still raises" [catch {dt_ansi_to_list not-a-date}]
    aa_equals "generic parsing remains supported" [lrange [dt_ansi_to_list {January 2, 2020}] 0 2] {2020 1 2}
}


aa_register_case -procs {
    dt_ansi_to_list dt_ansi_to_julian dt_num_days_in_month
    dt_first_day_of_month dt_next_month dt_prev_month dt_get_info
} -cats {api production_safe} dt_legacy_short_years {
    Preserve legacy short-year interpretation in ADP/include callers.
} {
    foreach year {0 00 1 01 9 09 20 38 68 69 70 99} {
        set resolved [clock format [clock scan "$year-01-01"] -format %Y]
        foreach month {01 02 08 09 12} {
            set first [clock scan "$year-$month-01"]
            aa_equals "$year-$month legacy first weekday" \
                [dt_first_day_of_month $year $month] \
                [expr {[clock format $first -format %w] + 1}]
            aa_equals "$year-$month legacy month length" \
                [dt_num_days_in_month $year $month] \
                [clock format [clock add [clock add $first 1 month] -1 day] -format %d]
            foreach {proc delta} {dt_next_month 1 dt_prev_month -1} {
                aa_equals "$year-$month legacy $proc" [$proc $year $month] \
                    [clock format [clock add $first $delta month] -format %Y-%m-%d]
            }
            foreach {proc delta} {dt_next_month_name 1 dt_prev_month_name -1} {
                aa_equals "$year-$month legacy $proc" [$proc $year $month] \
                    [lc_time_fmt [clock format [clock add $first $delta month] -format %Y-%m-%d] %B]
            }
            aa_equals "$year-$month legacy date parsing" \
                [lindex [dt_ansi_to_list "$year-$month-14"] 0] $resolved
            aa_equals "$year-$month explicit Julian format still rejects short years" \
                [dt_ansi_to_julian $year $month 14] -1
        }
    }
}
