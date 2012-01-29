local oo            = require("loop.simple")
local AppletMeta    = require("jive.AppletMeta")
local appletManager = appletManager
local jiveMain      = jiveMain

module(...)
oo.class(_M, AppletMeta)

function jiveVersion(self)
  return 1, 1
end

function registerApplet(meta)
  jiveMain:addItem(
    meta:menuItem('RatpBusTimeApplet', 'home', "Horaires Bus", function(applet, ...)
      applet:menu(...)
    end, 20, nil, 'hm_settingsPlugin'))
end

function defaultSettings(meta)
  return { stations = {} }
end

