
local pairs, tonumber, tostring = pairs, tonumber, tostring
local io                     = require("io")
local oo                     = require("loop.simple")
local math                   = require("math")
local string                 = require("string")
local table                  = require("jive.utils.table")
local debug                  = require("jive.utils.debug")
local os                     = require("os")

local Applet                 = require("jive.Applet")
local System                 = require("jive.System")
local Checkbox               = require("jive.ui.Checkbox")
local Choice                 = require("jive.ui.Choice")
local Framework              = require("jive.ui.Framework")
local Event                  = require("jive.ui.Event")
local Icon                   = require("jive.ui.Icon")
local Label                  = require("jive.ui.Label")
local Button                 = require("jive.ui.Button")
local Popup                  = require("jive.ui.Popup")
local Group                  = require("jive.ui.Group")
local RadioButton            = require("jive.ui.RadioButton")
local RadioGroup             = require("jive.ui.RadioGroup")
local SimpleMenu             = require("jive.ui.SimpleMenu")
local Slider                 = require("jive.ui.Slider")
local Surface                = require("jive.ui.Surface")
local Textarea               = require("jive.ui.Textarea")
local Textinput              = require("jive.ui.Textinput")
local Window                 = require("jive.ui.Window")
local ContextMenuWindow      = require("jive.ui.ContextMenuWindow")
local Timer                  = require("jive.ui.Timer")
local Keyboard               = require("jive.ui.Keyboard")

local http                   = require("socket.http")
local ltn12                  = require("ltn12")

local appletManager = appletManager

module(..., Framework.constants)
oo.class(_M, Applet)

