-- Binary32 round-to-nearest, ties-to-even for native weight accumulation.
-- Inputs here are verified finite native weights, not network values.
local F={}
function F.round(n)
 if n==0 then return 0 end
 local sign=n<0 and -1 or 1;local magnitude=math.abs(n)
 local m,e=math.frexp(magnitude);local subnormal=magnitude<2^-126
 local value=subnormal and math.ldexp(magnitude,149) or math.ldexp(m,24)
 local lo=math.floor(value);local fraction=value-lo
 if fraction>.5 or fraction==.5 and lo%2==1 then lo=lo+1 end
 return sign*math.ldexp(lo,subnormal and -149 or e-24)
end
return F
