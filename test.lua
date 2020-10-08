Request = require "perf"

-- demo code for big requests
local req

function request()
    local file = {
        name = "file",
        filename = "av",
        path = "/Users/yangxin/Downloads/av.mp4"
    }
    if req == nil then
        req = Request.new(true)
        req:set_uri("/upload")
        req:set_method("POST")
        req:set_form_body({ file = file })
    end

    return req:serialize()
end