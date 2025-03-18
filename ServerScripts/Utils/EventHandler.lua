local EventHandler = {
    callbacks = {}
}

function EventHandler:new()
    local newObj = { callbacks = {} }
    self.__index = self
    return setmetatable(newObj, self)
end

function EventHandler:Add(callback)
    table.insert(self.callbacks, callback)
end

function EventHandler:Fire(...)
    for _, callback in ipairs(self.callbacks) do
        callback(...)
    end
end

function EventHandler:Count()
    return #self.callbacks
end

function EventHandler:Clear()
    self.callbacks = {}
end

return EventHandler