Request = require "perf"

-- demo code for big requests
local req
local uri = ""
local method = ""
local file = {
    name = "",
    filename = "",
    path = ""
}

function request()
    if req == nil then
        req = Request.new(true)
        req:set_uri(uri)
        req:set_method(method)
        req:set_form_body({ file = file })
    end

    return req:serialize()
end