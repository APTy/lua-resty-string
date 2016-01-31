-- Copyright (C) by Yichun Zhang (agentzh)


local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C
--local setmetatable = setmetatable
--local error = error
local tonumber = tonumber


local _M = { _VERSION = '0.09' }


ffi.cdef[[
typedef unsigned char u_char;

typedef struct {
    size_t len;
    u_char *data;
} ngx_str_t;

u_char * ngx_hex_dump(u_char *dst, const u_char *src, size_t len);

intptr_t ngx_atoi(const unsigned char *line, size_t n);

void ngx_encode_base64(ngx_str_t *dst, ngx_str_t *src);
]]

local str_type = ffi.typeof("uint8_t[?]")
local str_ptr = ffi.typeof("char *")
local ngx_str_type = ffi.typeof("ngx_str_t")


function _M.to_hex(s)
    local len = #s * 2
    local buf = ffi_new(str_type, len)
    C.ngx_hex_dump(buf, s, #s)
    return ffi_str(buf, len)
end


function _M.to_base64(s)
    local len = math.floor(#s * 4 / 3 + 0.5)  -- convert byte length to base-64
    local src = ffi_new(ngx_str_type, #s, ffi.cast(str_ptr, s))
    local dst = ffi_new(ngx_str_type, len, ffi_new(str_type, len))
    C.ngx_encode_base64(dst, src)
    return ffi_str(dst.data, dst.len)
end


function _M.atoi(s)
    return tonumber(C.ngx_atoi(s, #s))
end


return _M
