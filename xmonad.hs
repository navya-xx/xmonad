module Main where

import Data.Maybe
import Graphics.X11.ExtraTypes
import System.IO
import System.Exit
--import ViewDoc
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.SpawnOn
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Place
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen
import XMonad.Layout.Gaps
import XMonad.Layout.IndependentScreens
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.ThreeColumns
import XMonad.Util.Cursor
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.WorkspaceCompare

import XMonad.Actions.WindowGo

import qualified XMonad.Hooks.EwmhDesktops as E
import qualified XMonad.StackSet as W
import qualified Data.Map as M

--------------------------------------------------
-- Settings
myTerminal = "urxvt -e fish"
myScreensaver = "xscreensaver-command --lock"

-- mySelectScreenshot = "shutter -a -o shot.png -e"
myScreenshot = "gnome-screenshot"

-- The command to use as a launcher, to launch commands that don't have
-- preset keybindings.
-- myLauncher = "$(yeganesh -x -- -fn '-*-terminus-*-r-normal-*-*-120-*-*-*-*-iso8859-*' -nb '#000000' -nf '#FFFFFF' -sb '#7C7C7C' -sf '#CEFFAC')"
myLauncher = "dmenu_run"


-- My prefered editor
--
myEditor = "subl3"
myAlternativeEditor = "vim"

myLockscreen = "sxlock"

-- Compostior settings
myCompositor = "compton -fcCz -l -17 -t -17 -b"
  --"compton --backend glx  --paint-on-overlay --unredir-if-possible    --vsync opengl-swc  -fcCz -l -17 -t -17"
  --"compton -b --backend glx --paint-on-overlay --unredir-if-possible  --glx-no-stencil  --vsync opengl-swc  -fcCz -l -17 -t -17"
--------------------------------------------------
-- workspaces
myWorkspaces = clickable workspaces
  where clickable l =
          [ "<action=xdotool key super+" ++ show i ++ " button=1>" ++ ws ++ "</action>"
          | (i,ws) <- zip ([1..9] ++ [0]) l ]
        workspaces = zipWith makeLabel [1..10] icons
        makeLabel index icon = show index ++ ": <fn=1>" ++ icon : "</fn> "
        icons = [ '\xf269', '\xf120', '\xf121', '\xf27a', '\xf128',
                  '\xf128', '\xf128', '\xf023', '\xf1b6', '\xf1bc' ]
-------------------------------------------------
-- Window rules

myManageHook = manageSpawn
--           <+> manageDocks
           <+> composeAll [
                 isDialog                        --> placeHook (smart (0.5, 0.5)) ,--(fixed (0.5, 0.5)),
                 className =? "Bash"             --> doShift (myWorkspaces !! 0),
                 className =? "Chromium"         --> doShift (myWorkspaces !! 1),
                 className =? "Emacs"            --> doShift (myWorkspaces !! 2),
                 className =? "Subl3"            --> doShift (myWorkspaces !! 2),
                 className =? "Slack"            --> doShift (myWorkspaces !! 3),
                 className =? "Spotify"          --> doShift (myWorkspaces !! 9),

                 resource  =? "desktop_window"   --> doIgnore,
                 className =? "Gimp"             --> doFloat,
                 className =? "Oblogout"         --> doFloat,
                 className =? "Vlc"              --> doShift (myWorkspaces !! 8),
                 className =? "Mplayer"          --> doShift (myWorkspaces !! 8),
                 className =? "Zeal"             --> doFloat,
                 isFullscreen --> (doF W.focusDown <+> doFullFloat)]

--------------------------------------------
-- Layout options
myLayout = myGaps (Tall 1 (3/100) (1/2))
       ||| ThreeColMid 1 (3/100) (1/2)
       ||| noBorders (fullscreenFull Full)
  where myGaps = lessBorders OnlyFloat
                 . avoidStruts
                 . spacing 0
                 . gaps [(U,0), (D,0), (R,0), (L,0)]


------------------------------------------------------------------------
-- Colors and borders

--myNormalBorderColor  = "#AD795B"
--myNormalBorderColor  = "#D39A78"
myNormalBorderColor = "#2F343F"
--myNormalBorderColor = "#B8CDD4"
--myNormalBorderColor = "#9aebf9"
myFocusedBorderColor = "#AD795B"

