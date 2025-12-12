import os, times, strformat, strutils

const
  VERSION = "spt-1.0"
  CONFIG_FILE = "spt.conf"

type
  Timer = object
    tmr: Duration
    cmt: string

  StartupConfig = object
    notifyCmt: string

# Default timers, used if config file is missing or invalid.
let defaultTimers: seq[Timer] = @[
  Timer(tmr: initDuration(minutes = 25), cmt: "Time to start working!"),
  Timer(tmr: initDuration(minutes = 5), cmt: "Time to start resting!"),
  Timer(tmr: initDuration(minutes = 25), cmt: "Time to start working!"),
  Timer(tmr: initDuration(minutes = 5), cmt: "Time to start resting!"),
  Timer(tmr: initDuration(minutes = 25), cmt: "Time to start working!"),
  Timer(tmr: initDuration(minutes = 5), cmt: "Time to start resting!"),
  Timer(tmr: initDuration(minutes = 25), cmt: "Time to start working!"),
  Timer(tmr: initDuration(minutes = 15), cmt: "Time to take a nap!")
]

proc writeDefaultConfig(): seq[string] =
  var lines: seq[string]
  for t in defaultTimers:
    let mins = t.tmr.inSeconds div 60
    lines.add(fmt"{mins}:{t.cmt}")
  try:
    writeFile(CONFIG_FILE, lines.join("\n"))
    echo fmt"Created default configuration file at '{CONFIG_FILE}'"
  except IOError:
    echo fmt"Warning: Could not write default config to '{CONFIG_FILE}'"
  return lines

proc loadTimers(): seq[Timer] =
  var lines: seq[string]

  if fileExists(CONFIG_FILE):
    try:
      lines = readFile(CONFIG_FILE).strip.splitLines
    except IOError:
      echo fmt"Warning: Could not read '{CONFIG_FILE}'. Using default timers."
      return defaultTimers
  else:
    echo fmt"Info: Config file '{CONFIG_FILE}' not found."
    lines = writeDefaultConfig()

  if lines.len == 0:
    return defaultTimers

  var timers: seq[Timer]
  for i, line in lines:
    if line.strip.len == 0 or line.startsWith("#"):
      continue
    let parts = line.split(':', 1)
    if parts.len == 2:
      try:
        let minutes = parseInt(parts[0].strip)
        let comment = parts[1].strip
        timers.add(Timer(tmr: initDuration(minutes = minutes), cmt: comment))
      except ValueError:
        echo fmt"Warning: Invalid minutes on line {i+1} in '{CONFIG_FILE}'. Skipping."
    else:
      echo fmt"Warning: Malformed line {i+1} in '{CONFIG_FILE}'. Should be 'minutes:comment'. Skipping."

  if timers.len == 0:
    echo fmt"Warning: No valid timers loaded from '{CONFIG_FILE}'. Using default timers."
    return defaultTimers

  return timers

proc notifySend(cmt: string, notifyCmt: string) =
  let cmd = "notify-send"
  var finalCmt = cmt
  if notifyCmt.len > 0:
    finalCmt = finalCmt & " - " & notifyCmt

  let args = "spt " & quoteShell(finalCmt)

  if findExe(cmd) == "":
    echo "Warning: 'notify-send' command not found. Cannot send notifications."
    return

  if execShellCmd(cmd & " " & args) != 0:
    echo "Error: Failed to send notification."

proc parseArgs(): StartupConfig =
  var args = commandLineParams()
  var i = 0
  var result: StartupConfig

  while i < args.len:
    let arg = args[i]
    case arg
    of "-v", "--version":
      echo "spt " & VERSION
      quit(0)
    of "-h", "--help":
      echo "usage: spt [-v | -h] [-n <comment>]"
      quit(0)
    of "-n":
      if i + 1 < args.len:
        i += 1
        result.notifyCmt = args[i]
      else:
        quit("Error: Missing argument for -n", 1)
    else:
      quit(fmt"Error: Unknown argument '{arg}'", 1)
    i += 1
  return result

proc startTimer(timers: seq[Timer], notifyCmt: string) =
  for i, timer in timers:
    let mins = timer.tmr.inSeconds div 60
    echo fmt"Timer started: {timer.cmt} ({mins} min)"
    notifySend(timer.cmt, notifyCmt)

    sleep(timer.tmr.inMilliseconds)

  let finalMsg = "Pomodoro sequence finished!"
  echo finalMsg
  notifySend(finalMsg, notifyCmt)

proc main() =
  let config = parseArgs()
  let timers = loadTimers()
  if timers.len > 0:
    startTimer(timers, config.notifyCmt)

main()
