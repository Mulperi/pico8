pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--vortex by mika mulperi lakanen
--www.mulperi.net

-- vortex 
vortex = {x=100,y=20,r=10,angle=0, speed=0.8, width=1, height=1}
vortexdots = {}
vortexpalette = {8,2,1}
vortexpalette2 = {1,12,3}
function new_vortex(x,y,r,dots,speed,width,height,palette)
-- vortex = {}
 vortex.x = x
 vortex.y = y
 vortex.r = r
 vortex.speed = speed
 vortex.height = height
 vortex.width = width
 vortex.palette = palette
 for i=1,dots do
	 add(vortexdots,
	 new_vortexdot(
	 -1,-1,flr(rnd(3)),rnd(1),palette
	 ))
	end
end
function new_vortexdot(x,y,layer,angle,palette)
 local colour = flr(rnd(3))+1
 local vortexdot = {
 x = x,
 y = y,
 layer = flr(rnd(3))+1,
 angle = angle,
 speedsin = rnd(2),
 colour = palette[colour]
 }
 -- color layers
 if vortexdot.speedsin > 0.5 then 
  vortexdot.layer = 1
 end
  if vortexdot.speedsin > 0.7 then 
  vortexdot.layer = 2
 end
  if vortexdot.speedsin > 1.5 then 
  vortexdot.layer = 3
 end
 
 return vortexdot
end



function draw_vortex()
      
 for i=1,#vortexdots do
	 pset(vortexdots[i].x,
	 					vortexdots[i].y,
	 					vortexdots[i].colour)
	end
end

function update_vortex()
	for i=1,#vortexdots do
		vortexdots[i].x = vortex.x+cos(vortexdots[i].angle)*vortex.r*vortexdots[i].speedsin/vortex.width
		vortexdots[i].y = vortex.y+sin(vortexdots[i].angle)*vortex.r*vortexdots[i].speedsin/vortex.height
	 vortexdots[i].angle += vortex.speed/vortexdots[i].speedsin/100
	end

end

function _update60()
 cls()
 update_vortex()
end
function _draw()
 cls()
 draw_vortex()
end

new_vortex(64,64,50,600,0.2,1,1,vortexpalette)
