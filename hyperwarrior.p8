pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- game by mika mulperi lakanen
-- all rights reserved
-- www.mulperi.net
-- email: mika@mulperi.net
-- all comments and feedback
-- and suggestions welcome!
-- still need to do some
-- performance optimization
-- and some other cool stuff.
-- still figuring this pico8
-- out :)

--[[
story:
it tells a story about a man 
who is forced to take part to 
a cruel experiment that 
transforms him to a cybernetic 
soldier. 
fortunately his consciousness 
is saved from total deletion 
to an external flash drive 
by a friendly scientist who
re-installs the data to the
brain. now, back to his
normal self and physically 
superior, he tries to destroy
the company that made 
him what he is. 
]]--

states = {}
menu = {}
general = {
	highscore = 0,
	bgcolour = 1,
	ultra = true,
	godmode = false,
	cpucolour = 11,
	memcolour = 11,
	debug = false,
	hud = true,
	counter = 0
}


function _init()
 show_transition1()
end
function _update60()
 states.update()
end
function _draw()
 states.draw()
end
function print_centered(str, y, colour)
  print(str, 64 - (#str * 2), y, colour) 
end
function show_transition1()
 states.update = update_transition1
 states.draw = draw_transition1
end
function draw_transition1()
 rectfill(0,0,127,127,flr(rnd(14))+1)
end
function update_transition1()
 general.counter += 1
 if general.counter > 20 then
  show_menu()
 end
end

function show_transition2()
 music(-1,0)
 sfx(22)
 transition2 = {
	 lefty = 64,
	 righty = 64
 }
 states.update = update_transition2
 states.draw = draw_transition2
end
function draw_transition2()
 rectfill(0,0,127,127,0)
	rectfill(0,transition2.lefty,127,transition2.righty,1)
end
function update_transition2()
 transition2.lefty -= 4
 transition2.righty += 4
 if transition2.lefty < 1 then
 restart()
 end
end
function show_menu()
 music(10)
 menu.midlineleftx = 64
 menu.midlinerightx = 64
 menu.startcolour = 0
 states.update = update_menu
 states.draw = draw_menu
 make_dots(64,127,10,500,800)
end
function start_game()
 music(0,0,1)
 states.update = update_game
 states.draw = draw_game
end

function update_menu()
 update_dots()
 general.counter += 1
 
 if general.counter > 30 then
  menu.startcolour = 7
 end
 if general.counter > 60 then
  menu.startcolour = 1
  general.counter = 0
 end
 if general.counter > 90 then
  menu.startcolour = 12
 end

	menu.midlineleftx -= 0.25
	menu.midlinerightx += 0.25

 if btn(5) then
  show_transition2()
 end
 
end

function draw_menu()
 cls()
 for i=1,400 do
  pset(rnd(128),rnd(128),1)
 end
 draw_dots()
 
 print_centered("highscore: "..flr(general.highscore),20,1)
 print("alpha",0,0,8)

 
 line(menu.midlineleftx-2,60,menu.midlinerightx+2,60,13)
 line(menu.midlineleftx,62,menu.midlinerightx,62,12)

 rectfill(menu.midlineleftx,63,menu.midlinerightx,70,1)
 print_centered("hyper warrior 2028",64,12)

 line(menu.midlineleftx-2,72,menu.midlinerightx+2,72,13)
 line(menu.midlineleftx,70,menu.midlinerightx,70,12)

 print_centered("press — to start",100,menu.startcolour)

end

gameoverscreen = {}
gameoverscreen.counter = 0
function update_gameover()
 gameoverscreen.counter += 1
 update_player()
 update_explosion()
 
 if gameoverscreen.counter > 120 then
	 if btnp(5) then
	  gameoverscreen.counter = 0
   show_transition2()
	 end
	 if btnp(4) then
	  gameoverscreen.counter = 0
	  show_menu()

	 end
	end
	
end

function gameover()
music(-1,0)

 states.update = update_gameover
 states.draw = draw_gameover
end
function draw_gameover()
 --draw_game()
 draw_player()
 draw_explosion()
 draw_transition3()
 print_centered("game over",50,rnd(20))
 print_centered("score: "..flr(player.score),70,12)
 print_centered("best: "..flr(general.highscore),80,12)
 print_centered("you are: "..level,90,12)
 if gameoverscreen.counter > 120 then
	 print_centered("press — to restart",110,11)
	 print_centered("press z to menu",120,11)
 end
end

function draw_transition3()
 for i=1,200 do
  pset(flr(rnd(128)),flr(rnd(128)),1)
 end
 for i=1,200 do
  pset(flr(rnd(128)),flr(rnd(128)),0)
 end
end

function restart()
shooting = false
weapon.selected = 1
 levelcurrent = 1
 gothighscore = false
 highscorecounter = 0
 highscoresound = false
 nextlevel = levellimit
 lastlevel = 0
 player.hp = player.maxhp
 player.colour = 12
 player.alive = true
 player.exploded = false
 player.score = 0
 player.levelscore = 0
 player.x = 64
 player.y = 64
 enemies = {}
 bullets = {}
 sparks = {}
 spawntimer = 0
 spawntimer2 = 0
 spawntimer3 = 0
 spawnspeed = defaultspawnspeed
 spawnspeed2 = defaultspawnspeed2
 spawnspeed3 = defaultspawnspeed3
 start_game()
end

function update_game()
--[[ if stat(1) > 0.5 then 
 general.cpucolour = 9 end
 if stat(1) > 0.8 then
 general.cpucolour = 8
 end
 
 if stat(0) > 200 then 
 general.memcolour = 9 end
 if stat(0) > 500 then
 general.memcolour = 8
 else 
 general.memcolour = 11
 end]]--

	 if player.alive then 
	 	update_player()
	 	if general.ultra then 
 		 update_explosion()
 		end
		 update_bullets()
		 update_enemies()
		 update_corpses()
		 update_level()
		 update_weapon()
	 else gameover() end
	 
	 if btnp(5,1) then
	  if general.hud then 
	  general.hud = false end
	  general.debug = true
	 end
	 if btnp(4,1) then
   general.godmode = true
  end
  	 if btnp(3,1) then
   general.godmode = false
  end
  	 if btnp(2,1) then
   general.hud = true
   general.debug = false
  end

end



function draw_game()
 if general.godmode then
 player.colour = rnd(20)
 end
	cls()
	rectfill(0,0,127,127,general.bgcolour) --bg
--	print(general.hud,50,50,7)
	
	-- instructions
	if levelcurrent < 2 and player.alive then	
		print("survive!",50,70,rnd(16))
		print("arrow keys to move",10,90,12)
	 print("z shoot",10,100,12)
	 print("x switch weapon",10,110,12)
 end

	draw_corpses()
	draw_bullets()
	draw_player()
	draw_enemies()
	draw_hud()
	if general.ultra then 
		draw_explosion() 
	end

	

end

-- hud stuff
function draw_hud()

	
	-- hud
	if general.hud then 
	print("score: "..flr(player.score),4,4,12)
	print("best: "..flr(general.highscore),4,14,12)
 print(weapons[weapon.selected].name,4,24,12)

 for i=1,#weapons do
  local guncolour = 13
		if i == weapon.selected then
			guncolour = 12
		end
		 print(
		 "."
		 ,
		 -0+i*4,30,guncolour
		 )
  end

	 rectfill(0,126,player.hp,127,11)
	 print("health",4,121,11)
	 draw_level()
 end
 --print("cpu",117,115,general.cpucolour)
 --print("mem",117,121,general.memcolour)

 if general.debug then
	 print("mem: "..stat(0),0,50,7)
	 print("cpu: "..stat(1).." / 1",0,60,7)
	 print("enemies: "..#enemies,0,70,7)
	 print("sparks: "..#sparks, 0,80,7)
	 print("corpses: "..#corpses, 0,90,7)
 end
 
 
end

function colliding(x1,y1,r1,x2,y2,r2)
 -- pythagorax 
 -- a2 + b2 = c2
 dx = x2 - x1;
 dy = y2 - y1;
 radii = r1 + r2;
 if ((dx*dx)+(dy*dy) < radii*radii) 
 then return true
 else
 return false
 end
end

function levelup()
	  lastlevel = nextlevel
		 levelcurrent += 1 
	  nextlevel = 
	  levellimit * (levelcurrent*(levelcurrent))
	 
	 	if spawnspeed > 10 then
	   spawnspeed -= spawnspeed/5
	  end
	  
 sfx(10)
 levelcounter = 0
end

highscoresound = false
function highscore()
 general.highscore = player.score
 gothighscore = true
 highscorecounter += 1 
 if not highscoresound then
  sfx(10)
  highscoresound = true
 end
end

levels = {
"baby",
"noob",
"hobbyist",
"wannabe",
"pro",
"master",
"elite",
"diamond",
"ultimate",
"survivor" -- level 10
}

level = levels[1]
levelcurrent = 1
levellimit = 100
nextlevel = 100
lastlevel = 0
levelcounter = 0
highscorecounter = 0
gothighscore = false



function update_level()
 player.score += 0.1
 levelcounter += 1
	level = levels[levelcurrent]

 if player.score > levellimit * (levelcurrent*(levelcurrent)) then 
	 if levelcurrent < 10 then
	 levelup()
	 end
	end
	
		if player.score > general.highscore
		 then
	  highscore()
	 end
	
end

function draw_level()

 print("level: "..level,64,4,12)
	if levelcounter > 1 and
	   levelcounter < 60 and 
	   levelcurrent > 1 then
	 print_centered("level up!",rnd(127),rnd(20))
	end
	
		if gothighscore and
		highscorecounter > 1 and
	   highscorecounter < 120 then
	 print_centered("highscore",rnd(127),10)
	end

 rect(64,9,115,16,12)
 rectfill(
 65 + 
	flr(
	(player.score-lastlevel)
	/
	(nextlevel-lastlevel)
	*50),
	 10,
	 65,
	 15,
	 12)
end


corpses = {}
function new_corpse(x,y,dots,colour)
	local corpse = {
		x = x, 
		y = y, 
		dots = dots,
		colour = colour
	}
	return corpse
end
function draw_corpses()
 for i=1,#corpses do
  pset(
  corpses[i].x,
  corpses[i].y,
  corpses[i].colour
  )
 end
end
function update_corpses()
 if #corpses > 500 then
  del(corpses, corpses[1])
 end
end

function new_enemymodel(name,wander,explode,colour,colour2,hp,minhp,speed,shockwaves,sound,minradius)
	local enemymodel = {
		name = name,
		wander = wander,
		explode = explode,
		colour = colour,
		colour2 = colour2,
		speed = speed,
		hp = hp,
		minhp = minhp,
		shockwaves = shockwaves,
		sound = sound,
		minradius = minradius
	}
	return enemymodel
end

enemymodels = {}
enemymodels[1] = new_enemymodel("assaultbot",false,false,8,2,2,2, rnd(0.35)+0.15 ,0,1,2)
enemymodels[2] = new_enemymodel("wanderer",true,false,11,3,10,8, rnd(0.08)+0.025 ,1,30,5)
enemymodels[3] = new_enemymodel("tank",false,false,6,0,80,50, 0.05 ,8,31,10)

function new_enemy(model,x,y,hp,velo)
 local radius = rnd(10)+enemymodels[model].minradius
 
 local enemy = {
  model = model,
	 wander = enemymodels[model].wander,
	 shockwaves = enemymodels[model].shockwaves,
	 x = x,
	 y = y,
	 velx = 0,
	 vely = 0,
	 radius = radius,
	 speed = enemymodels[model].speed,
	 colour = enemymodels[model].colour,
	 colour2 = enemymodels[model].colour2,
	 hp = flr(rnd(radius))*enemymodels[model].hp+enemymodels[model].minhp
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
 new_enemy(model,x,y)
 )
end

spawn_enemy(3)


enemies = {}
spawntimer = 0
spawntimer2 = 0
spawntimer3 = 0
spawnspeed = 100
spawnspeed2 = 1000
spawnspeed3 = 4000
defaultspawnspeed = 100
defaultspawnspeed2 = 1000
defaultspawnspeed3 = 4000
function update_enemies()
 ----------------
 -- spawn enemies
 ----------------
	spawntimer += 1
	spawntimer2 += 1
	spawntimer3 += 1
	if spawntimer > spawnspeed then
		spawn_enemy(1)
		spawntimer = 0
	end
	
if spawntimer2 > spawnspeed2 then
		spawn_enemy(2)
		spawntimer2 = 0
	end
	
	if spawntimer3 > spawnspeed3 then
		spawn_enemy(3)
		spawntimer3 = 0
	end
 ---------------------
 ---------------------
 -- do for all enemies
 ---------------------
 for i=1,#enemies do

						   
  if enemies[i] != nil then
  
   enemies[i].x += enemies[i].velx
   enemies[i].y += enemies[i].vely
  
	  -- follow player
	  if not enemies[i].wander then
		  if enemies[i].x < player.x then
		  	enemies[i].x += enemies[i].speed
		  end
		  if enemies[i].y < player.y then
		  	enemies[i].y += enemies[i].speed
		  end
		  if enemies[i].x > player.x then
		  	enemies[i].x -= enemies[i].speed
		  end
		  if enemies[i].y > player.y then
		  	enemies[i].y -= enemies[i].speed
		  end
		 end
		 
		 if enemies[i].wander then
		 	if enemies[i].x < player.x then
		  	enemies[i].velx += enemies[i].speed/100
		  end
		  if enemies[i].y < player.y then
		  	enemies[i].vely += enemies[i].speed/100
		  end
		  if enemies[i].x > player.x then
		  	enemies[i].velx -= enemies[i].speed/100
		  end
		  if enemies[i].y > player.y then
		  	enemies[i].vely -= enemies[i].speed/100
		  end
		 end
	
   -------------------------
   -- enemy-player collision
   -------------------------
	  if colliding(
										 enemies[i].x,
										 enemies[i].y,
										 enemies[i].radius,
										 player.x,
										 player.y,
										 player.radius
							 			) then
				enemies[i].hp -= 0.4
			 if not general.godmode then
			 	player.hp -= 1 end
			 sfx(3)
			end
			-------------------------

  --------------------
  -- bullet collisions
  --------------------
  for b=1,#bullets do
  
		 if bullets[b] != nil then
			 if colliding(
								 enemies[i].x,
								 enemies[i].y,
								 enemies[i].radius,
								 bullets[b].x,
								 bullets[b].y,
								 2
					 			) 
						then
						 local bulletdmg = bullets[b].damage 
						 local enemyhp = enemies[i].hp 
						 enemies[i].hp -= bulletdmg
						 bullets[b].damage -= enemyhp 
				   enemies[i].velx = abs(enemies[i].velx)
				   enemies[i].vely = abs(enemies[i].vely)
						 if bullets[b].damage < 1 then
						--  if not weapons[weapon.selected].phaser then
						 	 del(bullets, bullets[b]) 
						 -- end
						 end
	
					
						 player.score += 1
						 sfx(11)
						 --enemies[i].radius -= weapon.damage
				   --explode(x,y,particles,speed,life,colour,colour2,waves)
						 	explode(
								enemies[i].x,
								enemies[i].y,
								2,
								0.2,
								40,
								9,
								6,
								0)
								
						
			 		end
			 	end
	 	end
	 	--------------------
   if enemies[i].hp < 1 or 
						 enemies[i].radius < 2 then
							player.score += enemies[i].radius
								explode(
								enemies[i].x,
								enemies[i].y,
								enemies[i].radius*2,
								enemies[i].radius/15,
								50,
								enemymodels[enemies[i].model].colour,
								enemymodels[enemies[i].model].colour2,
								enemymodels[enemies[i].model].shockwaves)
						  sfx(
						  enemymodels[enemies[i].model].sound
						  )

						  add(corpses,
						  new_corpse(
						  5+enemies[i].x-rnd(10),
								5+enemies[i].y-rnd(10),
								10,
								enemymodels[enemies[i].model].colour2))
						
						  del(enemies, enemies[i])
						  player.score += 1
						  

						  break
			 		end
			 		
			 		
  end
 end
end

function draw_enemies() 
 for i=1,#enemies do


 circfill(
  enemies[i].x,
  enemies[i].y,
  enemies[i].radius,
  enemies[i].colour2
  )
  circ(
  enemies[i].x,
  enemies[i].y,
  enemies[i].radius,
  enemies[i].colour
  )
  
 end
end

shooting = false -- for ray gun
function shoot(x,y,velx,vely)
 shooting = true
 for i=1,weapons[weapon.selected].bullets do 
		add(
		bullets,
		new_bullet(x,y,velx,vely,velx,vely,weapons[weapon.selected].damage)
	 )
	end
end

bulletpalette = {10,9,8,5,0}
bullets = {}
function new_bullet(x,y,velx,vely,x2,y2,damage)
 local life = 40
 local bullet = {
  x = x,
  y = y,
  velx = velx + 
  weapons[weapon.selected].drift 
  - rnd(weapons[weapon.selected].drift*2),

  vely = vely + 
  weapons[weapon.selected].drift 
  - rnd(weapons[weapon.selected].drift*2),
 x2 = x2,
 y2 = y2,
 damage = damage,
 colour = 1,
 timer = 0,
 threshold = life / #bulletpalette
 }
 return bullet
end

function draw_bullets()
	if not weapons[weapon.selected].phaser then
		 for i=1,#bullets do
		  if bullets[i] != nil then
			  pset(
			  bullets[i].x,
			  bullets[i].y,
			  bulletpalette[bullets[i].colour])
			 end
		 end	
 end
end

function update_bullets()

if #bullets > 30 then
 del(bullets,bullets[1])
end

 for i=1,#bullets do

  if bullets[i] != nil then
  
   bullets[i].timer += 1
			bullets[i].x += bullets[i].velx * weapons[weapon.selected].speed
			bullets[i].y += bullets[i].vely * weapons[weapon.selected].speed
	 
		 if bullets[i].timer > bullets[i].threshold then
	   if bullets[i].colour < #bulletpalette then
	    bullets[i].colour +=1
	    bullets[i].timer = 0
	   else del(bullets,bullets[i]) break end
		 end
		 
	 	if 
			 bullets[i].x > 127 or
			 bullets[i].x < 0 or
			 bullets[i].y < 0 or
			 bullets[i].y > 127 then
			 del(bullets,bullets[i])
		 end
		 
	 end
	
 end
end

player = {
 colour = 12,
 colour2 = 0,
	x = 64,
	y = 64,
	radius = 3,
	angle = 0,
	velx = 0,
	vely = 0,
	speed = 1.2,
	gunx1 = 0,
	guny1 = 0,
	gunx2 = 0,
	guny2 = 0,
	laserx1 = 0,
	lasery1 = 0,
	laserx2 = 0,
	lasery2 = 0,
	hp = 0,
	maxhp = 128,
	score = 0,
	alive = true,
	exploded = false
}
function update_player()

if player.hp < player.maxhp then
 player.hp += 0.01
end

	if player.hp < 1 then
	 player.alive = false
	 if not player.exploded then 
	  sfx(20)
		 explode(
		 player.x,
		 player.y,
		 300,
		 0.1,
		 600,
		 8,
		 2,
		 0)
		 player.exploded = true
	 end
	 
	end
	
	if player.x > 127-player.radius then
	player.x = 127-player.radius end
	
	if player.x < 0 then
	player.x = 0 end
	
	if player.y < 0 then
	player.y = 0 end
	
	if player.y > 127 then
	player.y = 127 end

 player.gunx1 = player.x+cos(player.angle)*player.radius
	player.guny1 = player.y+sin(player.angle)*player.radius 
	player.gunx2 = player.x+cos(player.angle)*player.radius*player.speed
	player.guny2 = player.y+sin(player.angle)*player.radius*player.speed


	 player.laserx1 = player.x+cos(player.angle)*player.radius 
		player.lasery1 = player.y+sin(player.angle)*player.radius 
		player.laserx2 = player.x+cos(player.angle)*player.radius*50
		player.lasery2 = player.y+sin(player.angle)*player.radius*50


 if btn(0) then
  player.angle += 1/80
 end
  if btn(1) then
  player.angle -= 1/80
 end
 
 if btn(2) then
  player.x += player.gunx2 - player.gunx1
  player.y += player.guny2 - player.guny1
 end
 
  if btn(3) then
  player.x -= player.gunx2 - player.gunx1
  player.y -= player.guny2 - player.guny1
  end
end

function draw_player()
 if player.alive then
 -- player

	circfill(
		player.x,
		player.y,
		player.radius,
		player.colour
	)
 	circ(
		player.x,
		player.y,
		player.radius,
		player.colour2
	)	
	 -- laser
	if weapons[weapon.selected].laser then
		line(
			player.laserx1,
			player.lasery1,
			player.laserx2,
			player.lasery2,
			8
		)
	end
	
		if weapons[weapon.selected].phaser then

		if shooting then
	
				line(
					player.laserx1,
					player.lasery1,
					player.laserx2,
					player.lasery2,
					flr(rnd(14))+2
				)
				
			end
			end


 -- gun
	line(
		player.gunx1,
		player.guny1,
		player.gunx2,
		player.guny2,
		7
	)
	
 end 
end

weapon = {
 selected = 1,
 timer = 0
}

camerax = 0
cameray = 0
function update_weapon()

camera(camerax,cameray)
if camerax > 0 then camerax -= 0.2 end
if camerax < 0 then camerax += 0.2 end
if cameray > 0 then cameray -= 0.2 end
if cameray < 0 then cameray += 0.2 end

	 -- cooldown 
 weapon.timer += 1

 -- switch weapon
	if btnp(5) then
	 
	 if weapon.selected != #weapons+1
	 then
	  weapon.selected += 1
	  sfx(2) end
  if weapon.selected == #weapons+1
	 then weapon.selected = 1 end
	end
	

 -- shooting
 -----------
 if btn(4) then
	 if weapon.timer > weapons[weapon.selected].cooldown then
	  weapon.timer = 0
	  shoot(
	  player.gunx2,
	  player.guny2,
	  player.gunx2 - player.gunx1,
	  player.guny2 - player.guny1,
	 	player.gunx2 - player.gunx1,
	  player.guny2 - player.guny1
	  )
	  if not weapons[weapon.selected].phaser then
		  explode(player.gunx2,
		  player.guny2,2,0.2,10,10,8,0)
		 end
   camerax = weapons[weapon.selected].shake-
	  rnd(weapons[weapon.selected].shake)*2
	  cameray = weapons[weapon.selected].shake-
	  rnd(weapons[weapon.selected].shake)*2
	 

 sfx(weapons[weapon.selected].sound)
	  
	 else shooting = false end
 end
 
 
 
end

function new_weapon(name,cooldown,bullets,damage,speed,drift,shake,sound,laser,phaser)
  local weapon = {
  name = name,
  cooldown = cooldown,
  bullets = bullets,
  damage = damage,
  speed = speed,
  drift = drift,
  shake = shake,
  sound = sound,
  laser = laser,
  phaser = phaser
  }
 return weapon
end

--name,cooldown,bullets,damage,speed,drift,shake, sound, laser, phaser
weapons = {}
weapons[1] = new_weapon("minigun", 1, 1, 1, 5, 0.1, 1, 0, false, false)
weapons[2] = new_weapon("shotgun", 30, 16, 1, 5, 0.3, 2, 1, false, false)
weapons[3] = new_weapon("sniper", 55, 1, 100, 10, 0, 7, 9, true, false)
weapons[4] = new_weapon("burst rifle", 20, 3, 5, 10, 0.1, 1, 21, false, false)
weapons[5] = new_weapon("ray gun", 5, 1, 5, 10, 0, 0.1, 14, false, true)
weapons[6] = new_weapon("lighter", 1, 1, 1, 1, 0.1, 0, 13, false, false)
 
 





-- explosion stuff
function explode(x,y,particles,speed,life,colour,colour2,waves)
 -- shockwave
 for i=1,waves do
  add(shockwaves, new_shockwave(
   x,y,rnd(speed),rnd(life),colour
  ))
 end
 -- sparks
 if #sparks < 80 then
	 for i=1,particles do
	  add(
	  sparks,
	  new_spark(
		  x,y,rnd(speed),rnd(life),colour,colour2
	  ))
	 end
 end
end

shockwaves = {}
function new_shockwave(x,y,speed,life,colour)
 local shockwave = {
 radius = 1,
 x = x,
 y = y,
 speed = speed*5,
 life = life/2,
 timer = 0,
 colour = colour
 }
 return shockwave
end

sparks = {}
function new_spark(x,y,speed,life,colour,colour2)
 local spark = {
  x = x,
  y = y,
  velx = 4-rnd(8),
  vely = 4-rnd(8),
  speed = rnd(speed),
  life = life,
  timer = 0,
  colour = colour,
  colour2 = colour2
 }
 return spark
end

function update_explosion()
-- if #sparks > 20 then
 --del(sparks, sparks[1])
-- end

 for i=1,#shockwaves do
  if shockwaves[i] != nil then
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
  sparks[i].timer += 1
  sparks[i].x += (sparks[i].velx + 1-rnd(2)) * sparks[i].speed 
  sparks[i].y += (sparks[i].vely + 1-rnd(2)) * sparks[i].speed
 
  -- life
  if sparks[i].timer > 
     sparks[i].life * 0.6 then
     sparks[i].colour = sparks[i].colour2
  end
  if sparks[i].timer > 
     sparks[i].life * 0.75 then
     sparks[i].colour = 1
  end
  if sparks[i].timer > 
     sparks[i].life * 0.8 then
     sparks[i].colour = 5
  end
  if sparks[i].timer > 
     sparks[i].life * 0.9 then
     sparks[i].colour = 0
  end
  if sparks[i].timer > 
     sparks[i].life then
     del(sparks,sparks[i])
  end
   
 end
 end
end

function draw_explosion()

 for i=1,#sparks do
  pset(
  sparks[i].x,
  sparks[i].y,
  sparks[i].colour)
 end
 
 for i=1,#shockwaves do
 circ(
 shockwaves[i].x,
 shockwaves[i].y,
 shockwaves[i].radius,
 shockwaves[i].colour
 )
 end
 
end

-- menu fire
------------
dots = {}
palette = {12,13,1,0}
palettedefault = {10,9,8,2,1,5,0}
function new_dot(x,y,colour,lifemax)
 local dotlife = rnd(lifemax)
 local dot = {
 x = rnd(128),
 y = y,
 starty = y,
 velx = 0,
 vely = -0.5,
 colour = 1,
 life = dotlife,
 timer = 0,
 threshold = dotlife/#palette
 }
 return dot
end

function update_dots()
--if menu.midlineleftx < 1 then
 for i=1,#dots do
  dots[i].timer += 1
  dots[i].x += dots[i].velx
  dots[i].y += dots[i].vely + rnd(0.8)

  if dots[i].timer > dots[i].threshold then
  	dots[i].colour += 1
  	dots[i].timer = 0
  end
  if dots[i].colour == #palette then
	  dots[i].y = dots[i].starty
	  dots[i].x = rnd(128)
	  dots[i].colour = 1

  end
 end
--end
end

function draw_dots()
--if menu.midlineleftx < 1 then
 for i=1,#dots do
 pset(dots[i].x, dots[i].y, 
 palette[dots[i].colour])
 end
 line(0,64,127,64,0)
--end
end

function make_dots(x,y,colour,amount,lifemax)
 for i=1,amount do
  dots[i] = new_dot(
  x,y,colour,lifemax
  )
 end
end



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c000c00cc000c00c00000000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c000c00c0c00c00c0c000c00c770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c000c00c0c00c00c0c00cc00c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c000c00c0ccc000c00c0c000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000cccc00c00cc000c00ccc000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000cc0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
56555655565656555655565555555777555555755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
56555665565656655655566655555555555557755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
56555655566656555655555655555777555555755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
56665666556556665666566555555555555555775555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5ccc5ccc5ccc5c5c5c5c55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c5c5c5c5c5c5c5c5c55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555cc55ccc5cc55ccc555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5c5c5c5c555c555555755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ccc5c5c5ccc5ccc555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5cc555cc55cc5ccc5c5c55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c5c5c5c5c5c5c5c5c55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5c5c5c5c5cc5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5c5c5c5c5c5c555555755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5cc55cc55ccc555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c55cc5ccc5ccc5c5c5ccc55cc5ccc5c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c5c5c5c5c5c5c5c5c55c55c5555c55c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ccc5c5c5cc55cc55ccc55c55ccc55c555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5c5c5c5c5c5c555c55c5555c55c555555575555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5cc55ccc5ccc5ccc5ccc5cc555c555555755555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c5ccc5cc55cc55ccc5ccc5ccc5c5c55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c555c5c55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5ccc5c5c5c5c5ccc5cc55cc5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ccc5c5c5c5c5c5c5c5c5c5c5c55555555755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ccc5c5c5c5c5c5c5c5c5ccc5ccc555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5ccc5ccc55cc5c5c555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c5c5c5c5c5c5c555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ccc5cc55c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c555c5c5c5c5555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c555c5c5cc55555575555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5ccc5ccc55cc5ccc5ccc5ccc5c5c555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5ccc5c5c5c5555c55c555c5c5c5c555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5ccc5ccc55c55cc55cc55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5c5c555c55c55c555c5c5555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5c5c5cc555c55ccc5c5c5555575555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5ccc5c555ccc5ccc5ccc5c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c555c5555c555c55c555c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555cc55c5555c555c55cc555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c555c5555c555c55c5555555575555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ccc5ccc5ccc55c55ccc55555755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5cc55ccc5ccc5ccc55cc5cc55cc55c5c55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c55c55c5c5ccc5c5c5c5c5c5c5c5c55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c55c55ccc5c5c5c5c5c5c5c5c555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c55c55c5c5c5c5c5c5c5c5c5c555555755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ccc5ccc5c5c5c5c5cc55c5c5ccc555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c5c555ccc5ccc5ccc5ccc5ccc5ccc5c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c5c5c5c5555c555c55ccc5c5c55c55c555c5c5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5c5555c555c55c5c5ccc55c55cc555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555c5c5c5555c555c55c5c5c5c55c55c5555555575555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555cc5ccc55c55ccc5c5c5c5c55c55ccc55555755555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5c5c55cc5c5c5ccc5c5c5ccc5c5c55cc5ccc5c5c55555555555555555d555ddd5d5d5ddd5d5555555dd55ddd5555555555555555555555555555555555555555
5c5c5c555c5c5c5c5c5c55c55c5c5c5c5c5c5c5c55555555555555555d555d555d5d5d555d55555555d55d5d5555555555555555555555555555555555555555
55555ccc5c5c5cc55c5c55c55c5c5c5c5cc5555555555ddd5ddd55555d555dd55d5d5dd55d55555555d55d5d5555555555555555555555555555555555555555
5555555c5c5c5c5c5ccc55c55ccc5c5c5c5c555555555555555555555d555d555ddd5d555d55555555d55d5d5555555555555555555555555555555555555555
55555cc555cc5c5c55c55ccc55c55cc55c5c555555555555555555555ddd5ddd55d55ddd5ddd55555ddd5ddd5555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
57755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55775555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
57755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555888885555555555555555555555555555555555555555555555555555555555555555555
56555666565656665655555555555555565556665656566656555566888885555555555555555555555555555555555555555555555555555555555555555555
56555655565656555655555557775555565556555656565556555655888885555555555555555555555555555555555555555555555555555555555555555555
56555665565656655655555555555555565516655656566556555666888885555555555555555555555555555555555555555555555555555555555555555555
56555655566656555655555557775555565171555666565556555556888885555555555555555555555555555555555555555555555555555555555555555555
56665666556556665666555555555555566177165565566656665665888885555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555177715555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5655566656565666565555665656566656617777166556665555555555555cc55555555555555555555555555555555555555555555555555555555555555555
56555655565656555655565556565656565177115656556555555777555555c55555555555555555555555555555555555555555555555555555555555555555
56555665565656655655565556565665566511715656556555555555555555c55555555555555555555555555555555555555555555555555555555555555555
56555655566656555655565556565656565656555656556555555777555555c55555555555555555555555555555555555555555555555555555555555555555
5666566655655666566655665566565656565666565655655555555555555ccc5555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
56555666565656665655565556665666566656665555555555555cc55ccc5ccc5555555555555555555555555555555555555555555555555555555555555555
565556555656565556555655556556665565556555555777555555c55c5c5c5c5555555555555555555555555555555555555555555555555555555555555555
565556655656566556555655556556565565556555555555555555c55c5c5c5c5555555555555555555555555555555555555555555555555555555555555555
565556555666565556555655556556565565556555555777555555c55c5c5c5c5555555555555555555555555555555555555555555555555555555555555555
56665666556556665666566656665656566655655555555555555ccc5ccc5ccc5555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5665566656565666565556665656566656555555555555555cc55ccc5ccc55555555555555555555555555555555555555555555555555555555555555555555
56565655565655655655565556565655565555555777555555c55c5c5c5c55555555555555555555555555555555555555555555555555555555555555555555
56565665556555655655566556565665565555555555555555c55c5c5c5c55555555555555555555555555555555555555555555555555555555555555555555
56565655565655655655565556665655565555555777555555c55c5c5c5c55555555555555555555555555555555555555555555555555555555555555555555
5656566656565565566656665565566656665555555555555ccc5ccc5ccc55555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5655566655665666565556665656566656555555555555555ccc5555555555555555555555555555555555555555555555555555555555555555555555555555
5655565656555565565556555656565556555555577755555c5c5555555555555555555555555555555555555555555555555555555555555555555555555555
5655566656665565565556655656566556555555555555555c5c5555555555555555555555555555555555555555555555555555555555555555555555555555
5655565655565565565556555666565556555555577755555c5c5555555555555555555555555555555555555555555555555555555555555555555555555555
5666565656655565566656665565566656665555555555555ccc5555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5655566656565666565555665566565656655666566656665555555555555ccc5555555555555555555555555555555555555555555555555555555555555555
5655565556565655565556555656565656565565565556565555577755555c5c5555555555555555555555555555555555555555555555555555555555555555
5655566556565665565556555656565656565565566556655555555555555c5c5555555555555555555555555555555555555555555555555555555555555555
5655565556665655565556555656565656565565565556565555577755555c5c5555555555555555555555555555555555555555555555555555555555555555
5666566655655666566655665665556656565565566656565555555555555ccc5555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282228222888282288228822282228888888888888888888888888888888888888882228222828882228882822282288222822288
82888828828282888888888282828282882888288828888282828888888888888888888888888888888888888888828288828888828828828288288282888288
82888828828282288888882282828222882888288828882282228888888888888888888888888888888888888888228222822282228828822288288222822288
82888828828282888888888282828882882888288828888282828888888888888888888888888888888888888888828882828282888828828288288882828888
82228222828282228888822282228882828882228222822282228888888888888888888888888888888888888882228222822282228288822282228882822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010a00001d6351d6051d6050c60502600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003a630346302e630266301e63018630116300d630086300463001630016000160001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000240302b030240300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000135001320013500131001350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000415304155041550415504155041550415504155041550415504155041550415504155041550415504153041550415504155041550415504155041550415504155041550415504155041550415504155
001000001c4001f0001c0551c0241a0551c05500005180551800518055180551a055000051a055000050000500005000051c0551c0241a0551c055000051a055180051a0551a0551a055180051a0550000500405
0010000023005000051f0551f0241e0551f0551f0051c055000051c0551c0251f055000051e055000050000500005000051f0551f0241e0551f055000051f055000051f0551f0251e0551c0051e0550000000000
001000000040500005230552302421055230551c0051f055230051f0551f02521055000052105500005180050000518005230552302421055230550000523055000052305523025210551a005210551a00500005
01050000134551f415323001f30016300173000000005300063000b30017300000000d3000b300253000d300000000000000000143000000000000000001e3000000000000000000000000000000000000000000
011000002d650236401b630126200a610343253431500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000c37013370183701f370243700c36013350183401f3302432023600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100
011000003163501600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000021100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000126211c40710106173051c106231061730510106171061c1062310617102235041c40317307231061c50117405233021c20417503234071c10617201233021c50517404231031c50617207231011c302
011000002156300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000001c0141c0211c0211c0221c0221c0221c0221c0221c0121c0120c0531c0000c6450c6350c6250c6151a0141a0211a0211a0221a0221a0221a0221a0221a0121a0120c053000000c6450c6350c6250c615
002000001f0141f0211f0211f0221f0221f0221f0221f0221f0121f0121c0001c315213151f3151e3151c3151e0141e0211e0211e0221e0221e0221e0221e0221e0121e01200205173151a3151c3151e3151a315
00200000230142302123021230222302223022230222302223012230121c335213251f3351e3251c3351732521014210212102121022210222102221022210222101221012173351a3251c3351e3251a3351c325
00200008040550000504055000050405500005040550000000000000002330523305213051f3051e3051c30517305000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012400003067530675306653066530655306553064530645306353063530625306253061530615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000c6550c6550c6550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000055500a55010550155501a55020550265502d55033550385503f550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001805000000180101a051000001a0101c0301c0321c0321c0321c0221c0221c0121c0121c0121c01200000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001c050000001c0101e051000001e0102003020032200322003220032200222002220012200122001200000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001f050000001f0102105100000210102303023032230322303223032230222302223012230122301200000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000023050210501f0501e050210501f0501e0501a0501c022000001c000000001c000000001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000021655236451b635126250a615343053430500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00170000396742365233644126343a624126143a61412614000030000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000180141802118021180221802218022180221802218012180120000000000000000000000000000001a0141a0211a0211a0221a0221a0221a0221a0221a0121a012000000000000000000000000000000
00100000100141c0211c0211c0221c0221c0221c0221c0221c0121c012000000c10613156181361f126241161e0241e0211e0211e0221e0221e0221e0221e0221e0121e01200000000000e156131361a12621116
001000001f4241f4211f4211f4221f4221f4221f4221f4220c6551f4020c635210000c6152100021420214201e4201e4201e4201e4201e4201e4201e4201e4200c6551f4020c635210000c6151a4001a4201a420
001000000005000000000500000000050000000005000000000500000000050000000005000000000500000002050000000205000000020500000002050000000205000000020500000002050000000205000000
001000001f0141f0211f0211f0221f0221f0221f0221f0221f0121f0120000000000000000000000000000001f0141f0211f0211f0221f0221f0221f0221f0221f0121f012000000000010156171361c12623116
00100000170141702117021170221702217022170221702217012170120c60510174171511c136231262811617014170211702117022170221702217022170220c6551f4020c635210000c615000000000000000
001000001c4201c4221c4221c4221c4221c4221c4221c4220c6551c4020c6351c4020c6151700021000230002100023000214202342121420214201f4201f42021420214201f4201f4201e4201e4201a4201a420
001000000405000000040500000004050000000405000000040500000004050000000405000000040500000004050000000405000000040500000004050000000405000000040500000004050000000405000000
001000001f4241f4211f4211f4221f4221f4221f4221f4220c6551f4020c635210000c615000001e4201e42021420214202142021420214202142021420214200c6551f4020c635210000c615000002442024420
0010000023420234222342223422234222342223422234220c6551f4020c635210000c61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 0405060d
00 0405060d
00 04050607
02 04050607
00 17181944
00 41424344
00 41424344
00 41424344
00 41424344
04 1718195a
01 0f101112
00 0f101112
00 21222324
00 25262728
00 21222924
02 25262a28
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

