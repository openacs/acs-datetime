<!-- $Id$ -->

<master>

<property name="doc(title)">@title;literal@</property>
<property name="context">@context;literal@</property>

<pre>dt_widget_calendar_navigation <em>base_url</em> <em>view</em> <em>date</em> <em>pass_in_vars</em> </pre>

<p>
<dl>
<dt><strong>Parameters:</strong></dt><dd>
<strong>base_url</strong> (optional)<br>
<strong>view</strong> (defaults to <code>week</code>)<br>
<strong>date</strong> (optional)<br>
<strong>pass_in_vars</strong> (optional)<br>
</dd>
</dl>

<p>This procedure creates a mini calendar useful for navigating
various calendar views.  It takes a base url, which is the url to
which this mini calendar will navigate.  When defined,
<code>pass_in_vars</code> can be url variables to be set in
<code>base_url</code>.  They should be in the format returned by
<code>export_url_vars</code>.  This procedure will set two variables
in that url's environment: <code>view</code> and <code>date</code>.

<p>Valid views are list, day, week, month, and year.</p>

<h3>Example</h3>

<p>The following shows a sample navigation form for this page, which
simply reads <code>view</code> and <code>date</code> as URL variables
and uses them to initialize the display.


@calendar_widget;noquote@


<p>Click on any view, date, or other navigational element to change
the display of this page.</p>

