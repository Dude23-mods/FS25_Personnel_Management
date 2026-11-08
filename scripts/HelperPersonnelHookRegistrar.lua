HelperPersonnelHookRegistrar = HelperPersonnelHookRegistrar or {}
HelperPersonnelHookRegistrar.records = HelperPersonnelHookRegistrar.records or {}
HelperPersonnelHookRegistrar.instanceRecords = HelperPersonnelHookRegistrar.instanceRecords or setmetatable({}, {__mode = "k"})

function HelperPersonnelHookRegistrar:install(owner, methodName, hookKind, hookFunction, hookKey, purpose, side)
    if owner == nil or methodName == nil or hookFunction == nil or hookKey == nil then
        return false
    end

    local record = self.records[hookKey]
    if record ~= nil and record.installed == true then
        return true
    end

    record = record or {}
    record.methodName = methodName
    record.hookKind = hookKind
    record.purpose = purpose or ""
    record.side = side or "both"
    record.available = owner[methodName] ~= nil
    record.installed = false
    self.records[hookKey] = record

    if record.available ~= true or Utils == nil then
        return false
    end

    if hookKind == "append" and Utils.appendedFunction ~= nil then
        owner[methodName] = Utils.appendedFunction(owner[methodName], hookFunction)
    elseif hookKind == "prepend" and Utils.prependedFunction ~= nil then
        owner[methodName] = Utils.prependedFunction(owner[methodName], hookFunction)
    elseif hookKind == "overwrite" and Utils.overwrittenFunction ~= nil then
        owner[methodName] = Utils.overwrittenFunction(owner[methodName], hookFunction)
    else
        return false
    end

    record.installed = true
    return true
end

function HelperPersonnelHookRegistrar:replace(owner, methodName, replacement, hookKey, purpose, side)
    if owner == nil or methodName == nil or replacement == nil or hookKey == nil then
        return false
    end

    local record = self.records[hookKey]
    if record ~= nil and record.installed == true then
        return true
    end

    record = record or {}
    record.methodName = methodName
    record.hookKind = "replace"
    record.purpose = purpose or ""
    record.side = side or "both"
    record.available = owner[methodName] ~= nil
    record.installed = false
    self.records[hookKey] = record

    if record.available ~= true then
        return false
    end

    owner[methodName] = replacement
    record.installed = true
    return true
end

function HelperPersonnelHookRegistrar:getRecords()
    return self.records
end

function HelperPersonnelHookRegistrar:installInstance(owner, methodName, hookKey, purpose, side, installer)
    if owner == nil or methodName == nil or hookKey == nil or installer == nil then
        return false
    end
    local records = self.instanceRecords[owner]
    if records == nil then
        records = {}
        self.instanceRecords[owner] = records
    end
    if records[hookKey] ~= nil and records[hookKey].installed == true then
        return true
    end
    local record = {methodName = methodName, purpose = purpose or "", side = side or "both", installed = false}
    records[hookKey] = record
    if installer(owner) ~= true then
        return false
    end
    record.installed = true
    return true
end
