pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--[[
game by mika mulperi lakanen
twitter: @mulperi
www: www.mulperi.net
this is a work in progress

story:
it's beem almost 50 years since
the humans found the first 
vortex. at first we had no clue
what it was. when we finally
realized that all of 
the universe is connected 
and we could travel anywhere,
anytime through the vortex,
there was already dozens of
different bureaus and agencies
all claiming the ownership
of the new discovery.
my name is zack forrester and 
i am the agent number 7 in the
vortex force ultra.
my mission is to keep all of
the vortex zones safe from
hostile aliens.
]]--

states = {}

function _init()
 show_menu()
end
function _update60()
 states.update()
end
function _draw()
 states.draw()
end
function restart()
 music(-1)
 new_game()
end
function new_game()
 states.update = update_game
 states.draw = draw_game
 new_starsystem()
end
function show_menu()
 states.update = update_menu
 states.draw = draw_menu
 
 --vortexpalette = vortexpalette2
 new_vortex(64,64,40,400,0.2)
 music(0,4000,1)
end

function draw_menu()
 cls()
 draw_vortex()
 print_centered("game by mika mulperi lakanen",0,1)
 print_centered("twitter: @mulperi",10,1)
 print_centered("vortex force ultra",61,1)
 print_centered("vortex force ultra",60,12)
 print_centered("press ❎ to start",101,1)
 print_centered("press ❎ to start",100,8)
end
function update_menu()
 update_vortex()
 if btnp(5) then 
 	restart()
 	sfx(9) 
 end
end

