--[[
<?xml version='1.0' encoding='utf8'?>
<event name="Additional Options">
 <location>load</location>
 <chance>100</chance>
</event>
--]]

local luatk = require "luatk"
local fmt = require "format"

local difficulty_settings_gui
local last_time
local wealth_maintenance_rate

function create ()
  local maint_func = "apply_maintenance"
  hook.land(maint_func)
  hook.takeoff(maint_func)
  hook.jumpin(maint_func)
  
  last_time = time.get()

  player.infoButtonRegister( _("Additional Options"), difficulty_settings_gui)

  wealth_maintenance_rate = var.peek("wealth_maintenance_rate")
  if (wealth_maintenance_rate == nil) then
    var.push("wealth_maintenance_rate", 0)
    wealth_maintenance_rate = 0
  end
end

function apply_maintenance ()
  local new_time = time.get()
  local time_since_last_run = new_time - last_time
  last_time = new_time

  if (wealth_maintenance_rate > 0) then
    local cycles_since_last_run = time.tonumber(time_since_last_run) / time.tonumber(time.new(0,1,0))
    local wealth_maintenance = player.wealth() * wealth_maintenance_rate * cycles_since_last_run
    player.msg("Maintenance costs for last " .. time.str(time_since_last_run) .. ": " .. fmt.credits(wealth_maintenance))
    player.pay (-wealth_maintenance)
  end
end

function difficulty_settings_gui ()
  local w, h = 600, 420
  local wdw = luatk.newWindow( nil, nil, w, h )
  wdw:setCancel( luatk.close )
  luatk.newText( wdw, 0, 10, w, 20, _("Additional Options"), nil, "center" )

  local y = 55+120+20

  local wealth_maintenance_rate_text_box = luatk.newText( wdw, 20, y, w, 20, _("Wealth maintenance rate per period (%):") )
  local txtw = math.max( wealth_maintenance_rate_text_box:width() )

  local wealth_maintenance_box = luatk.newInput( wdw, 20+txtw+20, y, w-40-txtw-40, 30, 50 )
  wealth_maintenance_box:set( tostring(wealth_maintenance_rate * 100) )

  local function update_on_close ()
    wealth_maintenance_rate = tonumber(wealth_maintenance_box:get()) / 100
    var.push("wealth_maintenance_rate", wealth_maintenance_rate)
    luatk.close()
  end

  luatk.newButton( wdw, -20, -20, 80, 40, _("Close"), update_on_close )
  luatk.run()
end
