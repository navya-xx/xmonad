Config {
    font = "xft:SFNS Display:size=11",
    additionalFonts = ["xft:FontAwesome:size=11"],
    alpha = 0,
    --bgColor = "#575757",
    --fgColor = "#dcdccc",
    bgColor = "#2f343f",
    --fgColor = "#2f343f",
    fgColor = "#afb8c5",
    position = TopSize C 100 24,
    lowerOnStart = True,
    commands = [
        -- Gather and format CPU usage information.
        -- If it's above 50%, we consider it high usage and make it red.
        Run MultiCpu       [ 
        "--template" , "CPU: <total0>%|<total1>%"
        , "--Low"      , "50"         -- units: %
        , "--High"     , "85"         -- units: %
        , "--low"      , "darkgreen"
        , "--normal"   , "darkorange"
        , "--high"     , "darkred"
        ] 10,

        
        --Run Network "wlp3s0" ["-L","0","-H","32","--normal","green","--high","red"] 10,
        
        -- battery monitor
        Run BatteryP ["BAT0", "BAT1", "BAT2"]        [
        "--template" , "<acstatus> <left>% - <timeleft>",
        "--Low"      , "10",        -- units: %
        "--High"     , "80",        -- units: %
        "--low"      , "darkred",
        "--normal"   , "darkorange",
        "--high"     , "darkgreen",
        "--", -- battery specific options
                "--off-icon-pattern", "<fn=1>\xf240</fn>",
                "--on-icon-pattern", "<fn=1>\xf0e7</fn>",
                "--idle-icon-pattern", "<fn=1>\xf0e7</fn>",
               -- discharging status
                "-o"    , "<leftipat>",
                -- AC "on" status
                "-O"    , "<leftipat>",
                -- charged status
                "-i"    , "<leftipat>"
                --"-i"  , "<fn=1>\xf240</fn>",
                --"-o"   , "<left>% (<timeleft>)",
               -- AC "on" status
                --"-O"   , "<fc=#dAA520>Charging</fc>",
               -- charged status
                --"-i"   , "<fc=#006000>Charged</fc>"
        ] 50,

        -- brightness
        Run Com "/bin/bash" [
        "-c", "echo `xbacklight -get | grep -oE '^.[0-9]{0,3}'`%"
        ]  "mybright" 1,

        Run Date "%a %_d %b %H:%M" "date" 10,

        Run Wireless "wlp3s0" [
        "-t", "<fn=1>\xf1eb</fn>  <essid>",
        "-x", "Not Connected"
        ] 10,

        -- Run Network "enp2s0" [
        -- "-L","0",
        -- "-H","32",
        -- "--normal","green",
        -- "--high","red"
        -- ] 10,

        Run Com "/bin/bash" [
        "-c", "amixer sget Master | grep -Ewi '[0-9]{0,3}%' -o"
        ] "volume" 10,

        Run UnsafeStdinReader
    ], 
    sepChar = "%",
    alignSep = "}{",
    template = "  %UnsafeStdinReader% } %date% { %multicpu%  %wlp3s0wi%    %battery%   Lum:%mybright%  Volume: <fc=#b2b2ff>%volume%</fc>  <action=`oblogout` button=1><raw=1:X/></action>"
}
