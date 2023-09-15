-- MouseCircle example (tweaked)
mouseCircle = nil
mouseCircleTimer = nil

function mouseHighlight()
    -- Delete an existing highlight if it exists
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    -- Get the current co-ordinates of the mouse pointer
    mousepoint = hs.mouse.absolutePosition()
    -- Prepare a big red circle around the mouse pointer
    local r = 30
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x - r, mousepoint.y - r, 2 * r, 2 * r))
    mouseCircle:setStrokeColor({red=1, blue=0, green=0, alpha=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(5)
    mouseCircle:show()

    -- Set a timer to delete the circle after 2 seconds
    mouseCircleTimer = hs.timer.doAfter(2, function()
        mouseCircle:delete()
        mouseCircle = nil
    end)
end
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "O", mouseHighlight)


-- AClock spoon
hs.loadSpoon("AClock")
spoon.AClock["textColor"] = {red=.6, alpha=.75}
spoon.AClock["textFont"] = "Recursive Casual Bold"
spoon.AClock["textSize"] = 300
spoon.AClock["format"] = "%I:%M"
spoon.AClock["height"] = 600
spoon.AClock["width"] = 1000
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "K", function()
    spoon.AClock:toggleShow()
end)
clock_screen_watcher = hs.screen.watcher.newWithActiveScreen(
    function() spoon.AClock:init() end
):start()


-- Text-mode "menu bar indicator" replacement
canvas = nil
function createCanvas()
    if canvas then
        canvas:hide()
    end
    local screen = hs.screen.primaryScreen()
    local frame = screen:frame()
    local fullFrame = screen:fullFrame()
    canvas = hs.canvas.new({
        x = fullFrame.x,
        y = frame.y,
        w = frame.x - fullFrame.x,
        h = 175,
    })
    canvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {hex="#D0D0D0"},
    }
    canvas[2] = {
        type = "text",
        frame = {x=2, y=0, h="100%", w="100%"},
        textFont = "SF Pro Text",
        textSize = 14,
        textColor = {hex="#000000"},
    }
    canvas:show()
    canvas:sendToBack()
    drawInfo()
end

function drawInfo()
    text = ""
    text = text .. os.date("%I:%M\n%b %d\n"):gsub("^0", ""):gsub(" 0", "")

    if hs.battery.isCharging() then
        charge = "+"
    elseif hs.battery.isCharged() then
        charge = ""
    else
        charge = "-"
    end
    text = text .. string.format("%d%%%s\n", hs.battery.percentage(), charge)

    audio = hs.audiodevice.current()
    if audio.muted then
        vol = "\u{20e5}"
    elseif audio.volume then
        vol = string.format("%d", math.floor(audio.volume + 0.5))
    else
        vol = "—"
    end
    text = text .. "\u{24cb}" .. vol .. "\n"

    wifirate = hs.wifi.interfaceDetails().transmitRate
    text = text .. string.format("%d\u{2933}\n", wifirate)

    ssid = hs.wifi.currentNetwork()
    if string.len(ssid) > 5 then
        ssid = string.sub(ssid, 1, 3) .. string.sub(ssid, string.len(ssid)-1)
    end
    text = text .. ssid
    canvas[2].text = text
end

createCanvas()

-- Start over when any screen geometry changes.
watcher = hs.screen.watcher.newWithActiveScreen(createCanvas):start()
-- Redraw every 10 seconds.
timer = hs.timer.doEvery(10, drawInfo)
-- Redraw when any audio setting changes.
for i, dev in ipairs(hs.audiodevice.allOutputDevices()) do
    dev:watcherCallback(drawInfo):watcherStart()
end

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Q", hs.reload)
