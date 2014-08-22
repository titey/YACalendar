-- vim: ts=4 sw=4 expandtab

-----------------------------------------------------------------------------------------------
-- Name: LibMd5
-- Description: MD5 (Message-Digest algorithm 5) implementation.
-- Parts of this library was inspired on work from Jean-Claude Wippler
-- Author:  TiTeY`
-- Adapted to the WildStar Apollo API
-- Copyright (c) TiTeY`
-----------------------------------------------------------------------------------------------

local lib_name, lib_version = 'LibMd5-1', 2
local md5 = {}

local bit_mod = math.fmod
local str_char, str_len, str_byte, str_sub = string.char, string.len, string.byte, string.sub
local str_rep, str_format = string.rep, string.format
local tinsert, tremove = table.insert, table.remove


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- LuaBit v0.4
-- a bitwise operation lib for lua.
-- Under the MIT license.
-- copyright(c) 2006~2007 hanzhao (abrash_han@hotmail.com)

local function check_int(n)
 -- checking not float
 if(n - math.floor(n) > 0) then
  error("trying to use bitwise operation on non-integer!")
 end
end


local function tbl_to_number(tbl)
 local n = table.getn(tbl)

 local rslt = 0
 local power = 1
 for i = 1, n do
  rslt = rslt + tbl[i]*power
  power = power*2
 end
 
 return rslt
end


local to_bits -- needs to be declared before bit_not

local function bit_not(n)
 
 local tbl = to_bits(n)
 local size = math.max(table.getn(tbl), 32)
 for i = 1, size do
  if(tbl[i] == 1) then 
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end
 return tbl_to_number(tbl)
end


to_bits = function (n)
 check_int(n)
 if(n < 0) then
  -- negative
  return to_bits(bit_not(math.abs(n)) + 1)
 end
 -- to bits table
 local tbl = {}
 local cnt = 1
 while (n > 0) do
  local last = math.mod(n,2)
  if(last == 1) then
   tbl[cnt] = 1
  else
   tbl[cnt] = 0
  end
  n = (n-last)/2
  cnt = cnt + 1
 end

 return tbl
end

local function expand(tbl_m, tbl_n)
 local big = {}
 local small = {}
 if(table.getn(tbl_m) > table.getn(tbl_n)) then
  big = tbl_m
  small = tbl_n
 else
  big = tbl_n
  small = tbl_m
 end
 -- expand small
 for i = table.getn(small) + 1, table.getn(big) do
  small[i] = 0
 end

end

local function bit_or(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n)

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 and tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end
 
 return tbl_to_number(tbl)
end

local function bit_and(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n) 

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 or tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end

 return tbl_to_number(tbl)
end

local function bit_xor(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n) 

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i] ~= tbl_n[i]) then
   tbl[i] = 1
  else
   tbl[i] = 0
  end
 end
 
 --table.foreach(tbl, print)

 return tbl_to_number(tbl)
end

local function bit_rshift(n, bits)
 check_int(n)
 
 local high_bit = 0
 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
  high_bit = 2147483648 -- 0x80000000
 end

 for i=1, bits do
  n = n/2
  n = bit_or(math.floor(n), high_bit)
 end
 return math.floor(n)
end

-- logic rightshift assures zero filling shift
local function bit_logic_rshift(n, bits)
 check_int(n)
 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
 end
 for i=1, bits do
  n = n/2
 end
 return math.floor(n)
end

local function bit_lshift(n, bits)
 check_int(n)
 
 if(n < 0) then
  -- negative
  n = bit_not(math.abs(n)) + 1
 end

 for i=1, bits do
  n = n*2
 end
 return bit_and(n, 4294967295) -- 0xFFFFFFFF
end

local function bit_xor2(m, n)
 local rhs = bit_or(bit_not(m), bit_not(n))
 local lhs = bit_or(m, n)
 local rslt = bit_and(lhs, rhs)
 return rslt
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local ff = tonumber('ffffffff', 16)
local consts = {
	3614090360, 3905402710, 606105819, 3250441966,
	4118548399, 1200080426, 2821735955, 4249261313,
	1770035416, 2336552879, 4294925233, 2304563134,
	1804603682, 4254626195, 2792965006, 1236535329,
	4129170786, 3225465664, 643717713, 3921069994,
	3593408605, 38016083, 3634488961, 3889429448,
	568446438, 3275163606, 4107603335, 1163531501,
	2850285829, 4243563512, 1735328473, 2368359562,
	4294588738, 2272392833, 1839030562, 4259657740,
	2763975236, 1272893353, 4139469664, 3200236656,
	681279174, 3936430074, 3572445317, 76029189,
	3654602809, 3873151461, 530742520, 3299628645,
	4096336452, 1126891415, 2878612391, 4237533241,
	1700485571, 2399980690, 4293915773, 2240044497,
	1873313359, 4264355552, 2734768916, 1309151649,
	4149444226, 3174756917, 718787259, 3951481745,
	1732584193, 4023233417, 2562383102, 271733878,
}

