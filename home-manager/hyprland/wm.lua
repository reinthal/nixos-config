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

-- Focus the next (step 1) or previous (step -1) window, across all regular
-- workspaces, ordered by workspace and then by position on screen.
function wm.cycle(step)
  local wins = {}
  for _, w in ipairs(hl.get_windows()) do
    -- Special workspaces have no id (their `special` flag is not reliable).
    local id = w.workspace and w.workspace.id
    if w.mapped and not w.hidden and id and id > 0 then
      wins[#wins + 1] = w
    end
  end
  if #wins == 0 then return end

  local function key(w)
    local at = type(w.at) == "table" and w.at or {}
    return w.workspace.id, at.x or at[1] or 0, at.y or at[2] or 0
  end
  table.sort(wins, function(a, b)
    local aw, ax, ay = key(a)
    local bw, bx, by = key(b)
    if aw ~= bw then return aw < bw end
    if ax ~= bx then return ax < bx end
    if ay ~= by then return ay < by end
    return a.address < b.address
  end)

  local active = hl.get_active_window()
  local index
  for i, w in ipairs(wins) do
    if active and w.address == active.address then index = i end
  end
  if not index then index = step > 0 and 0 or 1 end

  local target = wins[(index - 1 + step) % #wins + 1]
  hl.dispatch(hl.dsp.focus({ window = target }))
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