-- Color of current window title in xmobar.
xmobarTitleColor = "#FFB6B0"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#Af745f"
--xmobarCurrentWorkspaceColor = "#58EBED"

-- Width of the window border in pixels.
--myBorderWidth = 8
myBorderWidth = 1

-----------------------------------------------
-- My keybindings

myModMask = mod4Mask

-- mySink = "alsa_output.pci-0000_00_1f.3.analog-stereo"

myKeys conf@XConfig{XMonad.modMask = modMask} = M.fromList $ [
  -- Start the terminal specified by myTerminal variable
  ((modMask, xK_Return),
    spawn $ XMonad.terminal conf)

  -- Lock the screen using command specified by myScreensaver
  ,((modMask .|. controlMask, xK_l),
      spawn myScreensaver)

  -- Take a screenshot using the command specified by mySelectScreenshot
  ,((modMask .|. shiftMask , xK_p),
      spawn myScreenshot)

  -- Spawn the launcher using command specified by myLauncher
  , ((modMask, xK_space),
     spawn myLauncher)
  
  -- Mute volume.
  , ((0, xF86XK_AudioMute),
     spawn "amixer -q set Master toggle")

  -- Decrease volume.
  , ((0, xF86XK_AudioLowerVolume),
     spawn "amixer -q set Master 5%-")

  -- Increase volume.
  , ((0, xF86XK_AudioRaiseVolume),
     spawn "amixer -q set Master 5%+")

  -- Toggle MIC
  , ((0, xF86XK_AudioMicMute),
    spawn "amixer -q set 'Capture' toggle")

  -- Audio previous
  --,((0, xF86XK_AudioPrev),
  --  spawn "playerctl previous")

    -- Play/pause
  --,((0, xF86XK_AudioPlay),
  --   spawn "playerctl play-pause")

    -- Audio next
  --,((0, xF86XK_AudioNext),
  --  spawn "playerctl next")

  -- brightness controlls
  , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 5")
  , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 5")

  -- Move to the next open workspace
  -- ,((modMask .|. shiftMask, xK_Tab), moveToNextNonEmptyNoWrap)
  ,((modMask, xK_Right), moveToNextNonEmptyNoWrap)

  -- Move to the previous open workspace
  --,((modMask .|. shiftMask .|. mod1Mask, xK_Tab), moveToPrevNonEmptyNoWrap)
  ,((modMask, xK_Left), moveToPrevNonEmptyNoWrap)

  -- Move to the next empty workspace
  ,((modMask, xK_e), moveTo Next EmptyWS)

        -- Move to the next empty workspace
   --,((modMask, xK_e), moveTo Next EmptyWS)

   --,((modMask .|. mod1Mask, xK_w), toggleHDMI)

   ------  Egen skit
   , ((modMask .|. shiftMask, xK_e), (windows $ W.view "3") >> raiseEditor)
   , ((modMask, xK_Escape), spawn myLockscreen)
    
    -- Bindings for xmonad-session
    -- ((modm, xK_s), toggleSaveState),

    -- ((modm .|. shiftMask, xK_s), launchDocuments),

    -- Disable touchpad
    , ((modMask, xK_k),
      spawn "xinput disable $(xinput list --id-only 'Synaptics TM3053-004')")

    -- Enable touchpad
    , ((modMask, xK_j), 
      spawn "xinput enable $(xinput list --id-only 'Synaptics TM3053-004')")

    -- Invert colors
    , ((mod4Mask .|. shiftMask, xK_i), 
      spawn "xrandr-invert-colors")

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

    -- Close focused window
   ,((modMask .|. shiftMask, xK_w),
     kill),

    -- Cycle through the available layout algorithms
    ((modMask .|. shiftMask, xK_Right),
     sendMessage NextLayout),

    --  Reset the layouts on the current workspace to default
    ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf),

    -- Resize viewed windows to the correct size
    ((modMask, xK_n),
     refresh),

    -- Move focus to the next window
    ((modMask, xK_Tab),
     windows W.focusDown),

    -- Move focus to the next window
    --((modMask, xK_j),
    -- windows W.focusDown),

    -- Move focus to the previous window
    --((modMask, xK_k),
    -- windows W.focusUp),

    -- Move focus to the master window
    --((modMask, xK_m),
    -- windows W.focusMaster),

    -- Swap the focused window and the master window
    --((modMask .|. shiftMask, xK_Return),
    -- windows W.swapMaster),

    -- Swap the focused window with the next window
    --((modMask .|. shiftMask, xK_j),
    -- windows W.swapDown),

    -- Swap the focused window with the previous window
    --((modMask .|. shiftMask, xK_k),
    -- windows W.swapUp),

    -- Shrink the master area
    ((modMask, xK_h),
     sendMessage Shrink),

    -- Expand the master area
    ((modMask, xK_l),
     sendMessage Expand),

    -- Push window back into tiling
    ((modMask, xK_t),
     withFocused $ windows . W.sink),

    -- Increment the number of windows in the master area
    ((modMask, xK_comma),
     sendMessage (IncMasterN 1)),

    -- Decrement the number of windows in the master area
    ((modMask, xK_period),
     sendMessage (IncMasterN (-1))),

    -- Quit xmonad
    ((modMask .|. shiftMask, xK_q),
     io exitSuccess),

    -- Restart xmonad
    ((modMask, xK_q),
     restart "xmonad" True)
  ]
  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0])
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

