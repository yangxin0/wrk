Request = require "perf"

function request()
    local file = {
        name = "file",
        filename = "wrk",
        path = "LICENSE"
    }
    local req = Request.new(true)
    req:set_uri("/upload")
    req:set_method("POST")
    req:set_form_body({ file = file })
    return req:serialize()
end