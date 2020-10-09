Request = require "perf"

-- demo code for upload big file
local uri = "/upload"
local method = "POST"
local file = {
    name = "file",
    filename = "LICENSE",
    path = "./LICENSE"
}

-- cache buf and reuse
local buf

function request()
    if buf == nil then
        local req = Request.new(true)
        req:set_uri(uri)
        req:set_method(method)
        req:set_form_body({ file = file })
        buf = req:serialize()
    end
    return buf
end
