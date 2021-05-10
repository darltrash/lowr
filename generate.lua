#!/usr/bin/lua
local license = [[
#   LÖWR: LöVR bindings for the Wu programming language

#    (C) 2021 Nelson "darltrash" Lopez
#
#    This software is provided 'as-is', without any express or implied
#    warranty.  In no event will the authors be held liable for any damages
#    arising from the use of this software.
#
#    Permission is granted to anyone to use this software for any purpose,
#    including commercial applications, and to alter it and redistribute it
#    freely, subject to the following restrictions:
#
#    1. The origin of this software must not be misrepresented; you must not
#        claim that you wrote the original software. If you use this software
#        in a product, an acknowledgment in the product documentation would be
#        appreciated but is not required.
#    2. Altered source versions must be plainly marked as such, and must not be
#        misrepresented as being the original software.
#    3. This notice may not be removed or altered from any source distribution.

]]

local lovrapi = require "lovrapi"
local lovrmod = {}

local typeTranslation = {
    number = "float", boolean = "bool", 
    string = "str", table = "any", 
    ["function"] = "any", thread = "any", userdata = "any", 
    ["nil"] = "nil", ["*"] = "any"
}

local function parseVariants(tab)
    local input, output = {}, {}
    for _, variant in ipairs(tab) do
        local minArguments = 100
        for rindex, arguments in ipairs(variant.arguments) do
            minArguments = math.min(rindex, minArguments)
            local ret = (typeTranslation[arguments.type] or "any")
            if input[rindex]~=ret and input[rindex]~=nil then
                ret = "any"
            end

            if minArguments < rindex then
                ret = ret .. "?"
            end
            input[rindex] = ret
        end

        local minReturns = 100
        for rindex, returns in ipairs(variant.returns) do
            minReturns = math.min(rindex, minReturns)
            local ret = (typeTranslation[returns.type] or "any")
            if output[rindex]~=ret and output[rindex]~=nil then
                ret = "any"
            end

            if minReturns < rindex then
                ret = ret .. "?"
            end
            output[rindex] = ret
        end
    end
    
    local inputStr = table.concat(input, ", ") or ""
    local outputStr = table.concat(output, ", ") or ""
    
    if #output>1 then 
        outputStr = "-> (" .. outputStr .. ")"
    elseif #output==1 then
        outputStr = "-> " .. outputStr .. ""
    end

    return inputStr, outputStr
end

local function fakeParseVariants()
    return "any?...", "any?..."
end

local function parseFunction(data)
    local input, output = parseVariants(data.variants)

    return data.name .. ": extern fun(".. input ..") ".. output .." = \"" .. data.key .. "\"" 
end

local function parseTrait(data)
    local input, output = parseVariants(data.variants)

    return data.name .. ": fun(".. input ..") ".. output
end

-- Wu devs, please make enums a thing soon =(
for _, mod in ipairs(lovrapi.modules) do
    for _, enu in ipairs(mod.enums) do
        typeTranslation[enu.name] = "str"
    end
end

local typecode = ""
local types = {}
local lovrmod
for _, mod in ipairs(lovrapi.modules) do
    if not mod.tag then 
        lovrmod = mod
        goto continue 
    end

    for _, obj in ipairs(mod.objects) do
        table.insert(types, obj.name)
        typeTranslation[obj.name] = obj.name
        typecode = typecode .. obj.name .. ": struct {}\n\n"
        typecode = typecode .. obj.name .. "_T: trait {\n"
        for _, met in ipairs(obj.methods) do
            typecode = typecode .. "\t" .. parseTrait(met) .. ",\n"
        end
        typecode = typecode .. "}\n\n"
    end

    local file, modulecode = io.open(mod.name..".wu", "w+"), "import types {"..(table.concat(types, ", ") or "").."}\n\n"
    for _, fun in ipairs(mod.functions) do
        modulecode = modulecode .. parseFunction(fun) .. "\n"
    end
    file:write(modulecode)
    file:close()

    ::continue::
end

local bombcode = "return function(any) any = lovr;lovr.patch = function(str, any)lovr[str] = any;end;end"

local file, initcode = io.open("init.wu", "w+"), license
for _, fun in ipairs(lovrmod.functions) do
    initcode = initcode .. parseFunction(fun) .. "\n"
end
initcode = initcode .. [[

patch: extern fun(str, any) = "function(str, any)lovr[str]=any;end"
_requirepatch: extern any = "package.loaded"
_lovrOrigin: extern any = "lovr"

]]
for _, mod in ipairs(lovrapi.modules) do
    if mod.name~="lovr" then
        initcode = initcode .. "_requirepatch[\"lowr."..mod.name.."\"] = _lovrOrigin "..mod.name.."\n"
        initcode = initcode .. "import "..mod.name.."\n"
        initcode = initcode .. "\n"
    end
end

initcode = initcode .. "import types"
file:write(initcode)
file:close()

local file = io.open("types.wu", "w+")
file:write(typecode)
file:close()