function print_centered(str, y, colour)
  print(str, 64 - (#str * 2), y, colour) 
end


levels = {}


-- general settings

debug = false
paused = false

-- player variables
player = {
alive = true,
godmode = false,
exploded = false,
score = 0,
level = 0,
invortex = false,
exitingvortex = true,
vortextimer = 0,
vortextimer2 = 0,
money = 0,
hp = 128,
maxhp = 128,
shooting = false,
-- ship info
radius = 4,
defaultradius = 4,
coreradius = 3,
-- coordinates and speed
angle = 0,
x = 64,
y = 64,
velx = 0,
vely = 0,
dx = 0,
dy = 0,
boostmultiplier = 1,
boostcap = 127,
boostcharge = 127,
boostoverheat = false,
boostohtimer = 0,
boostcolour = 12,
-- ship colors
colour = 7,
leftcolour = 7,
rightcolour = 7,
-- ship lines
topx = 0, topy = 0,
leftx = 0, lefty = 0,
rightx = 0, righty = 0,
bottomx = 0, bottomy = 0,
-- for movement
pointerx1 = 0, pointery1 = 0,
pointerx2 = 0, pointery2 = 0,
}

weapon = {
selected = 2,
cooldown = 8,
timer1 = 0,
timer2 = 0,
timer3 = 0,
timer4 = 0,
left1ready = true,
left2ready = false,
right1ready = false,
right2ready = false
}

leftgun = {x=0,y=0}
rightgun = {x=0,y=0}


function new_weaponmodel(name,cooldown,colour,colour2,sound)
 local weapon = {
 name = name,
 cooldown = cooldown,
 colour = colour,
 colour2 = colour2,
 sound = sound
 }
 return weapon
end

weapons = {}
weapons[1] = new_weaponmodel("basic cannon",25,7,5,0)
weapons[2] = new_weaponmodel("dual lasers",20,11,3,5)
weapons[3] = new_weaponmodel("quad lasers",8,12,1,7)
weapons[4] = new_weaponmodel("hyper lasers",2,8,2,6)



-- camera shake normalize
camerax = 0
cameray = 0
function normalize_camera()
	camera(camerax,cameray)
	if camerax > 0 then camerax -= 0.2 end
	if camerax < 0 then camerax += 0.2 end
	if cameray > 0 then cameray -= 0.2 end
	if cameray < 0 then cameray += 0.2 end
end

-- shoot actual laser
function call_laser(sidex,sidey,velx,vely,owner,colour)
 
    if	owner == "player" then 
				 recoil(2) 
				 -- player.shooting = true
			 end
			

 		 shoot(
			 sidex, sidey,
			 velx,
			 vely,
			 owner,colour)
			 
	
end

function enemy_shoot(enemy)
 enemy.timer += 1
 if enemy.timer > enemy.cooldown then
  sfx(7)
  call_laser(enemy.gunx, 
  										 enemy.guny,
  										 enemy.dx,
  										 enemy.dy,
  										 "enemy",14)
  enemy.timer = 0
 end
 
end


-- player shooting logic
function player_shoot()
-- cooldown if 
  if weapon.timer1 > weapons[weapon.selected].cooldown then
						call_laser(player.topx,
																	player.topy,
																	player.dx,
																	player.dy,
																	"player",
																	weapons[weapon.selected].colour)
					 weapon.timer1 = 0
					 sfx(weapons[weapon.selected].sound)
	end -- cooldown end
end -- end player_shoot


-- shooting
-----------
lasers = {}
function new_laser(x,y,velx,vely,owner,colour)
 local laserlife = 10
 local laser = {
 x = x,
 y = y,
 x2 = x,
 y2 = y,
 velx = velx,
 vely = vely,
 owner = owner,
-- palette = palette,
-- colour = palette[1],
 colnum = 1,
 drift = 0.3 - rnd(0.6),
 life = laserlife,
 timer = 0,
 colour = colour
-- threshold = laserlife/#palette
 }
 return laser
end
function update_lasers()
 for i=1,#lasers do
  if lasers[i] != nil then
    -- movement
    
	  lasers[i].x -= lasers[i].velx*5
	  lasers[i].x2 -= lasers[i].velx*4.8
	  lasers[i].y -= lasers[i].vely*5
	  lasers[i].y2 -= lasers[i].vely*4.8
	  if lasers[i].x > 127  or
		  lasers[i].x < 0  or
		  lasers[i].y > 127  or
		  lasers[i].y < 0
		 -- or lasers[i].colnum == #palette
		 then
		  del(lasers, lasers[i])
   end
  end
 end
end
function draw_lasers()
 for i=1,#lasers do
  if lasers[i] != nil then

  line(
  lasers[i].x,
  lasers[i].y,
  lasers[i].x2,
  lasers[i].y2,
  lasers[i].colour)

  end
 end
end
function shoot(x,y,velx,vely,owner,colour)
 add(lasers,
 new_laser(
	 x,
	 y,
	 velx,
	 vely,
	 owner,
	 colour
 	)
 )
end

-- when player moves, everything moves too
function movewithplayer(object,multiplier)
    object.x -= player.velx/horizonspeed * multiplier
    object.y -= player.vely/horizonspeed * multiplier
end

coins = {}
function new_coin(x,y,value)
 local coin = {
 x = x,
 y = y,
 frame = 32,
 value = value
 }
 return coin
end
function update_coins()
 for i=1,#coins do
  if coins[i] != nil then
 
   movewithplayer(coins[i],1)
   if coins[i].frame < 40 then
    coins[i].frame += 0.1
    else coins[i].frame = 32
   end
   
   if colliding(
    coins[i].x,
    coins[i].y,
    4,
    player.x,
    player.y,
    player.radius) 
    then
    explode(
    coins[i].x,
    coins[i].y,
    3,
			 1,
			 20,
			 0,
			 1,
			 1,
			 yellowpalette)
    sfx(9)
    player.money += coins[i].value
    del(coins,coins[i])
    
    break
   end
   
  end
 end
end
function spawn_coin(x,y,value)
 add(coins, new_coin(
 x,y,value
 ))
end
function draw_coins()
 for i=1,#coins do
  if coins[i] != nil then
  spr(coins[i].frame,
  coins[i].x,
  coins[i].y,
  1,1)
  
  end
 end
end


function new_starsystem()
 flashtimer = 0
 transitiontimer = 0
 enemies = {}
 spawn_enemy(1)
 vortexdots = {}
 player.exitingvortex = true
 player.vortextimer = 0
 player.x = 64 
 player.y = 64
 player.velx = 0.3
 player.level += 1
 new_vortex(64,64,10,100,0.2)
 player.godmode = false

 states.update = update_exitvortex
 states.draw = draw_game
end

function update_exitvortex()
 -- exiting vortex
 flashtimer += 1
 player.vortextimer += 1
 if player.vortextimer < 120 then
  player.angle += 0.03
 else 
  player.exitingvortex = false 
  player.vortextimer = 0 
 end
 update_game()
 
 if not player.exitingvortex then
 -- player.vortextimer = 0 
  states.update = update_game
 end
 
end
--[[function draw_exitvortex()
 draw_game()
 draw_player()
 draw_stars()
 draw_vortex()
end]]--



function update_game()
-- if player.alive then
 if not paused then
 	update_stars()
 	update_enemies()
-- end
	 update_player()
	 update_thrustsparks()
	 update_lasers()
	 update_explosion()
	 update_coins()
  update_vortex()
 end
 normalize_camera()
 update_pausemenu()
 
 -- pause menu
 if btnp(3) and player.alive 
 and not player.invortex 
 and not player.exitingvortex then
  if paused then 
  	paused = false
  	music(-1)
  else 
	  paused = true  
	  music(10)
	 end
	 sfx(10)
 end
 
 
end

flashtimer = 0
function draw_game()
 cls()

 if player.shooting then
  rectfill(0,0,127,127,weapons[weapon.selected].colour2)
 else
  rectfill(0,0,127,127,0)
 end
 draw_stars()

   if debug then
    print("angle: "..player.angle)
	   print("thrus sparks: "..#thrustsparks)
	   print("sparks: "..#sparks)
	   print("cpu: "..stat(1))
	   print("mem: "..stat(0))
	   print(player.shooting)
	   print(weapon.left1ready)
				print(weapon.right1ready)
				print("timer: "..weapon.timer1)
				print("cooldown: "..weapons[weapon.selected].cooldown)
		  print("t",player.topx-2,player.topy-3,7)
		  print("l",player.leftx-6,player.lefty+3,7)
		  print("r",player.rightx+3,player.righty+3,7)
   print(player.vortextimer)
   print(player.exitingvortex)

   end
   draw_coins()
   draw_lasers()
   draw_player()
   draw_enemies()
   draw_vortex()
   draw_thrustsparks()
   draw_explosion()
   if not debug and not player.invortex then draw_hud() end
   if paused then draw_pausemenu() end
  
   if player.invortex and not player.exitingvortex then
    print_centered("entering vortex",65,1)
    print_centered("entering vortex",64,10)
   end
   
   if player.exitingvortex and player.vortextimer2 < 60 then
    print_centered("exiting vortex",65,1)
    print_centered("exiting vortex",64,10)
   end
   -- borders
   rect(0,0,127,127,5)
   
   if flashtimer == 1 or  
      flashtimer == 3 or
      flashtimer == 5 then
    rectfill(0,0,127,127,7)
   end 
end
function shop_repair()
 player.hp += player.maxhp / 3
end
function shop_duallaser()
 weapon.selected = 2
end
function shop_turbocooler()
 player.boostcharge = player.boostcap
 player.boostoverheat = false
end
shopselection = 1
canbuycolour = 7
shopitems = {}
shopitems[1] = {
name = "repair",
desc = "repairs parts of your ship",
cost = "100",
price = 100,
image = 2,
action = shop_repair
}
shopitems[2] = {
name = "turbo cooler",
desc = "instant cooldown for turbo",
cost = "50",
price = 50,
image = 8,
action = shop_turbocooler
}
shopitems[3] = {
name = "dual lasers",
desc = "duals",
cost = "100",
price = 100,
image = 4,
action = shop_duallaser
}
shopitems[4] = {
name = "quad lasers",
desc = "fast and efficient",
cost = "600",
price = 600,
image = 6,
action = shop_quadlaser
}


function draw_pausemenu()
 rect(9,44,118,86,3)
 rect(9,45,118,85,11)
 
 rectfill(10,45,117,85,1)
 print_centered("ship upgrades",41,1)
 print_centered("ship upgrades",40,11)

 spr(
 shopitems[shopselection].image,
 20,60,2,2
 )
 
 print_centered(
 shopitems[shopselection].name,51,0)
 print_centered(
 shopitems[shopselection].name,50,7)
 
 print_centered(
 shopitems[shopselection].cost.." $",61,0)
 print_centered(
 shopitems[shopselection].cost.." $",60,9)
 
 
 print_centered(
 "❎ buy",71,0)
 print_centered(
 "❎ buy",70,canbuycolour)

 if not btnp(1) then 
	 print("➡️",100,65,3)
	 print("➡️",100,64,11)
 end
 if btnp(1) then
  print("➡️",100,65,11)
 end
 
 
-- print("$ "..player.money,10,86,1)
-- print("$ "..player.money,10,87,9)

--[[
 if player.money < 
 shopitems[shopselection].price
 and btnp(5) 
 then
 	print_centered("!not enough $crap!",81,0)
 	print_centered("!not enough $crap!",80,8)
 end ]]--

end
function buy()
 if player.money >= shopitems[shopselection].price then
	  player.money -= shopitems[shopselection].price
	  shopitems[shopselection].action()
   sfx(12)
 end
end
function update_pausemenu()

 if paused and btnp(1) then
  if shopselection < #shopitems then 
	  shopselection += 1 
  else shopselection = 1 end
  sfx(11)
 end
 
 if paused and btnp(5) then
  buy()
 end

 if player.money >= 
 shopitems[shopselection].price 
 then
 	canbuycolour = 11
 else canbuycolour = 8 end

end

function draw_hud()
 --print("score: "..flr(player.score/10), 0,0,11)

 -- print("turbo engine",108,3,1)
 -- print("turbo engine",106,3,1)
--  print("turbo engine",107,4,1)
 -- print("turbo engine",107,2,1)
  rectfill(1,1,2+player.boostcharge,3,1)
  rectfill(1,1,1+player.boostcharge,2,player.boostcolour)
 -- print("turbo engine",107,3,player.boostcolour)

  rectfill(0,3,2+player.hp,5,3)
  rectfill(0,4,1+player.hp,4,11)
 -- print("hp",90,6,11)

	 print(weapons[weapon.selected].name,4,10,1)
	 print(weapons[weapon.selected].name,4,9,weapons[weapon.selected].colour)
	 -- print("turbo",100,4,1,1)
	 --print(flr(player.boostcharge),10,10,12)
	 --print(player.boostmultiplier,10,20,12)
	 --print(player.boostoverheat,10,30,12)

 -- print("$ "..player.money,4,108,1)
  print("$ "..player.money,4,109,1)
  print("$ "..player.money,4,110,9)
 -- print("score: "..player.score,4,117,1)
  print("score: "..player.score,4,118,1)
  print("score: "..player.score,4,119,11)

 -- print("⬇️",116,118,1)
  if paused then
   print("⬇️",116,119,11)
  else 
   print("⬇️",116,119,1)
  end
end






function new_enemymodel(image,width,height,radius,bounty)
 local enemymodel = {
  image = image,
  width = width,
  height = height,
  radius = radius,
  bounty = bounty
 }
 return enemymodel
end

enemymodels = {}
enemymodels[1] = new_enemymodel(0,2,2,5,100)
enemymodels[2] = new_enemymodel(40,1,1,2,50)

enemies = {}
function new_enemy(x,y,model)
 local enemy = {
 model = model,
 hp = 100,
 x = x,
 y = y,
 velx = 0,
 vely = 0,
 angle = 0,
 dx = 0,
 dy = 0,
 radius = enemymodels[model].radius,
 gunx = x+cos(angle)*enemymodels[model].radius,
	guny = y+sin(angle)*enemymodels[model].radius,
 colour = 8,
 cooldown = 10,
 timer = 0
 }
 return enemy
end

function spawn_enemy(model)
 local direction = flr(rnd(4))+1
 local y = 0
 local x = 0
 if direction == 1 then 
  y = 0-20
  x = rnd(127)
 end
 if direction == 2 then 
  y = rnd(127)
  x = 127+20
 end
 if direction == 3 then 
  y = 127+20
  x = rnd(127)
 end
 if direction == 4 then 
  y = rnd(127)
  x = 0-20
 end

 add(enemies,
 new_enemy(100,100,model))
end

function enemy_charge(enemy)
 if player.x > enemy.x then
  if enemy.velx < 1 then
   enemy.velx += 0.000
  end
 end 
 if player.x < enemy.x then
  if enemy.velx > -1 then
   enemy.velx -= 0.000
  end
 end 
 if player.y > enemy.y then
  if enemy.vely < 1 then
   enemy.vely += 0.000
  end
 end 
 if player.y < enemy.y then
  if enemy.vely > -1 then
   enemy.vely -= 0.000
  end
 end 
  
 
end


function update_enemies()
 for i=1,#enemies do
  if enemies[i] != nil then
  
	  if enemies[i].hp < 1 then
	   spawn_coin(enemies[i].x, enemies[i].y, enemymodels[enemies[i].model].bounty)
	   explode(
    enemies[i].x,
    enemies[i].y,
    200,
			 0.5,
			 200,
			 2,
			 1,
			 2,
			 bluepalette)
	   del(enemies,enemies[i])
	   sfx(8)
	   camerax = 10-flr(rnd(20))--shake
	   cameray = 10-flr(rnd(20))--shake
	   break
	  end

  -- enemy direction
  enemies[i].dx = enemies[i].gunx/30 - enemies[i].x/30
  enemies[i].dy = enemies[i].guny/30 - enemies[i].y/30
  -- enemy move with stars
		movewithplayer(enemies[i],1)
	
	 enemies[i].x += enemies[i].velx
	 enemies[i].y += enemies[i].vely
	
	 enemy_charge(enemies[i])
		
   -- enemy player collision
   if colliding(
    enemies[i].x,
    enemies[i].y,
    enemies[i].radius,
    player.x,
    player.y,
    player.coreradius) then
    player.alive = false
   end

	  -- update rotating cannon
	  enemies[i].gunx = enemies[i].x+cos(enemies[i].angle)*enemies[i].radius
	  enemies[i].guny = enemies[i].y+sin(enemies[i].angle)*enemies[i].radius
   enemies[i].angle -= 0.025


		 -- enemy shooting
		 enemy_shoot(enemies[i])

   -- player's bullet hit enemy
   for l=1,#lasers do
    if lasers[l].owner == "player"  
    and 
    colliding(
    enemies[i].x,
    enemies[i].y,
    enemies[i].radius,
    lasers[l].x,
    lasers[l].y,
    2) 
    then
	    explode(
	    lasers[l].x,
	    lasers[l].y,
	    20,
				 0.3,
				 40,
				 0,
				 1,
				 1,
				 bluepalette)
	    sfx(2)
	
	    del(lasers,lasers[l])
	    enemies[i].hp -= 10
	    break
    end
   end

  end
 end
end

function draw_enemies()
 for i=1,#enemies do
  if enemies[i] != nil then

   
  
    circfill(
   enemies[i].x,
   enemies[i].y,
   enemies[i].radius,
   enemies[i].colour
   ) 
   
   
      spr(
   enemymodels[enemies[i].model].image,
   enemies[i].x-7,
   enemies[i].y-7,
   enemymodels[enemies[i].model].width,
   enemymodels[enemies[i].model].height
   )
   
  -- enemy weapon
  --[[    circ(
   enemies[i].gunx,
   enemies[i].guny,
   enemymodels[enemies[i].model].radius/5,
   8
   )]]--
   
   
   
  end
 end
end

-- circle collision
-------------------
function colliding(x1,y1,r1,x2,y2,r2)
 -- pythagorax
 -- a2 + b2 = c2
 dx = x2 - x1;
 dy = y2 - y1;
 radii = r1 + r2;
 
 if x1 > 128 or 
    y1 > 128 or
    x1 < 0 or
    y1 < 0 then
    else
					 if ((dx*dx)+(dy*dy) < radii*radii)
					 then return true
					 else
					 return false
		 			end
		  end
end

-- push back while shooting
function recoil(amount)
			 player.velx -= player.pointerx2*amount - player.pointerx1*amount
			 player.vely -= player.pointery2*amount - player.pointery1*amount
end


function enter_vortex()
 if player.radius > 0.5 then player.radius -= 0.1 end
 player.angle += 0.07
 player.invortex = true
 player.vortextimer += 1
 --sfx(13)
 if player.vortextimer > 60 then
  vortex_transition()
 end
end

function vortex_transition()
 player.godmode = true
 sfx(41)
-- music(15,0,2)
 player.vortextimer = 0
 player.invortex = false
 states.update = update_vortex_transition
 states.draw = draw_vortex_transition
end

function draw_vortex_transition()
 cls()
 print_centered("travelling to new sector",65,1)
 print_centered("travelling to new sector",64,11)
 draw_stars()
 draw_coins()
 draw_enemies()
 draw_vortex()  
end

transitiontimer = 0
function update_vortex_transition()
-- update_player()

-- player.angle = 0
-- player.velx = 0
 update_coins()
 update_stars()
 
 transitiontimer += 1
 if transitiontimer > 240 then
  new_starsystem()
 end

 update_enemies()

 for i=1,#stars do
  stars[i].x -= 3 / stars[i].layer
 end 
 
 for i=1,#vortexdots do
 vortexdots[i].x -= 2 / vortexdots[i].layer
 end 
 
  for i=1,#coins do
 coins[i].x -= 6
 end 
 
   for i=1,#enemies do
 enemies[i].x -= 4
 end 
 

 
end
-- player update
----------------
function update_player()

 if player.hp < 1 then 
 	player.alive = false 
 end

 -- player death
 if not player.alive and not
 	player.godmode and not player.exploded then
  player.shooting = false
 	explode(
	 player.x,
	 player.y,
	 300,
	 0.3,
	 240,
	 2,
	 1,
	 1,
	 greenpalette
	 )
	 music(-1,0)
	 sfx(3)
	 player.exploded = true
 end

 -- when player alive
 if player.alive then
 
  if player.radius < 
     player.defaultradius then
     player.radius += 0.08 
  end
 
  if not player.exitingvortex and colliding(
    player.x,
    player.y,
    player.radius,
    vortex.x,
    vortex.y,
    vortex.r) 
    then
   		enter_vortex()
    else 
     player.invortex = false
     if not player.exitingvortex then
      player.vortextimer = 0
     end
    end
 
  for l=1,#lasers do
   if lasers[l] != nil then
    if lasers[l].owner == "enemy"  
    and 
    colliding(
    lasers[l].x,
    lasers[l].y,
    2,
    player.x,
    player.y,
    player.radius) 
    then
    explode(
    lasers[l].x,
    lasers[l].y,
    20,
			 0.3,
			 40,
			 0,
			 1,
			 1,
			 exppalette)
    sfx(2)

    del(lasers,lasers[l])
    player.hp -= 25
    end
   end
 end
 
 
  -- aim
  player.dx = player.pointerx1*100 - player.pointerx2*100
		player.dy = player.pointery1*100 - player.pointery2*100
 
  -- basic hover
 	player.x += player.velx
	 player.y += player.vely
	 -- coordinates for ship 
		player.topx = player.x+cos(player.angle)*player.radius
		player.topy = player.y+sin(player.angle)*player.radius
		player.leftx = player.x+cos(player.angle-0.6)*player.radius
		player.lefty = player.y+sin(player.angle-0.6)*player.radius
		player.rightx = player.x+cos(player.angle+0.6)*player.radius
		player.righty = player.y+sin(player.angle+0.6)*player.radius
		player.bottomx = player.x+cos(player.angle+0.5)*player.radius
		player.bottomy = player.y+sin(player.angle+0.5)*player.radius
		player.pointerx1 = player.topx
		player.pointery1 = player.topy
		player.pointerx2 = player.x+cos(player.angle)*player.radius*1.001
		player.pointery2 = player.y+sin(player.angle)*player.radius*1.001
		leftgun.x = player.x+cos(player.angle+0.1)*player.radius
		leftgun.y = player.y+sin(player.angle+0.1)*player.radius

  -- rotation
		if btn(0) then player.angle += 1/80 end
		if btn(1) then player.angle -= 1/80 end

		-- thrust
		if btn(2) then
		 player.velx += (player.pointerx2 - player.pointerx1) * player.boostmultiplier
		 player.vely += (player.pointery2 - player.pointery1) * player.boostmultiplier
		 if player.boostmultiplier == 2 then
		 	 thrustfire(thrust_turbo,
		 	 player.bottomx,
		 	 player.bottomy,
		 	 player.pointerx1*200 - player.pointerx2*200,
		 	 player.pointery1*200 - player.pointery2*200,
		 	 40)
		 else
		 	 thrustfire(thrust_default,
		 	 player.bottomx,
		 	 player.bottomy,
		 	 player.pointerx1*100 - player.pointerx2*100,
		 	 player.pointery1*100 - player.pointery2*100,
		 	 20)
		 end
		 sfx(1)
		end

  -- shooting
  weapon.timer1 += 1
  if not btn(4) then
   player.shooting = false
  end
  if btn(4) then 
   	player_shoot()
  end
   
	-- turbo boost
	if player.boostcharge <
	   player.boostcap then
	   player.boostcharge += 0.1
	end

	if btn(5) and
	player.boostcharge > 1
	and not player.boostoverheat
	then
  player.boostmultiplier = 2
  if player.boostcharge > 0 then
   player.boostcharge -= 0.5
   sfx(4)
  end
	end

	if player.boostcharge < 1 then
	 player.boostoverheat = true
	 player.boostmultiplier = 1
	end

	if not btn(5) then -- turbo boost
  player.boostmultiplier = 1
	end
	if player.boostcharge > player.boostcap-1 then
	player.boostoverheat = false
	end

	if player.boostoverheat then
	 player.boostcolour = 8
	 else player.boostcolour = 12
	end



 --screen_wrap(player,player.radius)
 if player.x > 128 or player.x < -1 or
    player.y > 128 or player.y < -1 then
 			if not player.godmode then
 			 player.alive = false
 			end
 end 

 end -- if alive ends
end -- update_player ends

function draw_player()

 if player.alive then

  if debug then
	   circ( -- hit box
	  player.x,
	  player.y,
	  player.coreradius, 12)


   circ( -- player circle
  player.x,
  player.y,
  player.radius, 11)
 end

   circ( -- thruster
 player.bottomx,
 player.bottomy,
  0.5, 8)


  line( -- left side
  player.topx, player.topy,
  player.leftx, player.lefty,
  player.leftcolour)

    line( -- right side
  player.topx, player.topy,
  player.rightx, player.righty,
  player.rightcolour)

      line( -- bottom
  player.leftx, player.lefty,
  player.rightx, player.righty,
  player.colour)


        line( -- for move
  player.pointerx1, player.pointery1,
  player.pointerx2, player.pointery2,
  0)
 end
end




-- thrust sparks
----------------
thrust_default = {10,9,8,2,1}
thrust_turbo = {12,1}
thrustsparks = {}
function new_thrustspark(x,y,velx,vely,palette,life)
 local sparklife = life
 local thrustspark = {
 x = x,
 y = y,
 velx = velx + 0.3 - rnd(0.6),
 vely = vely + 0.3 - rnd(0.6),
 palette = palette,
 colour = palette[1],
 colnum = 1,
 drift = 0.3 - rnd(0.6),
 life = sparklife,
 timer = 0,
 threshold = sparklife/#palette
 }
 return thrustspark
end
function draw_thrustsparks()
 for i=1,#thrustsparks do
  circfill(thrustsparks[i].x,
  thrustsparks[i].y,
  0.5,
  thrustsparks[i].colour)
 end
end
function update_thrustsparks()
 if #thrustsparks > 100 then
  del(thrustsparks,thrustsparks[1])
 end

 -- for all sparks
 for i=1,#thrustsparks do
  if thrustsparks[i] != nil then

	  -- color change
	  thrustsparks[i].timer += 1
	  thrustsparks[i].colour = thrustsparks[i].palette[thrustsparks[i].colnum]
	  if thrustsparks[i].timer > thrustsparks[i].threshold then
	   thrustsparks[i].colnum += 1
	   thrustsparks[i].timer = 0
	  end

	  -- movement
	  thrustsparks[i].x += thrustsparks[i].velx
	  thrustsparks[i].y += thrustsparks[i].vely
	  if thrustsparks[i].x > 127  or
		  thrustsparks[i].x < 0  or
		  thrustsparks[i].y > 127  or
		  thrustsparks[i].y < 0  or
		  thrustsparks[i].colnum == #thrustsparks[i].palette+1 then
		  del(thrustsparks, thrustsparks[i])
   end

  end
 end
end

function thrustfire(palette,x,y,velx,vely,life)
 for i=1,1 do
  add(thrustsparks,
  new_thrustspark(x,y,velx,vely,palette,life))
 end
end


-- screen erase
---------------
function screen_erase(object,table,radius)
  if object.x > 127 + radius or
	  object.x < 0 - radius or
	  object.y > 127 + radius or
	  object.y < 0 - radius then
	  del(object, table)
  end
end

-- screen wrap
--------------
function screen_wrap(object,radius)
  if object.x > 130 + radius then
   object.x = -3
   object.y = flr(rnd(127))
  end

  if object.x < -3 - radius then
   object.x = 130
   object.y = flr(rnd(127))
  end

  if object.y > 130 + radius then
   object.y = -3
   object.x = flr(rnd(127))
  end

  if object.y < -3 - radius then
   object.y = 130
   object.x = flr(rnd(127))
  end
end


-- stars
--------
function new_star(x,y,colour,layer)
 local star ={
 x = x,
 y = y,
 velx = 0,
 vely = 0,
 colour = colour,
 layer = layer,
 size = rnd(2)
 }
 return star
end

horizonspeed = 3
stars = {}
starpalette = {6,6,5}
for i=1,150 do
 stars[i] = new_star(
 rnd(127), rnd(127),
 5,
 flr(rnd(3))+1
 )
end
function update_stars()
 for i=1,#stars do
 --  movewithplayer(stars[i], 3*stars[i].layer*0.1)
   stars[i].x -= player.velx/(horizonspeed * stars[i].layer*2)
	  stars[i].y -= player.vely/(horizonspeed * stars[i].layer*2)
	  screen_wrap(stars[i],1)
 end
end
function draw_stars()
 for i=1,#stars do
  pset(
  stars[i].x, 
  stars[i].y,
  starpalette[stars[i].layer])
 end
end




-- explosion v2
---------------
function explode(x,y,particles,speed,life,waves,velx,vely,palette)
 -- shockwave
 for i=1,waves do
  add(shockwaves, new_shockwave(
   x,y,rnd(speed),rnd(life),palette[1]
  ))
 end
 -- sparks
 for i=1,particles do
  add(
  sparks,
  new_spark(
	  x,y,rnd(speed),rnd(life),
   velx,vely,palette))
 end
end

shockwaves = {}
function new_shockwave(x,y,speed,life,colour)
 local shockwave = {
 radius = 1,
 x = x,
 y = y,
 speed = speed*5,
 life = life*2,
 timer = 0,
 colour = colour
 }
 return shockwave
end

--[[
sparks will cycle through
the colors of the palette table
--]]
exppalette = {7,12,10,9,8,6,5,2,1,0}
bluepalette = {12,1}
greenpalette = {11,12,3,1}
yellowpalette = {10,9}
sparks = {}
function new_spark(x,y,speed,life,velx,vely,palette)
 local sparklife = life
 local spark = {
  x = x,
  y = y,
  velx = velx+4-rnd(8),
  vely = vely+4-rnd(8),
  speed = rnd(speed),
  life = sparklife,
  timer = 0,
  colour = palette[1],
  threshold = sparklife/#palette,
  colnum = 1, -- palette index
  palette = palette
 }
 return spark
end

function update_explosion()
 -- if there's too much sparks
 -- then remove them
 if #sparks > 500 then
  del(sparks,sparks[1])
 end
 if #sparks > 1000 then
  sparks={}
 end

 for i=1,#shockwaves do
  if shockwaves[i] != nil then

 -- shockwaves[i].x -= player.velx/horizonspeed
 -- shockwaves[i].y -= player.vely/horizonspeed


   shockwaves[i].timer += 1
   shockwaves[i].radius += shockwaves[i].speed

 	if shockwaves[i].timer >
     shockwaves[i].life then
     del(shockwaves,shockwaves[i])
 	end
 	end
 end

 for i=1,#sparks do
 	if sparks[i] != nil then
 	
 	 -- sparks move with stars
 	 movewithplayer(sparks[i],1)

	  sparks[i].timer += 1
	  sparks[i].x += (sparks[i].velx + 1-rnd(2)) * sparks[i].speed
	  sparks[i].y += (sparks[i].vely + 1-rnd(2)) * sparks[i].speed

	  -- life
	  if sparks[i].timer > sparks[i].threshold and
	  sparks[i].colnum < #sparks[i].palette then
	  sparks[i].colnum += 1
	  sparks[i].timer = 0
	  sparks[i].colour = sparks[i].palette[sparks[i].colnum]
	  end
	  if sparks[i].timer >
	     sparks[i].life then
	     del(sparks,sparks[i])
	  end
 	end
 end
end

function draw_explosion()
 for i=1,#shockwaves do
 circ(
 shockwaves[i].x,
 shockwaves[i].y,
 shockwaves[i].radius,
 shockwaves[i].colour
 )
 end
 for i=1,#sparks do
  circfill(
  sparks[i].x,
  sparks[i].y,
  1.1/sparks[i].colnum,
  sparks[i].colour)
 end
end




-- vortex 
vortex = {x=100,y=20,r=10,angle=0, speed=0.8}
vortexdots = {}
vortexpalette = {8,2,1}
vortexpalette2 = {1,12,3}
function new_vortex(x,y,r,dots,speed)
 vortex = {}
 vortex.x = x
 vortex.y = y
 vortex.r = r
 vortex.speed = speed
 for i=1,dots do
	 add(vortexdots,
	 new_vortexdot(
	 -1,-1,flr(rnd(3)),rnd(1)
	 ))
	end
end
function new_vortexdot(x,y,layer,angle)
 local vortexdot = {
 x = x,
 y = y,
 layer = flr(rnd(3))+1,
 angle = angle,
 speedsin = rnd(2)
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
 --circ(vortex.x, vortex.y,
 --     vortex.r, 0)
      
 for i=1,#vortexdots do
	 circfill(vortexdots[i].x,
	 					vortexdots[i].y,
	 					vortexdots[i].speedsin,
	 					vortexpalette[vortexdots[i].layer])
	end
end

function update_vortex()
--player.vortextimer += 1
movewithplayer(vortex, 1)
	for i=1,#vortexdots do
		vortexdots[i].x = vortex.x+cos(vortexdots[i].angle)*vortex.r*vortexdots[i].speedsin
		vortexdots[i].y = vortex.y+sin(vortexdots[i].angle)*vortex.r*vortexdots[i].speedsin
	 vortexdots[i].angle += vortex.speed/vortexdots[i].speedsin/100
	end

end

__gfx__
000066666666000000066600000000070000b000000b000000000000006600000000007000700000000000000000000000000000000000000000000000000000
000611111111600000055560000000670000b000000b000000000000005560000000077000760000000000000000000000000000000000000000000000000000
006111111111160000000550000006600000000000000000000000000005570000007c77777c6600000000000000000000000000000000000000000000000000
06111111111111605600055600006600000000000000000066000000000000880005cc7ccc7c8a60000000000000000000000000000000000000000000000000
611111111111111555666555600660000000b000000b000056600000000660000005cccccccc8a60000000000000000000000000000000000000000000000000
611111111111111555555555565500000000b000000b000005660000005556000005cccccacc8a60000000000000000000000000000000000000000000000000
611111155111111505555567556000000000b000000b000000566000000055600005ccccaacc8a60000000000000000000000000000000000000000000000000
6111115e8511111500000556755660000000b000000b000000056600000005580005cccaaccc8a60000000000000000000000000000000000000000000000000
611111588511111500000055675556000000b000000b000000050700000000550005ccaacccc8a60000000000000000000000000000000000000000000000000
61111115511111150000006556555560000000000000000066600088000000000005ccaaaacc8a60000000000000000000000000000000000000000000000000
61111111111111150008876555555550000070000007000055660008800000000005cccccacc8a60000000000000000000000000000000000000000000000000
61111111111111150088ee0055555550000650000005600005566000080000000005ccccaacc8a60000000000000000000000000000000000000000000000000
0611111111111150088e8e0055600050000650000005600000556600008800000005cccaaccc8a60000000000000000000000000000000000000000000000000
006111111111150088e8e00055600000000650000005600000055560000880000005ccaacccc6660000000000000000000000000000000000000000000000000
00061111111150008e8e0000055600000066500000056600000005780000080000005ccccccc6000000000000000000000000000000000000000000000000000
0000555555550000e8e0000000000000006650000005660000000008800000000000055555550000000000000000000000000000000000000000000000000000
0000a0000009a00000097000000a9000000a0000000a0000000790000009a0000008800000055000000000000000000000000000000000000000000000000000
000aa700009a7a000009a00000a7a900007aa0000097a000000a9000009a7a000006600000066000000000000000000000000000000000000000000000000000
00a9a900009aa0000009a000000aa900009a9a00000a9000000a9000009aa00000b33b0000b33b00000000000000000000000000000000000000000000000000
000aaa00009aaa000009a00000aaa90000aaa000009aa000000a9000009aaa008638836856322365000000000000000000000000000000000000000000000000
0009a9a00009aa000009a00000aa90000a9a9000009a0000000a90000009aa00863aa368563aa365000000000000000000000000000000000000000000000000
0007aa0000097a000009a00000a7900000aa7000009a0000000a900000097a0000b33b0000b33b00000000000000000000000000000000000000000000000000
0000a0000009a0000007a000000a9000000a900000070000000a70000009a0000006600000066000000000000000000000000000000000000000000000000000
00000000000090000000900000090000000000000009000000090000000090000008800000055000000000000000000000000000000000000000000000000000
__label__
00000000011011101110111000001110101000001110111010101110000011101010100011101110111011100000100011101011111011001110110000000000
00000000100010101110100000001010101000001110010010101010000011101110100010101000101001000000100010101011101010101000101000000000
00000000100011101010110000001100111000001010010011001110000010101110100011101100110001000000100011101101111010101100101000000000
00000000101010101010100000001010001000001010010010101010000010101110100010001000111001000000100010101010101010101000101000000000
00000000111010101010111000001110111000001010111010101010000010100110111010001110111011100001111010101010101010101110101000000000
00000000000100000000000000000000000000000000000000000000000000000000000000000000010000000011100000000000000000000111000000000000
00000000001110000000000000010000000000100000000000000000000000000000000000000000002000000001000000000000000000000010000000000000
00000000000100000000000000111000000001110000000000000000000002000000000000000000022200000000000000000000000000000000000000000000
00000000000100000000000000010000000000100000000000000000000022200000000000000000002000000000000000000000000000000000000000000000
00000000001110000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000
00000000000100000000000001000011101010111011101110111011100000020001001110101010001110111011101110000000000000000000000000000000
00000000000000000000000011100001001010010001000100100010100100222010101110101010001010100010100100000000000000000000000000000000
00000000000000010000000001000001001010010001000100110011000000020010101010101010001110110011000100000000000000000000000000000000
00000000000000111000000000000001001110010001000100100010100100000012001010101010001000100010100100000000000000000000000000000000
00000000000000010000000000000001001110111001000100111010100000000021101010011011101000111010101110000000000000000000000000000000
00000000100000000000000000000000002220000020000000000000000000000002000000000000000000000000000000000000000000000000000000000010
00000001110000000000001000000000000200000222000000000000000000000000000200000000000000000000000000000000000000000000000000000111
00000000100000001000011100000000000000000020000000000000000000000000002220000000000000000000000000000000000000000000000000000010
00000000000000011100001000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000
00000000000000001110000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000100002220200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000202220000000000000200000000000000000200000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000200000000000002220000000000000002220000000000000000000000000000000000000000000000000000100000000000000
00000000000000000000000000000000000000000200000000000000000200000000000000000000000000000000000000000000000000001110000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000
00000000000000000000000000000000000000000000000000000000000000000000020000000000000000000020000000000000000000000000000000000000
00000000000000000000000000000000000200000000000000002000000000000000000000000000000000002222000000000000000000000000000000000000
00000000000000000000000000000000002220000000000000000000000000000000000000000000000000022220000000000000000000000000000000000000
00000000000010000000000000000000002220000000000000000000000000020000000000000000000020002000000000000000000000000000000000000000
00000000000111000000000000000000000200000000000000000002000000000000000000000000000222000000000000000000000000000000000000000010
00000000000010000000000000000000000000000002020000000000200000000000000000000000000020000000000000000000000000000000000000000111
00000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010
00000000000000000000002220000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000002000000000220000000000000200000000000000000000000000020000000000000000200000000000000000000000000000000000001000000
00000000000022200000000222000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000011100000
00000000000002000000000020000000000000000000000000000020000000000000000000000000000000000000000200000000000000000000000011100000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002220000000000000000000000001000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000200000000200000200000000000000200000000000010000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002220000000000111000
00000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000020000200000000000010000
00000000000000000000000000222000000000000000000200000000000000000080000080000000000000000000000000000000222000000000000000100000
00000000000000000000000000020000000000000200000000000000000000000000000000000000000000000000000000000000020000000000000001110000
01000000000200200000000000000000022200000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000
11100000002222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000000200200000000000000000000000000000000000800000080000200000000000000080000000000000000000000000000000000000000000000000
00000000000000000000000000000000200000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000200000000080000000000000000000000000000000000000000000000000020000200000000000000000000
00000000000000000000000000000000000000200000000000000000080000000020200000000000000000000000000000000222002220000000000000000000
00000002000000000000000000000000000000000000000000000800000020000000200000000000000008000000000000000022200200000000000000000000
00000022200000000000000000000000000000000000000000000000000010000000000000000008000000000002000000000002000000000000000000000000
00000002000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000010000
00000000000000000000000000000000000000008000000000000000800020000000000000000000800000000022000000000000000000000000000000111000
00000000000000000000000000020000000000000000000000000000000008000008000000000000000000000000000000000000000000000000000000010001
00010000000000000000000000000000000000000000000000000000000000000008000000000008000000000000000000000002000000000000000000000011
00111000000000000000000000000000000000000000000000000000000000000820000000000000000000000000000020000022200000000000000000000001
00010000000000000000002000000000000200000000000000000000100000000000000000000000008080000000000000000002000000000000000000000000
00000000000000000000022200000000000000000000080000000000000000000000000000000000800000000000000000000020000000000000000000000001
00000000000020000000002000000000000000000000000000000000000020000000000100000000080000000000000000000000020000000000000000000011
00010000000222000000000000000000000000000000000002000000000002000000002000000000000008000000000002000020222000000000000000000001
00111000002020000000000000000000000080000000000008000020000000000200000000000800000000000000000000000000020000000000000000000000
0001000002220000000000000000c0c00cc0ccc0ccc0ccc0c0c00000ccc00cc0ccc00cc0ccc00080c0c0c000ccc0ccc0ccc00000000000000000000000000000
0000000000200000000000000000c0c0c1c0c1c01c10c110c0c00000c110c1c0c1c0c110c1100008c0c0c0001c10c1c0c1c00000000000000000000000000000
0000000000000000000020000000c0c0c0c0cc180c00cc001c120000cc00c2c0cc10c000cc000000c0c0c0000c00cc12ccc00000000000000000000000000000
0000000200000000000222200000ccc0c0c0c1c00c00c100c1c00000c100c2c2c1c0c000c1000020c0c0c0000c00c1c0c1c00000000000000000200000000000
00000022200002000000222200001c10cc10c0c00c00ccc0c0c80000c000cc11c0c01cc0ccc008001cc0ccc00c00c0c0c0c00000000000000002220000000000
00000002000022200000002000000100110010100100111010100100100011001010011011100000011011100100101010100002000000000000200000000000
00000000000002000000000000000000000000080000000000000000002010000000000010000000000000000000000000000000000000000000000000000000
00001000000000000000000000000000000000000000000000000000000000000220000000000000000000000000000000020020020000000000000000000000
00011100200000000000000000000002002000000000000000800000000000080002000000080000000000000800002000000000222000000000000000000111
00001002220000000000000000000000000000000000000000000000000000008000000200000000000000000000000000000000020000000000000000001111
00000022200000000000000000000000000000000000000000000000020000000001100000000000000000000000000000200000000000000000000000000111
00000002000000002000000000000000000000080008000000000000010010001000000200800000000000000000000000000000000000000000000000000000
00000000000000222202000000000000000000008000000000000000000000000002000000000000000000000000000200000000000000000000000000000000
00000000000002222022200000000000000000800000800000000000000000000000000000000000000000000000000000000000000000020000000000000000
00000000000000200002000000000000000000000000800000000000000000000000000200000000000000000000000000000000000000222000000000000000
00000000000000000000000000000000000000000000000801000000000000000000080001000000000008008000000000000000000000020000000000000000
00000000000020000000000000000000000000000000000000000000000000000020000000000000000008000000000000000000000000000000000000000000
00000000000222000000000000002000000200000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000020000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000800000010000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000080000000000001000000000000000000000000008000000000000000000000000020000000000001000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222000000000011100000
00000000000000000000000020000000000000000000000800000000000100000000000000000000000000000000000000000000000020000000000001000000
00000000002000000000000222000000000000000000000000000080000008000000000000000000000000000000000000000000000000000000000000000000
00000001022200000000000020000000000000000000000000000000000000000000080000000000080000000000000000000000000000000000000000000000
00000011102000200000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000
00000001000002220000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000
10000000000000200000000020000200000000000000000000000000000000008000000000000000002000000000000000200000000000000000000000000000
00001000000000000000000222002220000000000000000000200000000000000000000000000000000000000000000022220000000000000000000000000000
00011100002000000000000020000222000000000000000000000000000000000000000000000200000000000000000222200000000000000000000000000001
00001000122200000000000000002020000000000000000000000000000000000000000002000000000000000000000020000020000000000000000000000011
00000001112000000000000000022200220000000000000000002000000000000000000000000000000000000000000000000222000000000000000000000101
00110000100000000000000000002002222000000000000000000000000000000200000000000000200000000000000000000020000000000000000000001110
01111000000000000000000000000000220000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000100
00110000000000000000000000000000000000000000000000000000000202000000000000000000000000000200000000000000000000000000100000000000
00000000000000000000000000000000000000000000000000000000000000000000000020000000000000002220000000020000000000000001110000000000
00000000000000000000000000002000000000000000000000000000200000000000000000000000000000000200000000222000000000000000100000000000
00000000000000000000000000022200000000000000000000000000000000000000000000000000000000000000000000020000000002000000000000000000
00000000000000000000000000002000000000000000000000000000000020000000000200000000000000000000000000000000000022200000000000000000
00000000000000000000000000022200000000000000000000002000000000000000000002000000000000000000000000000000000002000000000000000000
10000000000000000000002000002000888088808880088008800000088888000002888008800000088088808880888088800000000000000000000000000000
11000000000000000000022200000000818081808110811081100000881818800000181081800002811218108180818018100000000000000000000000000000
10000000000000000000002000000000888088108800888088800000888188800000080080800022888028028880881008000000000000000000000000000000
00000100000000000000000000020000811081808100118011800000881818800000080080800002118008228180818208000000000000000000000000000000
00001110000000000001000000222000800080808880881088100000188888100000080088100000881008028080808008000000000000000000000001000000
00000100000000000011100000020000102010101110110011000000011111220000010011000000110001001010121001000000000000000000000011100000
00000000000000000001000000000000022200002000000000000000000000200002000000000000000000000000222000002000000000000000000001000000
00000000000000000000000000000000002000022200200200200000000000000022200000200000000000000000020000022200000000000010000000000000
00000000000000100000000000000000000000002002222222220000000000000002000002220000000000000000000000002000000000000111000000000000
00000000000001110000000000000000000000000000202220200000000000000000000000200000000000000000000000000000000000000010000000000000
00000000000000100000000000000000000000000000022222000000000000000000020000000000000000000000000000000000000000000000000000000000
00000000000001000000000000000000000000000000002020000000000000200000222000000000000000000000000000000010000000000000000000000000
00000000010011100000000000000000000000000020000000000000000002220002020000000000000000000000000000000111000000000000000000000000
00000000111001000000000000000000000000000222000000000000000000200022200000000000000000000000000000000010100000000000000000000000
00000000010000010010000000000000000000000020000000000000000000000002000000000000000000000000000000000001110000000000000000000000
00000000000000111111000000000000000102000000000000000000000000000000000000000000000000000000000000000100100000000000000000000000
00000000000000010010000000000000001122200000000000000000000000000000000000000000000000000000000010001110000000000000000000000000
00000000000000000000000000000000000102000000000000000000000000020000000000000000000000000000000111000100000000000000100000000000
00000000000000000000000000000000000000000000020000000000000000222000200000000000000000000000000010000000010000000001110000000000
00000000010000000000000000000000000000000000222000000020000000020002220000000000000000000000000000000000111000000000100000000000
00000000111000000000000000000001000000000000020000000222000000000000200000000000000000000000000000000000111000000000000000000000
00000000010000000000000000000011100000000000111000000020000000000000000000000000001000000000000000000000010000000000000000000000
00000000000000001000000000000001000000000000010000000000000000000000002000000000011100000000000000000000000000000000000000000000
00000000000000011100000000000000000000000000000000000000000000100000022200000000001000000000000000000000000000000000000000000000
00000000000000001000000000000000000000000000000000000000000001110000002000000001000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000100000000000000011100000000000000000000000000000000000000000000000
00000000000000000000000010000100000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000
00000000000000000000000111001110000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000

__sfx__
000600001d05300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00003062300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013000000c0730c0530c0330c0230c013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012a00003c6112b706307060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003b00003c41330300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00002655300000013030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003972300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
014300001865518635186251861500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000183502b350303503032130311000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000c45413454184541f45404205042051020510205042050420510205102050420504205102051020504205042051020510205042050420510205102050420504205102051020504205042051020510205
010f000034055340111c40017405234022340221400154051f4021f4021e400174051e4021e4021c4001a4001c4021c40200003230002340223402214001f4001f4021f4021e4001c4001e4001c4001a4001a400
000600001f350303502b350183210c311000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000c4241c2021f0001f2052340223402214001e4051f4021f4021e4001f4051e4021e4021c4021a4001c4021c402000000000000000000001c4001e4001f4021f4021e4001c4001a400004001c40000000
001000001c4551c4151c4551c415044051a4551a41518455184150440518455184150440518455184151a4551c4551c4151c4551c415044051f4551f4151a4551a4151a4051a4551a45518455184551a4551a455
001000001f4551f4151f4551f415106551e4551e4151c4551c415004051c4551c415106551c4551c4151e4551f4551f4151f4551f4151065523455234151e4551e415004051e4551e4551f4551f455214551e455
011000002f23528235232351c2352f23528235232351c2352f23528235232351c2352f23528235232351c2352f23528235232351c2352f23528235232351c2352f23528235232351c2352f23528235232351c235
001000001c053040551c05304055040551c053040551c053040550405510055100551c17623156281362f1161c053040551c05304055040551c053040551c053100551005523332263422b3322f3322f3222f313
00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000230132302321033210431f0531f0631e0731e073
001000001c053000551c05300055000551c053000551c053000550005510055100551c17623156281362f116040531c0551c05304055040551c053040551c053100551005528073280531c6251c6352864528655
0010000010055170551c0552305110055170551c0552305510055170551c0552305510055170551c0552305510055170551c0552305510055170551c0552305510055170551c0552305510055170551c05523055
00100000283550000028305283450000000000283350000000000283250000000000283150000000000283151a35500000000001a34500000000001a33500000000001a32500000000001a31500000000001a315
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001f35500000000001f34500000000001f33500000000001f32500000000001f32500000000001f3152135500000000002134500000000002333521006230061e32500000000001e31500000000001e315
0010000018355000002830518345000000000018335000000000018325000000e000183150e00023000183151a35500000283051a34500000000001a33500000000001a325100001e0001a3151a000100001a315
001000001f35500000283051f34500000000001f33500000000001f32500000000001f31500000000001f3151535500000283051534500000000001533500000000001f32500000000001f3251f305000001f325
001000000c05513055180551f0550c05513055180551f0550c05513055180551f0550c05513055180551f0550e055150551a055210550e055150551a055210550e055150551a055210550e055150551f0551e055
001000000c0730c0530c0330c0230c013000000000000000000000000000000000000000000000000000000026256212261f006262561f22621006262561e2361a2261e216000000000026256232361a22623216
00100000184551845518425184551845518425184551845518425184551845518425184551845518425184551c4551c4551c4251c4551c4551c4251c4551c4551c4251c4551c4551c4251c4551c4551c4251c455
001000001c4551c4551c4251c4551c4551c4251c4551c4551c4251c4551c4551c4251c4551c4551c4251c4551f4551f4551f4251f4551f4551f4251f4551f4551f4251e4551e4551f4251e4551e4551f42523455
004000000400504005040050400504005040050400504005020050200502005020050200502005020050200500005000050000500005000050000500005000050b0050b0050b0050b0050b0050b0050b0050b005
002000001805318003230021800318053230022300223000180531500215002150021500215002150021500013000130021300213002130021300213002130001700017002170021700217002170021700217000
0020000013005130051300513005130051300513005130050e0050e0050e0050e0050e0050e0050e0050e0050c0050c0050c0050c0050c0050c0050c0050c0050c0050c0050c0050c0050c0050c0050c0050c005
002000001f0051f0021e0051f0021f0051f0021e0051f0051e0001e0051e0021f0051e002210051e0021e0001f0051f0021e0051f0021f0051f0021e0051f0051e0001e0051e0021f0051e0021a0051e0021e000
002000002300000000210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
018f00003573300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008200001863418621186111861300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011700002b0501605020030010400a0201705009020060401603011030190301f010280201a03033020180301b030210202a0301b020270300500008000010000000024000000000000015000000000000000000
__music__
00 0e124c0f
00 4e4f5011
00 4e4f5011
01 0e0f1013
00 0e0f1013
00 5c5d1013
00 1c1d1053
02 1c1d1013
02 54555b57
00 5a58595c
01 14155b17
00 14151b17
02 14151b17
02 1a18191c
00 41424344
04 1c1d4344
00 41424344
00 41424344
00 41424344
03 0e0f1011

