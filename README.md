# ntfy: phone notifications from Stata

`ntfy` sends a push notification to an [ntfy](https://ntfy.sh) topic from Stata.
Use it to get a message on your phone when a long run finishes.

- No account and no cost. Install the free ntfy app (Android or iOS) and subscribe to a topic.
- Uses Stata's built-in Java, so you don't need curl, a shell window or other software.
- If a notification fails, `ntfy` prints a warning and the do-file keeps running. Add `strict` to make a failure an error.

Requires Stata 16 or later.

## Install

From a public GitHub repository:

```stata
net install ntfy, from("https://raw.githubusercontent.com/szabobarnaKI/ntfy/main") replace
```

Or by hand: copy `ntfy.ado` and `ntfy.sthlp` into your PERSONAL ado folder (type `sysdir` in Stata to find it).

## Usage

```stata
ntfy "Bootstrap finished", topic(mytopic_8f3k)

capture noisily do analysis.do
local rc = _rc
ntfy "analysis.do ended, rc=`rc'", topic(mytopic_8f3k) title("Stata") ///
    priority(`=cond(`rc',5,3)') tags(`=cond(`rc',"rotating_light","white_check_mark")')
```

| Option | Meaning |
|---|---|
| `topic(name)` | required; letters, digits, `-`, `_`; max 64 characters |
| `title(string)` | notification title |
| `priority(#)` | 1 (min) to 5 (max); default 3 |
| `tags(list)` | emoji short codes or plain words, e.g. `tags(warning, white_check_mark)` |
| `click(url)` | URL opened when the notification is tapped |
| `server(url)` | ntfy server; default `https://ntfy.sh` |
| `strict` | error (rc 677) if sending fails |

Stored results: `r(sent)`, `r(rc)`, `r(topic)`, `r(id)`. See `help ntfy` for the list of tags.

On the public server, anyone who knows a topic name can read its messages. Use a hard-to-guess topic name and don't send confidential data.

## Files

- `ntfy.ado`, `ntfy.sthlp`: the command and its help file
- `ntfy.pkg`, `stata.toc`: package files for `net install`
- `test_ntfy.do`: tests. It sends four real notifications and uploads its log with `ghlog`.
