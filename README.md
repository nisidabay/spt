# spt - A Simple Pomodoro Timer

A simple, configurable pomodoro timer written in Nim. It runs a sequence of
timers in your terminal and sends desktop notifications when each period is
over.

## Features

- Runs a sequence of work/rest timers based on the Pomodoro Technique.
- Sends desktop notifications via `notify-send`.
- Timer sequence is configurable through a simple `spt.conf` text file.
- Automatically creates a default `spt.conf` if one is not found.
- Allows appending a custom message to notifications.

## Requirements

- A Nim compiler (version 1.6.0 or newer).
- `notify-send` for desktop notifications (commonly available on Linux desktop
environments).

## Installation & Usage

1.  **Compile the script:**
    ```sh
    nim c -d:release spt.nim
    ```
    This will create a `spt` executable in the current directory.

2.  **Run the timer:**
    ```sh
    ./spt
    ```

## Configuration

The first time you run `spt`, it will create a `spt.conf` file in the same
directory. You can edit this file to customize the timer sequence.

The format is one timer per line: `minutes:Comment`

#### Example `spt.conf`:

```
# This is a comment, it will be ignored.
25:Time to start working!
5:Time for a short break!
25:Time to start working!
15:Time for a long break!
```

## Command-Line Options

-   `./spt -h`: Show the help message.
-   `./spt -v`: Show the version number.
-   `./spt -n "My Project"`: Append a custom message ("My Project") to every
    notification. This is useful for tracking what you are working on.
