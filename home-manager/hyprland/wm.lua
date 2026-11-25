-- Workspace and window helpers for the binds in hyprland.nix.
--
-- Layout: workspaces 1-5 belong to the main monitor, 6-10 to the secondary
-- one. The main monitor is the external display when one is connected and the
-- laptop panel otherwise. Higher workspaces (one per app) stay wherever they
-- were opened.

wm = {}

local LAPTOP = "eDP-1"
local PER_MONITOR = 5

-- Set when a number key was used while Space was held, so releasing Space
-- does not also open the launcher.
local chord = false
-- Workspace -> time its app was last started, to ignore a repeated key press
-- while the app is still opening its window.
local launched = {}

-- Returns the main and secondary monitor (the same one if only one exists).
local function monitors()
  local all = hl.get_monitors()
  table.sort(all, function(a, b) return a.id < b.id end)

  local main
  for _, m in ipairs(all) do
    if m.name ~= LAPTOP then
      main = m
      break
    end
  end
  main = main or all[1]
  if not main then return nil, nil end

  local side
  for _, m in ipairs(all) do
    if m.name ~= main.name then
      if m.name == LAPTOP then
        side = m
        break
      end
      side = side or m
    end
  end
  return main, side or main
end

-- The monitor workspace `n` belongs to, or nil if it is not tied to one.
local function home(n)
  local main, side = monitors()
  if n <= PER_MONITOR then return main end
  if n <= 2 * PER_MONITOR then return side end
  return nil
end

-- Moves workspace `n` to its monitor if it exists somewhere else.
local function place(n)
  local mon = home(n)
  local ws = hl.get_workspace(n)
  if mon and ws and ws.monitor and ws.monitor.name ~= mon.name then
    hl.dispatch(hl.dsp.workspace.move({ workspace = n, monitor = mon.name }))
  end
  return mon
end

-- SUPER + 1-5 is the main monitor; with Space held it is the secondary one.
local function resolve(n)
  if hl.is_key_down("space") then
    chord = true
    return n + PER_MONITOR
  end
  return n
end

function wm.go(n)
  n = resolve(n)
  local mon = place(n)
  -- A workspace that does not exist yet is created on the focused monitor.
  if mon and not hl.get_workspace(n) then
    hl.dispatch(hl.dsp.focus({ monitor = mon.name }))
  end
  hl.dispatch(hl.dsp.focus({ workspace = n }))
end

function wm.send(n)
  n = resolve(n)
  hl.dispatch(hl.dsp.window.move({ workspace = n }))
  place(n)
end

-- Jump to an app's workspace and start the app there if nothing is open.
function wm.app(n, cmd)
  hl.dispatch(hl.dsp.focus({ workspace = n }))
  local ws = hl.get_workspace(n)
  if ws and ws.windows > 0 then return end
  local now = os.time()
  if launched[n] and now - launched[n] < 10 then return end
  launched[n] = now
  hl.exec_cmd(cmd)
end

function wm.launcher_down()
  chord = false
end

function wm.launcher_up(cmd)
  if not chord then hl.exec_cmd(cmd) end
  chord = false
end

-- Put every existing workspace on its monitor and make each monitor show one
-- of its own workspaces.
function wm.arrange()
  local main, side = monitors()
  if not main then return end
  for n = 1, 2 * PER_MONITOR do place(n) end
  if main.name == side.name then return end

  local active = hl.get_active_window()

  -- Emptying a monitor makes Hyprland open a fresh workspace on it, which may
  -- carry a number that belongs to the other monitor.
  local function show(name, first)
    local mon = hl.get_monitor(name)
    local id = mon and mon.active_workspace and mon.active_workspace.id
    if not id or id > 2 * PER_MONITOR then return end
    if id >= first and id < first + PER_MONITOR then return end
    hl.dispatch(hl.dsp.focus({ monitor = name }))
    hl.dispatch(hl.dsp.focus({ workspace = first }))
  end
  show(side.name, PER_MONITOR + 1)
  show(main.name, 1)

  if active then
    hl.dispatch(hl.dsp.focus({ window = active }))
  else
    hl.dispatch(hl.dsp.focus({ monitor = main.name }))
  end
end

-- Monitors are still settling when the hotplug event fires.
function wm.arrange_soon()
  wm.arrange_timer = hl.timer(wm.arrange, { timeout = 500, type = "oneshot" })
end
