*! version 1.0.0  15nov2026
*! ntfy: send a push notification to an ntfy topic (https://ntfy.sh)
*! Uses Stata's built-in Java (no curl, PowerShell or shell window needed)

program define ntfy, rclass
    version 16.0
    syntax anything(name=msg id="message" everything) , Topic(string) ///
        [ TItle(string) PRiority(integer 3) TAgs(string) CLick(string) ///
          SERVer(string) STRict ]

    * --- message: strip outer quotes if the message is one quoted string ---
    gettoken first rest : msg, quotes
    if strtrim(`"`rest'"') == "" {
        gettoken first : msg
        local msg `"`first'"'
    }

    * --- checks --------------------------------------------------------------
    if !ustrregexm(`"`topic'"', "^[-_A-Za-z0-9]{1,64}$") {
        di as err "topic() may contain only letters, digits, - and _ (max 64 characters)"
        exit 198
    }
    if !inrange(`priority', 1, 5) {
        di as err "priority() must be an integer from 1 (min) to 5 (max)"
        exit 198
    }
    if `"`server'"' == "" local server "https://ntfy.sh"

    * --- hand everything to Java through locals --------------------------------
    local ntfy_msg      `"`msg'"'
    local ntfy_topic    `"`topic'"'
    local ntfy_title    `"`title'"'
    local ntfy_priority "`priority'"
    local ntfy_tags     `"`tags'"'
    local ntfy_click    `"`click'"'
    local ntfy_server   `"`server'"'
    local ntfy_id       ""
    local ntfy_err      ""
    local ntfy_rc       "677"

    java: NtfySend.run();

    return scalar sent = (`ntfy_rc' == 0)
    return scalar rc   = `ntfy_rc'
    return local topic  `"`topic'"'
    return local id     `"`ntfy_id'"'

    if `ntfy_rc' != 0 {
        if "`strict'" != "" {
            di as err `"ntfy: notification not sent: `ntfy_err'"'
            exit `ntfy_rc'
        }
        * default: warn but never break the calling do-file
        di as txt `"(ntfy: notification NOT sent: `ntfy_err')"'
        exit
    }
    di as txt "(ntfy: notification sent to topic " as res `"`topic'"' as txt ")"
end

java:

import com.stata.sfi.Macro;
import com.stata.sfi.SFIToolkit;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class NtfySend {

    static String loc(String name) {
        String s = Macro.getLocal(name);
        return s == null ? "" : s.trim();
    }

    // called from Stata with  java: NtfySend.run();
    // return code -> local ntfy_rc, error text -> local ntfy_err
    public static void run() {
        int rc;
        try { rc = send(); }
        catch (Throwable t) {
            Macro.setLocal("ntfy_err", clean(t.toString()));
            rc = 677;
        }
        Macro.setLocal("ntfy_rc", Integer.toString(rc));
    }

    static int send() {
        try {
            System.setProperty("java.net.useSystemProxies", "true");

            String server = loc("ntfy_server").replaceAll("/+$", "");
            String msg    = loc("ntfy_msg");
            String title  = loc("ntfy_title");
            String tags   = loc("ntfy_tags");
            String click  = loc("ntfy_click");

            // ---- JSON body (publishing as JSON keeps UTF-8 intact everywhere)
            StringBuilder j = new StringBuilder("{");
            j.append("\"topic\":\"").append(esc(loc("ntfy_topic"))).append("\"");
            j.append(",\"message\":\"").append(esc(msg)).append("\"");
            if (!title.isEmpty()) j.append(",\"title\":\"").append(esc(title)).append("\"");
            j.append(",\"priority\":").append(Integer.parseInt(loc("ntfy_priority")));
            if (!tags.isEmpty()) {
                j.append(",\"tags\":[");
                boolean firstTag = true;
                for (String t : tags.split("[,\\s]+")) {
                    if (t.isEmpty()) continue;
                    if (!firstTag) j.append(",");
                    j.append("\"").append(esc(t)).append("\"");
                    firstTag = false;
                }
                j.append("]");
            }
            if (!click.isEmpty()) j.append(",\"click\":\"").append(esc(click)).append("\"");
            j.append("}");

            HttpURLConnection c = (HttpURLConnection)
                java.net.URI.create(server + "/").toURL().openConnection();
            c.setRequestMethod("POST");
            c.setDoOutput(true);
            c.setConnectTimeout(15000);
            c.setReadTimeout(30000);
            c.setRequestProperty("Content-Type", "application/json; charset=utf-8");
            c.setRequestProperty("User-Agent", "stata-ntfy");
            try (OutputStream os = c.getOutputStream()) {
                os.write(j.toString().getBytes(StandardCharsets.UTF_8));
            }

            int code = c.getResponseCode();
            if (code < 200 || code >= 300) {
                String body = readAll(c.getErrorStream());
                String m = firstString(body, "error");
                Macro.setLocal("ntfy_err", clean("server returned HTTP " + code
                    + (m == null ? "" : " (" + m + ")")));
                return 677;
            }
            String id = firstString(readAll(c.getInputStream()), "id");
            Macro.setLocal("ntfy_id", id == null ? "" : id);
            return 0;
        }
        catch (Exception e) {
            Macro.setLocal("ntfy_err", clean(e.getClass().getSimpleName() + ": "
                + e.getMessage() + " - check internet access and proxy settings"));
            return 677;
        }
    }

    // keep error text safe to display inside Stata compound quotes
    static String clean(String s) {
        return s == null ? "" : s.replace("`", "'").replace("$", "S").replace("\"", "'");
    }

    static String readAll(InputStream in) throws Exception {
        if (in == null) return "";
        try (InputStream is = in) {
            ByteArrayOutputStream b = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = is.read(buf)) > 0) b.write(buf, 0, n);
            return new String(b.toByteArray(), StandardCharsets.UTF_8);
        }
    }

    static String firstString(String json, String key) {
        if (json == null) return null;
        Matcher m = Pattern.compile("\"" + key + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"").matcher(json);
        return m.find() ? m.group(1) : null;
    }

    static String esc(String s) {
        StringBuilder sb = new StringBuilder();
        for (char ch : s.toCharArray()) {
            switch (ch) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                default:
                    if (ch < 0x20) sb.append(String.format("\\u%04x", (int) ch));
                    else sb.append(ch);
            }
        }
        return sb.toString();
    }
}

end