local httpHeaders = {
  ['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:5.0.1) Gecko/20100101 Firefox/5.0.1",
  ["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  ["Accept-Language"] = "fr,fr-fr;q=0.8,en-us;q=0.5,en;q=0.3",
  ["Accept-Charset"] = "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
}
local entities = {
  ["&amp;"   ] = "&",
  ["&lt;"    ] = "<",   ["&gt;"    ] = ">",
  ["&quot;"  ] = '"',
  ["&nbsp;"  ] = ' ',
  ["&iquest;"] = "¿",
  ["&Aacute;"] = "Á",   ["&aacute;"] = "á",
  ["&Eacute;"] = "É",   ["&eacute;"] = "é",
  ["&Iacute;"] = "Í",   ["&iacute;"] = "í",
  ["&Oacute;"] = "Ó",   ["&oacute;"] = "ó",
  ["&Uacute;"] = "Ú",   ["&uacute;"] = "ú",
  ["&Ntilde;"] = "Ñ",   ["&ntilde;"] = "ñ",
  ["&Agrave;"] = "À",   ["&agrave;"] = "à",
  ["&sect;"  ] = "§",
  ["&szlig;" ] = "ß",
  ["&Auml;"  ] = "Ä",   ["&auml;"  ] = "ä",
  ["&Ccedil;"] = "Ç",   ["&ccedil;"] = "ç",
  ["&Egrave;"] = "È",   ["&egrave;"] = "è",
  ["&Euml;"  ] = "Ë",   ["&euml;"  ] = "ë",
  ["&Igrave;"] = "Ì",   ["&igrave;"] = "ì",
  ["&Iuml;"  ] = "Ï",   ["&iuml;"  ] = "ï",
  ["&Ograve;"] = "Ò",   ["&ograve;"] = "ò",
  ["&Ouml;"  ] = "Ö",   ["&ouml;"  ] = "ö",
  ["&Ugrave;"] = "Ù",   ["&ugrave;"] = "ù",
  ["&Uuml;"  ] = "Ü",   ["&uuml;"  ] = "ü",
  ["&ecirc;" ] = "ê",   ["&Ecirc;" ] = "Ê",
}
local function htmlEntitiesDecode(str)
  local clean = string.gsub(str, "&[a-zA-Z]+;",
    function (v)
      if entities[v] then return entities[v] else return v end
    end
  )
  return clean
end

function showTimes(self, menuItem, station)
  local url = station.link
  local body = {}
  local page, err = http.request{
    url = url,
    method = 'GET',
    headers = httpHeaders,
    sink = ltn12.sink.table(body)
  }
  local title = "Connexion impossible"
  local message = "Impossible de se connecter sur les serveurs de la Ratp. Merci de vérifier votre connexion et de réessayer plus tard."
  if body then
    body = htmlEntitiesDecode(table.concat(body, ""))
    local arret = string.match(body, 't <b class="bwhite">([^<]+)')

    local ndate, heure  = string.match(body, '<div class="bg2">([^%)]+)%(([0-9:]+)%)</div>')

    local times = {}
    for time in string.gmatch(body, '<div class="schmsg1"><b>([0-9]+) mn</b>') do
      times[#times+1] = os.date('%H:%M', os.time() + (tonumber(time) * 60))
    end
    for time in string.gmatch(body, '<div class="schmsg3"><b>([0-9]+) mn</b>') do
      times[#times+1] = os.date('%H:%M', os.time() + (tonumber(time) * 60))
    end

    local dirs = {}
    for direction in string.gmatch(body, 'Direction <b class="bwhite">([^<]+)</b>') do
      dirs[#dirs+1] = direction
    end

    title = station.line.." "..arret

    if dirs[1] and times[1] and times[3] then
      message = "Dir. "..dirs[1].." : "..times[1].." ... "..times[3]
      if dirs[2] and times[2] and times[4] then
        message = message.."\nDir. "..dirs[2].." : "..times[2].." ... "..times[4]
      end
    end
  end

	local window = Window("horaires", title, 'settingstitle')
	window:addWidget(Textarea("text", message))
	self:tieAndShowWindow(window)
	return window
end

function listStations(self, menuItem, bus)
  local url = bus.link

  -- donne la liste des stations
  local stations = {}
  local body = {}
  local page, err = http.request{
    url = url,
    method = 'GET',
    headers = httpHeaders,
    sink = ltn12.sink.table(body)
  }
  body = htmlEntitiesDecode(table.concat(body, ""))
  body:gsub('lineid=([^&]+)&stationid=([^"]+)">([^<]+)', function(lineId, stationId, stationName)
    table.insert(stations, {id = stationId, link = 'http://wap.ratp.fr/siv/schedule?service=next&reseau=bus&lineid='..lineId..'&stationid='..stationId, title = stationName, line = bus.num})
  end)

	local window = Window("text_list", "Liste des stations")
  local menu = SimpleMenu('menu', items)
  local settings = self:getSettings()
  if not settings.stations then
    settings.stations = {}
  end

	for _,station in pairs(stations) do
	  local selected = false
    if settings.stations[station.id] then
      selected = true
    end
		menu:addItem( {
			text = station.title,
			style = 'item_choice',
			check = Checkbox("checkbox", 
				function(object, isSelected)
					local settings = self:getSettings()

					if isSelected then
						-- turn it on
						settings.stations[station.id] = station
					else
						-- turn it off
						settings.stations[station.id] = nil
					end
					self:storeSettings()
				end,
			selected),
		})
	end
	window:addWidget(menu)
	self:tieAndShowWindow(window)
	return window
end

function addStation(self, menuItem)
  -- donne la liste des catalogues de lignes
  local url  = "http://wap.ratp.fr/siv/schedule?service=next&reseau=bus&referer=line&linecode=*"
  local urls = {}
  local body = {}
  local page, err = http.request{
    url = url,
    method = 'GET',
    headers = httpHeaders,
    sink = ltn12.sink.table(body)
  }
  body = htmlEntitiesDecode(table.concat(body, ""))
  body:gsub('start=([^&]+)', function(start)
      table.insert(urls, 'http://wap.ratp.fr/siv/schedule?service=next&reseau=bus&start=' .. start .. '&linecode=*&referer=line')
  end)

  -- donne la liste des bus
  body = {}
  local busList = {}
  for _, url in pairs(urls) do
    local body = {}
    local page, err = http.request{
      url = url,
      method = 'GET',
      headers = httpHeaders,
      sink = ltn12.sink.table(body)
    }
    body = htmlEntitiesDecode(table.concat(body, ""))
    body:gsub('<div class="bg1"><img alt="%[([^%]]+)%]%s*" class="float" src="([^"]+)"><a href="([^"]+)">([^<]+)</a></div>', 
      function(alt, src, link, title)
        local bus = link:match('lineid=([^&]+)')
        if bus then
          link = "http://wap.ratp.fr/siv/schedule?service=next&reseau=bus&lineid="..bus.."&referer=station&stationname=*"
          table.insert(busList, {id = bus, num = alt, link = link, title = title})
        end
      end)
  end
  
  if #busList > 0 then
  	local window = Window("text_list", "Liste des bus")
  	local items = {}
  	for _,bus in pairs(busList) do
      -- Load icon from URL
      --local icon = jive.ui.Icon("icon")
      --local http = SocketHttp(jnt, host, port, "example")
      --local req = RequestHttp(icon:getSink())
      --http:fetch(req)
  		items[#items + 1] = { 
  			text = bus.num..' '..bus.title,
  			weight = tonumber(bus.num) or 1000,
        callback = function(event, menuItem) 
          self:listStations(menuItem, bus)
        end
  		}
  	end

  	local menu = SimpleMenu('menu', items)
    menu:setComparator(SimpleMenu.itemComparatorKeyWeightAlpha)
  	window:addWidget(menu)
  	self:tieAndShowWindow(window)
  	return window
  end
end

function menu(self, menuItem)
  local settings = self:getSettings()
  if not settings.stations then
    settings.stations = {}
  end
  local stations = settings.stations
  local menu = SimpleMenu("menu")
  for i,station in pairs(stations) do
		menu:addItem({
  		text = station.line .. " - " .. station.title,
  		callback = function(event, menuItem)
  			self:showTimes(menuItem, station)
  		end
		})
  end

  menu:addItem({
    text = "Configurer les stations",
    iconStyle = 'hm_myMusicSearch',
    callback = function(event, menuItem) 
      self:addStation(menuItem)
    end
  })

	local window = Window("text_list", "Horaires Bus")
	window:addWidget(menu)
	window:show()
end

function listSelectedBuses(self)
  
end

function addBus(self, bus)
  
end

function getNextTime(self, bus, station)
  
end

local function buildQuery(bus, station)
  local url = 'http://wap.ratp.fr/siv/schedule?service=next&reseau=bus&lineid=B%d&stationid=%s'
  return string.format(url, bus, station)
end



