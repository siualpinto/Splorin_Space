pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
--mini mortal kombat
--a game by burning_out

debug=false
hitboxshow=false

screen=0
countdown=0
countdownactive=false

--[[
screens
0 = title
1 = gameplay
2 = level select
]]--

fcount=0

rain={}
bloodsplats={}
lava={}
--clouds={}
--clouds.max=5
--clouds.stormy=true

_map={}
_mapbounds={l=0,r=112}

drawcontrolscreen=false
gamepaused=false
gamecurrentround=1
gamemaxrounds=3
gamepoints={p1=0,p2=0}
gametimer=60
gamestate=0
--[[
game states
0 = game ready
1 = fighting
2 = finish him
3 = game complete
4 = new round
5 = end round
]]--
gametext="" 
gamegore=true

levels={}
selectedlevel={}
lvlselectindex = 1
rarrowcol=6
larrowcol=6
rarrowcount=0
larrowcount=0
lvlselectsection=1
--[[
1=character
2=stage
3=rounds
]]--

characters={}
charselectp1=2
charselectp2=3

p1={
	ctrl=0,
	ctrljumpleft=0,
	ctrljumpright=0,
	ctrlbtn2=0,
	ctrlbtn3=0,
	ctrlbtn4=0,
	ctrlbtn5=0,
	ctrl=0,
	ctrlcomboresetcount=0,
	ctrlcombobtns="",
	ctrlcombo="",
	posx=25,
	posy=96,
	flipped=false,
	dx=0,
	dy=0,
	fatality=false,
	babality=false,
	state=0,
	animatecount=0,
	health=100,
	character={},
	hitboxes={},
	blood={},
	projectiles={},
	ready=false
}

p2={
	ctrl=1,
	character={},
	ctrljumpleft=0,
	ctrljumpright=0,
	ctrlbtn2=0,
	ctrlbtn3=0,
	ctrlbtn4=0,
	ctrlbtn5=0,
	ctrl=1,
	ctrlcomboresetcount=0,
	ctrlcombobtns="",
	ctrlcombo="",
	posx=90,
	posy=96,
	hitboxes={},
	flipped=true,
	dx=0,
	dy=0,
	fatality=false,
	babality=false,
	state=0,
	animatecount=0,
	health=100,
	blood={},
	projectiles={},
	ready=false
}

p1.alive=(p1.health>0)
p2.alive=(p2.health>0)
skull={
	draw=false,
	posx=0,
	posy=0,
	blood={}
}

--[[ 
	hitbox states
	0=dflt
	1=a1
	2=a2
	3=a3
	4=dfnd
	5=stun
]]--

function _init()
	music(0)
	cls()
	_drawtitle()
	create_hitboxes()
	create_levels()
	create_characters()
	menuitem(1,"disable gore", togglegoremenu)
	menuitem(2,"show controls", showcontrols)
	menuitem(3,"level select", levelselect)
end

--** helpers **--
function mainmenu()
	screen=0
	resetgame()
end

function levelselect()
	screen=2
	resetgame()
end

function resetgame()
	selectedlevel=levels[1]
	lvlselectindex=1
	lvlselectsection=1
	gamestate=0
	gametimer=60
	gametext=""
	gamecurrentround=1
	gamepoints.p1=0
	gamepoints.p2=0

	setcharacter(p1,characters[2])
	p1.ready=false
	setcharacter(p2,characters[3])
	p2.ready=false
	resetplayers()

	clear_tables()
end

function resetplayers()

	p1.posx=25
	p1.posy=99
	p1.flipped=false
	p1.fatality=false
	p1.babality=false
	p1.health=100	
	_updateplyr(p1)
	p1.charactersprite=p1.characterdflt

	p2.posx=90
	p2.posy=99
	p2.flipped=true
	p2.fatality=false
	p2.babality=false
	p2.health=100	
	_updateplyr(p2)
	p2.charactersprite=p2.characterdflt
end

function setcharacter(p,c)
	p.characterid=c.id
	p.charactername=c.name
	p.characterselected=c.selected
	p.charactercol1=c.col1
	p.charactercol2=c.col2
	p.charactersprite=c.sprite
	p.characterdflt=c.dflt
	p.characterdfnd=c.dfnd
	p.charactera1=c.a1
	p.charactera2=c.a2
	p.charactera3=c.a3
	p.characterstun=c.stun
	p.characterfatality=c.fatality
	p.characterbabality=c.babality
	p.characterprojectilesprite=c.projectilesprite	
end

--used in the level select screen to update character selections
function selectcharacter(p)
	pctrl=p.ctrl
	pcharid=p.characterid
	if lvlselectsection==1 and p.ready != true then
		if (btnp(0,pctrl) and pcharid!=1 and pcharid!=5) pcharid-=1 menunavsfx()
		if (btnp(1,pctrl) and pcharid!=4 and pcharid!=6) pcharid+=1 menunavsfx()
		if btnp(2,pctrl) then
			if (pcharid==5) pcharid=2
			if (pcharid==6) pcharid=3
			menunavsfx()
		end
		if btnp(3,pctrl) then
			if (pcharid==2) pcharid=5
			if (pcharid==3) pcharid=6
			menunavsfx()
		end
		if btnp(5,pctrl) then
			p.ready=true 
			if pcharid==1 or pcharid==4 then
				repeat
					pcharid=1+flr(rnd(6))
				until pcharid!=1 and pcharid!=4
			end
			setcharacter(p,characters[pcharid])
			sfx(18,-1,-1)
		end
		if p.ctrlcombobtns=="4401012323" then
			p.ready=true 
			pcharid=7
			setcharacter(p,characters[pcharid])
			sfx(18,-1,-1)
		end
		p.characterid=pcharid
	end	
end

function menunavsfx()
	sfx(19,-1,-1) 
end

function newround()
	gamestate=0
	gametimer=60
	gametext=""
	gamecurrentround+=1

	resetplayers()

	p1.blood={}
	p2.blood={}
end

function clear_tables()
	p1.blood={}
	p2.blood={}
	rain={}
end

function resetcombocount(p)
	p.ctrlcomboresetcount=0
end

