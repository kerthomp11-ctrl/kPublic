### Start Script  -- need to log changes - need some tests ###
#* write time + cpu? + voice memo on time changes *#
#param($mins = 60) - testt
notepad #open notepad application to see timer

# Idle time detector and mouse mover using Windows API
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class UserInput {
    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }
    public static double IdleSeconds() {
        LASTINPUTINFO info = new LASTINPUTINFO();
        info.cbSize = (uint)Marshal.SizeOf(info);
        GetLastInputInfo(ref info);
        return (Environment.TickCount - info.dwTime) / 1000.0;
    }
}

public class MouseMove {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);
    public struct POINT { public int X; public int Y; }
    public static void Nudge() {
        Random rnd = new Random();
        POINT p;
        GetCursorPos(out p);
        int dx = rnd.Next(3, 13) * (rnd.Next(2) == 0 ? 1 : -1);
        int dy = rnd.Next(3, 13) * (rnd.Next(2) == 0 ? 1 : -1);
        SetCursorPos(p.X + dx, p.Y + dy);
    }
}
"@ -ErrorAction SilentlyContinue

# Setup log file on Desktop with dated filename
$logDate = Get-Date -Format "yyyy-MM-dd"
$logPath = "$env:USERPROFILE\Desktop\timerApp_$logDate.txt"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$mytime = Get-Date -Format "HH:mm"
$myshell = New-Object -ComObject "wscript.shell"
$notes = $myshell.AppActivate('Notepad')

################ run number ##################
$runnum = 63
#########################################

Start-Sleep -Seconds 9
### `r --> carraige return && `n --> new line ###
[void]$myshell.AppActivate('Notepad')
$myshell.sendkeys("Timer App Started at $($mytime)`rRun Number: $($runnum)`r")
$myshell.sendkeys("No. Time1 / Pause1 / Elapsed / Pause2`r")

# Write header to log file
$header = "Timer App Started at $mytime`r`nRun Number: $runnum`r`nNo. Time1 / Pause1 / Elapsed / Pause2"
Add-Content -Path $logPath -Value $header

$n = 0
### starting at 39 ###
# 39 - last 2 tests were 2hr 4min and 2hr 7min
### should last up to 2 hr presentation ###
try {
    for ($i = 0; $i -lt $runnum; $i++)
    {
        $n = $n + 1
        $mytime = Get-Date -Format "HH:mm"
        [void]$myshell.AppActivate('Notepad')
        ### format my number to 2 digits ###
        $mynum = "{0:D2}" -f $n
        $ran = Get-Random -Minimum 69 -Maximum 159

        ### Only log and nudge if idle more than 3 minutes ###
        if ([UserInput]::IdleSeconds() -gt 180) {
            [MouseMove]::Nudge()
            $myshell.sendkeys("$($mynum). $($mytime) /  $($ran)  / ") #`r --> carraige return && `n --> new line
        }

        Start-Sleep -Seconds $ran

        ### middle timer ###

        $mytime = Get-Date -Format "HH:mm"
        [void]$myshell.AppActivate('Notepad')
        $elapsed = "$($stopwatch.Elapsed.Hours):$($stopwatch.Elapsed.Minutes):$($stopwatch.Elapsed.Seconds)"
        $ran2 = Get-Random -Minimum 102 -Maximum 333

        ### Only log and nudge if idle more than 3 minutes ###
        if ([UserInput]::IdleSeconds() -gt 180) {
            [MouseMove]::Nudge()
            $myshell.sendkeys("$($elapsed) / $($ran2)`r") #`r --> carraige return && `n --> new line
        }

        Start-Sleep -Seconds $ran2

        ### Auto-save to Desktop every 10 iterations ###
        if ($n % 10 -eq 0) {
            $saveTime = Get-Date -Format "HH:mm"
            [void]$myshell.AppActivate('Notepad')
            $myshell.sendkeys("^s") # Ctrl+S saves in Notepad
            Add-Content -Path $logPath -Value "--- Auto-saved at $saveTime (iteration $n) ---"
        }
    }
} finally {
    $mytime = Get-Date -Format "HH:mm"
    [void]$myshell.AppActivate('Notepad')
    $myshell.sendkeys("Timer App Ended at $($mytime)")
    Add-Content -Path $logPath -Value "Timer App Ended at $mytime"
    $myshell.sendkeys("^s") # Final save in Notepad
    $stopwatch.Stop()
}

### End Script ###