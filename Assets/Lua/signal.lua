--@ signal class 
--@ signal.new -> signal; 
--@ signal:(new, connect, close, fire, once)
local signal = { }; 
signal.__index = signal; 

function signal.new()
    local new_signal = { };
    new_signal.listeners = { }; 

    setmetatable(new_signal, signal);
    return new_signal;
end; 

function signal.connect(self, call_back)
    local listener = { };
    listener.call_back = call_back;
    listener.id = #self.listeners + 1;  

    function listener.close(self)
        listener = nil;
        table.remove(self.listeners, listener.id);
    end; 

    table.insert(self.listeners, listeners); 
end; 

function signal.fire(self, ...)
    self.waiting = false; 

    for i, listener in pairs(self.listeners) do 
        listener.call_back(...);
    end; 
end;

function signal.close(self)
    table.clear(self);
end; 

function signal.once(self, call_back)
    local temp; temp = self:connect(function()
        temp:close(); 
        call_back();
    end);
end; 

return signal
