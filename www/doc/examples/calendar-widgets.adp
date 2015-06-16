<!-- $Id$ -->

<master>

<property name="doc(title)">@title@</property>
<property name="context">@context@</property>

<p>These are the various widgets to generate calendar views.  Note
that the <a href="calendar-navigation">calendar navigation</a> widget is
documented separately.  This page documents the following:

<ol>
<multiple name="dt_examples">
   <li><a href="#@dt_examples.rownum@">@dt_examples.procedure@</a></li>
</multiple>
</ol>

<multiple name="dt_examples">

<hr>

<h4><a name="#@dt_examples.rownum@"></a>@dt_examples.procedure@</h4>

<center> @dt_examples.result;noquote@ </center>

</multiple>


<h4>Notes</h4>

<ol>

<li>All widgets accept an <code>ns_set</code> keyed on Julian date to
link specific days with events occurring on those days.

</ol>

