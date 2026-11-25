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

-- Window switcher: hold SUPER, press Tab (SHIFT + Tab goes back) to move
-- through the windows, release SUPER to focus the selected one; Escape
-- cancels. Windows are a stack, most recently focused on top, starting on the
-- one below the current window. While it runs the "switcher" submap is
-- active; hyprland-window-switcher only draws the list in fuzzel.
local SWITCHER = "switcher"
local LIST = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hyprland-window-switcher.tsv"
-- Running switch: { wins = windows in stack order, index = selected one,
-- gen = which switch this is }, nil otherwise.
local sw = nil
-- Both start from the clock: the drawing script keeps the last values it saw
-- in files that outlive a config reload, which resets these.
local gen = os.time() * 1000
-- Orders the drawing script's calls, so a late one cannot redraw a stale list.
local seq = os.time() * 1000

local function draw(args)
  seq = seq + 1
  hl.exec_cmd(string.format("hyprland-window-switcher %d %s", seq, args))
end

local function stack()
  local wins = {}
  for _, w in ipairs(hl.get_windows()) do
    -- Special workspaces have no id (their `special` flag is not reliable).
    local id = w.workspace and w.workspace.id
    if w.mapped and not w.hidden and id and id > 0 then
      wins[#wins + 1] = w
    end
  end
  table.sort(wins, function(a, b) return a.focus_history_id < b.focus_history_id end)
  return wins
end

function wm.switch(step)
  if not sw then
    local wins = stack()
    if #wins == 0 then return end
    local f = io.open(LIST, "w")
    if not f then return end
    for _, w in ipairs(wins) do
      local clean = function(s) return (tostring(s or ""):gsub("[\t\n]", " ")) end
      f:write(w.workspace.id, "\t", clean(w.class), "\t", clean(w.title), "\n")
    end
    f:close()
    gen = gen + 1
    sw = { wins = wins, index = 1, gen = gen, seen_held = false }
    hl.dispatch(hl.dsp.submap(SWITCHER))
    -- Releasing SUPER focuses the selection. A release bind cannot catch it:
    -- Hyprland only fires one that was armed when its keys went down, and
    -- SUPER went down before the submap was entered. So poll the key instead.
    -- Only commit once SUPER was seen held, so a missed read leaves Enter or
    -- Escape to finish rather than switching at once.
    sw.timer = hl.timer(function()
      if not sw then return end
      if hl.is_key_down("Super_L") or hl.is_key_down("Super_R") then
        sw.seen_held = true
      elseif sw.seen_held then
        wm.switch_commit()
      end
    end, { timeout = 25, type = "repeat" })
  end
  sw.index = (sw.index - 1 + step) % #sw.wins + 1
  draw(string.format("show %d %d", sw.gen, sw.index - 1))
end

local function finish()
  local w = sw and sw.wins[sw.index]
  if sw and sw.timer then sw.timer:set_enabled(false) end
  sw = nil
  hl.dispatch(hl.dsp.submap("reset"))
  draw("hide")
  return w
end

function wm.switch_commit()
  if not sw then return end
  local target = finish()
  -- The window may have closed while the list was up.
  for _, w in ipairs(hl.get_windows()) do
    if w.address == target.address then
      hl.dispatch(hl.dsp.focus({ window = w }))
      return
    end
  end
end

function wm.switch_cancel()
  if sw then finish() end
end

-- A click on an entry (index counts from 0) in switch `g`.
function wm.switch_pick(g, index)
  if not sw or sw.gen ~= g or not sw.wins[index + 1] then return end
  sw.index = index + 1
  wm.switch_commit()
end

hl.define_submap(SWITCHER, function()
  hl.bind("SUPER + Tab", function() wm.switch(1) end)
  hl.bind("SUPER + SHIFT + Tab", function() wm.switch(-1) end)
  hl.bind("SUPER + Escape", wm.switch_cancel)
  hl.bind("Escape", wm.switch_cancel)
end)

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
