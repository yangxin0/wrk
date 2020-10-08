local BufferIndex = {
    append = function(self, data)
        self.data = self.data .. data
    end,
    -- table's __len cannot be overrided
    size = function(self)
        return string.len(self.data)
    end
}

local Buffer = {
    new = function()
        local buf = { data = "" }
        return setmetatable(buf, {
            __index = BufferIndex,
            __tostring = function(self)
                return string.format("buffer(size %d)", string.len(self.data))
            end
        })
    end
}

local RequestIndex = {
    set_header = function(self, name, value)
        self.headers[name] = value
    end,
    set_uri = function(self, uri)
        self.uri = uri
    end,
    set_method = function(self, method)
        self.method = method
    end,
    set_body = function(self, body)
        self.buf:append(body)
        self:set_header("Content-Length", string.len(body))
    end,
    set_form_body = function(self, form)
        self:set_header("Content-Type", "multipart/form-data; boundary=\"" .. self.boundary .. "\"")
        for key, val in pairs(form) do
            self.buf:append("--" .. self.boundary .. "\r\n")
            if key == "file" then
                self:append_file_body(val)
            else
                self:append_form(key, val)
            end
        end
        self.buf:append("--" .. self.boundary .. "--")
    end,
    append_file_body = function(self, file)
        if file.name == nil or file.path == nil then
            error("name or path is required")
        end
        if file.filename then
            self.buf:append("Content-Disposition: form-data; name=\"" .. file.name .. "\"; filename=\"" .. file.filename .."\"\r\n")
        else
            self.buf:append("Content-Disposition: form-data; name=\"" .. file.name .. "\"\r\n")
        end
        self.buf:append("Content-Type: application/octet-stream\r\n\r\n")
        local fin = io.open(file.path, "rb")
        if fin == nil then
            error(string.format("%s is not avaiable", file.path))
        end
        while true do
            local tmp = fin:read(1024 * 128)
            if tmp then
                self.buf:append(tmp)
            else
                fin:close()
                break
            end
        end
        self.buf:append("\r\n")
    end,
    append_form = function(self, name, val)
        self.buf:append("Content-Disposition: form-data; name=\"" .. name .. "\"\r\n\r\n")
        self.buf:append(val .. "\r\n")
    end,
    serialize = function(self)
        if self.bypass then
            self:set_header("Content-Length", self.buf:size())
            local head = self.wrk.format(self.method, self.uri, self.headers)
            local buf = self.wrk.buffer(string.len(head) + self.buf:size())
            buf:append(head)
            buf:append(self.buf)
            return buf
        else
            return self.wrk.format(self.method, self.uri, self.headers, self.buf.data)
        end
    end
}

local Request = {
    new = function(bypass)
        local buf
        local wrk = require("wrk")
        local boundary = "boundary_" .. os.time()
        if bypass then
            buf = wrk.buffer(1024)
        else
            buf = Buffer.new()
        end
        local req = {
            bypass = bypass,
            buf = buf,
            wrk = wrk,
            uri = "/",
            boundary = boundary,
            method = "GET",
            headers = {}
        }
        return setmetatable(req, {
            __index = RequestIndex
        })
    end
}

return Request