function center_text(str, y, c0)
	x=63.5-flr((#str*4)/2)
	print(str,x,y,c0)
end

 function outline_text(str, x, y, c0, c1, center_align)
	if (center_align) x=63.5-flr((#str*4)/2)
	for xx = -1, 1 do
			for yy = -1, 1 do
				print(str, x+xx, y+yy, c1)
			end
	end
	print(str,x,y,c0)
end

function grounded(p)
	if p.dy<0 then 
		--if moving up then grounded is always false
		r = false 
	else
		v = mget(((flr(p.posx))/8)+selectedlevel.x+1, 
			flr(p.posy)/8+1)
		--printh(v)
		r = fget(v, 0)
	end
	if (r) p.ctrljumpleft=0 p.ctrljumpright=0
	return r
end

function get_winner()
	p1health=p1.health
	p2health=p2.health
	wintext=p1health==p2health and "its a draw" or p1health>p2health and p1.charactername.." wins!" or p2.charactername.." wins!"
	return wintext
end

function togglegoremenu() 
	if gamegore then 
		gamegore=false
		menuitem(1,"enable gore", togglegoremenu)
	else
		gamegore=true
		menuitem(1,"disable gore", togglegoremenu)
	end
end

function showcontrols()
	gamepaused=true
	drawcontrolscreen=true
end

function create_hitboxes()	
	--default 
	p1.hitboxes={
		--default
		{x=3,y=5,w=9,h=6,f=false,s=0,d=false},
		{x=5,y=0,w=5,h=16,f=false,s=0,d=false},
		{x=3,y=5,w=9,h=6,f=true,s=0,d=false},
		{x=5,y=0,w=5,h=16,f=true,s=0,d=false},
		--attack 1
		{x=5,y=0,w=5,h=16,f=false,s=1,d=false},
		{x=10,y=4,w=4,h=3,f=false,s=1,d=true},
		{x=5,y=0,w=5,h=16,f=true,s=1, d=false},
		{x=1,y=4,w=4,h=3,f=true,s=1,d=true},
		--attack 2
		{x=4,y=0,w=5,h=5,f=false,s=2,d=false},
		{x=2,y=6,w=8,h=3,f=false,s=2,d=false},
		{x=3,y=10,w=10,h=1,f=false,s=2,d=true},
		{x=6,y=12,w=3,h=4,f=false,s=2,d=false},
		{x=7,y=0,w=5,h=5,f=true,s=2,d=false},
		{x=4,y=6,w=8,h=3,f=true,s=2,d=false},
		{x=2,y=10,w=10,h=1,f=true,s=2,d=true},
		{x=6,y=12,w=3,h=4,f=true,s=2,d=false},
		--jumping attack 3
		{x=3,y=0,w=5,h=11,f=false,s=3,d=false},
		{x=9,y=5,w=3,h=1,f=false,s=3,d=true},
		{x=9,y=9,w=2,h=1,f=false,s=3,d=true},
		{x=5,y=12,w=4,h=1,f=false,s=3,d=true},
		{x=7,y=0,w=5,h=11,f=true,s=3,d=false},
		{x=3,y=5,w=3,h=1,f=true,s=3,d=true},
		{x=4,y=9,w=2,h=1,f=true,s=3,d=true},
		{x=6,y=12,w=4,h=1,f=true,s=3,d=true},
		--defending
		{x=5,y=2,w=5,h=13,f=false,s=4,d=false},
		{x=5,y=4,w=7,h=1,f=false,s=4,d=false},
		{x=4,y=6,w=8,h=4,f=false,s=4,d=false},
		{x=5,y=2,w=5,h=13,f=true,s=4,d=false},
		{x=3,y=4,w=7,h=1,f=true,s=4,d=false},
		{x=3,y=6,w=8,h=4,f=true,s=4,d=false},
		--stunned
		{x=12,y=6,w=3,h=4,f=false,s=5,d=false},
		{x=7,y=8,w=5,h=7,f=false,s=5,d=false},
		{x=3,y=13,w=3,h=2,f=false,s=5,d=false},
		{x=0,y=6,w=3,h=4,f=true,s=5,d=false},
		{x=4,y=8,w=5,h=7,f=true,s=5,d=false},
		{x=9,y=13,w=3,h=2,f=true,s=5,d=false}
	}

	--copy to player 2
	p2.hitboxes=p1.hitboxes
end

function create_characters()
	
	characters={
		{id=1,name="random1"},
		{id=2,name="scorpion",selected=false,col1=9,col2=10,sprite=64,dflt=64,dfnd=68,a1=70,a2=72,a3=66,stun=74,fatality=92,babality=30,projectilesprite=79},
		{id=3,name="sub-zero",selected=false,col1=13,col2=12,sprite=64,dflt=64,dfnd=68,a1=70,a2=72,a3=66,stun=74,fatality=92,babality=31,projectilesprite=94},
		{id=4,name="random2"},
		{id=5,name="reptile",selected=false,col1=11,col2=3,sprite=64,dflt=64,dfnd=68,a1=70,a2=72,a3=66,stun=74,fatality=92,babality=14,projectilesprite=95},
		{id=6,name="liu kang",selected=false,col1=9,col2=10,sprite=96,dflt=96,dfnd=100,a1=102,a2=104,a3=98,stun=106,fatality=124,babality=15,projectilesprite=78},
		{id=7,name="burning",selected=false,col1=9,col2=10,sprite=224,dflt=224,dfnd=228,a1=230,a2=232,a3=226,stun=234,fatality=252,babality=208,projectilesprite=78}
	}
	
	setcharacter(p1,characters[2])
	setcharacter(p2,characters[3])
end

function create_levels()

	levels={
		{index=1,name="arena (day)",x=2,y=0,backcol=12,cloud={stormy=false,max=5,clouds={}},raining=false,raincol=12,groundyoffset=3}, --daylight arena
		{index=2,name="arena (night)",x=2,y=0,backcol=1,cloud={stormy=true,max=8,clouds={}},raining=true,raincol=12,groundyoffset=3}, --stormy night arena
		{index=3,name="fortress (day)",x=22,y=0,backcol=12,cloud={stormy=false,max=5,clouds={}},raining=false,raincol=12,groundyoffset=0}, --day fortress
		{index=4,name="fortress (night)",x=22,y=0,backcol=1,cloud={stormy=true,max=5,clouds={}},raining=true,raincol=12,groundyoffset=0}, --stormy night fortress
		{index=5,name="fire tower",x=42,y=0,backcol=2,cloud={stormy=true,max=10,clouds={}},raining=true,raincol=8,groundyoffset=0}, --fire tower
		{index=6,name="sewer",x=62,y=0,backcol=2,cloud={stormy=true,max=10,clouds={}},raining=false,raincol=8,groundyoffset=0} --sewer
	}
	
	selectedlevel=levels[1]

end

function collide(obj, other)
	otherposx=other.posx
	otherposy=other.posy
	for hb in all(obj.hitboxes) do
		if hb.d==true and hb.s==obj.state then
			for hb2 in all(other.hitboxes) do
				if hb2.s==other.state then
					if
						other.posx+hb2.x+hb2.w >= obj.posx+hb.x and 
						other.posy+hb2.y+hb2.h >= obj.posy+hb.y and
						other.posx+hb2.x <= obj.posx+hb.x+hb.w and
						other.posy+hb2.y <= obj.posy+hb.y+hb.h
					then
						return true
					end
				end
			end
		end
	end
end

function calcdamage()	
	--game playing state
	if gamestate==1 then
		checkdmg(p1,p2)
		checkdmg(p2,p1)		
	end
	--finish him state
	if gamestate==2 then		
		if collide(p1,p2) and p2.fatality==false and p1.alive then
			--p2 must be dead so soak the ground with his entrails
			if (p1.charactersprite==p1.charactera1) p2.fatality=true make_skull(p2)
			if (p1.charactersprite==p1.charactera2) p2.babality=true
		end
		if collide(p2,p1) and p1.fatality==false and p2.alive then
			--p1 must be dead so wipe him off the face off the earth
			if (p2.charactersprite==p2.charactera1) p1.fatality=true make_skull(p1)
			if (p2.charactersprite==p2.charactera2) p1.babality=true
		end
	end
end

function checkdmg(player,target)
	local targetsprite=target.charactersprite
	local targetdfnd=target.characterdfnd
	local targetflipped=target.flipped
	local targetposx=target.posx
	local targetposy=target.posy
	local playersprite=player.charactersprite
	local playerflipped=player.flipped
	--checks for damage against target
	if (targetsprite != targetdfnd or playerflipped == targetflipped) then
		if player.posy<targetposy and playersprite==player.charactera3 then
			if collide(player,target) then
				target.health-=1--rnd(1)+1
				make_objectblood(target,7,5,2,targetflipped)
			end
		end
		if playersprite==player.charactera1 then
			if collide(player,target) then
				target.health-=0.5--rnd(2)+2
				make_objectblood(target,7,5,6,targetflipped)
			end
		end
		if playersprite==player.charactera2 then
			if collide(player,target) then
				target.health-=0.5--rnd(2)+2
				make_objectblood(target,7,5,4,targetflipped)
			end
		end
	end
		
	--projectiles check
	for pr in all(player.projectiles) do
		for hb in all(target.hitboxes) do
			if hb.s==target.state then
				if
					targetposx+hb.x+hb.w >= pr.hitx and 
					targetposy+hb.y+hb.h >= pr.hity and
					targetposx+hb.x <= pr.hitx+pr.hitw and
					targetposy+hb.y <= pr.hity+pr.hith 
				then
					if (targetsprite != targetdfnd or playerflipped == targetflipped) then
						target.health-=10*pr.t--rnd(2)+2
						make_objectblood(target,7,5,4,targetflipped)
						del(player.projectiles,pr)
					else
						del(player.projectiles,pr)
					end
				end
			end
		end
	end
end

function make_blood(num)
	srand(0)
	for c=1,num do
		la=0
		lx=110+rnd(10)ly=100+rnd(10)la=rnd(5)-5
		lb=rnd(5)-5
		for i=1,30 do
		local blood={
		x=lx+rnd(9),
		y=ly+rnd(9),
		r=rnd(5)+1,
		col=8
		}
		add(bloodsplats,blood)
		lx+=la
		ly+=lb
		end
	end
end

function make_skull(p)
	f=p.flipped and 1 or -1
	skull.draw=true
	skull.posx=p.posx
	skull.posy=p.posy
	skull.flipped=p.flipped
	skull.t=0
	skull.life_time=45
	skull.dy=-5
	skull.dx=f*0.3
	skull.ddy=0.2
	skull.ddx=0
	if (not skull.flipped)skull.posx+=8
end

function make_rain(startx,starty)
	local rain_particle={
				--the location of the particle
				x=startx,
	y=starty,
	--what percentage 'dead'is the particle
	t = 0,
	--how long before the particle fades
	life_time=100+rnd(10),
	--how big is the particle,
	--and how large will it grow?
	size = 2,
	max_size = 2,--+rnd(3),   
	--'delta x/y' is the movement speed,
	--or the change per update in position
	--randomizing it gives variety to particles
	dy = 5,--rnd(0.7) * 10,
	dx = 1.5,--rnd(0.4)+0.2,--rnd(0.4) - 
	--'ddy' is a kind of acceleration
	--increasing speed each step
	--this makes the particle seem to float
	ddy = 0,
	--what color is the particle
	col = 12,
	splash=false
	}
		add(rain,rain_particle)
end

function make_clouds()
	if count(selectedlevel.cloud.clouds)<selectedlevel.cloud.max then
		--randomize between cloud types
		if flr(rnd(2))==0 then
			cs=1
			cw=2
			ch=1
		else
			cs=18
			cw=3
			ch=1
		end
		
		local cloud={
			sprite=cs,
			x=-20,
			y=rnd(40)+5,
			w=cw,
			h=ch,
			dx=rnd(0.5)+0.1
		}
		add(selectedlevel.cloud.clouds,cloud)
	end
end

function make_objectblood(p,xoffset,yoffset,num,flipped,color,fadecolor)
	if flipped then f=-1 else f=1 end
	--if gamegore then c1 = 8 c2 = 2 else c1 = 11 c2 = 3 end
	color=color or 8
	fadecolor=fadecolor or 2
	for c=1,num do
		local playerblood_particle={
			x=p.posx+xoffset,
			y=p.posy+yoffset,
			t=0,
			life_time=100+rnd(50),
			size=1,
			max_size=1,--2+rnd(2),
			dy=-(rnd(0.9)+1),
			dx=f*(rnd(0.7)+1),
			ddy=0.2,
			ddx=0.1,
			col=color,
			col2=fadecolor
		}
		add(p.blood,playerblood_particle)
	end
end

function make_lava(startx,starty,num)
	for c=1,num do
		local lava_particle={
			x=startx,
			y=starty,
			t=0,
			life_time=120,
			size=1,
			dy=(rnd(1)+0.2),
			col=rnd(1)>0.5 and 8 or 10
		}
		add(lava,lava_particle)
	end
end

function combocounter(p)
	local ctrl = p.ctrl
	p.ctrlcomboresetcount+=1
	p.ctrlcombo=""
	local maxcombo=5
	if gamestate==0 then
		maxcombo=11
		if (btnp(0,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."0") resetcombocount(p)
		if (btnp(1,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."1") resetcombocount(p)
		if (btnp(2,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."2") resetcombocount(p)
		if (btnp(3,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."3") resetcombocount(p)
	end
	if (btnp(4,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."4") resetcombocount(p)
	if (btnp(5,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."5") resetcombocount(p)
	if p.ctrlcomboresetcount > maxcombo or #p.ctrlcombobtns > maxcombo then
		resetcombocount(p)
		printh(" combo: "..p.ctrlcombobtns)
		p.ctrlcombo=p.ctrlcombobtns
		p.ctrlcombobtns=""
	end
end 

--** updates **--
function _update()
	--increase the frame count
	fcount+=1

	--combos
	combocounter(p1)
	combocounter(p2)

	if gamepaused then
		if drawcontrolscreen then
			if (btnp(5)) drawcontrolscreen=false gamepaused=false return
		end
	end

	--title screen
	if screen==0 then
		for r=1,3 do
    		make_rain(rnd(160),0)
  		end
  		update_rain()
		if not countdownactive then
			if btnp(5) then 
				make_blood(10)
				--music(-1)
				sfx(12,-1,0,8)
				countdownactive=true
			end
		else
			if countdown==100 then
				countdownactive=false
				screen=2
				countdown=0
			else
				countdown+=1
			end
		end
	end	

	--level select screen
	if screen==2 then
		if gamepaused==false then
			update_level()
			update_levelselect()
		end
	end
	--game screen
	if screen==1 then
		_updategame()
	end
	if (fcount==30) fcount=0
end

function update_level()
	if (selectedlevel.raining) for r=1,3 do make_rain(rnd(160),0) end
	--if (selectedlevel.index==5) 
	make_lava((50+rnd(28)),0,5)
	update_rain()
	update_lava()
	if (selectedlevel.cloud) make_clouds() update_clouds()
end

function update_levelselect()
	if (rarrowcol==8) rarrowcount+=1
	if (larrowcol==8) larrowcount+=1
	selectcharacter(p1)
	selectcharacter(p2)
	
	if (p1.ready and p2.ready and lvlselectsection==1) lvlselectsection=2

	--left
	if btnp(0) then
		if lvlselectsection==2 and lvlselectindex>1 then
			lvlselectindex-=1
			selectedlevel=levels[lvlselectindex]
			larrowcol=8
			larrowcount=0
		end
		if (lvlselectsection==3 and gamemaxrounds!=3) gamemaxrounds-=2
		menunavsfx()
	end
	--right
	if btnp(1) then
		if lvlselectsection==2 and lvlselectindex < count(levels) then
			lvlselectindex+=1
			selectedlevel=levels[lvlselectindex]
			rarrowcol=8
			rarrowcount=0
		end
		if (lvlselectsection==3 and gamemaxrounds!=7) gamemaxrounds+=2
		menunavsfx()
	end
	--up
	if btnp(2) then
		if lvlselectsection>2 then
			lvlselectsection-=1
			menunavsfx()
		end
	end
	--down
	if btnp(3) then
		if p1.ready and p2.ready and lvlselectsection<3 then
			lvlselectsection+=1
			menunavsfx()
		end
	end
	--z
	if btnp(4) then 
		
	end
	--x
	if btnp(5) and p1.ready and p2.ready then 
		screen=1
		gamestate=0
	end
end

function _updategame()
	if (gamepaused) return
	--do regardless of state
	update_level()
	update_playerblood(p1)
	update_playerblood(p2)
	update_playerblood(skull)
	if (gamestate==1 and (gametimer==0 or p1.alive==false or p2.alive==false)) gamestate=5 countdownactive=true
		--check both players are still alive
	--if ((p1.alive==false or p2.alive==false) and gamestate==1) gamestate=5 countdownactive=true

	--countdown state
	if gamestate==0 then
		if not countdownactive then
			gametext="round "..gamecurrentround.."!"
			sfx(16,2)
			countdownactive=true
		else
			countdown+=1
			countdowninterval=30
			if (countdown==(1*countdowninterval)) gametext="3!" sfx(16,2)
			if (countdown==(2*countdowninterval)) gametext="2!" sfx(16,2)
			if (countdown==(3*countdowninterval)) gametext="1!" sfx(16,2)
			if (countdown==(4*countdowninterval)) gametext="fight" sfx(17,2)
			if countdown==(5*countdowninterval) then
				countdown=0
				countdownactive=false
				gamestate=1
			end		
		end
	end

	--fighting state
	if gamestate==1 then 
		gametimer -= ((time()%1==0) and 1 or 0)		
	end

	--finish him state
	if gamestate==2 and countdownactive then
		countdown+=1
		if (countdown==150) gamestate=3 countdownactive=true countdown=0
	end

	--player updates
	if gamestate==1 or gamestate==2 or gamestate==5 then
		if (p1.alive and p1.state!=4) p1.flipped=(p2.posx<p1.posx)
		if (p2.alive and p2.state!=4) p2.flipped=(p1.posx<p2.posx)
		_updateplyr(p1)	
		_updateplyr(p2)
		update_skull()
		calcdamage()
	end

	--make sure that when the timer runs out the 
	--players dont get stuck in the air
	if gamestate==3 or gamestate==4 then
		_updateplyr(p1)
		_updateplyr(p2)
		update_skull()
		if grounded(p1) then 
			if (p1.charactersprite!=p1.characterdfnd and p1.charactersprite!=p1.characterstun) p1.charactersprite=p1.characterdflt 
		end
		if grounded(p2) then 
			if (p2.charactersprite!=p2.characterdfnd and p2.charactersprite!=p2.characterstun) p2.charactersprite=p2.characterdflt 
		end
	end

	if gamestate==3 then
		if countdownactive then 
			countdown+=1
			if countdown==30 then 
				countdownactive=false
				countdown=0 
			end
		else
			if (btnp(5)) screen=2 resetgame()
			if (btnp(4)) mainmenu()
		end
	end

	if gamestate==4 then
		if countdownactive then 
			countdown+=1
			if countdown==60 then 
				countdownactive=false
				countdown=0 
			end
		else		
			newround() 
		end
	end

	if gamestate==5 then
		if countdownactive then
			countdown+=1
			if countdown==30 then
				if (p1.health>p2.health) gamepoints.p1+=1
				if (p2.health>p1.health) gamepoints.p2+=1
				if (gamepoints.p1 > flr(gamemaxrounds/2)) or (gamepoints.p2 > flr(gamemaxrounds/2)) then
					if p1.alive==false or p2.alive==false then
						gamestate=2 gametext="finish" countdownactive=true countdown=0
					else
						gamestate=3 countdownactive=true countdown=0
					end
				else
					gamestate=4 countdownactive=true countdown=0
				end
			end
		end
	end
end

function update_rain()
  --perform actions on every particle
  for p in all(rain) do
    --move the rain
    p.y += p.dy
    p.x -= p.dx
    p.dy+= p.ddy
    --increase the rain's life counter
    --so that it lives the correct number of steps
    p.t += 1/p.life_time
	local t=p.t
    --grow the rain particle over time
    --(but not smaller than its starting size)
    p.size = max(p.size, p.max_size * t )
    --make fading rain particles a darker color
    --gives the impression of fading
    --change color if over 70% of time passed
    if t > 0.7  then
      p.col = 6
    end
    if t > 0.9 then
      p.col = 5
    end
    --if the particle has expired,
    --remove it from the 'rain' list
    if t > 1 then
      del(rain,p)
    end
  end
end

function update_clouds()
	for c in all(selectedlevel.cloud.clouds) do
		c.x+=c.dx
		if (c.x>130) del(selectedlevel.cloud.clouds,c)
	end
end

function update_playerblood(p)
  --perform actions on every particle
  for b in all(p.blood) do
  	b.t += 1/b.life_time
	t=b.t
    if b.y<=110+selectedlevel.groundyoffset then
		b.y += b.dy
		--if (b.dx>0) 
		b.x -= b.dx
		b.dy+= b.ddy
		--b.dx-= b.ddx		
		b.size = max(b.size, b.max_size * t )
	end		
    if t > 0.7  then
      b.col = b.col2
    end
    if t > 1 then
      del(p.blood,b)
    end
  end
end

function update_skull()
	if (skull.draw==false) return
	skull.posy+=skull.dy
	skull.posx+=skull.dx
	skull.dy+=skull.ddy
	skull.dx+=skull.ddx
	skull.t +=1/skull.life_time
	if skull.t>1 then
		skull.draw=false
		make_objectblood(skull,0,0,20,true)
		make_objectblood(skull,0,0,20,false)
	end
end


function update_lava()
  --perform actions on every particle
  for l in all(lava) do
	l.y += l.dy
	--l.dy+= l.ddy
	l.t += 1/l.life_time
    if l.t > 1 or l.y>110 then
      del(lava,l)
    end
  end
end

function _updateplyr(p)
	local ctrl=p.ctrl
	--[[combos
	p.ctrlcomboresetcount+=1
	p.ctrlcombo=""
	--if (btnp(0,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."0") resetcombocount(p)
	--if (btnp(1,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."1") resetcombocount(p)
	--if (btnp(2,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."2") resetcombocount(p)
	--if (btnp(3,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."3") resetcombocount(p)
	if (btnp(4,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."4") resetcombocount(p)
	if (btnp(5,ctrl)) p.ctrlcombobtns = (p.ctrlcombobtns.."5") resetcombocount(p)
	if p.ctrlcomboresetcount > 5 or #p.ctrlcombobtns > 5 then
		resetcombocount(p)
		--printh(p.name.." combo: "..p.combobtns)
		p.ctrlcombo=p.ctrlcombobtns
		p.ctrlcombobtns=""
	end
	]]--

	if (p.posx<=_mapbounds.l)p.posx=_mapbounds.l
	if (p.posx>=_mapbounds.r)p.posx=_mapbounds.r

	p.alive=(p.health>0)
	--check if player has suffered a fatality
	if p.fatality and (fcount%15==0) then
		if p.flipped then
			make_objectblood(p,5,8,10,not p.flipped)
		else
			make_objectblood(p,10,8,10,not p.flipped)
		end
	end
	--check if player has suffered a babality
	if p.babality then--and (fcount%15==0) then
		bx=p.flipped and 4 or 10
		make_objectblood(p,bx,13,1,not p.flipped,12,1)
		make_objectblood(p,bx,13,1,p.flipped,12,1)
	end

	update_projectiles(p)

	--check if the player is dead
	if p.alive==false and grounded(p) then
		p.charactersprite=p.characterstun	
		p.state=5	
		return
	end

	if ((gamestate==3 or gamestate==4) and grounded(p)) return

	--attack animations
	if p.state==1 or p.state==2 or p.state==4 and grounded(p) then
		if p.animatecount<7 then
			p.charactersprite=p.characterdflt 
			p.animatecount+=1
			p.charactersprite=p.state==1 and p.charactera1 or p.state==2 and p.charactera2 or p.characterdfnd
		else
			p.animatecount=0
			p.state=0
		end
	else
		p.dx=0
		p.charactersprite=p.characterdflt

		--reset button state if nothing is depressed
		if (not btn(2,ctrl)) p.ctrlbtn2=0
		if (not btn(3,ctrl)) p.ctrlbtn3=0
		if (not btn(4,ctrl)) p.ctrlbtn4=0
		if (not btn(5,ctrl)) p.ctrlbtn5=0
		
		--p ctrls
		--defend
		if grounded(p) and btnp(3,ctrl) and p.ctrlbtn3==0 then
			p.charactersprite=p.characterdfnd
			p.state=4
			p.ctrlbtn3=1
		else
			p.state =0
		end
		
		--if defending then cant move
		if p.charactersprite==p.characterdfnd then
			return
		end
		
		--left	
		if btn(0,ctrl) and grounded(p) then
			--p.posx-=1
			p.dx-=1
		end
		--right
		if btn(1,ctrl) and grounded(p) then
			--p.posx+=1
			p.dx+=1
		end
			
		--jumping
		if (grounded(p)) then
			if(btn(2,ctrl) and p.ctrlbtn2==0) then
				if (btn(0,ctrl)) p.ctrljumpleft=1
				if (btn(1,ctrl)) p.ctrljumpright=1
				p.ctrlbtn2=1
				p.dy-=8
				sfx(13,-1,0,2)
			else
				p.dy=0
				p.posy=flr(flr(p.posy)/8)*8
			end
		else
			p.charactersprite=p.charactera3
			if (p.dy<7) p.dy+=0.98
			p.state=3
			if (p.ctrljumpleft==1) p.dx-=2
			if (p.ctrljumpright==1) p.dx+=2
		end	
		p.posx+=p.dx
		p.posy+=p.dy
		if(grounded(p)) then			
			p.dy=0
			p.posy=(flr(flr(p.posy)/8)*8)
		end

		if gamestate==1 then
			--attack 1
			if (grounded(p) and p.ctrlcombo=="4") then
				p.ctrlbtn4=1
				p.state=1
				p.charactersprite=p.charactera1 
				sfx(14,-1,-1)
			end
			
			--attack 2
			if (grounded(p) and p.ctrlcombo=="5") then
				p.ctrlbtn5=1
				p.state=2
				p.charactersprite=p.charactera2
				sfx(15,-1,-1)
			end

			--projectile attack
			if (p.ctrlcombo=="545") then
				if p.flipped then
					pf=-1
					xoff=0
				else
					pf=1
					xoff=5
				end
				local proj={
					x=p.posx+xoff,
					y=p.posy+2,
					f=p.flipped,
					dx=pf*3,
					life_time=60,
					sprite=p.characterprojectilesprite,
					t=0,
					hitx=p.posx+xoff,
					hity=p.posy+4,
					hitw=8,
					hith=4
				}
				add(p.projectiles,proj)
				sfx(20,-1,-1)
			end

		else
			if (p.ctrlcombo=="445") then
				p.ctrlbtn4=1
				p.state=1
				p.charactersprite=p.charactera1 
				sfx(14,-1,-1)
			end
			if (p.ctrlcombo=="5545") then
				p.ctrlbtn5=1
				p.state=2
				p.charactersprite=p.charactera2 
				sfx(15,-1,-1)
			end
		end
	end
end

function update_projectiles(p)
	for c in all(p.projectiles) do
		c.x+=c.dx
		c.hitx+=c.dx
		c.t+=1/c.life_time
		if (c.t>1) del(p.projectiles,c)
	end
end

--** drawing **--
function _draw()
	cls()
	if screen==0 then
		_drawtitle()
		if(countdownactive) clip(10,22,104,70) draw_blood() clip()
		draw_rain()		
	end
	if screen==1 then
		_drawgame()
	end
	if screen==2 then
		_drawlevelselect()
	end

	--[[draw hitboxes in debug mode
	if hitboxshow then
	if p1.flipped then p1f=-1 else p1f=1 end
	if p2.flipped then p2f=-1 else p2f=1 end
		for hit in all(p1.hitboxes) do
			if (p1.flipped == hit.f) and (hit.s==p1.state) then
				if hit.d==false then hcol=12 else hcol=8 end
				rect(p1.posx+hit.x,p1.posy+hit.y,p1.posx+hit.x+hit.w,p1.posy+hit.y+hit.h,hcol)
			end
		end
		for hit in all(p2.hitboxes) do
			if (p2.flipped == hit.f) and (hit.s==p2.state) then
				if hit.d==false then hcol=11 else hcol=8 end
				rect(p2.posx+hit.x,p2.posy+hit.y,p2.posx+hit.x+hit.w,p2.posy+hit.y+hit.h,hcol)
			end
		end
	end
	]]--

	if drawcontrolscreen then
		_drawcontrols()
	end
	
	--[[
	if debug then 
		print("screen: "..screen,0,122,7)
		print(stat(1),50,122,7)
	end
	]]--
end

function _drawcontrols()
	x=13
	y=6
	w=100
	h=115
	rectfill(x,y,x+w,y+h,7)
	rectfill(x+1,y+1,x+w-1,y+h-1,0)
	print("basic controls :", x+5,y+5,7)

	print("left = \x8b", x+5,y+20,7)
	print("right = \x91", x+55,y+20,7)
	print("jump = \x94", x+5,y+30,7)
	print("block = \x83", x+55,y+30,7)
	print("punch = \x8e", x+5,y+40,7)
	print("kick = \x97", x+55,y+40,7)

	print("projectile = \x97 \x8e \x97", x+5,y+50,7)

	print("finishers :", x+5,y+65,7)
	print("fatality = \x8e \x8e \x97", x+5,y+80,7)
	print("babality = \x97 \x97 \x8e \x97", x+5,y+90,7)

	print("press \x97 to close", x+5,y+107,7)
	--str, x, y, c0, c1, center_align
end

function draw_rain()
	--rect(0,0,127,120)
	if (screen == 0) clip(6,9,116,108)
	if (screen == 1) clip(1,3,126,122)
	if (screen == 2) clip(11,58,106,30)

	if ((screen==0) or ((screen==1 or screen==2) and selectedlevel.raining==true)) then
	--draw each particle
		for p in all(rain) do	  
			if (screen==1 or screen==2) and p.y>=113 and p.splash==false then			
				if flr(rnd(10))==0 then
					p.splash=true
					p.life_time=5
					p.dx=0
				else
				p.t=p.life_time
				end
			end
				
			if(p.splash) then	
				pal(12,selectedlevel.raincol)
				spr(32,p.x,107)
				pal()
			else
				line(p.x,p.y-5,p.x-1,p.y-2,selectedlevel.raincol)
			end	
		end
	end
 clip()
end

function draw_clouds()
	palt(12,true)
	if (selectedlevel.cloud.stormy) pal(6,5) pal(7,6)
	for c in all(selectedlevel.cloud.clouds) do		 
		spr(c.sprite,c.x,c.y,c.w,c.h)
		--pal()
	end
	palt()
	pal()
end

function draw_blood()
  	for b in all(bloodsplats) do
  		circfill(b.x,b.y,b.r,b.col)
   	end
end

function _drawlevelselect()
	mapoffsety=13

	if (lvlselectsection==1) rect(2,5,125,46,8)
	if (lvlselectsection==2) rect(2,mapoffsety+35,125,mapoffsety+84,8)
	if (lvlselectsection==3) rect(2,99,125,109,8)

	drawcharacterselect()	

	--level select section
	clip(11,mapoffsety+45,106,30)
	rectfill(11,mapoffsety+45,117,mapoffsety+75,selectedlevel.backcol)
	draw_clouds()
	palt(0,false) 
	palt(12,true)	
	--draw specific animations
	draw_levelanims()
	mapdraw(selectedlevel.x,0,0,mapoffsety,16,15)
	clip()
	if lvlselectindex>1 then
		if (larrowcount>5) pal(larrowcol,6) larrowcol=6
		pal(6,larrowcol)
		spr(131,3,mapoffsety+52,1,1,true)
		spr(131,3,mapoffsety+60,1,1,true,true)
	end
	
	if lvlselectindex!=count(levels) then
		if (rarrowcount>5) pal(rarrowcol,6) rarrowcol=6
		pal(6,rarrowcol)
		spr(131,117,mapoffsety+52,1,1)
		spr(131,117,mapoffsety+60,1,1,false,true)
	end
	palt()
	pal()	
	draw_rain()
	rect(11,mapoffsety+44,116,mapoffsety+75,7)	
    
	outline_text("-stage select-",0,mapoffsety+37,7,0,true)
	outline_text(selectedlevel.name,0,mapoffsety+78,7,0,true)

	--round select section
	numroundsx=10
	numroundsy=102
	print("number of rounds:",numroundsx,numroundsy,7)
	offset=numroundsx+71
	if (gamemaxrounds==3) rect(offset,numroundsy+1,offset+2,numroundsy+3,8)
	print("3",offset+5,numroundsy,7)
	if (gamemaxrounds==5) rect(offset+15,numroundsy+1,offset+17,numroundsy+3,8)
	print("5",offset+20,numroundsy,7)
	if (gamemaxrounds==7) rect(offset+30,numroundsy+1,offset+32,numroundsy+3,8)
	print("7",offset+35,numroundsy,7)

	outline_text("press \x97 to fight !",0,113,0,7,true)
	--rect(0,0,127,119,7)
	rect(0,3,127,122,7)
end

function drawcharacterselect()
	--character select section
	charselectx=10
	charselecty=15

	if (time()%1)==0 then
		if p1.characterid==1 or p1.characterid==4 then
			selplyr=charselectp1
			repeat
				charselectp1=1+flr(rnd(6))
			until (charselectp1!=1 and charselectp1!=4 and charselectp1!=selplyr)
		else
			charselectp1=p1.characterid
		end
		if p2.characterid==1 or p2.characterid==4 then
			selplyr=charselectp2
			repeat
				charselectp2=1+flr(rnd(6))
			until (charselectp2!=1 and charselectp2!=4 and charselectp2!=selplyr)
		else
			charselectp2=p2.characterid
		end
	end
	p1char=characters[charselectp1]
	p2char=characters[charselectp2]
	outline_text("-character select-",0,8,7,0,true)
	
	if flr(time())%2==0 then
		backcol=1
		p1sprite=p1char.dflt
		p2sprite=p2char.dflt
	else
		backcol=13
		p1sprite=p1char.dfnd
		p2sprite=p2char.dfnd		
	end
	palt(14,true)
	palt(0,false)
	--player 1 selection
	pal(9,p1char.col1)
	pal(10,p1char.col2)
	rectfill(charselectx,charselecty,charselectx+18,charselecty+28,p1.ready and 3 or backcol)
	rect(charselectx,charselecty,charselectx+18,charselecty+28,7)
	spr(p1sprite,charselectx+2,charselecty+8,2,2)
	--player 2 selection
	pal(9,p2char.col1)
	pal(10,p2char.col2)
	rectfill(charselectx+90,charselecty,charselectx+108,charselecty+28,p2.ready and 3 or backcol)
	rect(charselectx+90,charselecty,charselectx+108,charselecty+28,7)
	spr(p2sprite,charselectx+92,charselecty+8,2,2,true)
	palt()
	pal()
	--character sprites
	--random1 id=1
	spr(196,charselectx+28,charselecty+3,1,1)
	rect(charselectx+27,charselecty+2,charselectx+28+8,charselecty+11,7)
	--scorpion id=2
	spr(192,charselectx+43,charselecty+3,1,1)
	rect(charselectx+42,charselecty+2,charselectx+43+8,charselecty+11,7)
	--subzero id=3
	spr(193,charselectx+58,charselecty+3,1,1)
	rect(charselectx+57,charselecty+2,charselectx+58+8,charselecty+11,7)
	--random2 id=4
	spr(196,charselectx+73,charselecty+3,1,1)
	rect(charselectx+72,charselecty+2,charselectx+73+8,charselecty+11,7)
	--reptile id=5
	spr(195,charselectx+43,charselecty+18,1,1)
	rect(charselectx+42,charselecty+17,charselectx+43+8,charselecty+26,7)
	--liu kang id=6
	spr(194,charselectx+58,charselecty+18,1,1)
	rect(charselectx+57,charselecty+17,charselectx+58+8,charselecty+26,7)
	if p1.characterid!=7 then
		if p1.characterid<5 then
			pidadd=(p1.characterid)*15
			line(charselectx+10+pidadd,charselecty,charselectx+15+pidadd,charselecty,10) 
			line(charselectx+10+pidadd,charselecty,charselectx+10+pidadd,charselecty+5,10)
			line(charselectx+18+pidadd,charselecty+13,charselectx+23+pidadd,charselecty+13,10) 
			line(charselectx+23+pidadd,charselecty+8,charselectx+23+pidadd,charselecty+13,10)
		else
			pidadd=(p1.characterid-3)*15
			line(charselectx+10+pidadd,charselecty+15,charselectx+15+pidadd,charselecty+15,10) 
			line(charselectx+10+pidadd,charselecty+15,charselectx+10+pidadd,charselecty+20,10)
			line(charselectx+18+pidadd,charselecty+28,charselectx+23+pidadd,charselecty+28,10)
			line(charselectx+23+pidadd,charselecty+23,charselectx+23+pidadd,charselecty+28,10)
		end
	end
	if p2.characterid!=7 then
		if p2.characterid<5 then
			pidadd=(p2.characterid)*15
			line(charselectx+18+pidadd,charselecty,charselectx+23+pidadd,charselecty,12) 
			line(charselectx+23+pidadd,charselecty,charselectx+23+pidadd,charselecty+5,12)
			line(charselectx+10+pidadd,charselecty+13,charselectx+15+pidadd,charselecty+13,12) 
			line(charselectx+10+pidadd,charselecty+8,charselectx+10+pidadd,charselecty+13,12)
		else
			pidadd=(p2.characterid-3)*15
			line(charselectx+18+pidadd,charselecty+15,charselectx+23+pidadd,charselecty+15,12) 
			line(charselectx+23+pidadd,charselecty+15,charselectx+23+pidadd,charselecty+20,12)
			line(charselectx+10+pidadd,charselecty+28,charselectx+15+pidadd,charselecty+28,12)
			line(charselectx+10+pidadd,charselecty+23,charselectx+10+pidadd,charselecty+28,12)
		end
	end
end

function draw_levelanims()
	if lvlselectindex==5 then --fire waterfall
		rectfill(50,0,78,110,9)
		for l in all(lava) do
  			circfill(l.x,l.y,1,l.col)
   		end
	end
end

function _drawgame()
	clip(0,3,127,119)
	rectfill(0,3,127,122,selectedlevel.backcol)
	draw_clouds()
	palt(0,false) 
	palt(12,true)	
	draw_levelanims()
	mapdraw(selectedlevel.x,0,0,3,16,15)
	palt()
	--the below is to cover the screen with a fade
	--palt(7,true)
	--palt(0,false)
	--mapdraw(0,15,0,0,16,15)
	--palt()
	pal()
	_drawplyr(p1)
	_drawplyr(p2) 
	draw_rain()	
	_drawhealth(-1,p1,p1.charactername)
	_drawhealth(1,p2,p2.charactername) 
	outline_text(gametimer,60,10,8,10)	
	_drawpoints()	
	rect(0,3,127,122,7)
	if (gamestate==0) then
		if gametext=="fight" then
			outline_text(gametext,57,98,10,8,true)
		else
			outline_text(gametext,63,98,10,8,true)
		end
	end
	if gamestate==2 then
		--finish him state 
		if flr(time())%2==0 then outline_text("finish him",0,53,7,0,true) else outline_text("finish him",0,53,0,7,true) end
	end
	if gamestate==3 then
		--game over state
		outline_text("game over",45,63,10,8,true)
		outline_text(get_winner(),45,73,10,8,true)
		outline_text("press \x97 to play again",45,83,8,10,true)
		outline_text("press \x8e to return to the menu",45,93,8,10,true)
	end
	if gamestate==4 then
		--new round state
		outline_text(get_winner(),45,73,10,8,true)
	end
	clip()
end

function _drawpoints()
	c=63 --center of screen
	d=60 --distance from center
	w=50 --width of health bar
	y=19
	if gamepoints.p1>0 then
		for i=0,gamepoints.p1-1,1 do
			spr(147,c-(d-(i*8)),y,1,1,false,false)
		end
	end
	if gamepoints.p2>0 then
		for i=0,gamepoints.p2-1,1 do
			spr(147,c+(d-(i*8)-7),y,1,1,true,false)
		end
	end
end

function _drawplyr(p)
  	for b in all(p.blood) do
	  	if gamegore then
  			rectfill(b.x,b.y,b.x+b.size,b.y+b.size,b.col)
		else
			spr(16,b.x,b.y)
		end  		
	end
	for b in all(skull.blood) do
		if gamegore then
			rectfill(b.x,b.y,b.x+b.size,b.y+b.size,b.col)
		else
			spr(16,b.x,b.y) 
		end 
	end
	palt(14,true)
	palt(0,false)
	for pr in all(p.projectiles) do		
		spr(pr.sprite,pr.x,pr.y,1,1,pr.f)
		if (hitboxshow) rect(pr.hitx,pr.hity,pr.hitx+pr.hit.w,pr.hity+pr.hit.h,8)
	end

	if not p.alive and not p.fatality and not p.babality then
		col1 = (flr(time())%2==0) and p.charactercol1 or 2
		col2 = (flr(time())%2==0) and p.charactercol2 or 14
	else
		col1=p.charactercol1
		col2=p.charactercol2
	end

	pal(9,col1)
	pal(10,col2)
	
	if p.fatality then
		if (skull.draw) draw_skull()
		spr(p.characterfatality,p.posx,p.posy+8+selectedlevel.groundyoffset,2,1,p.flipped)
	else 
		if p.babality then
			xoff= p.flipped and 0 or 8
			spr(p.characterbabality,p.posx+xoff,p.posy+8+selectedlevel.groundyoffset,1,1,p.flipped)
		else
			spr(p.charactersprite,p.posx,p.posy+selectedlevel.groundyoffset,2,2,p.flipped)
		end
	end
	palt()
	pal()
end

function draw_skull()
	spr(76,skull.posx,skull.posy,1,1,skull.flipped,skull.dy>0)
end

function _drawhealth(f,p,name)
	--center of screen = 63
	--distance from center = 10
	--width of health bar = 50
	--y value = 8
	if (p.health<0) p.health=0
	rem=flr((100-p.health)/2)
	if (rem==0 and p.health>0 and p.health<10) rem=59
	--printh("63:"..63.."   rem:"..rem.."  health:"..p.health)
	rectfill(63+(f*10),8,63+(f*(60)),16,11)--green
	if (p.health!=100) rectfill(63+(f*10),8,63+(f*(10+rem)),16,8)--red
	rect(63+(f*9),8,63+(f*61),16,10)
	if (f==1) then print(name,83,10,7) else print(name,13,10,7) end	
end

function _drawtitle()
	--clip(0,3,127,119)
	rectfill(0,3,130,121,1)
	titlecol = (flr(time())%2==0) and 6 or 8
	rect(2,5,125,120,titlecol)
	rect(5,8,122,117)
	rect(0,3,127,122,7)
	print("mini",86,15)
	draw_m(10,22)
	draw_o(35,22)
	draw_r(52,22)
	draw_t(69,22)
	draw_a(86,22)
	draw_l(103,22)
	draw_k(10,60)
	draw_o(27,60)
	draw_m(44,60)
	draw_b(69,60)
	draw_a(86,60)
	draw_t(103,60)
	print("press \x97 to play",30,100)
	clip()
end

--title letters
function draw_m(posx,posy)
	spr(134,posx,posy)
	spr(150,posx,posy+8)
	spr(132,posx,posy+16)
	spr(148,posx,posy+24)
	spr(135,posx+8,posy)
	spr(151,posx+8,posy+8)
	spr(167,posx+8,posy+16)
	spr(134,posx+16,posy,1,1,true)
	spr(150,posx+16,posy+8,1,1,true)
	spr(132,posx+16,posy+16,1,1,true)
	spr(148,posx+16,posy+24,1,1,true)
end

function draw_o(posx,posy)
	spr(133,posx,posy)
	spr(132,posx,posy+8)
	spr(132,posx,posy+16)
	spr(133,posx,posy+24,1,1,false,true)
	spr(133,posx+8,posy,1,1,true)
	spr(132,posx+8,posy+8,1,1,true)
	spr(132,posx+8,posy+16,1,1,true)
	spr(133,posx+8,posy+24,1,1,true,true)
end

function draw_r(posx,posy)
	spr(133,posx,posy)
	spr(180,posx,posy+8)
	spr(181,posx,posy+16)
	spr(148,posx,posy+24)
	spr(164,posx+8,posy)
	spr(165,posx+8,posy+8)
	spr(166,posx+8,posy+16)
	spr(148,posx+8,posy+24)
end

function draw_t(posx,posy)
	spr(182,posx,posy)
	spr(183,posx,posy+8)
	spr(183,posx,posy+16)
	spr(184,posx,posy+24)
	spr(182,posx+8,posy,1,1,true)
	spr(183,posx+8,posy+8,1,1,true)
	spr(183,posx+8,posy+16,1,1,true)
	spr(184,posx+8,posy+24,1,1,true)
end

function draw_a(posx,posy)
	spr(133,posx,posy)
	spr(180,posx,posy+8)
	spr(181,posx,posy+16)
	spr(148,posx,posy+24)
	spr(133,posx+8,posy,1,1,true)
	spr(180,posx+8,posy+8,1,1,true)
	spr(181,posx+8,posy+16,1,1,true)
	spr(148,posx+8,posy+24,1,1,true)
end

function draw_l(posx,posy)
	spr(148,posx,posy,1,1,false,true)
	spr(132,posx,posy+8)
	spr(132,posx,posy+16)
	spr(133,posx,posy+24,1,1,false,true)
	spr(152,posx+8,posy+24)
end

function draw_k(posx,posy)
	spr(148,posx,posy,1,1,false,true)
	spr(180,posx,posy+8)
	spr(181,posx,posy+16)
	spr(148,posx,posy+24)
	spr(148,posx+8,posy,1,1,false,true)
	spr(166,posx+8,posy+8,1,1,false,true)
	spr(166,posx+8,posy+16)
	spr(148,posx+8,posy+24)
end

function draw_b(posx,posy)
	spr(133,posx,posy)
	spr(180,posx,posy+8)
	spr(180,posx,posy+16,1,1,false,true)
	spr(133,posx,posy+24,1,1,false,true)
	spr(137,posx+8,posy)
	spr(153,posx+8,posy+8)
	spr(169,posx+8,posy+16)
	spr(185,posx+8,posy+24)
end

__gfx__
00000000cccccccc7ccccccc8888888888888888545655558cccccc8cccccccc3533533553353353cccccccc333333333333333354565555eeeeeeeeeeeeeeee
00000000cccc7ccccc7ccccc8ccc8ccc8cc88cc84565555588888088cccccccc3533533553353353ccccccccbbbbbbbbbbbbbbbb45655555ee55eeeeee88eeee
00700700cc777cccc7677ccc8c88888c8c8888c8455655558c8800c8cccccc33533533533533533533cccccc555555555555555545565555ee505eeeee00feee
00077000c776c7cc76c66ccc8c8ccc8c888cc888545655558c0000c8ccc33333533533533533533533333ccc333333333333333354565555ee5bbeeeee0ffeee
000770006776677ccc7ccccc888ccc88888cc888999999998808008833333333533533533533533533333333353353355335335399999999e53535eeefffffee
00700700c67777777ccccccc8c8ccc8c8c8888c83333333388880088c588888888888888888888888888885c353353355335335333333333eb353beee5fff5ee
000000007c66c666c67ccccc8c88888c8cc88cc8343443448c0080c8c555555555555555555555555555555c533533533533533544444444eb777beee07770ee
00000000cccccccccccccccc8ccc8ccc88888888434434348c8080c8cccccccccccccccccccccccccccccccc533533533533533555555555e5b7b5eee58785ee
00000000cccccccccccccccccccc77cccccccccc6666666688888088cc5885cccccccc7ff7cccccccccccc3553cccccc33cccccc56567765eeeeeeeeeeeeeeee
00000000cccccccccccccc777cc77777c77cc7cc6666666688088088cc5885cccccccc7ff7ccccccccc3533553353cccbbbccccc46556765ee55eeeeee55eeee
00000000ccccccccccccc77cc777c77c76c77ccc666666668c8000c8cc5885ccccccc776677ccccc353353533535335333cccccc46567765ee505eeeee505eee
000e0000cccccccccc777c7777777c7776667ccc666666668c8080c8cc5885cccccc5d77d7d5cccc53353353353353353ccccccc56556765ee5aaeeeee5cceee
00eae000cccccccc6667777776677777777777cc6666666688008088cc5885ccccc5d87dd78d5ccc5335335335335335cccccccc99999999e59595eee5d5d5ee
000e0000cccccccccc6666666c6666777777777c6666666688000888cc5885ccccc8f99dd98f8ccc8888888888888888cccccccc33333333ea959aeeecd5dcee
00000000cccccccccccccccccccccc666666cccc666666668c0088c8cc5885cccc8a989dd989a8cc5555555555555555cccccccc34344344ea777aeeec777cee
00000000cccccccccccccccccccccccccccccccc566656658c8008c8cc5885cccc89a899998a98cccc5995cccc5995cccccccccc43443434e5a7a5eee5c7c5ee
0000000055555555666666665555555505555555f5555557888800888cc8cc88cc8a98995589a8cc88cc8cc8cccccc3356567765cccccccc54899a55c656776c
0000000065656565666666665555555505555555ff5555ff888880888cc8cc86666666666666666668cc8cc8cccccbbb46556765cccccccc4598a955c655676c
0000000056565656666666667777777707777777f557f55f8c8808c888888886666666655666666668888888cccccc3346567765cccccccc45989a55c656776c
0000000065666566666666665555555505555555f9ffff7f8c8808c866666666666666575566666666666666ccccccc356556765cccccccc54899a55c655676c
0000000066656665666666666655577606555776999ffe778880888855555556666667555556666665555555cccccccc46567765cccccccc9998a999c656776c
0c0c0c0066666666666666667766557607665576997ff9e98880088855555555566667777756666555555555cccccccc465567654454454439999993c655676c
00c0c000666666666666666655566666055666669e7799998c0800c866666655566666775766666555666666cccccccc565677655545545549494949c656776c
00ccc0006666666666666666666666660666666667e999968c8088c855555555666666677666666655555555cccccccc465567655555555594949494c655676c
070707078888888888888888888888885666666656566665555555556666666666666665566665655555555589989a99ccccccccccc5cccc5456555554899a55
707070708cc58cc58cc58cc58cc58cc8565555555656666556665555555555555555556556666565545445559989a9aaccccccccccc54ccc456555554598a955
070707078c88888888888888888888c85656666556566665555665555556655556666565566665655555454598998a99ccccccccccc54ccc4556555545989a55
707070708c85555555555555555558c85656666556566665555555555555555556666565566665655555555588989a99ccccccccccc555cc5456555554899a55
07070707888cccccccccccccccccc8885656666556566665555566655555666556666565566665655445545598889a9a99999999cc5544cc456555554598a955
70707070858cccccccccccccccccc85856566665565666655555555555555555566665655666656555454555898989a933333333cc5455cc4556555545899a55
070707078c88888888888888888888c85656666556566665665665556656655556666565566665655554455589899a9a44444444c545455c545655555489a955
707070708cc58cc58cc58cc58cc58cc8565666655656666565655555656555555666656556666565555555559898a99a5555555555555555456555554598a955
eeeee0000eeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeee00f0aeeeeeeeee00f0aeeeeeeeeeeeeeeeeeeeeeeeeeeeee00f0aeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeee00ee00eeeee
eeeee09ffaeeeeeeeee09ffaeeeeeeeeeeeee0000eeeeeeeeeeee09ffaeeeeeeeeee00f0aeeeeeeeeeeeeeeeeeeeeeeeee00706eeeeeeeee0e0e088006600eee
eeeee09999eeeeeeeee09999eeeeeeeeeeeee00f0aeeeeeeeeeee09999eeeeeeeeee09ffaeeeeeeeeeeeeeeeeeeeeeeeee05776eeeeeeeee80808aa8e006500e
eeeeee000eeeeeeeeeee000eeeeeeeeeeeeee09ffaefaeeeeeeeee000eeeeeeeeeee09999eeeeeeeeeeeeeeeeeeeeeeeee05555eeeeeeeee0808a8a866577560
eeee00a00a00eeeeeee0a00a09fa9eeeeeeee09999ef9eeeeeeee0a00a09fa9eeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeee0e00880e006500e
eeef90a00a09feeeeee9a00a09fffeeeeeeeee000eeffeeeeeeee9a00a09fffeeee00a00a00eeeeeeeeeeeeeeeee0000ee777eeeeeeeeeeeeeeee00e06600eee
eeeff0aa0a0ffeeeeee9fffa0eeeeeeeeeee00a00a099eeeeeeee9fffa0eeeeeeeef9a0fff9eeeeeeeeeeeeeeeee9900eee7eeeeeeeeeeeeeeeeeeeee00eeeee
eeeaf09a000faeeeeeeffa909eeeeeeeeeee9a000a000eeeeeeeeffa909eeeeeeeeffaa9affeeeeeeeeeeeeeee009ff0eeeeeeeeee87eeeeeeeeeeeeeeeeeeee
eee9fe9009ef9eeeeeee90090005eeeeeeee9fff0a0eeeeeeeeeee9009eeeeeeeeeaf9a00eeeeeeeeeeeeeee00a09f00eeeeeeee0088eeeeeeeeeeeeeeeee00e
eeeeee0990eeeeeeeeee09900005eeeeeeeeffa9009eeeeeeeeeee0990eeeeeeeee9f090900005eeeeeeeee0009f9aaeeeeeeee0009feeeeeee000ee0e0e0330
eeeeee0990eeeeeeeeee009eeeeeeeeeeeeeee9009eeeeeeeeeeee0990eeeeeeeeeeee09900005eeeeeeeee000ffeeeeeeeeeee000ffeeeee007cc0e30303bb3
eeeeee0990eeeeeeeeeee09005eeeeeeeeeeee099000eeeeeeeeee0990eeeeeeeeeeee099eeeeeeeeeeeeee999faeeeeeeeeeee999faeeee0c7777700303b3b3
eeeeee0090eeeeeeeeeeee0005eeeeeeeeeeee099000eeeeeeeeee0090eeeeeeeeeeee009eeeeeeeeeeeeee009f9eeeeeeeeeee009f9eeeee00c7c0ee0e00330
eeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeee50099e00eeeeeeeeee0000eeeeeeeeeeee00eeeeeeeeeeee500009eeeeeeeeee500009eeeeeeeee000eeeeeee00e
eeeeee5555eeeeeeeeeeeeeeeeeeeeeeeeee50009e55eeeeeeeeee5555eeeeeeeeeeee55eeeeeeeeeeee500009eeeeeeeeee500009eeeeeeeeeeeeeeeeeeeeee
eeeee8888eeeeeeeeee8888eeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeee00f0eeeeeeeee000f0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee00f0eeeeeeeeeee8888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeee00fffeeeeeee0e00fffeeeeeeeeeeeee8888eeeeeeeeeeee00fffeeeeeeeeee00f0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeee00ffeeeeeeeee00fffeeeeeeeeeeeeee00f0eeeeeeeeeeee00ffeeeeeeeeeee00fffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeee0ffeeeeeeeee0eeffeeeeeeeeeeeeeee00fffeffeeeeeeee0ffeeeeeeeeeeee00ffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeeffffffffeeeeeeefffffff50feeeeeeee00ffee00eeeeeeeefffffff50feeeee0ffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeffffffffffeeeeeefffffff50feeeeeeee0ffeee55eeeeeeeefffffff50feeeeeffffffeeeeeeeeeeeeeeeeee0008eeeeeeeeeeeeeeee0000000000000000
eee55effffe55eeeeeef50ffeeeeeeeeeeeefffffffffeeeeeeeef50ffeeeeeeeeefffff05feeeeeeeeeeeeeeee00008eeeeeeeeeeeeeeee0000000000000000
eee00effffe00eeeeeef50ffeeeeeeeeeeeefffffffffeeeeeeeef50ffeeeeeeeee55fff05feeeeeeeeeeeeeee000ff8eeeeeeeeee87eeee0000000000000000
eeeffe8888effeeeeeee88888005eeeeeeeef50fffeeeeeeeeeeee8888eeeeeeeee00ff88eeeeeeeeeeeeeeeff00ff08eeeeeeeeff88eeee0000000000000000
eeeeee8008eeeeeeeeee80000005eeeeeeeef50fffeeeeeeeeeeee8008eeeeeeeeeffe80088005eeeeeeeeeffff0efeeeeeeeeeffff0eeee0000000000000000
eeeeee8008eeeeeeeeee800eeeeeeeeeeeeeee8888eeeeeeeeeeee8008eeeeeeeeeeee80000005eeeeeeeeefff55eeeeeeeeeeefff55eeee0000000000000000
eeeeee8008eeeeeeeeeee80005eeeeeeeeeeee800888eeeeeeeeee8008eeeeeeeeeeee80eeeeeeeeeeeeeee88800eeeeeeeeeee88800eeee0000000000000000
eeeeee8000eeeeeeeeeeee8885eeeeeeeeeeee800000eeeeeeeeee8000eeeeeeeeeeee80eeeeeeeeeeeeeee800ffeeeeeeeeeee800ffeeee0000000000000000
eeeeee8000eeeeeeeeeeeeeeeeeeeeeeeeee5880ee00eeeeeeeeee8000eeeeeeeeeeee80eeeeeeeeeeee588800eeeeeeeeee588800eeeeee0000000000000000
eeeeee5555eeeeeeeeeeeeeeeeeeeeeeeeee5000ee55eeeeeeeeee5555eeeeeeeeeeee55eeeeeeeeeeee500000eeeeeeeeee500000eeeeee0000000000000000
aaaaaaaaaaaaaaaa55555555cccccccc59999a500555555505555500000000005555555555555500000000003333333333333333333533333333333333333333
abbbbbbbbbbbbbbb56655665000ccccc59999a505999999959999550000000009999999999995550aaa0a0aa3333a333333333a3336663333333333333333333
abbbbbbbbbbbbbbb655665560600cccc59999a505999999959999995000000009999999999999950a880a0a83333333333a33333336563333333333333333333
abbbbbbbbbbbbbbb5666566606600ccc59999a505999999959999995000000009999999999999955aa00a0a033a3333333333333336563333333333333333333
abbbbbbbbbbbbbbb99999999066600cc59999a505999999959999999500000059999999999999995a800a0a0333333333a333333333533333333333333333333
abbbbbbbbbbbbbbb333333330666600c59999a5059999aaa5999999950000005aaaaaaaaaa999995a000a0aa3333333a33333a33336563333566673333333333
abbbbbbbbbbbbbbb343443440666660059999a5059999a555999999995000059555555555aa99995800080883333333333333333336563333556673333333333
aaaaaaaaaaaaaaaa434434340666666059999a5059999a5059999999950000590000000005a99995000000005553333333333555336663333356733355555555
56cccccccccccc65555555550000000059999a505550000059999999995555990000000005a99995555555555555555533333a3333b333333335333305050505
56cccccccccccc65566556650006600059999a505995000059999999999559995555555505a999955355353533353333333a333333b33a3a3366633355555555
566cccccccccc66565566556006aa60059999a505999500059999999999559999999999505a999955353353333333333a333333aaabb33333365633305050505
556cccccccccc6555666566606aaaa5059999a505999500059999aaaaa999999999999955aa99995333333353333333333a3333333bb33a33365633355555553
555cccccccccc555a9aa98a906aaaa5059999a505999950059999a555a99999599999995999999556666666066666666333333333abbb3333335333305050533
56cccccccccccc658a9aa9a8005aa50059999a505999955059999a505a9999959999999599999950a6a66606a66666a65555555533bbb5553365633355555533
566cccccccccc665398a88a4000550005aaaaa505999995559999a5005a99950999999959aa555506a66a06a66aa6a663535535533bb55553365633305055333
555cccccccccc5554344343400000000555555505999999559999a5005a99950555555559a50000066a60666a666a66a5333535333b555553366633355533333
56cccccccccccc65cccccccc0000000055555500059999959950000005aa9950000000009a500000666606666666666633a33d3333a3350550533a3335050505
56cccccccccccc65cccccccc00000000999955500599999599555000005a9500000000009aa55550666606666666666633333d33333335555553333335555555
566cccccccccc665cccccccc00000000999999500599999599995500005aa5000000000099aaaa500006060000000000a333dd33a333a505505a333a35050505
656cccccccccc656cccccccc00000000999999555999999599999500000550000000000099999a5500000000000000003333dd33333335555553333333555555
5656cccccccc6565cccccccc00000000999999959999995559999550000000000000000059999aa53333333333333333333ddd3a333335055053333333350505
656566cccc665656c56c66cc000000009999999599999950599999500000000000000000059999a5b33333bbb33333bb555ddd3a333335555553333333355555
665656666665656666665566000000005999999599995550599999500000000000000000059999a5bbbbb3bbbbbbb3bb5555dd333a333505505333a333335505
556565555556565565556555000000000599999599555000599999500000000000000000059999a5bbbbbbbbbbbbbbbb55555da3333a35555553a33333333355
65556555cc6555cccccccccccccccccc59999a50599999995555555500005a9900005a99059999a53333333533a33d3333a33505050550503333333355333333
66665566cc6655cccccccccccccccccc59999a50599999995a99999900005a9900005a99599999a53333355533333d3333333555555555553333333355553333
c56c66cccc5655cccccccccccccccccc59999a50599999995a99999900005a9900005a99999999a533335505a333dd33a333a505050550503333333305055333
cccccccccc5655cccccccccccccccccc59999a5559999aaa5a99999900005a9900005a9999999aa5333555553333dd3333333555555555553333333355555533
cccccccccc6555cc655565556555655559999aaa59999a555a99999900005a9900005a9999999a5533550505333ddd3a33333505050550503333333305050553
cccccccccc6655cc66665566666655665999999959999a505aaaaa9900005a9900005a99999aaa5035555555555ddd3a33333555555555553333333355555555
cccccccccc5655cc55656655c56c66cc5999999959999a5055555a9900005a9900005a99aaaa5550350505055555dd333a333505050550503333333305050505
cccccccccc5655ccc556555ccccccccc5999999959999a5000005a9900005a9900005555555550003555555555555da3333a3555555555553333333355555555
22000022220000222000000222055552888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000002200f00020008080020000055887777880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20fffff222fff0028808080820ffff05887887880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f0ff022f0f0c020fff0ff0220f0f00888877880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09afaaa22ccccc020f0ff0f022bbbb30888778880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d09aaaa21cccc0110ffffff033bbbb30888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd95aaa211cc00110ffeeff2335bb300888778880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd0955220000000066ffff6633555003888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee00eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee00feee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eefffeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e77777ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ef7775ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ef111fee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e51dd5ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee000feeeeeeeeee000feeeeeeeeeeeeeeeeeeeeeeeeeeeeee000feeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeee0ff0eeeeeeeeee0ff0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0ff0eeeeeeeeeee000feeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeeefffffeeeeeeeeefffffeeeeeeeeeeeee000feeeeeeeeeeeefffffeeeeeeeeee0ff0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeeeffffeeeeeeeeeeffffeeeeeeeeeeeeee0ff0eeeeeeeeeeeeffffeeeeeeeeeeefffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeeeeeffeeeeeeeeeeeeffeeeeeeeeeeeeeeefffffeffeeeeeeeeeffeeeeeeeeeeeeffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeee777f7777eeeeeee77f7777f5feeeeeeeeffffee55eeeeeeee77f7777f5feeeeeeffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
eeef77577777feeeeee7577777f5feeeeeeeeeffeeeffeeeeeeee7577777f5feeeee777777eeeeeeeeeeeeeeeeeeff00eeeeeeeeeeeeeeee0000000000000000
eeeffe7777effeeeeee7fff7eeeeeeeeeeee777f777ffeeeeeeee7fff7eeeeeeeee7777f5f7eeeeeeeeeeeeeeeeefff0eeeeeeeeeeeeeeee0000000000000000
eeeffe7777e55eeeeee7fff5eeeeeeeeeeee775777777eeeeeeee7fff5eeeeeeeeeff77f5f7eeeeeeeeeeeeeee7ffff0eeeeeeeee787eeee0000000000000000
eeeffe55a5effeeeeeee11111115eeeeeeee7fff77eeeeeeeeeeee1111eeeeeeeeeff75a5eeeeeeeeeeeeeee7777ff0feeeeeeee7788eeee0000000000000000
eeeeee1111eeeeeeeeee1dddddd5eeeeeeee7fffa5eeeeeeeeeeee10d1eeeeeeeeeffe11111115eeeeeeeee77777efeeeeeeeee77777eeee0000000000000000
eeeeee11d1eeeeeeeeee100eeeeeeeeeeeeeee1111eeeeeeeeeeee10d1eeeeeeeeeeee10ddddd5eeeeeeeee55affeeeeeeeeeee55affeeee0000000000000000
eeeeee11d1eeeeeeeeeee10005eeeeeeeeeeee10d111eeeeeeeeee10d1eeeeeeeeeeee10eeeeeeeeeeeeeee11155eeeeeeeeeee11155eeee0000000000000000
eeeeee11d1eeeeeeeeeeee1115eeeeeeeeeeee10ddd1eeeeeeeeee10d1eeeeeeeeeeee10eeeeeeeeeeeeeee100ffeeeeeeeeeee100ffeeee0000000000000000
eeeeee11d1eeeeeeeeeeeeeeeeeeeeeeeeee5110eed1eeeeeeeeee10d1eeeeeeeeeeee10eeeeeeeeeeee511100eeeeeeeeee511100eeeeee0000000000000000
eeeeee5555eeeeeeeeeeeeeeeeeeeeeeeeee5000ee55eeeeeeeeee5555eeeeeeeeeeee55eeeeeeeeeeee500000eeeeeeeeee500000eeeeee0000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
71111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111117
71666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666617
71611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111617
71611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111617
71611666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666611617
71611611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611617
71611611111111111111111111111111111111111111111111111c11111111111c11111111111111111111111111111111111111111111111111111111611617
71611611111111111111111111111111111111111111111111111c11111111111c11111111111111111111111111111111111111111111111111111111611617
7161161111111111111111111111111111111111111111111111c11111111111c111111111111111111111111111111111111111111111111111111111611617
7161161111111111111111111111111111111111111111111111c11111111111c111111111111111111111111111111111111111111111111111111111611617
71611611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611617
7161161111111111111111111111111111111111111c111111111111111111111111111111c11111111111777177717711777111111111111111111111611617
7161161111111111111111111111111111111111111c111111111111111111111111111111c11111111111777117117171171111111111111111111111611617
716116111111111111111111111111111111111111c111111111111111111111111111111c111111111111717117117171171111111111111111111111611617
716116111111111111111111111111111111111111c111111111111111111111111111111c111111111111717117117171171111111111111111111111611617
71611611111111111111111111111111111111111111111111111111111111111111111111111111111111717177717171777111111111111111111111611617
716116111111111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111c1111111111111111111111611617
716116111111111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111c1111111111111111111111611617
71611611111555551c11111111115555511155555555555555111555555555555511155555555555555551155555555555c55115555555111111111111611617
71611611115999955c1111111115599995159999999999999951599999999999555115a999999999999a51599999999999c99515aaaaa5111111111111611617
7161161111599999951111111159999995159999999999999951599999999999995115a999999999999a515999999999999995159999a5111111111111611617
7161161c11599999951111111159999995159999999999999951599999999999995515a99999999999ca515999999999999995159999a5111111111111611617
7161161c11599999995111111599999995159999999999999951599999999999999515a99999999999ca515999999999999995159999a5111111111111611617
716116c111599999995111111599999995159999aaaaaa99995159999aaa9999999515aaaaa9999aacaa5159999aaaaaa99995159999a5111111111111611617
716116c111599999999511115999999995159999a5555a99995159999a5559999995155555a9999a5c555159999a5555a99995159999a5111111111111611617
7161161111599999999511115999999995159999a5115a99995159999a5115999995111115a9999a51111159999a5115a99995159999a5111111111111611617
7161161111599999999955559999999995159999a5115a99995159999a5115999995111115a9999a51111159999a5115a99995159c99a5c11111111111611617
7161161111599999999995599999999995159999a5115a99995159999a5115999995111115a9999a51111159999a5115a99995159c99a5c11111111111611617
7161161111599999999995599999999995159999a5115a99995159999a5115999995111115a9999a51111159999a5115a9999515c999ac111111111111611617
716116111159999aaaaa999999aaa99995159999a5115a99995159999a5559999995111115a9999a51111159999a5555a9999515c999ac111111111111611617
716116111159999a555a99999555a99995159999a5115a99995159999aaa99999955111115a9999a51111159999aaaaaa99995159999a5111111111111611617
716116111159999a515a99999515a99995159999a5115a99995159999c999c999951111115a9999a5111115999999999999995159999a5111111111111611617
716116111159999a5115a9995115a99995159999a5115a99995159999c999c995551111115a9999a5111115999999999999995159999a5111111111111611617
716116111159999a5115a9995115a99995159999a5115a9999515999c999c9555111111115a9999a5111115999999999999995159999a5111111111111611617
716116111159999a5115aa995115a99995159999a5115a9999515999c999c9511111111115a9999a5111115999999999999995159999a5111111111111611617
716116111159999a51115a951115a99995159999a5115a9999515999999999555111111115a9999a5111115999999999999995159999a5111111111111611617
716116111159999a51115aa5111ca99995159999a5115a9999515999999999995511111115a9999a5111115999999999999995159999c5111111111111611617
716116111159999a51111551111ca99995159999a5115a99995159999aaa99999511111115a9999a51111159999aaaaaa99995159999c5111111111111611617
716116111159999a5111111111c5a99995159999a5115a99995159999a5559999551111115a9999a51111159999a5555a9999515999ca5111111111111611617
716116111159999a5111111111c5a99995159999a5115a99995159999a5159999951111115a9999a51111159999a5115a9999515999ca5111111111111611617
716116111159999a511111111115a99995159999a5115a99995159999a5159999951111115a9999a51111159999a5115a99995159999a5111111111111611617
716116111159999a511111111115a999c5159999a5115a99995159999a5159999951111115a9999a511111c9999a5115a99995159999a51111c1111111611617
716116111159999a511111111115a999c5159999a5115a99995159999a5159999a51111115a9999a511111c9999a5115a99995159999a51111c1111111611617
716116111159999a511111111115a99c95159999a5555a99995159999a5159999a51111115a9999a51111c59999a5115a99995159999a5555c55555111611617
716116111159999a511111111115a99c95159999aaaaaa99995159999a5159999a51111115a9999a51111c59999a5115a99995159999aaa99c99995111611617
716116111159999a511111111115a9999515999999999999995159999a5159999a51111115a9999a51111159999a5115a9999515999999999999995111611617
716116111159999ac11111111115a9999515999999999999995159999a5159999a51111115a9999a51111159999a5115ac999515999999999999995111611617
716116111159999ac11111111115a9999515999999999999995159999a5159999a51111115a9999a51111159999a5115ac999515999999999999995111611617
71611611115aaaac511111111115aaaaa51599999999999999515aaaaa515aaaaa51111115a9999a5111115aaaaa5115caaaa51599999999999999511c611617
716116111155555c51111111111555555511555555555555551155555551555555511111155555555111115555555115c555551155555555555555511c611617
71611611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611617
71611611111111111111111111111111111111c11111c111111111111111111111111111111c1111111111111111111111111111111111111111111111611617
71611611111111111111111111111111111111c11111c111111111111111111111111111111c1111111111111111111111111111111111111111111111611617
7161161111111111111111111111111111111c11111c111111111111111111111111111111c11111111111111111111111111111111111111111111111611617
7161161111111111111111111111111111111c11111c111111111111111111111111111111c11111111111111111111111111111111111111111111111611617
71611611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611617
7161161111555555515555555111555555555555551115555511111111c1115555511155555555555551111555555555555c5115555555555555555111611617
71611611115aaaaa515aaaaa5115999999999999995159999551111111c1155999951599999999999555115999999999999c9515a999999999999a5111611617
716116111159999a5159999a511599999999999999515999999511111c1159999995159999999999999511599999999999c99515a999999999999a5111611617
716116111159999a5159999a511599999999999999515999999511111c1159999995159999999999999551599999999999c99515a999999999999a5111611617
716116111159999a5159999a51159999999999999951599999995111111599999995159999999999999951599999999999999515a999999999999a5111611617
71611611115c999a515c999a51159999aaaaaa999951599999995c11111599999995159999aaaaa999995159999aaaaaa9999515aaaaa9999aaaaa5111611617
71611611115c999a515c999a51159999a5555a999951599999999c11115999999995159999a555aa99995159999a5555a99995155555a9999a55555111611617
7161161111c9999a51c9999a51159999a5115a99995159999999c511115999999995159999a5115a99995159999a5115a99995111115a9999a51111111611617
7161161111c9999a51c9999951159999a5115a99995159999999c955559999999995159999a5115a99995159999a5115a99995111115a9999a51111111611617
716116111159999a5159999951159999a5115a999951599999999995599999999995159999a5115a99995159999a5115a99995111115a9999a51111111611617
716116111159999a5159999951159999a5115a999951599999999995599999999995159999a5115a999951c9999a5115a9999511c115a9999a51111111611617
716116111159999a5559999551159999a5115a99995159999aaaaa999999aaa99995159999a555aa999951c9999a5555a9999511c115a9999a51111111611617
716116111159999aaa99999511159999a5115a99995159999a555a99999555a99995159999aaa99999955c59999aaaaaa999951c1115a9999a51111111611617
71611611115999999999995511159999a5115a99995159999a515a99999515a9999515999999999999951c59999999999999951c1115a9999a51111111611617
71611611115999999999555111159999a5115a99995159999a5115a9995115a999951599999999aa5555115999999999999995111115a9999a51111111611617
71611611115999999999511111159999a5115a99995159999a5115a99951c5a999951599999999a5111c115999999999999995111115a9999a51111111611617
71611611115999999999511111159999a5115a99995159999a5115aa9951c5a999951599999999a5111c115999999999999995111115a9999a51111111611617
71611611115999999999555111159999a5115a99995159999a51115a951c15a999951599999999aa55c5115999999999999995111115a9999a51111111611617
71611611115999999999995511159999a5115a99995159999a51115aa51c15a9999515999999999aaac5115999999999999995111115a9999a51111111611617
716116111159999aaa99999511159999a5115a99995159999a511115511115a99995159999aaa99999a55159999aaaaaa99995111115a9999a51111111611617
716116111159999a5559999551159999a511ca99995c59999a511111111115a99995159999a5559c99aa5159999a5555a99995111115a9999a51111111611617
716116111159999a5159999951159999a511ca99995c59999a511111111115a99995159999a5115c999a5159999a5115a99995111115a9999a51111111611617
716116111159999a5159999951159999a51c5a9999c159999a511111111115a99995159999a511c9999a5159999a5115a99995111115a9999a51111111611617
716116111159999a5159999951159999a51c5a9999c159999a511111111115a99995159999a511c9999a5159999a5115a99995111115a9999a51111111611617
716116111159999a5159999a51159999a5115a99995159999a511111111115a99995159999a51159999a5159999a5115a99995111115a9999a51111111611617
716116111159999a5159999a51159999a5555a99995159999a511111111115a99995159999a55599999a5159999a5115a99995111115a9999c511c1111611617
716116111159999a5159999a51159999aaaaaa99995159999a511111111115a99995159999aaa999999a5159999a5115a99995111115a9999c511c1111611617
716116111159999a5159999a5115999999999999995159999a511111111115a9999515999999999999aa5159999a5115a99995111115a999ca51c11111611617
716116111159999a5159999a5115999999999999995159999a511111111115a9999515999999999999a55159999a5115a99995111115a999ca51c11111611617
716116111159999a5159999a5115999999999999995159999a511111111115a99995159999999999aaa51159999a5115a99995111115a9999a51111111611617
71611611115aaaaa515aaaaa511599999999999999515aaaaa511111111115aaaaa5159999999aaaa555115aaaaa5115acaaa5111115a9999a51111111611617
7161161111555555515555555111555555555555551155555551111111111555555511555555555555111155555551155c555511111555555551111111611617
716116111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111c1111111111111111111111111611617
716116111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111c1111111111111111111111111611617
71611611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611617
71611611111111111111111111111111111111111111c1111111111111111111111111111111111111111111111111111111111111c111111111111111611617
71611611111111111111111111111111111111111111c1111111111111111111111111111111111111111111111111111111111111c111111111111111611617
7161161111111111111111111111111111111111111c1111111111111111111111111111111111111111111111111111111111111c1111111111111111611617
7161161111111111111111111111111111111111111c1111111111111111111111111111111111111111111111111111111111111c1111111111111111611617
71611611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611617
71611611111111111111111111111177717c7177711771177111111777771c111177711771111177717111777171711111111111111111111111111c11611617
71611611111111111111111111111171717c7171117111711111117717177c111117117171111171717111717171711111111111111111111111111c11611617
7161161111111111111111111111117771c7117711777177711111777177c111111711717111117771711177717771111111111111111111111111c111611617
7161161111111111111111111111117111c1717111117111711111771717c111111711717111117111711171711171111111111111111111111111c111611617
71611611111111111111111111111171117171777177117711111117777711111117117711111171117771717177711111111111111111111111111111611617
7161161111111111111111111111111111111111111111111111111111111111111111111111111111111c111111111111111111111c11111111111111611617
7161161111111111111111111111111111111111111111111111111111111111111111111111111111111c111111111111111111111c11111111111111611617
716116111111111111111111111111111111111111111111111111111111111111111111111111111111c111111111111111111111c111111111111111611617
716116111111111111111111111111111111111111111111111111111111111111111111111111111111c111111111111111111111c111111111111111611617
71611611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611617
71611611111111111111111111c111111111111111111111111111111111111c1111111111111111111111111111111111111111111111111111111111611617
71611611111111111111111111c111111111111111111111111111111111111c1111111111111111111111111111111111111111111111111111111111611617
7161161111111111111111111c111111111111111111111111111111111111c11111111111111111111111111111111111111111111111111111111111611617
7161161111111111111111111c111111111111111111111111111111111111c11111111111111111111111111111111111111111111111111111111111611617
71611611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611617
71611611111111111111111c1111111111111111111111111111111111111111111111111111111111111111c111111111111111111111111111111111611617
71611611111111111111111c1111111111111111111111111111111111111111111111111111111111111111c111111111111111111111111111111111611617
71611666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666611617
71611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111617
71611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111617
71666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666617
71111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111117
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000010000000000000001000000000000000100000000000000010000000000000000000000000000000101000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000010001010101010100000000000000000300010101010101010100000000000000000101010100010000000000000001010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111111111111000000000000000000000000000000000000000000000000000000009011119100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111000000000000000000000000000000000000000000000000000000009011119100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111000000000000000000000000000000000000000000000000000000009011119100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111112b0b0b0b0c0c0c1c1111111111110000000000000000000000000000000000000000000000000000000090b3b39100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111106071a0808080909091b0a0611111111000000000000000000000000000000000000000000000000000000009011119100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111161117040411110404171116111111113d000000000000003c3c3c3c000000000000003d00000000000000009011119100000000000000003d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11313233261117040418190404171126313233113e3d000000000000002f2f000000000000003d3e000000000000000090b3b39100000000000000009a9b9b9a9b9b9b9b9a9a9b9b9b9a9a9a9b9b9b9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11343737373737382728292a34373737373738113e3e3d0000000000002f2f0000000000003d3e3e0000000000000000901111910000000000000000bebe8ebebebe8ebebebe8ebebebe8ebebebebebe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11353636363636393636363635363636363639113e3e3e3d3d3d3d3d3d2f2f3d3d3d3d3d3d3e3e3e0000000000000000901111910000000000000000bebe9e8c8f8b9ebebebe9ebebebe9ebe8c8f8bbe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
25252525252525252525252525252525252525253e3e3e0d0d0d3e3e3e2c2c3e3e3e0d0d0d3e3e3e000000000000000090b3b3910000000000000000bebe9eadbdae9ebebebe9ebabfbe9ebeadbdaebe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23232323232423232323232423232323242323233e3e3e3e2c3e3e3e3e2c2c3e3e3e3e2c3e3e3e3e00000000b2b20000901111910000b2b200000000bebe9eadbdae9ebebebe9eaf9fbe9ebeadbdaebe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21212121212121212121212121212121212121213e3e3e3e2c3e3e3e3e2c2c3e3e3e3e2c3e3e3e3e00000000b1b10000901111910000b1b100000000bebebeadbdae9ebebebebebebebe9ebeadbdaebe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222223e3e3e3e2c3e3e3e3e2c2c3e3e3e3e2c3e3e3e3e2323232323232323a0a2a2a123232323232323239c9c9cacbe9d9c9c9c9c9c9c9c9c9c9cacbe9d9c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151515151515050505051d050505051d1d050505051d0505050582829282829292928282829292828282929282829b9a9b9a9b9b9b9a9b9b9a9b9a9b9b9b9b9a9b9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222223a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3aabaaabaaabababaaababaaabaaababababaaabaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010d0000150321510015130180021803221000210301a0001a03221000210301c0021c0321a0001a030180001803218100181301c0021c0321800018030180001f03218000180301c0021c032180001803018000
010d000015030150001500015030150001500015032186021500215032130021300213032180021803218002150301510215002150301500015002150321c00215002150321500213002130321c0021c03215002
010d00000c0330c0030c0333c6053c615150020c0033c6050c0333c6053c615150020c0033c605130021c0020c0330c0030c0333c6053c615150020c0033c6050c0333c6053c615150020c0033c605130021c002
010d00101c2051c1251c1051c12518105181051c1251c1051c105181051c1251c1051c1251c1051c1252460524005240070000700000000000000000000000000000000000000000000000000000000000000000
010d0000154221c4221540215422184220a40215422164220940015422184220040015422164221342200400154221c4221540215422184220a40215422164220040015422184220040015422164221342200400
010d0000153221c3221530215322183220a30215322163220930315322183220030015322163221332200300154221c4221540215422184220a40213422134220040013422134220c40015422154221542200000
010d00080c0330c0333c615150020c0330c0333c61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d0000130321310013130170021703213000130301a0001803213000130301a0021a03218000180301800011032111001113015002150321100011030180001803211000110301700217032180001803018000
010d000015030151021500215030150001500215032180021500215032130021300213032180021803218002150301510215002150301500015002150321c0021503215032150321300215032150321503215002
010600000c0530c6060c6060c0070c0030c6060c606100070c05330606306060e0070c00330606306060e0000c0530e3000e30010300103001030010300103000c0530d3000d3000e3000e3000e3000e3000e300
010d00001503615036150361503613036130361303613030150361503615036150361303613036130361303015036150361503615036130361303613036130301503615036150361503611032110321303213032
010d00001503615036150361503613036130361303613030150361503615036150361303613036130361303015036150361503615036130361303613036130301503615036150361503618032180321a0321a032
010400000037300373000630005300043000330002300013003031d0001a000180001800018000180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000183201d520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000064500012183000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001c04518655000001d00518605000001d00518605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002805028050280502805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002945100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002302000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001d43329134291242911400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00024344
00 07024344
00 00024344
00 07024344
00 01020344
00 08020344
00 01020344
00 08020344
00 04064344
00 05064344
00 04064344
00 05064344
00 09424344
00 0a024344
00 0b024344
00 0a024344
00 0b024344
00 00014344
00 07084344
00 01020344
00 08020344
00 04064344
00 05064344
00 04064344
02 05064344
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