compareToCurrent :: X (WindowSpace -> Ordering)
compareToCurrent =
    do comp <- getWsCompare
       ws <- gets windowset
       let cur = W.workspace (W.current ws)
       return $ comp (W.tag cur) . W.tag

greaterNonEmptyWs =
    do comp <- compareToCurrent
       return (\w -> comp w == LT && isJust (W.stack w))

lessNonEmptyWs =
    do comp <- compareToCurrent
       return (\w -> comp w == GT && isJust (W.stack w))


moveToNextNonEmptyNoWrap = moveTo Next (WSIs greaterNonEmptyWs)
moveToPrevNonEmptyNoWrap = moveTo Prev (WSIs lessNonEmptyWs)

toggleHDMI :: X ()
toggleHDMI = do
  count <- countScreens
  spawn $ "echo " ++ show count ++ " >> ~/test.txt"
  if count > 1
    then spawn "xrandr --output HDMI1 --off"
    else spawn "sleep 0.3; xrandr --output HDMI1 --auto --scale 2x2 --right-of eDP1"

------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings XConfig {XMonad.modMask = modMask} = M.fromList
  [
    -- Set the window to floating mode and move by dragging
    ((modMask, button1),
     \w -> focus w >> mouseMoveWindow w),

    -- Raise the window to the top of the stack
    ((modMask, button2),
       \w -> focus w >> windows W.swapMaster),

    -- Set the window to floating mode and resize by dragging
    ((modMask, button3),
       \w -> focus w >> mouseResizeWindow w)
  ]


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.

myStartupHook = --spawn "source ~/.fehbg"
            -- spawn myCompositor
            -- <+> spawn "xcreensaver"
            setDefaultCursor xC_left_ptr
            -- <+> spawn "hsetroot -solid '#F5F6F7'"
            -- <+> spawn "xinput --set-prop 13 290 1"
            -- <+> spawn "xinput --set-prop 13 302 0"
            <+> spawn "~/bin/libinput-gestures"
            -- <+> spawn "/usr/bin/enpass"
            -- <+> spawn "xrandr --output HDMI1 --off"
            -- <+> spawn "xrandr --output HDMI1 --auto --right-of eDP1"
            <+> setWMName "LG3D"
	    <+> spawn "xmodmap ~/xmodmap.conf"


-----------------------------------------------------------------------
-- Log hook


myLogHook xmproc = do
    -- fadeInactiveLogHook 0.5
    dynamicLogWithPP $ xmobarPP {
      ppOutput = hPutStrLn xmproc,
      ppTitle = xmobarColor xmobarTitleColor "" . shorten 100,
      -- ppLayout = const "",
      ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "",
      ppSep = "   "
}

------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.

main = do
  xmproc <- spawnPipe "xmobar -d ~/.xmonad/xmobar.hs"
  xmonad $ docks defaults {
    logHook = myLogHook xmproc
    }



------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.

defaults = def {
    -- simple stuff
    terminal           = myTerminal,
    --focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    keys               = myKeys,
    --mouseBindings      = myMouseBindings,

    -- hooks, layouts
    layoutHook         = myLayout,
    manageHook         = myManageHook,
    startupHook        = myStartupHook,
    handleEventHook    = E.fullscreenEventHook
}
