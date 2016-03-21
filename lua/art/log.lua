local log = {}

log.level = 2

local function logger(name, level)
  return function(...)
    if level >= log.level then
      print(name .. ": " .. string.format(...))
    end
  end
end

log.debug = logger("debug", 0)
log.info = logger("info", 1)
log.warn = logger("warning", 2)
log.error = logger("ERROR", 3)
log.fatal = logger("FATAL", 4)

return log
