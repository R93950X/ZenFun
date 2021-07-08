local width, height = term.getSize()
local oldTerm = term.current()
if width > 3*height then
    local halfwidth = math.floor(width/2)
    window1 = window.create(term.current(), 1, 1, halfwidth, height)
    window2 = window.create(term.current(), halfwidth, 1, halfwidth, height)
else
    local halfheight = math.floor(height/2)
    window1 = window.create(term.current(), 1, 1, width, halfheight)
    window2 = window.create(term.current(), 1, halfheight, width, halfheight)
end

local co1 = coroutine.create(function()
  shell.run("shell")
end)

local co2 = coroutine.create(function()
  shell.run("shell")
end)

while coroutine.status(co1) ~= "dead" and coroutine.status(co2) ~= "dead" do
  local eventData = {os.pullEventRaw()}
  term.redirect(window1)
  coroutine.resume(co1, table.unpack(eventData))
  term.redirect(window2)
  coroutine.resume(co2, table.unpack(eventData))
end
term.redirect(oldTerm)
term.setCursorPos(1,1)
term.clear()