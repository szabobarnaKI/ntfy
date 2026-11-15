{smcl}
{* *! version 1.0.1  15nov2026}{...}
{title:Title}

{phang}
{bf:ntfy} {hline 2} Send a push notification to an ntfy topic


{title:Syntax}

{p 8 16 2}
{cmd:ntfy} {it:message}{cmd:,} {opt t:opic(name)} [{it:options}]

{synoptset 20}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt t:opic(name)}}ntfy topic (letters, digits, {cmd:-} and {cmd:_}; max 64){p_end}
{synopt:{opt ti:tle(string)}}notification title{p_end}
{synopt:{opt pr:iority(#)}}1 (min) to 5 (max); default {cmd:3}{p_end}
{synopt:{opt ta:gs(list)}}tags or emoji short codes, e.g. {cmd:tags(warning, white_check_mark)}{p_end}
{synopt:{opt cl:ick(url)}}URL opened when the notification is tapped{p_end}
{synopt:{opt serv:er(url)}}ntfy server; default {cmd:https://ntfy.sh}{p_end}
{synopt:{opt str:ict}}exit with an error if sending fails{p_end}
{synoptline}
{p 4 6 2}* {opt topic()} is required.{p_end}


{title:Description}

{pstd}
{cmd:ntfy} publishes {it:message} to an ntfy topic. Phones subscribed to the
topic in the ntfy app receive it as a push notification. The request is sent
by Stata's built-in Java, so no shell window or extra software is needed.

{pstd}
Put {it:message} in double quotes if it contains a comma. Use compound quotes
({cmd:`"..."'}) if it also contains double quotes.

{pstd}
By default a failed send only prints a note, so a notification problem never
stops a long job. Specify {opt strict} to make it an error (rc 677).


{title:Examples}

{phang}{cmd:. ntfy "Bootstrap finished", topic(mytopic_8f3k)}{p_end}

{phang}{cmd:. capture noisily do analysis.do}{p_end}
{phang}{cmd:. local rc = _rc}{p_end}
{phang}{cmd:. ntfy "analysis.do ended, rc=`rc'", topic(mytopic_8f3k) title("Stata") priority(`=cond(`rc',5,3)') tags(`=cond(`rc',"rotating_light","white_check_mark")')}{p_end}


{title:Tags}

{pstd}
{opt tags()} takes one or more tags separated by commas or spaces. A tag that
is an emoji short code is shown as that emoji in front of the title (or the
message, if there is no title). Any other word is shown as a plain-text tag
under the message, e.g. {cmd:tags(warning, stcoxem, bootstrap)}.

{pstd}
Useful emoji short codes:

{synoptset 26}{...}
{p2col 5 31 33 2: {it:Status}}{p_end}
{synopt:{cmd:white_check_mark}}green box with white tick{p_end}
{synopt:{cmd:heavy_check_mark}}black tick{p_end}
{synopt:{cmd:x}}red cross{p_end}
{synopt:{cmd:heavy_multiplication_x}}black cross{p_end}
{synopt:{cmd:warning}}warning triangle{p_end}
{synopt:{cmd:rotating_light}}police light (alarm){p_end}
{synopt:{cmd:no_entry}}no-entry sign{p_end}
{synopt:{cmd:stop_sign}}stop sign{p_end}
{synopt:{cmd:sos}}SOS button{p_end}
{synopt:{cmd:skull}}skull{p_end}
{synopt:{cmd:boom}}collision/explosion{p_end}
{synopt:{cmd:fire}}fire{p_end}
{synopt:{cmd:bug}}bug{p_end}
{synopt:{cmd:information_source}}information sign{p_end}
{synopt:{cmd:question}}red question mark{p_end}
{synopt:{cmd:exclamation}}red exclamation mark{p_end}
{synopt:{cmd:+1} / {cmd:-1}}thumbs up / thumbs down{p_end}
{synopt:{cmd:green_circle}}green circle{p_end}
{synopt:{cmd:yellow_circle}}yellow circle{p_end}
{synopt:{cmd:red_circle}}red circle{p_end}
{synopt:{cmd:large_blue_circle}}blue circle{p_end}

{p2col 5 31 33 2: {it:Finished / progress}}{p_end}
{synopt:{cmd:tada}}party popper{p_end}
{synopt:{cmd:partying_face}}party face{p_end}
{synopt:{cmd:checkered_flag}}chequered flag{p_end}
{synopt:{cmd:rocket}}rocket{p_end}
{synopt:{cmd:zap}}lightning bolt{p_end}
{synopt:{cmd:snail} / {cmd:turtle}}snail / turtle (slow run){p_end}
{synopt:{cmd:repeat}}repeat arrows (loop, iteration){p_end}
{synopt:{cmd:arrows_counterclockwise}}refresh arrows (restart){p_end}

{p2col 5 31 33 2: {it:Time}}{p_end}
{synopt:{cmd:hourglass}}hourglass, finished{p_end}
{synopt:{cmd:hourglass_flowing_sand}}hourglass, running{p_end}
{synopt:{cmd:stopwatch}}stopwatch{p_end}
{synopt:{cmd:alarm_clock}}alarm clock{p_end}
{synopt:{cmd:coffee}}hot drink (break){p_end}
{synopt:{cmd:sleeping}}sleeping face (overnight run){p_end}

{p2col 5 31 33 2: {it:Data and computing}}{p_end}
{synopt:{cmd:bar_chart}}bar chart{p_end}
{synopt:{cmd:chart_with_upwards_trend}}chart going up{p_end}
{synopt:{cmd:chart_with_downwards_trend}}chart going down{p_end}
{synopt:{cmd:chart}}chart with yen sign{p_end}
{synopt:{cmd:abacus}}abacus{p_end}
{synopt:{cmd:computer}}laptop{p_end}
{synopt:{cmd:floppy_disk}}floppy disk (saved){p_end}
{synopt:{cmd:package}}package{p_end}
{synopt:{cmd:memo}}memo (log, report){p_end}
{synopt:{cmd:bookmark_tabs}}bookmark tabs{p_end}
{synopt:{cmd:mag}}magnifying glass{p_end}
{synopt:{cmd:gear}}gear{p_end}
{synopt:{cmd:hammer_and_wrench}}hammer and wrench{p_end}
{synopt:{cmd:loudspeaker}}loudspeaker{p_end}
{synopt:{cmd:bell}}bell{p_end}

{p2col 5 31 33 2: {it:Science and medicine}}{p_end}
{synopt:{cmd:microscope}}microscope{p_end}
{synopt:{cmd:test_tube}}test tube{p_end}
{synopt:{cmd:dna}}DNA{p_end}
{synopt:{cmd:pill}}pill{p_end}
{synopt:{cmd:stethoscope}}stethoscope{p_end}
{synopt:{cmd:hospital}}hospital{p_end}
{p2colreset}{...}

{pstd}
ntfy accepts about 1,800 short codes, the same names GitHub uses for emoji. For
the full list see
{browse "https://docs.ntfy.sh/emojis/":docs.ntfy.sh/emojis}.


{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(sent)}}1 if sent, 0 otherwise{p_end}
{synopt:{cmd:r(rc)}}0 if sent, otherwise 677{p_end}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(topic)}}topic{p_end}
{synopt:{cmd:r(id)}}message id returned by the server{p_end}


{title:Remarks}

{pstd}
On the public server anyone who knows the topic name can read its messages,
so use a hard-to-guess name and do not send confidential data.
