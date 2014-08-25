# /packages/acs-datetime/www/doc/examples/calendar-widgets.tcl

ad_page_contract {

    Examples of the basic dt_ calendar widgets

    @author  ron@arsdigita.com
    @creation-date 2000/12/01
    @cvs-id  $Id$
} -properties {
    dt_examples:multirow
}

set title "Calendar Widgets"
set context [list [list . "ACS DateTime Examples"] $title]

set example_list {
    "dt_widget_month_small"
    "dt_widget_month_centered"
    "dt_widget_month"
    "dt_widget_year -width 4"
    "dt_widget_calendar_year -width 4"
}

# Generate a multirow datasource to transmit the examples to the
# template.  Then we just loop over the examples list to generate all
# of the display information.

multirow create dt_examples "procedure" "result"

foreach example $example_list {
    multirow append dt_examples $example [{*}$example]
}

ad_return_template
