aa_register_case dt_get_days_of_week {
} {
    set old_locale [ad_conn locale]

    ad_conn -set locale en_US
    aa_true "1-letter weekdays in en_US: [dt_get_days_of_week]" [string equal [dt_get_days_of_week] "S M T W T F S"]
    aa_true "3-letter weekdays in en_US: [dt_get_days_of_week -weekday_format ab]" [string equal [dt_get_days_of_week -weekday_format ab] "Sun Mon Tue Wed Thu Fri Sat"]
    aa_true "Long weekdays in en_US: [dt_get_days_of_week -weekday_format long]" [string equal [dt_get_days_of_week -weekday_format long] "Sunday Monday Tuesday Wednesday Thursday Friday Saturday"]

    ad_conn -set locale da_DK
    aa_true "1-letter weekdays in da_DK: [dt_get_days_of_week]" [string equal [dt_get_days_of_week] "M T O T F L S"]

    ad_conn -set locale $old_locale
}
