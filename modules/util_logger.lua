
logger = {
    loggers = {
        debug = false,
        info = false,
        normal = true
    }
}

function logger.toggle_logger(logger, toggle)
    loggers[logger] = toggle
end

function logger.log(id, group, msg)
    if (loggers[id] ~= nil and loggers[id] == true) then
        api_log(group, msg)
    end
end