--string.gsub([[
--	d76aa478 e8c7b756 242070db c1bdceee
--	f57c0faf 4787c62a a8304613 fd469501
--	698098d8 8b44f7af ffff5bb1 895cd7be
--	6b901122 fd987193 a679438e 49b40821
--	f61e2562 c040b340 265e5a51 e9b6c7aa
--	d62f105d 02441453 d8a1e681 e7d3fbc8
--	21e1cde6 c33707d6 f4d50d87 455a14ed
--	a9e3e905 fcefa3f8 676f02d9 8d2a4c8a
--	fffa3942 8771f681 6d9d6122 fde5380c
--	a4beea44 4bdecfa9 f6bb4b60 bebfbc70
--	289b7ec6 eaa127fa d4ef3085 04881d05
--	d9d4d039 e6db99e5 1fa27cf8 c4ac5665
--	f4292244 432aff97 ab9423a7 fc93a039
--	655b59c3 8f0ccc92 ffeff47d 85845dd1
--	6fa87e4f fe2ce6e0 a3014314 4e0811a1
--	f7537e82 bd3af235 2ad7d2bb eb86d391
--	67452301 efcdab89 98badcfe 10325476
--[[, '(%w+)', function (s) tinsert(consts, tonumber(s, 16)) end)]]-- precalculated above

local f = function(x, y, z) return bit_or(bit_and(x, y),bit_and(-x - 1, z)) end
local g = function(x, y, z) return bit_or(bit_and(x, z),bit_and(y, -z - 1)) end
local h = function(x, y, z) return bit_xor(x, bit_xor(y, z)) end
local i = function(x, y, z) return bit_xor(y, bit_or(x, -z - 1)) end

local z = function(f, a, b, c, d, x, s, ac)
	a = bit_and(a + f(b, c, d) + x + ac, ff)
	return bit_or(bit_lshift(bit_and(a, bit_rshift(ff, s)), s),bit_rshift(a, 32 - s)) + b
end

local function MD5Transform(X, A, B, C, D)

	local a, b, c, d = A, B, C, D

	a = z(f, a, b, c, d, X[ 0],  7, consts[ 1])
	d = z(f, d, a, b, c, X[ 1], 12, consts[ 2])
	c = z(f, c, d, a, b, X[ 2], 17, consts[ 3])
	b = z(f, b, c, d, a, X[ 3], 22, consts[ 4])
	a = z(f, a, b, c, d, X[ 4],  7, consts[ 5])
	d = z(f, d, a, b, c, X[ 5], 12, consts[ 6])
	c = z(f, c, d, a, b, X[ 6], 17, consts[ 7])
	b = z(f, b, c, d, a, X[ 7], 22, consts[ 8])
	a = z(f, a, b, c, d, X[ 8],  7, consts[ 9])
	d = z(f, d, a, b, c, X[ 9], 12, consts[10])
	c = z(f, c, d, a, b, X[10], 17, consts[11])
	b = z(f, b, c, d, a, X[11], 22, consts[12])
	a = z(f, a, b, c, d, X[12],  7, consts[13])
	d = z(f, d, a, b, c, X[13], 12, consts[14])
	c = z(f, c, d, a, b, X[14], 17, consts[15])
	b = z(f, b, c, d, a, X[15], 22, consts[16])

	a = z(g, a, b, c, d, X[ 1],  5, consts[17])
	d = z(g, d, a, b, c, X[ 6],  9, consts[18])
	c = z(g, c, d, a, b, X[11], 14, consts[19])
	b = z(g, b, c, d, a, X[ 0], 20, consts[20])
	a = z(g, a, b, c, d, X[ 5],  5, consts[21])
	d = z(g, d, a, b, c, X[10],  9, consts[22])
	c = z(g, c, d, a, b, X[15], 14, consts[23])
	b = z(g, b, c, d, a, X[ 4], 20, consts[24])
	a = z(g, a, b, c, d, X[ 9],  5, consts[25])
	d = z(g, d, a, b, c, X[14],  9, consts[26])
	c = z(g, c, d, a, b, X[ 3], 14, consts[27])
	b = z(g, b, c, d, a, X[ 8], 20, consts[28])
	a = z(g, a, b, c, d, X[13],  5, consts[29])
	d = z(g, d, a, b, c, X[ 2],  9, consts[30])
	c = z(g, c, d, a, b, X[ 7], 14, consts[31])
	b = z(g, b, c, d, a, X[12], 20, consts[32])

	a = z(h, a, b, c, d, X[ 5],  4, consts[33])
	d = z(h, d, a, b, c, X[ 8], 11, consts[34])
	c = z(h, c, d, a, b, X[11], 16, consts[35])
	b = z(h, b, c, d, a, X[14], 23, consts[36])
	a = z(h, a, b, c, d, X[ 1],  4, consts[37])
	d = z(h, d, a, b, c, X[ 4], 11, consts[38])
	c = z(h, c, d, a, b, X[ 7], 16, consts[39])
	b = z(h, b, c, d, a, X[10], 23, consts[40])
	a = z(h, a, b, c, d, X[13],  4, consts[41])
	d = z(h, d, a, b, c, X[ 0], 11, consts[42])
	c = z(h, c, d, a, b, X[ 3], 16, consts[43])
	b = z(h, b, c, d, a, X[ 6], 23, consts[44])
	a = z(h, a, b, c, d, X[ 9],  4, consts[45])
	d = z(h, d, a, b, c, X[12], 11, consts[46])
	c = z(h, c, d, a, b, X[15], 16, consts[47])
	b = z(h, b, c, d, a, X[ 2], 23, consts[48])

	a = z(i, a, b, c, d, X[ 0],  6, consts[49])
	d = z(i, d, a, b, c, X[ 7], 10, consts[50])
	c = z(i, c, d, a, b, X[14], 15, consts[51])
	b = z(i, b, c, d, a, X[ 5], 21, consts[52])
	a = z(i, a, b, c, d, X[12],  6, consts[53])
	d = z(i, d, a, b, c, X[ 3], 10, consts[54])
	c = z(i, c, d, a, b, X[10], 15, consts[55])
	b = z(i, b, c, d, a, X[ 1], 21, consts[56])
	a = z(i, a, b, c, d, X[ 8],  6, consts[57])
	d = z(i, d, a, b, c, X[15], 10, consts[58])
	c = z(i, c, d, a, b, X[ 6], 15, consts[59])
	b = z(i, b, c, d, a, X[13], 21, consts[60])
	a = z(i, a, b, c, d, X[ 4],  6, consts[61])
	d = z(i, d, a, b, c, X[11], 10, consts[62])
	c = z(i, c, d, a, b, X[ 2], 15, consts[63])
	b = z(i, b, c, d, a, X[ 9], 21, consts[64])

	return
		bit_and(A + a, ff),
		bit_and(B + b, ff),
		bit_and(C + c, ff),
		bit_and(D + d, ff)
end

local function LIntToString(i)
	return str_char(bit_and(bit_rshift(i, 0), 255)) .. str_char(bit_and(bit_rshift(i, 8), 255)) .. str_char(bit_and(bit_rshift(i, 16), 255)) .. str_char(bit_and(bit_rshift(i, 24), 255))
end

local function StringToBInt(s)
	local v = 0
	for i = 1, str_len(s) do
		v = v * 256 + str_byte(s, i)
	end
	return v
end

local function StringToLInt(s)
	local v = 0
	for i = str_len(s), 1, -1 do
		v = v * 256 + str_byte(s, i)
	end
	return v
end

local function StringToLIntArray(s, size, count)
	local o, r = 1, {}

	for i = 1, count do
		tinsert(r, StringToLInt(str_sub(s, o, o + size - 1)))
		o = o + size
	end

	return r
end

function md5:MD5AsTable(s)
	local l = str_len(s)
	local pad = 56 - bit_mod(l, 64)

	if bit_mod(l, 64) > 56 then
		pad = pad + 64
	end
	if pad == 0 then
		pad = 64
	end

	s = s .. str_char(128) .. str_rep(str_char(0), pad - 1)
	s = s .. LIntToString(8 * l) .. LIntToString(0)

	assert(bit_mod(str_len(s), 64) == 0)

	local a, b, c, d = consts[65], consts[66], consts[67], consts[68]

	for i = 1, str_len(s), 64 do
		local x = StringToLIntArray(str_sub(s, i, i + 63), 4, 16)

		assert(#(x) == 16)
		x[0] = tremove(x, 1)

		a, b, c, d = MD5Transform(x, a, b, c, d)
	end

	local swap = function (w)
		return StringToBInt(LIntToString(w))
	end

	return {
		swap(a),
		swap(b),
		swap(c),
		swap(d),
	}
end

function md5:hash(s)
	local h = self:MD5AsTable(s)

	return str_format("%08x%08x%08x%08x", h[1], h[2], h[3], h[4])
end


assert(md5:hash("abcdefghijklmnopqrstuvwxyz") == "c3fcd3d76192e4007dfb496cca67e13b", "MD5 hash failed self test!")

if Apollo then
    Apollo.RegisterPackage(md5, lib_name, lib_version, {})
end
md5 = nil -- setting nil here allows this table to be collected if a newer one exists



