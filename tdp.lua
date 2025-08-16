local encoded = [[
bG9jYWwgSHR0cFNlcnZpY2UgPSBnYW1lOkdldFNlcnZpY2UoIkh0dHBTZXJ2aWNlIikNCmxvY2FsIGVuY29kZWQgPSBbWw0KLS0gIC0tDQpdXQ0KbG9jYWwgZGVjb2RlZCA9IEh0dHBTZXJ2aWNlOkJhc2U2NERlY29kZShlbmNvZGVkKQ0KbG9hZHN0cmluZyhkZWNvZGVkKSgp==]]

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function decode(data)
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
		return r
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if #x ~= 8 then return '' end
		local c=0
		for i=1,8 do
			c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0)
		end
		return string.char(c)
	end))
end

local decoded = decode(encoded)

local f = loadstring(decoded)
if f then
	f()
end