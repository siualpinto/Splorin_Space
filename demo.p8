pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
--            spaceman 8
--         (c) tic tac toad
dep_normal = 0.70
dep_rebreath = 0.45
dep_loaded = 1.05

highscore=0

fadelen=6

instructions={
	 {1007,"         instructions",999,999,
			1012,"find ",3, ", ",4," and ",5," and carry ",999,
			"them to ",6,9,", ",7,9, " or ",8,9," for",999,
			"1, 2 or 3 times the value.",999,999,
			"exit via ",10,11," before ",35," runs",999,"out.",999,999,
			"collect ",2," for pocket money.",999,999
		}
,		
--{"     shop item information",999,999,
{1007,"upgrade equipment in the shop",999,999,
	1009,
	"rebreather",1012," gives you time to",999,
	"explore the asteroid. ",1009,999,
	"boost ",1012,"& ",1009,"oxygen tanks",1012,999,
	"help you to lift heavy gems.",999,
	1009,"compass",1012," shows you where to go.",999,
	1009,"torch",1012," shows you the easy money.",999,
	1009,"sonar",1012," finds you the good stuff."
	},
{
 999,999,"   game by ",1009,"kometbomb",1007,
 " and ",1011,"ilkke",1002,999,"      both awesome and cool",
 999,999,999,999,1008,
 "          tic tac toad\n            (c) 2017"
 
}
}

-- max hurt time
maxhurt=30
maxoxy = 2100*dep_normal
oxybonus = 450*dep_normal

wtmul=1.25
wtbase=0.25

-- in pixels
ropetotallen = 16

-- in segments
ropelen = 8

ropewt=1.0/ropelen


s_gameplay=6
s_intermission=1
s_shop=2
s_end=3
s_title=4
s_levelgen=5

o_exit = 0
o_obj0 = 1
o_obj1 = 2
o_obj2 = 3
o_objn = 7
o_hole1 = 4
o_hole2 = 5
o_hole3 = 6
o_oxygen = 8

i_compass = 1
i_sonar = 2
i_tow = 3
i_turbo = 4
i_rebreather = 5
i_oxygen=6
i_torch=7

scan_coltab = {
	13,6,13,1
}

tick = 0

statemode = -1
fade = 0

return_coltab = {}

shop={}

return_coltab[o_obj1]={7,14,8,4,4,2,2}
return_coltab[o_obj2]={7,10,10,9,9,9,4}
return_coltab[o_oxygen]={7,12,12,12,12,13,1}

levpal={
	{1,2,4,9,10},
	{1,5,13,8,9},
	{2,1,5,6,7},
	{0,1,2,13,12},
	{1,2,3,10,7},
}

mapx=0
mapy=0
plrleftright=false

leveldata = {
	{size=25,col=1,bcol=1,olim=5},
	{size=30,col=1,bcol=2,olim=6},
	{size=38,col=2,bcol=3,olim=7},
	{size=48,col=2,bcol=5,olim=7},
	{size=56,col=3,bcol=5,olim=8},
	{size=64,col=3,bcol=2,olim=9},
	{size=80,col=4,bcol=1,olim=10},
	{size=96,col=4,bcol=2},
	{size=128,col=5,bcol=2},
	{size=160,col=5,bcol=3}
}

intermission={}

--pillbox data
--g_title=nil
--g_shop=nil
gc_skull="n3dkdra/3dkdraq85nmtaqp56ita$4ekasaq3blosa0rkhbvar03pavarz3pclaz@lghvaz&lchua8&ccbba$qdkltawzrkpmat2yjbnaz4nkimaw4fffda94ffeda48ceddawzrbhya8(cajaa0&ccaba0/cbcaa"
gc_happy="n3dkdra/3dkdraq85nmtaqp56ita$4ekasaq3blosa0rkhbvar03pcvarz3pczaz@lghvaz&lchua8&ccbba$qdklta2zgpgoav4hhcda8(cajaa0&ccaba0/cbcaaw6eebza84hhdda-6eeazav9ucmya29gdeoa"
gc_title="c4qqbdaqe#redcqd!pfbcfnv_gfc'h_sctc*g9qcjcgmt9gdcges1kbddissabcigs1jtdbgsoltce6mmbxax,hidna!2pukpa$4isbna2*hibla14uzb1a2zsmifaru5nntarb56mtayekhava$*hjclasnypevasnmpauarmmpbyatmxpezaxmkpapa!)imd1a0)ikk1ax2kfnva.!hidla1/uddia_,hidna8ncnb1a55cfbfax5ccbba&ofkbra?_dcbra9scfldatscflda4/fdhsa&cdkktaj-ffchah9ffbva.,ffgpax6cbjaa:_bcaqah8ddgpajhs1jjdbfqlnjc:rhhdda;sffdbabhfhntbbffindbbgfhnfba3eebdapnbgpca"
gc_shop="+q40hdc?r2zfbcm[mdgcah5qpeca25cfbfaz5cfcfaw8mrcfa,cgdefa*dhdbfa*ddjjra6dfwcda2ae3fka3af1cla4af2ila6.8npca1af3ana0af2j1a6w84ndaa'~foka._cnlba_3jfbbaaa5fe1aay5fe1aaaf1c1aduyfgpa8m0kfra!fpxcra!ufmjra=ufmjraa&~heya>0guofa+3jfaba-2jfbra=2jfbra/tdliba_pgfada_offbpa'pgfbda*offapa.qccdza#fjkdta:qcccza_owcaqa2(-cg1a_$ifara2%deira7&deira3$kcjra$0edbra(veddra$qicfqa,cdkira&pfccta_mtcfta_2fcctaxdfvcha?2fcdtaddfvklafdufdgafetvfwawefvbxaeefvaxaq2dmjvar3bhktau;gcpcai245bvbd{pwf1av<fcmkaf{lfdfaj(mmgvaj@mmbuac(qmgubh6z3otbj;wxepb/#tfkraj>txhnbs#flarak)ikkta&$begua>8hmcraz-ffkta&%bbooa12abeaa@;gcpca^'ffoea#<fcmka^<fggba$[mdgca^+ffofay2abfaaw2abeaa"

function drawpage(page)
	palt()
		
		x=0
		y=0
		for i in all(page) do
			if i == 999 then
				y+=8
				x=0
			elseif type(i)=="number" then
				if i>=1000 then
					color(i-1000)
				else
					spr(i,x,y-1)
					x+=8
				end
			else
				print(i,x,y)
				x+=#i*4
			end

		end
		if p==3 then
		 spr(78,56,38,2,2)
		 txt="best score: $"..highscore
		 print(txt, 64-#txt*2, 78, tick)
		end
end

function pillbox(x,y,w,h,c,re)
color(c)
-- fix negative size
--if (h<0) y,h=y+h,-h --not happening here?
--if (w<0) x,w=x+w,-w
local x2,y2=x+w,y+h
local r
--// rounded --or else
if re!=0 then
if h<w then
r=h/2
rectfill(x+r,y,x2-r,y2)
else
r=w/2
rectfill(x,y+r,x2,y2-r)
end
circfill(x+r,y+r,r)
circfill(x2-r,y2-r,r)
else
rectfill(x,y,x2,y2)
end
end

enc_chars="abcdefghijklmnopqrstuvwxyz0123456789-_.,!@#$%&/()=+?'*:;<>{}[]^~"
function num(s,i)
local c=sub(s,i,i)
for i=1,#enc_chars do
if sub(enc_chars,i,i)==c then
return i-1
end
end
end

function decode(s)
local o = {}
for i=1,#s,7 do
local e=num(s,i+4)
local f=num(s,i+5)
local g=num(s,i+6)
local x=num(s,i)*2+e%2
local y=num(s,i+1)*2+band(e/2,1)
--local y=num(s,i+1)*2+e/2%2--wrong mantissa
if (g%2>0) x=-x
if (g%4>1) y=-y
add(o,{x,y,
num(s,i+2)*2+band(e/4,1),
num(s,i+3)*2+band(e/8,1),
f/2%15,--(color->mantissa ignored)
f%2 })
end
return o
end

function drawpb(p,z)
for e in all(p) do
pillbox((e[1]-64)*z+64,(e[2]-64)*z+64,e[3]*z,e[4]*z,e[5],e[6])
end
end

function text(str,x,y,c,bc,center)
	if center then
		x-=#str*2
	end
	for dx=x-1,x+1 do
 	for dy=y-1,y+1 do
--  	if dx!=x or dy!=y then
    print(str,dx,dy,bc)
--  	end
 	end
	end
 print(str,x,y,c)
end

function drawshop()
	cls()
	drawpb(g_shop,1)
	
	-- pupil
	spr(127,shop.px+54,shop.py+77)
	--draw pillbox
	local i = shopitem[shop.item]
	print(i.name,33-#i.name*2,35,3)
	
	s=shopitem[shop.item].s
	spr(s,24,18,1,2)
	spr(s,32,18,1,2,true)
	text("cash $"..player.money,32,11, 3,10,true)
-- print("cash $"..player.money,24,12,3)
	if i.price > 0 then
 	if i.disabled then
 		txt="bought!"
 		c=8
 	else
 		txt="$"..i.price
 		c=10
 	end
 	print(txt,32-#txt*2,42,c)
	end

--	txt="you have $"..player.money
--	txt="left/right to select"
--	text(txt,126-#txt*4,122,7,0)
end

function expandgrid(grid)
	newgrid = {}
	for y=1,#grid do
		newgrid[y] = {}
		for x=1,#grid[y] do
			local a = grid[y][x]
			local c = 0
			
			if a == 0 then
				for dy=-1,1 do
					for dx=-1,1 do
						if grid[y+dy]  and 
							grid[y+dy][x+dx] and grid[y+dy][x+dx] != 0 then
							c += 1
						end
					end
				end
				
				if c > 3 then
					a = 1
				end
			end
			
			newgrid[y][x] = a
		end
	end
	
	return newgrid
end

function addparticle(x,y,dx,dy,t)
	add(particles,{x=x,y=y,dx=dx,dy=dy,t=t,ttl=15})
end

function adddot(x,y,dx,dy,c,ttl)
	add(dots,{x=x,y=y,dx=dx,dy=dy,c=c,ttl=ttl})
end

function addmoney(x,y,a)
	local t="$"..a
	local l=#t*4
	add(moneys,{x=x-l/2,y=y,a=t,ttl=45})
end


function changestate(state)
	if (player) highscore=max(highscore,player.money)
	dset(0,highscore)
	
	fade=0
	statemode = -1
	gamestate = state
	
	inittab={
	initintermission,
	initshop,
	initend,
	inittitle,
	initlevelgen,
	initgameplay,
	}
	
	inittab[gamestate]()
	
	--[[
	if gamestate == s_intermission then
		initintermission()
	elseif gamestate == s_gameplay then
		initgameplay()
	elseif gamestate == s_levelgen then
		initlevelgen()
	elseif gamestate == s_shop then
		initshop()
	elseif gamestate == s_end then
		initend()
	elseif gamestate == s_title then
		inittitle()
	end--]]
end

function doparts()
	for p in all(particles) do
		if p.ttl <= 0 then
			del(particles,p)
		else
			p.x += p.dx
			p.y += p.dy
			
			p.ttl -= 1
		end
	end
	
	for p in all(dots) do
		if p.ttl <= 0 then
			del(dots,p)
		else
			p.x += p.dx
			p.y += p.dy
			
			p.ttl -= 1
		end
	end
end

function domoneys()
	for p in all(moneys) do
		if p.ttl <= 0 then
			del(moneys,p)
		else
			p.y -= 0.5
			p.ttl -= 1
		end
	end
end


function addradar(x,y,c)
	local dx = (x-player.x)/256
	local dy = (y-player.y)/256
	local a = atan2(-dx,dy)
	local d = sqrt(dx*dx+dy*dy)
	add(radar,{x=x,y=y,a=a,c=c,r=0,ttl=d*256})
end

function doradars()
	for r in all(radar) do
		r.r += 6
		if r.r > r.ttl then 
			del(radar,r)
		end
	end
end

function drawradars()
	
	for r in all(radar) do
		--circ(r.x-mapx,r.y-mapy,r.r)
		local a = r.a
		
		local dx = cos(a)
		local dy = -sin(a)
		
		for s=0,16,4 do
			if r.r+s-16 > 0 then
				local c = r.r*5/r.ttl+3-s/3
				if c < r.r*5/r.ttl then
					c = r.r*5/r.ttl
				end
				
				color(return_coltab[r.c][flr(c)+1])
				local rad = r.r - 16 + s
				local rad2 = (r.r+s-16) / 8
				local cx = rad*dx
				local cy = rad*dy
				local ecx = cx*1.05
				local ecy = cy*1.05
				line(cx-dy*rad2-mapx+r.x,cy+dx*rad2-mapy+r.y,
				ecx+r.x-mapx,ecy+r.y-mapy)
				line(ecx+r.x-mapx,ecy+r.y-mapy,
				cx+dy*rad2-mapx+r.x,cy-dx*rad2-mapy+r.y)
			end
		end
		--spr(5, cos(a)*r.r+r.x-mapx, 
		--	-sin(a)*r.r+r.y-mapy)
	end
end

function drawparts()
	for p in all(particles) do
		spr(p.t+(tick/4)%3,p.x-4-mapx,p.y-4-mapy)
	end
	
	for p in all(dots) do
		pset(p.x-mapx,p.y-mapy,p.c)
	end

end

function drawmoneys()
	for p in all(moneys) do
		local c = (p.ttl/2) % 2 + 7
		print(p.a, p.x-mapx, p.y-mapy+1, 1)
		print(p.a, p.x-mapx, p.y-mapy, c)
	end
end


function zoomgrid(grid,grow)

	local newgrid = {}

	for y=0,#grid-1 do
		newgrid[y * 2 + 1] = {}
		newgrid[y * 2 + 1 + 1] = {}
		for x=0,#grid[y+1]-1 do
			
			local a = grid[y+1][x+1]
		
			newgrid[y * 2 + 1][x * 2 + 1] = a
			newgrid[y * 2 + 2][x * 2 + 1] = a
			newgrid[y * 2 + 1][x * 2 + 2] = a
			newgrid[y * 2 + 2][x * 2 + 2] = a
		end
	end

	for i=0,#newgrid*#newgrid[1] do	
		local x = flr(rnd() * (#newgrid[1] - 3)) + 2
		local y = flr(rnd() * (#newgrid - 3)) + 2
		local c = newgrid[y][x] 
		if newgrid[y-1][x] != c or
			newgrid[y+1][x] != c or
			newgrid[y][x-1] != c or
			newgrid[y][x+1] != c then
			if rnd() < grow then
					newgrid[y][x] = 1
			end
		end
	end

	return newgrid

end

function genmap(size)
	local grid = {}
	local w=32
	local h=16
	
	for y=1,h do
		grid[y]={}
		for x=1,w do
			grid[y][x] = 0
		end
	end
	
	grid[h/2][w/2] = 1
	y=h/2
	local objs = {
		{o_hole1,-100,y},
		{o_obj0,-100,y},
		{o_exit,-100,y},
		{o_obj1,-100,y},
		{o_obj0,-100,y},
		{o_obj0,-100,y},
		{o_hole2,-100,y},
		{o_oxygen,-100,y},
		{o_hole1,-100,y},
		{o_obj1,-100,y},
		{o_obj2,-100,y},
		{o_obj0,-100,y},
		{o_obj1,-100,y},
		{o_hole3,-100,y},
		{o_oxygen,-100,y},
		{o_obj1,-100,y},
		{o_obj2,-100,y},
		{o_obj2,-100,y},
	}
	
	if leveldata[level].olim != nil then
		local i = 1
		for o in all(objs) do
			if i > leveldata[level].olim then
				del(objs,o)
			end
			i+=1
		end
	end
	
	objidx = 1
	open = 0
	
	for i=0,5000 do
		if open >= size then
			break
		end
		local x = flr(rnd() * (w-2))+2
		local y = flr(rnd() * (h-2))+2
		local diagneighbors = 0
		
		if grid[y][x] == 0 then
			
		if grid[y + 1][x + 1] != 0 then
			diagneighbors += 1
		end
		
		if grid[y - 1][x - 1] != 0 then
			diagneighbors += 1
		end
		
		if grid[y + 1][x - 1] != 0 then
			diagneighbors += 1
		end
		
		if grid[y - 1][x + 1] != 0 then
			diagneighbors += 1
		end
		
		if (grid[y][x - 1] != 0 or
			grid[y][x + 1] != 0 or 
			grid[y - 1][x] != 0 or
			grid[y + 1][x] != 0) 
			and
				(diagneighbors == 1 or
				diagneighbors == 0)
			then
			
			grid[y][x] = 1
			open += 1
			
			local processed = false
			
			for o in all(objs) do
				if abs(o[2] - x) < 2 and 
					abs(o[3] - y) < 2
				then
					processed = true
					o[2] = x
					o[3] = y
					break
				end
			end
			
			if not processed then
				objs[objidx][2] = x
				objs[objidx][3] = y
				objidx += 1
				
				if objidx > #objs then
					objidx = 1
				end
			end
		end
		end
	end
	
	local exitx, exity
	
	for o in all(objs) do
		if o[2] >= 0 then
		if o[1] == o_exit then
			exitx=o[2]
			exity=o[3]
			add(exits,{x=o[2]*32-24,y=o[3]*32-24})
		elseif o[1] >= o_obj0 and
			o[1] <= o_obj2 then
			if week >= 3 then
				o[1]=max(o_obj1, o[1])
			end
			local vals ={}
			vals[o_obj0]=25
			vals[o_obj1]=50
			vals[o_obj2]=105
		add(objects,
			{type=o[1],x=o[2]*32-16,y=o[3]*32-16,
				dx=0,dy=0,wt=wtbase+(o[1]-o_obj0)*wtmul,active=false,
				value=vals[o[1]]})
		elseif o[1] >= o_hole1 and o[1] <= o_hole3 then
			add(holes,{x=o[2]*32-24,y=o[3]*32-24,mult=o[1]-o_hole1+1})
		elseif o[1] == o_oxygen then
			if week >= 2 and #objects>=10 then
				-- after week 1 halve the oxygen
				o[1] = o_obj1
			elseif week >= 3 then
				-- after week 2 no extra oxygen!
				o[1] = o_obj2
			end
			add(objects,{type=o[1], x=o[2]*32-24,y=o[3]*32-24})
		end
		end
	end
	


	grid = zoomgrid(grid,0.05)
	--grid = zoomgrid(grid,0.25)
	grid = zoomgrid(grid,0.15)
	grid = expandgrid(grid)
	exitx*=4
	exity*=4
	
	-- do nuggets
	for i=1,level*week+(week-1)*20+4 do
		local x,y
		
		repeat
			x=flr(rnd(#grid[1]))
			y=flr(rnd(#grid))
		until 
			grid[y+1][x+1] == 1
			and grid[y+1+flr(rnd(3))-1]
							 [x+1+flr(rnd(3))-1] == 0
		
		add(objects,
			{type=o_objn,x=x*8+4,y=y*8+4,active=false,
				value=5,seen=false})
		printh(x.." "..y)
	end
	

		
	--[[
	for y=1,#grid do
		for x=1,#grid[y] do
			color(grid[y][x])
			rectfill(x, y+32, x+1,y+1+32)
		end
	end		
	--]]

	local rndempty = {
		42, 42, 59, 58, 58, 58, 43
	}	
	
	for y=2,#grid-1 do
		for x=2,#grid[y]-1 do
			--color(grid[y][x])
			--rectfill(x * 2, y* 2, x*2+2,y*2+2)
			local tile = 63
			
			if	grid[y][x] == 1 then
				local dx=exitx-x
				local dy=exity-y
				if rnd()<0.05 or 
					(sqrt(dx*dx+dy*dy) < rnd(16)
					 and rnd() < 0.75) then
					tile = rndempty[flr(rnd()*#rndempty) + 1]
				else
					tile = 27
				end
			else
				local mask = 0
				if grid[y - 1][x] == 0 then
					mask += 1
				end
				if grid[y][x + 1] == 0 then
					mask += 2
				end
				if grid[y + 1][x] == 0 then
					mask += 4
				end
				if grid[y][x - 1] == 0 then
					mask += 8
				end
			
				if mask == 15 then
					mask = 0
					if grid[y - 1][x - 1] != 0 then
						mask += 1
					end
					if grid[y - 1][x + 1] != 0 then
						mask += 2
					end
					if grid[y + 1][x - 1] != 0 then
						mask += 4
					end
					if grid[y + 1][x + 1] != 0 then
						mask += 8
					end
					
					tile = mask % 4 + (flr(mask/4)) * 16 + 64
					
					if mask == 0 and rnd() > 0.75 then
					local rndfilled = {
						41, 41, 41,57,40,56
					}
					if rnd() > 0.75 then
						tile = rndfilled[flr(rnd()*#rndfilled) + 1]
					end
				
				end
				else
					tile = mask % 4 + (flr(mask/4)) * 16 + 12
				end
			end
			
			mset(x-1,y-1,tile)
		end
	end
	
	for y=0,#grid-1 do
		mset(0, y, 63)
		mset(#grid[1]-1, y, 63)

	end
	
	for x=0,#grid[1]-1 do
		mset(x, 0, 63)
		mset(x, #grid-1, 63)
	end

end

--cls()
--while true do
--	genmap(64)
--end

function pickup(obj)
	if obj.type >= o_obj0 and obj.type <= o_obj2 then
		player.object = obj
  player.compassmode = 0	
		obj.active = true
		
		local dx = obj.x - player.x
		local dy = obj.y - player.y
		
		for i=1,ropelen do
			local r = rope[i]
			r.x = player.x + dx * (i-0.5) / ropelen
			r.y = player.y + dy * (i-0.5) / ropelen
			r.dx = 0
			r.dy = 0
		end
		
		player.item = i_tow
	elseif obj.type == o_objn then
		player.money += obj.value
		lmoney += obj.value
		addmoney(obj.x,obj.y,obj.value)
		del(objects,obj)
	elseif obj.type == o_oxygen then
		player.oxygen += oxybonus
		if player.oxygen > player.maxoxy then
			player.oxygen = player.maxoxy
		end
		del(objects,obj)
	end
end

function drop()
	for i=1,ropelen do
		local o
		if i < ropelen then
			o = rope[i+1]
		else
			o = player.object
		end
		
		for d=1,4 do
			local p=rnd()
			
			local dx = o.x - rope[i].x
			local dy = o.y - rope[i].y
			local c = 11
			if rnd(1) < 0.5 then
				c = 3
			end

			adddot(p*dx+rope[i].x, p*dy+rope[i].y, rnd(1)-0.5, rnd(1)-0.5, c, rnd(20)+5)
		end
	end

	player.object = nil
	player.compassmode = 1	
end

function checkcol(obj,verthorz)
	local subx=obj.x-flr(obj.x)-3
	local suby=obj.y-flr(obj.y)-3
	if abs(subx)+abs(suby)<=4 then
		return false
	end
	local tile = mget(flr(obj.x / 8), flr(obj.y / 8))
	local col = false
	
	if not fget(tile, 0) then
		obj.lx = obj.x
		obj.ly = obj.y
		return false
	end
	
	if fget(tile,3) then
		return true
	end
	
	local d0 = fget(tile, 7)
	local d1	= fget(tile, 6)
	local d2 = fget(tile, 5)
	local d = 0
	
	if d0 then
		d += 1
	end
	
	if d1 then
		d += 2
	end
		
	if d2 then
		d += 4
	end
	
	obj.x = obj.lx
	obj.y = obj.ly
	obj.dx = cos(d/8)
	obj.dy = -sin(d/8)
	
	return true
end

function moveobj(obj,isplr)
	local hurt = 10*(abs(player.dx)+abs(player.dy))
	obj.x += obj.dx
	local col =	checkcol(obj,false)
	obj.y += obj.dy
	col = checkcol(obj,true) or col
	
	if col then
		if isplr then
			sfx(4,2)
			if player.halt <= 0 then
				player.oxygen -= 30
				player.halt = min(maxhurt,hurt)
			end
		else
			sfx(3,2)
			--if obj == player.object then
				-- check if too hard a collision
				-- and then drop
			--end
		end
	
		for i=0,9 do
			adddot(obj.x,obj.y,rnd(2)-1,rnd(2)-1,10,rnd(20))
		end
	end

	
	obj.dx *= 0.99
	obj.dy *= 0.99
	obj.dy += 0.025
	
	return col
end

function moverope(r)
	r.x += r.dx
	r.y += r.dy
	r.dx *= 0.99
	r.dy *= 0.99
	r.dy += 0.025
end

function pushobect(obj, dx, dy)
	obj.dx += dx
	obj.dy += dy
end

function gravitate(obj, tgt, g)
	local dx = obj.x - tgt.x
	local dy = obj.y - tgt.y
	
	if abs(dx) > g or abs(dy) > g then
		return
	end
	
	local d = sqrt(dx*dx+dy*dy)
	if d != 0 then
		dx /= d
		dy /= d
	end
	
	if d < g and d > 0 then
		if d < 1 then
			d = 1
		end
		dx /= d * obj.wt
		dy /= d * obj.wt
		obj.dx -= dx*g*0.1875
		obj.dy -= dy*g*0.1875
	end
	
end

function constraint(a,b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local wt = a.wt + b.wt
	local d = sqrt(dx*dx+dy*dy)
	if d != 0 then
		dx /= d
		dy /= d
	end
	
	local f = (ropetotallen/ropelen - d) 
	
	dx *= f
	dy *= f
	
	local adx = dx * b.wt / wt
	local ady = dy * b.wt / wt
	local bdx = dx * a.wt / wt
	local bdy = dy * a.wt / wt

	a.x += adx
	a.y += ady
	
	b.x -= bdx
	b.y -= bdy
	
	a.dx += adx
	a.dy += ady
	
	b.dx -= bdx
	b.dy -= bdy
end

function initlevel()
	pulse=1
	lmoney=0
	
	player.compassmode = 0
	player.item = i_compass
	player.dx = 0
	player.dy = 0
	player.sonardelay = 5
	player.x = 496
	player.y = 240
	player.halt=0
	player.scan=0
	player.maxoxy = maxoxy*( 1.0 + player.equipment.oxytank * 0.5)
	player.dead=false
	player.deathctr=0
	mapx=player.x-64
	mapy=player.y-64

	player.oxygen = player.maxoxy
end

function initend()
	g_happy=decode(gc_happy)
end

function updateend()
	if btnp(4) then
		week += 1
  transition(s_levelgen)
	end
end

function drawend()
	cls()
	level=1
	drawpb(g_happy,1)
	text("it's weekend! have a good one",64,20,12,0,true)
	text("you made a total of $"..player.money,64,100,3,0,true)
	text("Ž continue ",64,112,11,0,true)
end

function inittitle()
	tick=0
	reload(0x1000,0x1000,0x1000)
	g_title=decode(gc_title)
	music(4)
end

function updatetitle()
	if btnp(4) then
		initgame()
		transition(s_levelgen)
	end
end

function drawtitle()
	cls()
	p=flr(tick/256)%4
	if p==0 then
		drawpb(g_title,sin(tick/100)*0.2+1.1)
	else
		drawpage(instructions[p])
	end
	palt(0,false)
	palt(11,true)
	spr(128,0,87,16,4)
 line(98,119,104,119,0)
	print("or wait for instructions",14,122,1)
	print("or wait for instructions",14,121,10)
	print("press Ž to start",28,114,1)
	print("press Ž to start",28,113,7)


end


function initgame()
	level=1
	week=1
	lmoney=0
	player={
		money=0,
		dead=false,deathctr=0,oxydep=1,halt=0,x=64*4,y=64,
		dx=0,dy=0,object=nil,wt=1.0,
		dropctr=0,scan=0,compass=0,
		compassd=0,compassmode=1,
		equipment={torch=0,compass=0,tows=3,sonar=0,
		turbo=0,oxytank=0,rebreather=0},
		item=i_tow,sonardelay=0}
end

function initlevelgen()
	radar={}
	objects={}
	holes={}
	exits = {}
	particles ={}
	dots={}
	moneys={}
	music(99)
	sfx(21+level%2)
end

function updatelevelgen()
	local levsiz = leveldata[level].size + 80 * (week-1)
	genmap(levsiz)
	changestate(s_gameplay)
end

function drawlevelgen()
	cls()
	local shifts={
	" morning shift",
	"afternoon shift"}
	text(shifts[(level-1)%2+1],34,61,3,0)
end
		
function initgameplay()
	g_skull=decode(gc_skull)
	initlevel()
	rope={}
	music(2)
	for i=1,ropelen do
 	add(rope,{x=0,y=0,dx=0,dy=0,wt=ropewt})
	end

end

function _init()
	cartdata("toad_spaceman8")
	highscore=dget(0)
	changestate(s_title)
end

function startscan()
	sfx(0,2)
	player.sonardelay = 150
	player.scan = 1
	for o in all(objects) do
		o.scanned = false
	end
end

function findshopitem(t)
	for i in all(shopitem) do
		if i.item == t then
			return i
		end
	end
	return nil
end

function doshopprices()
	shopitem = {
	{s=36,name="oxygen tank",item=i_oxygen,price=110},
	{s=39,name="roket boost",item=i_turbo,price=325},
	{s=68,name="rebreather",item=i_rebreather,price=300},
	{s=69,name="sonar",item=i_sonar,price=390},
	{s=72,name="compass",item=i_compass,price=210},
	{s=73,name="torch",item=i_torch,price=105},
	{s=109,name="cola",item=-1,price=10},
	{s=77,name="exit shop",item=nil,price=0}--keep 77,93 blank
	}
	
	-- inflation
	for i in all(shopitem) do
		i.price *= 1.0 + (level-3+(week-1)*10)/8
		i.price = -flr(-flr(i.price / 5))*5
	end
	
	i = findshopitem(i_oxygen)
	i.price *= 1+player.equipment.oxytank^2
	
	e=player.equipment

	if e.oxytank >= 3 then
		i = findshopitem(i_oxygen)
		i.disabled=1
	end
	
	if e.turbo > 0 then
		i = findshopitem(i_turbo)
		i.disabled=1
	end
	
	if e.sonar > 0 then
		i = findshopitem(i_sonar)
		i.disabled=1
	end
	
	if e.rebreather > 0 then
		i = findshopitem(i_rebreather)
		i.disabled=1
	end
	
	if e.compass > 0 then
		i = findshopitem(i_compass)
		i.disabled=1
	end
	
	if e.torch > 0 then
		i = findshopitem(i_torch)
		i.disabled=1
	end
	
end

function initshop()
 music(99)
 sfx(15)
	shop.item = 1
	shop.px=0
	shop.py=0
	shop.pdx=0
	shop.pdy=0
	g_shop=decode(gc_shop)
	
	doshopprices()

end

function initintermission()
	music(1)
	intermission.stars = {}
	
	intermission.f = 0
	intermission.x = rnd(120)
	intermission.y = rnd(120)
	intermission.dx = rnd(0.5)+1
	intermission.dy = rnd(0.5)+0.5
	
	if rnd() < 0.5 then
		intermission.dy *= -1
	end
	
	for i=0,60 do
		add(intermission.stars,
			{x=rnd(128),y=rnd(128),z=rnd(3)})
	end

	intermission.d=1
	if (intermission.nxt==s_levelgen) intermission.d = -1
		
end

function updateintermission()
	intermission.x += intermission.dx
	intermission.y += intermission.dy
	
	local s = 8
	
	if intermission.x < 32 then
		intermission.x = 32
		intermission.dx *= -1
	end
	
	if intermission.y < 32 then
		intermission.y = 32
		intermission.dy *= -1
	end
	
	if intermission.x > 96-s then
		intermission.x = 96-s
		intermission.dx *= -1
	end
	
	if intermission.y > 96-s then
		intermission.y = 96-s
		intermission.dy *= -1
	end
	
	intermission.f += 1
	
	for s in all(intermission.stars) do
		
		s.x = (s.x - s.z*intermission.d)%128
	end
	
	if intermission.f > 90 then
		changestate(intermission.nxt)
	end
end

function drawintermission()
	cls()
	palt()
	
	for s in all(intermission.stars) do
		spr(35-s.z,s.x,s.y)
	end
	
	spr(70,-intermission.f*intermission.d,64,2,3)
	
	local f = false
	if intermission.dx < 0 then
		f = true
	end	
	spr(1,intermission.x,intermission.y,1,1,f,false)
	clip()
	
	local days={
		"mon", "tue", "wed", "thu", "fri", "sat"
	}

		c=7	
	for i = 1,5 do
		spr(100,i*18-7,99,2,2)
  print(days[i],i*18-5,101,7)
 	if (level-1) / 2 >= i then
			spr(37,i*18-8,100,2,2)
		end
	end
	spr(104,101,99,2,2)

	local txt
	local c = 7
	
	if intermission.nxt==s_levelgen then
		if level%2 == 1 then
			local days={
				"monday...","tuesday",
				"wednesday","thursday",
				"friday!"
			}
			local pre={
				"", "another ", "yet another damn "
			}
			txt=days[(level-1)/2+1]
			if level >=9 then
				c=intermission.f%15+1
			else
				txt=pre[min(3,week)]..txt
			end
		else
			txt="lunch break"
			c=3
		end
	elseif intermission.nxt==s_end then
		txt="weekend at last"
	elseif intermission.nxt==s_shop then
		txt="going shopping"
	end
	
	text(txt,64,22,c,0,true)
	
	if week>1 then
		text("week "..week,52,120, 6,0)
	end
	
end

function _update()
	if fade<fadelen and statemode < 1 then
		fade += 1
		if fade >= fadelen then
		if statemode < 1 then
			fade = 0
			statemode += 1
		end
		end
	else

	tick+=1
	
	local gs=gamestate
	
	if gs == s_intermission then
		updateintermission()
	elseif gs == s_gameplay then
		updategame()
	elseif gs == s_levelgen then
		updatelevelgen()
	elseif gs == s_shop then
		updateshop()
	elseif gs == s_end then
		updateend()
	elseif gs == s_title then
		updatetitle()
	end
	end
end


function transition(nxt)
	sfx(-1,0)
	sfx(-1,1)
	sfx(-1,2)
	sfx(-1,3)
	intermission.nxt = nxt
	changestate(s_intermission)
end


function updateshop()

	shop.px=(shop.px+shop.pdx)/2
	shop.py=(shop.py+shop.pdy)/2
	ep=0
	
	if rnd()<0.02 then
		ep=3
	end

 if btnp(0) then
 	ep=1
 	shop.item = max(1,shop.item-1)
 elseif btnp(1) then
 	ep=1
  shop.item = min(#shopitem,shop.item+1)
 elseif btnp(4) then
 	ep=2
 	local s = shopitem[shop.item]
  if not s.item then
  	music(99)
  	transition(s_levelgen)
  	sfx(12)
  elseif player.money >= s.price then
   --buy it!
   player.money -= s.price
   
   if s.item == i_oxygen then
			 player.equipment.oxytank += 1
   end
   
   if s.item == i_rebreather then
			 player.equipment.rebreather += 1
   end
   
   if s.item == i_turbo then
			 player.equipment.turbo += 1
   end
   
   if s.item == i_sonar then
			 player.equipment.sonar += 1
   end
   
   if s.item == i_compass then
			 player.equipment.compass += 1
   end
   
   if s.item == i_torch then
			 player.equipment.torch += 1
   end
 
   
   -- so that oxygen etc. is more expensive
   doshopprices()
   
   sfx(6)
  else 
  	sfx(11)
  end
 end
 
 if ep>0 then
 	local e={0.1,0.66,0.4}
 	shop.pdx=cos(e[ep])*3
 	shop.pdy=sin(e[ep])*3
 end
end


function updategame()
	doparts()
	domoneys()
	doradars()
	
	updatecompass()
		
	if player.equipment.sonar > 0 then
		if player.scan > 0 and player.scan < 10000 then
			player.scan += 6
		end
	end

	if player.object then
		player.oxydep = dep_loaded
	else
		if not player.equipment.rebreather then
			player.oxydep = dep_rebreath
		else
			player.oxydep = dep_normal
		end
	end
	
	player.oxygen -= player.oxydep
	
	if player.halt > 0 then
		player.halt -= 1
	end
	
	if player.dead and player.deathctr < 500 then
		player.deathctr += 1
	end
	
	if player.sonardelay > 0 then
		player.sonardelay -= 1
	end
	
	if player.deathctr < 120 then
	if player.oxygen < 0 then
		if not player.dead then
			sfx(7,2)
			player.dead = true
		end
		player.oxygen = 0
	end

	moveobj(player,true)
	
	for i=1,ropelen do
		moverope(rope[i])
	end
	
	for o in all(objects) do
		if o.active then
			if moveobj(o) and player.object != o then
				--del(objects, o)
			end
		end
	end
	
	if player.object == nil then
		for h in all(exits) do
			if abs(player.x - (h.x+8)) < 8 and 
						abs(player.y - (h.y+8)) < 8 then
						
						--advance level
						level += 1
						if level > 10 then
							transition(s_end)
						else
							if level % 2 == 1 then
							transition(s_shop)
							else
							transition(s_levelgen)
							end
						end
						return
			end
		end
	end
	end
	
	local hr = 24
	
	if player.equipment.torch > 0 then
		hr = 48
	end
	
	for o in all(objects) do
		if o.type == o_objn and not o.seen and abs(o.x - player.x) +
			abs(o.y - player.y) <= hr then
			o.seen = true
			for i=0,1,0.1 do
				adddot(o.x-1,o.y-1,cos(i),sin(i),12,10)
			end
			sfx(10,3)
		end
	end
	
	if player.object != nil then
		constraint(player,rope[1])
		for i=1,ropelen-1 do
			constraint(rope[i],rope[i+1])
		end
		constraint(rope[ropelen],player.object)
		
		for h in all(holes) do
			if player.object != nil then
				gravitate(player.object, {x=h.x+8, y=h.y+8}, 24)
			
				if abs(player.object.x - (h.x+8)) < 5 and 
					abs(player.object.y - (h.y+8)) < 5 then
					local m = player.object.value * h.mult
					lmoney += m
					player.money += m
					addmoney(player.object.x, player.object.y, player.object.value * h.mult)
					sfx(5,1)
					
					del(objects, player.object)
					for i=0,0.75,0.25 do
 					addparticle(player.object.x, 
 						player.object.y, cos(i)*1.5, sin(i)*1.5, 49)
					end
	 			drop()
				end
			end
		end
	end
	
	if player.oxygen > 0 then
		for o in all(objects) do
			
			if abs(o.x - player.x) +
					abs(o.y - player.y) <= 8 then
				if o.type >= o_objn or not player.object then
					pickup(o)
				
					sfx(6,2)
					break
				end
			end
		end
	end
	
	if player.scan > 0 then
		for o in all(objects) do
			local dx = (o.x - player.x)/32
			local dy = (o.y - player.y)/32
			local d = player.scan/32
			d*=d
			if o.type != o_objn 
				and o.type != o_obj0
				and dx*dx+dy*dy < d 
				and not o.scanned then
				sfx(1,2)
				o.scanned = true
				if	player.scan < 4096 then
					addradar(o.x,o.y,o.type)
				end
			end
		end
	end
	
	local hd = 0.075
	local upd = 0.16
	local dnd = 0.05
	
	if player.equipment.turbo > 0 then
		upd *= 1.5
	end
	
	local thrust = false
	
	if not player.dead and player.halt <= 0 then
		
		if btn(1) then
			player.dx += hd
			plrleftright = false
			thrust=true
		end
	
		if btn(0) then
			player.dx -= hd
			plrleftright = true
			thrust=true
		end
	
		if btn(2) then
			player.dy -= upd
			thrust=true
		end
	
		if btn(3) then
			player.dy += dnd
			thrust=true
		end
	end
	
	if player.dead and player.object then
		drop()
	end
	
	if player.dead and player.deathctr >= 120 then
		if btnp(4) then
			changestate(s_title)
		end
	
	end
	
	if thrust then
		if btn(2) and player.equipment.turbo > 0 then
			adddot(player.x,player.y+12,rnd()*0.4-0.2,rnd(0.5)+0.1,9,10)
		end
		sfx(2,0)
	else
	 sfx(-1,0)
	end
	
	if btnp(5) then
		if player.equipment.sonar > 0 and
		 (player.scan > 128 or player.scan == 0) 
		 and player.sonardelay <= 0 
		 then
			startscan()
		--elseif player.item == i_compass then
		--	if player.compassmode == 0 then
		--		player.compassmode = 1
		--	else
		--		player.compassmode = 0
		--	end
		end
	end
	
	if btn(4) then
		--if player.item == i_tow then
			if player.dropctr > 15 and player.object then
				local cx = (player.x+player.object.x)/2
				local	cy	=	(player.y+player.object.y)/2
				--addparticle(cx,cy,-0.5,-0.5, 32)
				--addparticle(cx,cy,0.5,-0.5, 32)
				--addparticle(cx,cy,-0.5,0.5, 32)
				--addparticle(cx,cy,0.5,0.5, 32)
				
				drop()
				player.dropctr = 0
			else
				player.dropctr += 1
			end
		--end
	else
		if player.dropctr > 0 and player.dropctr < 10 then
		 player.compassmode = 1-player.compassmode
		end
		player.dropctr = 0	
	end
	
	if not player.dead and btnp(5) then
		player.item += 1
		if player.item > i_tow then
			player.item = 1
		end
	end
	
	player.oxygen = max(0, player.oxygen)
	
	mapx = player.x-64
	mapy = player.y-64
end

function updatecompass()
	local bestx
	local besty
	local bestd = nil

	if player.compassmode == 0 then
		for h in all(holes) do
			local dx = (h.x + 8 - player.x)/16
			local dy = (h.y + 8 - player.y)/16
		
			if bestd == nil or bestd > dx*dx + dy*dy then
				bestd = dx*dx + dy*dy
				bestx = dx
				besty = dy		
				
				player.compassspr = 6 + h.mult-1
			end
		end
	else
		for h in all(exits) do
			local dx = (h.x + 8 - player.x)/16
			local dy = (h.y + 8 - player.y)/16
		
			if bestd == nil or bestd > dx*dx + dy*dy then
				bestd = dx*dx + dy*dy
				bestx = dx
				besty = dy		
			end
		end
	end
	
	local a = atan2(bestx,-besty)
	a = (a+1) % 1
	
	if player.compass < a then
		if abs(player.compass - a) < 0.5 then
			player.compassd += 0.01
		else
			player.compassd -= 0.01
		end
	elseif player.compass > a then
		if abs(player.compass - a) < 0.5 then
			player.compassd -= 0.01
		else
			player.compassd += 0.01
		end
	end
	
	player.compass = (player.compass + 1 + player.compassd) % 1

	player.compassd *= 0.95
end
function drawcompass()

 palt(0,false)
 palt(11,true)
	spr(74,-8,0,3,4)
	spr(74,16,0,3,4,true)
 palt()
 
	local rad = 12
	for y=-1,1 do
	for x=-1,1 do
		line(16+x,14+y,16+cos(player.compass)*(rad-2),15-sin(player.compass)*(rad-2),8)
		line(16+x,14+y,16+cos(player.compass)*-(rad-2),15-sin(player.compass)*-(rad-2),12)
	end
	end

	circfill(16,15,6,0)
	
	if player.compassmode==1 then
		spr(10,8,11,2,1)
	else
		spr(player.compassspr,8,11)
		spr(9,16,11)
	end
end

function pad(x)
	if x < 10 then
		return "0"..x
	end
	return x
end

function _draw()
	gs=gamestate
	if statemode >= 0 then
		drawtab={
		drawintermission,
		drawshop,
		drawend,
		drawtitle,
		drawlevelgen,
		drawgame
		}
	
	drawtab[gs]()

	end
	
	if statemode == 0 then
		rectfill(0,fade*127/fadelen,127,127,0)
		--line(0,fade*127/fadelen,127,fade*127/fadelen,10)
	elseif statemode == -1 then
		rectfill(0,(fadelen-fade)*127/fadelen,127,127,0)
		--line(0,(fadelen-fade)*127/fadelen,127,(fadelen-fade)*127/fadelen,10)
	end	
	
--	rectfill(0,0,32,6,0)
--	print(stat(1),0,0,7)
end

function setpal()
	pal(1,p[1])
	pal(2,p[2])
	pal(4,p[3])
	pal(9,p[4])
	pal(10,p[5])
	pal(12,leveldata[level].bcol)
end

function drawgame()
	if player.deathctr < 120 then
	cls()
	
		
	--we first draw bg color
	--then the bg tiles
	--then draw torch over bg
	--finally draw cave tiles
	--over the torch 
	
	p=levpal[leveldata[level].col]
	
	
	setpal()
	--clip(64-range,64-range,range*2,range*2)
	map(0,0,-mapx,-mapy,128,64,2)
	pal()
	if player.equipment.torch > 0 then	
	local mr=32
	local r = sin(tick/30)+mr-1
	local r2 = sin(tick/30+0.03)*2+mr-8
	
	r*=r
	r2*=r2
	
	for y=-mr,mr do
		for x=-mr,mr do
			d=x*x+y*y
			if d < r2 then
				c=pget(x+64,y+64)
				if c==0 then
					c=2
				else
					c=0
				end
				pset(x+64,y+64,c)
			elseif d < r then
				c=pget(x+64,y+64)
				if c==0 then
					c=1
				else
					c=0
				end
				pset(x+64,y+64,c)
			end
		end
	end
	
	end
	
	setpal()
	map(0,0,-mapx,-mapy,128,64,1)
	pal()
	
	palt()

--	rectfill(0-mapx+8-64,0-mapy,128*8-mapx+64,0-mapy-64+8,p[3])
--	rectfill(0-mapx+8-64,64*8-mapy-8,128*8-mapx+64,64*8-mapy+64-8,p[3])
--	rectfill(0-mapx+8-64,0-mapy,-mapx+8,64*8-mapy-8,p[3])
-- rectfill(0-mapx-8+128*8,0-mapy,-mapx-8+128*8+64,64*8-mapy-8,p[3])

 color(p[3])
	rectfill(-56-mapx,0-mapy,1088-mapx,-mapy-56)
	rectfill(-56-mapx,504-mapy,960-mapx,568-mapy)
	rectfill(-56-mapx,-mapy,8-mapx,504-mapy)
	rectfill(1016-mapx,-mapy,1080-mapx,504-mapy)
	
--	pal()

	
	if player.object != nil then
		
	local fsh=player.dropctr > 0 and player.dropctr % 2 == 0
	--line(player.x-mapx, player.y-mapy,
	--	player.object.x-mapx, player.object.y-mapy)
	
	for i=0,ropelen do
		local c = 3
		if i%2 == 0 then
			c = 11
		end
		if fsh then
			c = 7
		end
		
		
		if i == 0 then
 		line(player.x-mapx, player.y-mapy,
 		rope[1].x-mapx, rope[1].y-mapy,c)
		elseif i==ropelen then
			line(rope[ropelen].x-mapx, rope[ropelen].y-mapy,
		 player.object.x-mapx, player.object.y-mapy,c)
		else
 		line(rope[i].x-mapx, rope[i].y-mapy,
 			rope[i+1].x-mapx, rope[i+1].y-mapy,c)
		end
	end

	
	end
	
	if player.halt > 0 and tick % 2 == 0 then
		for i=0,15 do
			pal(i,7)
		end
	end
	
	spr(1,player.x-4-mapx,player.y-4-mapy,1,1,plrleftright,player.dead)
	pal()
	
	if player.halt <= 0 and not player.dead then
	if btn(2) then
		spr(23+tick%2,player.x-5-mapx,player.y+4-mapy)
	end
	
	if btn(3) then
		spr(23+tick%2,player.x-5-mapx,player.y-12-mapy,1,1,false,true)
	end
	
	if btn(0) then
		spr(25+tick%2,player.x-mapx+4,player.y-4-mapy)
	end
	
	if btn(1) then
		spr(25+tick%2,player.x-4-mapx-8,player.y-4-mapy,1,1,true)
	end
	end
	
	for o in all(objects) do
		if o.x > mapx - 16 and o.y > mapy - 16 then
			if o.type >= o_obj0 and o.type <= o_obj2 then
				spr(o.type - o_obj0 + 3, o.x-4-mapx,o.y-4-mapy)
			elseif o.type == o_objn then
				if o.seen then
					spr(2, o.x-4-mapx,o.y-4-mapy)
				end
			else
				spr(35,o.x-4-mapx,o.y-4-mapy)
			end
		end
	end
	
	
	for h in all(exits) do
		if h.x > mapx - 16 and h.y > mapy - 16 then
		spr(16+flr(tick) % 7, h.x-mapx, h.y-mapy)
		spr(16+flr(tick+2) % 7, h.x+8-mapx, h.y-mapy, 1, 1, true)
		spr(16+flr(tick+4) % 7, h.x-mapx, h.y+8-mapy, 1, 1, false, true)
		spr(16+flr(tick+6) % 7, h.x+8-mapx, h.y+8-mapy, 1, 1, true, true)
		spr(10,h.x-mapx,h.y+4-mapy,2,1)
		end
	end
	
	
	for h in all(holes) do
		if h.x > mapx-16 and h.x > mapx-16 then
		spr(16+flr(tick) % 7, h.x-mapx, h.y-mapy, 1,1)
		spr(16+flr(tick+2) % 7, h.x+8-mapx, h.y-mapy, 1, 1, true, false)
		spr(16+flr(tick+4) % 7, h.x-mapx, h.y+8-mapy, 1, 1, false, true)
		spr(16+flr(tick+6) % 7, h.x+8-mapx, h.y+8-mapy, 1, 1, true, true)
		spr(6+h.mult-1,h.x-mapx,h.y-mapy+4)	
		spr(9,h.x-mapx+8,h.y-mapy+4)	
		end
	end
	
	drawparts()
	drawmoneys()
	
	clip()
	
	--[[for e=0,penumbra,2 do
		line(64-range+e,0,64-range+e,127)
		line(64+range-e,0,64+range-e,127)
		line(0,64-range+e,127,64-range+e)
		line(0,64+range-e,127,64+range-e)
	end--]]
	
	if player.equipment.compass > 0 then
		drawcompass()
	end
	ty=0
	ps=player.scan
	if player.equipment.sonar > 0 then
		if ps > 0 and ps <96 then
			for i=0,3,1 do
--				color(scan_coltab[i+1])
				circ(player.x-mapx,player.y-mapy,ps-i*4,scan_coltab[i+1])
			end
		end
		drawradars()
		text("— to sonar", 84,0, ps>0 and ps<128 and tick%4<2 and 12 or 13, 0)
		ty+=7
	end
	
	if (player.object) text("Ž to drop", 88, ty, btn(4) and tick%4<2 and 8 or 2, 0)
	
	local rc = 12
	local rt=7
	if (player.oxygen / (30*player.oxydep) < 10) and tick % 8 < 4 then
		rc = 8
		rt = 8
	end
	
--	rectfill(1,123,1+player.oxygen/(player.maxoxy)*100,126,0)
	rectfill(1,123,1+player.oxygen/(player.maxoxy)*100,125,rc)
	text(flr(player.oxygen/(30*60*player.oxydep))..
	":"..pad(flr(player.oxygen/(30*player.oxydep)) % 60), 112, 122, rt)

	--color(10)	
	--cursor(0,0)
	--print(stat(1))
	
	else
	y=player.deathctr*2-240
--	if (y >= 128) y=127-(y-128)
	if (y >= 128) y=255-y
	line(0,y,127,y,0)
	
	end
	
	if player.dead and player.deathctr >= 120 then
		z=min(1,(player.deathctr-120)/60)
		if (z > 0)	drawpb(g_skull,z)
--		txt="game over"
--		text(txt,64-#txt*2,64-24,8,nil)
  print("game over",46,40,8)
  text("survived for "..flr((week-1)*5+(level-1)/2).." days",64,102,2,0,true)
		text("Ž continue",42,110,3,0)
	end
	
	text("$"..player.money,64,0,10,0,true)
	
end

__gfx__
000000000047a9400000000000000000000e800000a7a9000000002700047779000c7779000000000e99994a99999b00000aa000492442940000000a49244444
00000000009ac7c0000700000007a00000e788000a77aa90002cd27a2cd7a1aa26c7a0aa2cc66620288a88288888882000999900049229400000009904924444
007007000099c7c00077d0000077ba000e778880a777aaa900d7d7aad7d014aad7c011aad67776d0d777a82a4888822009411490004994000000094100492444
0007700007d99990077fed000777bba0e77788887777aaa900dc209adcd24aa2d6cd27a1d61116d0d7777a892980822099122199000440000000991200049244
00077000086d52000d11cc000b33cc30eee822249999222400dcd2aadcd27a1dd6c220aad63b36d0d777a8892980822049244294000000000000492400004924
00700700066265d000d1c00000b3c3000eee22404a992224002cd2aa2cd7a1dc26d771aa266a6c20288a88002889822004922940000000000000049200000492
0000000000055500000d0000000b300000ee240004a92240002dd2a72d27aaa70019aa912ddddd202888882e8888828000499400000000000000004900000049
0000000000c0c0000000000000000000000e400000494400000010010010111100000111000000000244440dddddd20000044000000000000000000400000004
d00100110000000000000000001100000000000000000000000c0000000888000000800000000000000000000000000000000000492442940000000a49244444
000c00110d0010000000000000110000000000000000000000000000008777800009790000000000000000000000000000000000049229400000009904924444
000000000000c01100c0d0000000000000011000000000000000000000a777a0000aaa0008a98000000000000000000000000000004994000000094100492444
00000000000000110000e000000c0d00000110000000000000000000009aaa900009a900877aa80009a980000000000000000000000440000000991200049244
00000000000000000000001100000e0000007d000000dd0000000000008aaa8000089800877aa99087aa980000000000000aa000000aa000000a9124000a9144
0000000000000000c00000111c00000001c00e000000d7d000000dd00008980000008000877aa80009a980000000000000999900009999000099124400991244
00001c0000000000000000000000001100000000001c00e00001cd7d000090000000000008a98000000000000000000009411490094114900941244409412444
00000000000001c00000001c0000001100000000000000000000000e000000000000000000000000000000000000000099122199991221999912444499124444
000000000000000000000000c77c0000bbbbbbbb0000000000000000bbbbbbbb44444444444444440000000000000000a000000044444294a000000a44444444
00999d00000000000000000070279940bbbbbc330888000000000888bbbb333c444441144411444400000c000000000099000000444429409900009944444444
0229991000024d00000000007447977cbbbb3cbb0888800000008888bbb3ccca44444224412224440000ccc00000000014900000444294001490094144422444
0442d42000044200000c000074474447bbbccbba0288880000088888bbb3cccb444449944222244400000c0000cc000021990000442940002199991244299244
04421110000000000000000072474974bbb3bcba0028888000888882bb3b3ccb4444444444229444000000000cccc00042940000429400004294492442944924
011111000000000000000000c7794722bbb3bcba0002888808888820b3bc3ccb4774444444994444000000000cccc00029400000294000002940049229400492
00110000000000000000000002222777bbb3c3cb0000288888888200b3cc3ccb46644444444444440000000000cc000094000000940000009400004994000049
00000000000000000000000000222220bbb3bcba0000028888882000b5555ccb4224444444444444000000000000000040000000400000004000000440000004
000ba000000000000000000000000000bbb3bcba0000008888820000bbb5333c444444444444444400000000000ccc00a000000044444294a000000a44444444
00003b00000000000000000000c77c00bbb3bcba0000088888800000bb5ca3ba444444444dd4444400c0000000c000c099000000444429409900009944444444
000003a000000000000770000cc00cc0bbb3bcba0000e88828880000bb5cb3ba444444444dd444440c0c00000c00000c14900000444294001490094144444444
0003ab30000770000070070007000070bbb3cbcb000e888202888000bb5cb3ba44d777444224444400c000000c00000c2199000044294000219aa91244444444
003b3000000770000070070007000070bbbc5cbb0008882000288800bb5cb3cb447666444444444400000cc00c00000c4219a0004419a0004219912444444444
03a0000000000000000770000cc00cc0bbbbc5550088820000028880bbb5cc3c44666d444444d4440000c00c00c000c044219900442199004421124444444444
3b300000000000000000000000c77c00bbbbbbbb0088200000002880bbbb555544222244444424440000c00c000ccc0044421490444214904442244444444444
03b00000000000000000000000000000bbbbbbbb0022000000000220bbbbbbbb444444444444444400000cc00000000044442199444421994444444444444444
44444444912444444444421991244219bbbbbbbbbbbbbbbb0000700000000000bbbbbbbbbbbbbbbbbbbbbbbdd2bbbbdccc666677000000000000000000000000
44444444124444444444442112444421bbb333bbbbbbbbbb00072aaaaaaa7000bbbb3333bbbbbbbbbbbbbb267c2bbdccccc6667700000000009aaa9009aaa900
44444444244444444444444224444442bb3abc3bbbb333330072d2111111a000bbb3bbbbbbbbbcccbbbbbb2776c22cccccc677770000000000ae4ea00a4a4a00
44444444444444444444444444444444b3bb333bbb3aacaa072d7dcdcd7da000bb3bb333bbbbcaaabbbbbbb0dc7dccccc677cd000000000000a4a4a00aa4aa00
44444444444444444444444444444444b5c3cbc3bb5baaaa03ad2d1d1d2da000bb3b3ba3bbbcaaaabbbbbbbb0ddd7cdc76d000000000000000ae4ea00a4a4a00
44444444444444444444444444444444b5c3baaabb5cbbbb003adaaaaaaa7000bb3bcaa3bb3caaaabbbbbbbbb12ccdc7d000000000000000009aaa9009aaa900
44444444444444444444444444444444b5c3bbaabb5cbc550003723333333000bb3bcaabbb3bccccbbbbbbbb1ddddd7d000000000000000003bbbbbbbbbbbb30
44444444444444444444444444444444bb35cbbbb5b3b53b0000310110000000bb3bcbaabb3cbbaabbbbbbbb1dddd6c000000000000000003bbbbbbbbbbbbbb3
44444444912444444444421991244219bbbb5cbbb5b3b53b0000000220000000bb3bbcccbbb55333bbbbbbb1ddddc7000000000000000000bbbbbbbbbbbbbbbb
44444444124444444444442112444421bbbb5cccb5c3b5330000000220000000bb5abbbbbbb5ccbbbbbbbbb1dddd7d000000000000000000bbb1111111111bbb
44444444244444444444444224444442bb3333ccbb5cbc330000000d10000000bb5caaaabbb5cb3cbbbbbbb12ddc70000000000000000000bbbbbbbbbbbbbbbb
44444444444444444444444444444444b5cbc33cbb5cbbaa000029a844500000bb5ccccbbbb5cb3bbbbbbb122226c0000000000000000000bbbbbbbbbbbbbbbb
44444444444444444444444444444444b5b3b555bb5cc5cc0005999d44410000bbb5cccbbbb5cb3bbbbbbb12222750000000000000000000cbbbbbbbbbbbbbbc
44444444444444444444444444444444b5cbc5bbbbc555550049999dddd51000bbbb5555bbbb5555bbbbbb011117000000000000000000005cbbbbbbbbbbbbc5
24444444244444442444444424444444bb555bbbbbbbbbbb0d9999dcddddd200bbbbbbbbbbbbbbbbbbbbbb0cddd7000000000000000000000533333333333350
92444444924444449244444492444444bbbbbbbbbbbbbbbb99999d44bcdddd20bbbbbbbbbbbbbbbbbbbbbb022227000000000000000000000000000000000000
44444444912444444444421991244219255555555555552044444444d21144422888888888888820bbbbbb022227200000000000bbbbbabb0000000000010000
44444444124444444444442112444421555555555555555044444444d11294448888888888888880bbbbbb022126d00000000000bbbbbccc00020100010d0100
44444444244444444444444224444442555555555555555044444444d21d94448887787778777880bbbbbbb01d0c600000000000babb3cba001c1000002c2000
44444444444444444444444444444444555555555555555024444444499944428878887878878880bbbbbbb01d01600000000000bbaa333c02c7c2001dc7cd10
44444444444444444444444444444444555555555555555011111244444442228877787878878880bbbbbbb01001dc0000000000bbbab3bb001c1000002c2000
44444444444444444444444444444444555555555555555011112224444212208888787778878880bbbbbbbb0111160000000000aaaabcba01020000010d0100
44444442444444424444444244444442555555555555555001122224442122108877887878878880bbbbbbbb0111116000000000baaacbaa0000000000010000
44444429444444294444442944444429555555555555555000012214421122008888888888888880bbbbbbbbb011110620000000bbacbbaa0000000000000000
44444444912444444444421991244219777777777777777011111111111111117777777777777770bbbbbbbbbb011000cd100000bbbcbbba0000000001110000
44444444124444444444442112444421777777777777777011111111111111117777777777777770bbbbbbbbbb01000002cdd100babccccb0000000011111000
44444444244444444444444224444442777777777777777011111111111111117777777777777770bbbbbbbbbbb000000001dcccbbb3cccb0000000011111000
44444444444444444444444444444444777777777777777011111111111111117777777777777770bbbbbbbbbbbb000000000000bba3cccb0000000011111000
44444444444444444444444444444444777777777777777011111111111111117777777777777770bbbbbbbbbbbbbb0000000000baa3bbba0000000001110000
44444444444444444444444444444444777777777777777011111111111111117777777777777770bbbbbbbbbbbbbbb000000000aaa3abba0000000000000000
24444442244444422444444224444442777777777777777011111111111111117777777777777770bbbbbbbbbbbbbbbbb0000000bbbc55550000000000000000
92444429924444299244442992444429d7777777777777d01111111111111111d7777777777777d0bbbbbbbbbbbbbbbbbbbb0000bbbbbbba0000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb07aaaaaaaaaaaaaaa0b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0a88888888888888890b
bbbbbbbbb000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0a888888888888888910b
bbbbbbbb07777777770bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0a8888888888888889110b
bbbbbbb07ddddddd710bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0a88888888888888891110b
bbbbbb07dcccccc7110bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0a888888888888888911110b
bbbbb07dcccccc71110bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0a888888888888888911110bb
bbbb07dcccccc71110bbbbbbbbbbbbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000bbbbbbbbbbbbbbb0a888888899999988911110bbb
bbb07dcccccc71110bb00000000000bb07777770bbb00000000000b00000000000b0000bbb0000bb07777770bbb0000b0000000988888889111a88911110bbbb
bb07dcccccc71110bb0777777777770b07ddddd70b077777777777077777777777077770b077770b07ddddd70b077770777777019888888891a88911110bbbbb
b07dcccccc71110bbb07ddddddddd700017ccccd7007ddddddddd707ddddddddd707ddd707ddd700017ccccd7007ddd77dddd701198888888a88911110bbbbbb
b07ccccccc7110bbbb07ccccccccc7077777ccccd707ccccccccc707ccccccccc707cccd7dccc7077777ccccd707cccd7cccc70111988888888911110bbbbbbb
b017ccccccd70bbbbb07ccccccccc707ddddccccc707ccccccccc707ccccccccc707ccccdcccc707ddddccccc707ccccdcccc7011119888888891110bbbbbbbb
b0117ccccccd70bbbb07ccccccccc707ccccccccc707ccccccccc707cccc77ccc707ccccccccc707ccccccccc707ccccccccc700111198888888910bbbbbbbbb
b01117ccccccd70bbb07cccc77ccc707cccc77ccc707cccccc777707ccccddccc707ccccccccc707cccc77ccc707ccccccccc70b011119888888890bbbbbbbbb
bb01117ccccccd70bb07ccccddccc707ccccddccc707ccccccddd707ccccccccc707ccccccccc707ccccddccc707ccccccccc70bb0111a8888888890bbbbbbbb
bbb01117ccccccd70b07ccccccccc707ccccccccc707ccccccccc707ccccc7777707ccccccccc707ccccccccc707cccc7cccc70bbb01a889888888890bbbbbbb
bbbb01117ccccccd7007ccccccccc707ccccccccc707ccccccccc7017ccccd711107ccccccccc707ccccccccc707cccc77ccc70bbb0a88919888888890bbbbbb
bbbbb01117ccccccd707cccc7777770777777777770777777777770117ccccd71107777ccc77770777777777770777777177770bb0a9991119999999990bbbbb
bbbbbb01177777777707cccc712222022222222222022222222222011177777711022257c712220222222222220222222122220b0a889aaaa7888888890bbbbb
bbbbbbb07ccccccc7107cccc71222202222222222202222222222200112222220002225571122202222222222202222221222200a999999999999999910bbbbb
bbbbbb0777777777110777777122220222222222220222222222220b012222220b0222552112220222222222220222222022220a8888888888888889110bbbbb
bbbbb07ccccccc7111022222200000b00000000000b00000000000bbb02222220bb00005210000b00000000000b000000b0000a99999999999999991110bbbbb
bbbb0777777777111002222220bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000bbbbbbb020bbbbbbbbbbbbbbbbbbbbbbbbbb0a999999999999999911110bbbbb
bbb07777777771110b02222220bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbb0a999999999999999911110bbbbbb
bb07777777771110bbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0a999999999999999911110bbbbbbb
b07777777771110bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0999999999999999911110bbbbbbbb
b0222222222110bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb022222222222222221110bbbbbbbbb
b022222222210bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb02222222222222222110bbbbbbbbbb
b02222222220bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0222222222222222210bbbbbbbbbbb
bb000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb022222222222222220bbbbbbbbbbbb
11101110111110111010010000100001111010010000000000011111101111111010000100155221000000000111101110111011111001111001111101010101
10101010101010100010010001000010001010010000000000010000001000001010000102552222210000000100001010101010000101000100010001010101
00101010101010101010001111082010010010010049777a94001111101111111011111002210022255555100111101010100011111001111100010000000001
00101010101010111010820001088010100010100977777aaa900100000000000000000000000001255555210000101110101010000101000001010001010100
00101010000000001010282011028011008010104a77a94004a40101110101110001255555210000000012220110101000101000000000100001010000000001
0010101004999e40000000800000800008201100aaaaa00049aa0101010101001015555555522000000002220100101010110049999940011110000111111100
010011004aaa77a9001000020000200020000001aaaaaaaaaaaa0001010101001025555555522200000002220100101110100499999994000000011111111110
10001104a940077ae000000000001000100000339aaaaaaaaaa9100101010100102221000011221000001221010100000000099999999900000011dc31111110
100000094000077a9405500000000000000003cc599aaaaaaa9e20010101011100222000000012200001221001100221000009959595990011011dccc1111110
1000010a0049aaaa9e13352bc2000000000053cc35999999999250010101000000122000000002222254444200000222200109999999990101011cccc1111110
1001110aaaaaaaaa9e13332cc52533521001333bc34e99999e2551000101000155222000000012252444444420000000000004999999940111011cccd1111110
11100009aaaaaaa99e4c33233523333335223333cc3444444255520001010015555210000012445244467644420000000000004999994000000113c201222110
000000049aaaaa99ecbb33112225cc33cb3523333333ee9999999e400011002210000000024444552163376442200d77d0000299442000110101100002222100
002200014999999ecbac3512c3525c33cc33523333e9ffff999999ee000000222200000014421125542337724252273360004420000001000000100012222001
00222005334333cbbbcc315533d335c355335524e99fffff94224e9e40111001520011004421d252544266624252263360000000100000002444111112210001
000012033cccccccccc311555ddc53533333244e999999e444e8024ee0010000000101014510e44254442d145252446620000000000244244444411111000101
020000053ccccccc335111115133333553324e9e999ee4488866044ee0010100101001024206e442554442442545244551244100012442444444442112010101
0004ee425533333524e9fffffe22222244e9e9e9eee400dd0466044ee00101111011110241178445255525454444225525444212124442444444444222010111
0009ff99e4442224e99fffffff99e44eeeeeeeee44d0006606d024ee40010100101000044d701544225555555221122254444555244444444424444244001100
0009ff99eeeeeee999e422224e999eeeee444442066000000d824eee10000000001110044d616e54452252522544445254445522444444444444444244000001
000e9421244eeeeee4202ddd0024eeee428ee88200000d60084eeee100000b10c0000104410d7712444444444444444452222254444444244444444444010001
0004e9442200dddd00000d6600dd00dd028dd200d6d0066d2eeeee1000000cb2c1b000044528608e811225444452002444444444442444444244424444011111
00004eee4420066000660000000000000006660d66682224eeeee111000003bbb5c000024458e06610000000dd00000244444444444244444444444442010001
000004eeee442000028e8066d066d006d0066d066ee884eeeee40112200001cbbb30000054444200177006600000000000dd0000dd0000002224444200000000
00000014eeeeeeee422008e668e6608660000008888eeeeee41111122100003bbc200000024444452d6254452012882000000000660000000000ddd001110111
00000001244eeeeeeeeeee4288ee82222244eeeeeeeeee42100111122210023355100082010254444444444444522ee8200dd002760dd0000000d76010010101
015551000001244eeeeeeeeee4222224eeeeeeee422110011111153522511333520001888211112444444444444528ee85444444522520001000066010010101
0552550000000000111224eeeeeefffeeeee44210001112444335533335533355000028889982101254452225545218885444444444452000510000010010101
055255000000000222222224eeeefffee4211001111112244433bc53333355550000088899888882200000000112218880124444444452000252000100010101
0255210000000002255222552221111100111111111112244333cc35333335100000011288888888800111010000008888100000124420011025001111100111
0012555522110004445533555222222111111111111555333333ccc3533333320001542212288888201001000001008e88801010000000101000010000000100
0000000000012004444443333222222111111151155553333333ccc3333333335154444422112882001110000100002888200101000100110010011111110111
__label__
444444444444444444444444449999990000111199999999aaaaaaaaaaaaaaaaaa99999999999999999999999000009999999900000000009994444444444444
44444444444444444444444449999990000111199999999aaaaaaaaaaaaaaaaaaaa9999999999999999999999900009999999900000000009999444444444444
4444444444444444444444449999990000011199999999aaaaaaaaaaaaaaaaaaaaaa999999999999999999999990009999999900000000000999944444444444
4444444444444444444449999999900000111999999999aaaaaaaaaaaaaaaaaaaaaa999999999999999999999999009999999900000000000999994444444444
444444444999999999999999999900000111999999999aaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999909999999900000000000099999444444444
444444444999999999999999990000000111999999999aaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999909999999900000000000009999944444444
444444444999999999999999000000001119999999999aaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999999900000000000009999994444444
444444444999999999999900000000011199999999999aaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999999900000000000000999999444444
444444444990000000000000000001111999999999999aaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999999900000000000000099999994444
4444444449900000000000000000111119999999999999aaaaaaaaaaaaaaaaaaaaaa999999999999999999999999999999999900000000000000001999999994
4444444449900000000000000011111199999999999999aaaaaaaaaaaaaaaaaaaaaa999999999999999999999999999999999900000000000000011199999999
44444444499000000000000011111111999999999999999aaaaaaaaaaaaaaaaaaaa9999999999999999999999999999999999900000000000000111100999999
444444444990000000000111111111199999999999999999aaaaaaaaaaaaaaaaaa99999999999999999999999999999999999900000000000001111000009999
4444444449900000011111111111111999999999999999999aaaaaaaaaaaaaaaa999999999999999999999999999999999999900000000000111110000000009
444444444990000001111111111111999999999999999999999aaaaaaaaaaaa99999999999999999999999999999999999999900000000011111000000000000
44444444499000000111111111111199999999999999999999999999999999999999999999999999999999999999999999999000000001111110000000000000
44444444499000000111111111111199999999999999999999999999999999999999999999999999999999999999999999990000011111111000000000000000
44444444499000000111111111111ccccccccccccccccccccc7777777cccccccccccccccccc99999999999999999999999991111111111000000000000000000
44444444499000000111111111111ccccccccccccccccccc77777777777cccccccccccccccccc999999999999999999999991111110000000000000000000000
44444444499000000111111111111cccccccccccccccccc7777777777777ccccccccccdddcccccc9999999999999999999990000000000000000000000000000
44444444999000000111111111111cccccccccccccccc77777777777777777cccccccdddddccccccc99999999999999999990000000000000000000000000000
44444444999000000111111111111cccccccccccccccc77777777777777777cccccccdddddcccccccc9999999999999999888880000000000000000000000000
44444444990000000111111111111ccccccccccccccc7777777777777777777ccccccdddddccccccccc999999999999998888888000000000000000000000000
44444449990000000111111111111cccccccccccccc777777777777777777777cccccdddddcccccccccc99999999999988888888800000000000000000000000
44444449990000000111111111111cccccccccccccc777777777777777777777cccccdddddccccccccccc9999999999888888888880000000000000000000000
44444499900000000111111111111ccccccccccccc77777777777777777777777ccccdddddccccccccccc9999999999888888888880000000000000000000000
44444499900000001111111111111ccccccccccccc77777777777777777777777ccccdddddcccccccccccc999999999888888888888000000000000000000000
44444999000000001111111111111ccccccccccccc77777777777777777777777ccccdddddcccccccccccc999999999888888888888000000000000000000000
44449999000000001111111111111ccccccccccccc777777777777777777777777cccdddddccccccccccccc99999999888888888888000000000000000000000
44449990000000011111111111111ccccccccccccc777777777777777777777777cccdddddccccccccccccc99999999888888888888000000000000000111110
44499900000000011111111111111ccccccccccccc777777777777777777777777cccdddddcccccccccccccc9999999888888888888000000000000011111111
44999900000000111111111111111ccccccccccccc777777777777777777777777cccdddddcccccccccccccc9999999888888888888000000000000111111111
99999000000000111111111111111cccccc111cccc777777777777777777777777cccdddd111cccccccccccc9999999888888888888000000000001111000001
99990000000001111111111111111ccccc11111ccc777777777777777777777777cccddd11111ccccccccccc9999999888888888888000000000011110000000
99000000000011111111111111111ccccc11111ccc777777777777777777777777cccddd11111ccccccccccc9999999888888888888000000000011100000000
90000000000011111111111111111ccccc11111ccc777777777777777777777777cccddd11111ccccccccccc9999999888888888888000000000111000000000
00000000000111111111111111111ccccc11111ccc777777777777777777777777cccddd11111ccccccccccc9999999888888888888000000000111000000000
00000000002221111111111111111ccccc11111ccc777777777777777777777777cccddd11111ccccccccccc9999999888888888888000000000111000000000
00000000002222111111111111111ccccc11111ccc777777777777777777777777cccddd11111ccccccccccc9999999888888888888000000000111000000000
00000000000222222111111111111ccccc11111ccc777777777777777777777777cccddd11111cccccccccca9999999888888888880000000000111000000000
00000000000002222222111111111ccccc11111ccc777777777777777777777777cccddd11111cccccccccca9999999888888888880000000000011100000000
00000000000000022222222222222ccccc11111ccc77777777777777777777777ccccddd11111ccccccccca99999999988888888800000000000011110000000
00000000000000000222222222222ccccc11111ccc77777777777777777777777ccccddd11111ccccccccca99999999998888888000000000000001111000001
00000000000000000000022222222ccccc11111ccc77777777777777777777777ccccddd11111cccccccca999999999999888880000000000000000111111111
00000000000000000000000000000cccccc111ccccc777777777777777777777cccccdddd111ccccccccca999999999999999000000000000000000011111111
00000000000000000000000000000cccccccccccccc777777777777777777777cccccdddddcccccccccca9999999999999999000000000000000000000111110
00000000000000000000000000000ccccccccccccccc7777777777777777777ccccccdddddcccccccccaa9999999999999999000000000000000000000000000
00000000000000000000000000000cccccccccccccccc77777777777777777cccccccdddddccccccccaa99999999999999999900000000000000000000000000
00000000000000000000000000000cccccccccccccccc77777777777777777cccccccdddddcccccccaa999999999999999999900000000000000000000000000
00000000000000000000000000000cccccccccccccccccc7777777777777ccccccccccdddccccccaaa9999999999999999999900000000000000000000000000
00000000000000000000000000000ccccccccccccccccccc77777777777ccccccccccccccccccaaaa99999999999999999999900000000000000000000000000
00000000000000000000000000000ccccccccccccccccccccc7777777ccccccccccccccccccaaaa9999999999999999999999900000000000000000000000000
00000000000000000000000000000ccccccccccccccccccccccccccccccccccccccccccaaaaaa999999999999999999999999900000000000000000000000000
0000000000000000000000000000099aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999900000000000000000000000000
0000000000000000000000000000009aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa999999999999999999999999999999000000000000000000000000000
00000000000000000000000000000099999999999999999aaaaaaaaaaaaaaaaaaa99999999999999999999999999999999999777000000000000000000000000
0000000000000000000000000000009999999999999999aaaaaaaaaaaaaaaaaaaaa9999999999999999999999999999999999777770000000000000000000000
000000000000000000000000000000099999999999999aaaaaaaaaaaaaaaaaaaaaaa999999999999999999999999999999997777777700000000000000000000
00000000000000000000000000000009999999999999aaaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999997777777777000000000000000000
00000000111111111000000000000000999999999999aaaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999966677777777700000000000000000
00000111111111111111000000000000099999999999aaaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999666666777777770000000000000000
00011111111111111111110000000000009999999999a000aaaaaaaaaaaaaaa222aaa99999999999999999999999999996666666667777777000000000000000
0011111111111111111111100000000000099999999900000aaaaaaaaaaaaa22222aa99999999999999999999999999966666666666777777700000000000000
0111111111111111111111110000000000009999999900000aaaaaaaaaaaaa22222a999999999999999999999999999266666666666777777700000000000000
1111111111bbbbbbb11111111000000000000099999900000aaaaaaaaaaaaa222229999999999999999999999999922266666666666677777770000000000000
1111111bbbbbbbbbbbbb11111100000000000000099900000aaaaaaaaaaaaa222229999999999999999999999922222666666666666677777770000000000000
111111bbbbbbbbbbbbbbb1111110000000000000000000000aaaaaaaaaaaaa222229999999999999999999922222222666666666666667777777000000000000
1111bbbbbbbbbbbbbbbbbbb111110000000000000000000000000002222222222222222222222222222222222222222666666666666667777777000000000000
111bbbbbbbbbbbbbbbbbbbbb1111100000000000000000000000000022222222222222222222222222222222222222d666666666666667777777700000000000
11bbbbb7777bbbbbbbbbbbbbb11110000000000000000000000000000222222222222222222222222222222222222ddd66666666666667777777700000000000
11bbbb777777bbbbbbbbbbbbb1111100000000000000000000000000d222222222222222222222222222222222222dddd6666666666667777777700000000000
1bbbb77777777abbbbbbbbbbbb111100000000000000000000000000dd2222222222222222222222222222222222ddddd6666666666667777777700000000000
bbbbb77777777aabbbbbbbbbbbb1110000000000000000000000000dddd22222222222222222222222222222222ddddddd666666666667777777770000000000
bbbbb77777777aaabbbbbbbbbbb1111000000000000000000000000dddddd2222222222222222222222222222ddddddddd666666666667777777770000000000
bbbbbb777777aaaaa3bbbbbbbbb111100000000000000000000000dddddddd22222222222222222222222222ddddddddddd66666666667777777770000000000
bbbbbba7777aaaaaa33bbbbbbbbb11100000000000000000000000ddddddddddd22222222222222222222dddddddddddddd66666666667888888880000000000
bbbbbbaa77aaaaaaaa33bbbbbbbb11100000000000000000000000dddddddddddddd22222222222222ddddddddddddddddd66666666668888888880000000000
bbbbbbaaaaaaaaaaa3333bbbbbbb11110000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddd66666666668888888880000000000
bbbbbbaaaaaaaaaaa3333bbbbbbb1110000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddddd6666666668888888880000000000
bbbbbbbaaaaaaaaa333333bbbbbb1110000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddddd6666666667888888880000000000
bbbbbbbbaaaaaaa333333bbbbbbb1110000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddddd6666666667777777770000000000
bbbbbbbbbaaaaa3333333bbbbbbb1110000000000000000000666dddddddddddddddddddddddddddd777777ddddddddddddd6666666667777777770000000000
bbbbbbbbbbb333333333bbbbbbb11100000000000000000066666ddddddddddddddddddddddddddd777777776ddddddddddd6666666667777777770000000000
bbbbbbbbbbbb3333333bbbbbbbb11100000000000000000666666dddddddddddddddddddddddddd77777777776dddddddddd6666666667777777770000000000
bbbbbbbbbbbbb33333bbbbbbbbb11100000000000000006666666ddddddddddddddddddddddddd77777777777765dddddddd6666666667777777770000000000
1bbbbbbbbbbbbbbbbbbbbbbbbb111000000000000000066666666dddddddddddddddddddddddd6777777777777665ddddddd6666666667777777770000000000
11bbbbbbbbbbbbbbbbbbbbbbb1111000000000000000066666666dddddddddddddddddddddddd67777777777776655dddddd6666666667777777700000000000
11bbbbbbbbbbbbbbbbbbbbbbb1110000000000000000666666666ddddddddddddddddddddddd6677777777777766655ddddd6666666667000000000000000000
111bbbbbbbbbbbbbbbbbbbbb11100000000000000000666666666ddddddddddddddddddddddd6677777777777766655ddddd66666666607aaaaaaaaaaaaaaa00
1111bbbbbbbbbbbbbbbbbbb111000000000000000000666666666ddddddddddddddddddddddd66677777777776666555dddd666666660a888888888888888900
111111bbb000000000bbb11110000000000000000000666666666ddddddddddddddddddddddd66667777777766666555dddd66666660a8888888888888889100
0111111b07777777770b111100000000000000000000666666666ddddddddddddddddddddddd66666777777666666555dddd6666660a88888888888888891100
001111107ddddddd7101111000000000000000000000666666666ddddddddddddddddddddddd66666667766666666555dddd666660a888888888888888911100
00011107dcccccc71101110000000000000000000000666666666ddddddddddddddddddddddd66666666666666666555dddd66660a8888888888888889111100
0000007dcccccc711101000000000000000000000000066666666dddddddddddddddddddddddd6666666666666665555dddd6660a88888888888888891111000
000007dcccccc7111000000000000000000000000000066666666dddddddddddddddddddddddd6666000000666665555dddd660a888888899999988911110000
00007dcccccc711100000000000000000777777000000000000000d00000000000d0000ddd000066077777706660000d0000000988888889111a889111100000
0007dcccccc71110000777777777770007ddddd700077777777777077777777777077770d077770607ddddd706077770777777019888888891a8891111000000
007dcccccc7111000007ddddddddd700017ccccd7007ddddddddd707ddddddddd707ddd707ddd700017ccccd7007ddd77dddd701198888888a88911110000000
007ccccccc7110000007ccccccccc7077777ccccd707ccccccccc707ccccccccc707cccd7dccc7077777ccccd707cccd7cccc701119888888889111100000000
0017ccccccd700000007ccccccccc707ddddccccc707ccccccccc707ccccccccc707ccccdcccc707ddddccccc707ccccdcccc701111988888889111000000000
00117ccccccd70000007ccccccccc707ccccccccc707ccccccccc707cccc77ccc707ccccccccc707ccccccccc707ccccccccc700111198888888910000000000
001117ccccccd7000007cccc77ccc707cccc77ccc707cccccc777707ccccddccc707ccccccccc707cccc77ccc707ccccccccc707011119888888890000000000
0001117ccccccd700007ccccddccc707ccccddccc707ccccccddd707ccccccccc707ccccccccc707ccccddccc707ccccccccc70000111a888888889000000000
00001117ccccccd70007ccccccccc707ccccccccc707ccccccccc707ccccc7777707ccccccccc707ccccccccc707cccc7cccc7000001a8898888888900000000
000001117ccccccd7007ccccccccc707ccccccccc707ccccccccc7017ccccd711107ccccccccc707ccccccccc707cccc77ccc700000a88919888888890000000
0000001117ccccccd707cccc7777770777777777770777777777770117ccccd71107777ccc77770777777777770777777177770000a999111999999999000000
00000001177777777707cccc712222022222222222022222222222011177777711022257c71222022222222222022222212222000a889aaaa788888889000000
000000007ccccccc7107cccc71222202222222222202222222222200112222220002225571122202222222222202222221222200a99999999999999991000000
0000000777777777110777777122220222222222220222222222220d012222220d0222552112220222222222220222222022220a888888888888888911000000
0000007ccccccc7111022222200000000000000000000000000000ddd02222220dd00005210000d00000000000d000000d0000a9999999999999999111000000
0000077777777711100222222000000000000000000000000ddddddddd000000ddddddd020dddddddddddddddddddddddddd0a99999999999999991111000000
0000777777777111000222222000000000000000000000000ddddddddddddddddddddddd0dddddddddddddddddddddddddd0a999999999999999911110000000
0007777777771110000000000000000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddddddd0a9999999999999999111100000000
0077777777711100000000000000000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddddddd099999999999999991111000000000
0022222222211000000000000000000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddddddd022222222222222221110000000000
0022222222210000000000000000000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddddddd022222222222222221100000000000
0022222222200000000000000000000000000000000000000ddddddddddddddddddd5550ddddddddd00ddddddddddddddd022222222222222221000000000000
0000000000000000000000000000000000000000000000000ddddddddddddddddddd555000000000000ddddddddddddddd022222222222222220000000000000
0000000000000000000000000000000000000000000000000ddddddddddddddddddd555500000000000ddddddddddddddd000000000000000000000000000000
00000000000000000000000000000000000000000000000000ddddddddddddddddd5555500000000000ddddddddddddddddddd55550000000000000000000000
00000000000000000000000000000000000000000000000000ddddddddddddddddd5555500000000000ddddddddddddddddddd55550000000000000000000000
000000000000000000000000000000000000000000000000000ddddddddddddddd55555500000000000ddddddddddddddddddd55550000000000000000000000
000000000000000000000000000000000000000000000000000ddddddddddddddd55555500000000000ddddddddddddddddddd55550000000000000000000000
0000000000000000000000000000000000000000000000000000ddddddddddddd5555555000000000000ddddddddddddddddd555550000000000000000000000
000000000000000000000000000000000000000000000000000000ddddddddd555555555000000000000ddddddddddddddddd555550000000000000000000000
00000000000000000000000000000000000000000000000000000000ddddd555555555500000000000000ddddddddddddddd5555550000000000000000000000
0000000000000000000000000000000000000000000000000000000055555555555555500000000000000ddddddddddddddd5555550000000000000000000000

__gff__
000000000000000000000000094121c10000000000000000000000026109a12100000000000000000101020201810941000000000000000001010202e101610909a1e161000000000000000000000000c12109a1000000000000000000000000810901e100000000000000000000000041c18109000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2503264141414148484861410e41414148484848484848484848484848484848484800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2744270000000043484844000000000000000000000000000000000000000048484848484848000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
353736000000000046471d000000000000000000000000000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4700000000000000462e402e0000000000000000000000000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4700000000000000464848000000000000000000000000000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4700004040000000432d44001e00000000000000000000000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
48420040400000002d00001e6100000000000000000000000000000000000000000000004848000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
484842000000000000001e610000000000000000000000000000000000480000000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4848470000000000000000000000000000000000484848484848484848000000000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4848470000000000000000000000000000000000484848480000000048000000000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4848470000000000004848000000000000000048484848000048480048484800000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000048480000000000004848000048004848484848484800000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000004800000000004848000000004848484800000000000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000004800000000000000484848484848480000000000000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000004800000000000000484848484848480000000000000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000004800000000000000484848484848000000000000000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000004848000000000000484848484848480000000000000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000000048480000000000484848480000484848480000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000000000484848484848484800000000004800484800000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000484848484848484848000048484800000000004800004800000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000480000000000000000004800004800000000004800004800000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000480000000000000000480000004848000000484800480000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000480000000000000048000000004848000000480000480000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000480000000000000048000000004800000048000000480000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000484848000000004848000000004800000048484848480000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000048484848484800000000000000000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000000000000000000000000000000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4848000000000000000000000000000000000000000000000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0048000000000000000000000000000000000000000000000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0048480000000000000000000000000000000000000000000000000000000000000000484848000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000484848484848484848000000000000000000000000000000000000000048484848480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000484848484848484848484848484848484848484800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000038070330702c0602a0502a0502a0402903029030290202901029010290103b0003b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b0702a060290602905029050290402904029030290202902029020290102901029010290102901000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000503710037100371003710016103f6103f6203f6203f6203f6203f6303f6303f6303f6303f6303f6303f6303f6303f6303f6303f6303f6303f6303f6303f6103f6103f6103f6103f6103f6103f6703f670
00030000107700b760057600575004750137400a740077400e7300a73007710057100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000176703e67007370046500365001640127300c7700a75008740107400b7200872006710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001337013320283703134028330313202831031310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000057100b7100f71013720173201c3202133028440304503945039440394003943039420000003942039420000003941039410000000000000000000000000000000000000000000000000000000000000
010200003764033650304602e4700000000000000002564022650204601d4701c470000000000000000000002d6202c6302b640124301143011440000000000000000000000d4200c4300c4400b4300a42000000
000500003811038120381100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900023613036130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003f0403f0203f0203f0103f0403f0203f0203f010010000200002000020000200002000020000200002000020000200002000010000000000000000000000000000000000000000000000000000000000
0108000018233182320033200332002320d002260020d0022a002090022f0032d0032c002080022d002080022e002273022f00226002250021500602006263022630226302263062730622302223022230222302
000400001263012610126003e6203e6203e6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000080061000615006120061200615006130061500614000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111001800172001750017233335333053333500645001730010033335000003333500170001750017033335000003333500645001030c0500a0520c0000c0500010000105001003330500000333050c6050c600
011000000c5750f57513575185751d552000001b55200000165521655200000165050c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c1730c070001700f07030636001700a050110500c1730f070001700f07030636001700a050001500c1730c070001700f07030636001700a050110500c1730f070001700f07030636001700a0500c173
01100000243550c35518355223550c35518355223551635524455184551b4550f455244550c455224551b455242550c25518255222550c25518255222551625524455184551b4550f455244550c455224551b455
011000002433222332183321833218332183321833218332183121831224433244332233222332273322733227332273322733227332273322733627336263322633226332263362733622332223322231222312
011000000070222302183021830218302183021830200714007120071200722007220073200732007420074200752007520076200762007520075200742007420073200732007220072200712007120071500702
011000001b5751f5751d5751f5751b552000002255200000275522755200000165050c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c5750f57513575185751d552000001b55200000165521655200000165050c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000c0540c0640c1540c0440c2340c0740c3440c0540c0540c0640c4440c0440c5340c0740c5640c0540a0540a0640a5540a0440a5340a0740a4440a0540f0540f0640f3440f0440f2340d0740d1640d054
012000001875518752185121d7521d5121d7121675516752165121b7521b5121b7121b7521975219512197121875518752185121d7521d5121d7121675516752165121b7521b5121b7121b7521b5121975219512
012000000c073000733501335013006161800000510000000c073000733501535015006161800000000000000c073000733501535015006161800005510000000c07300073350153501500616180000000000000
012000000c0540c0640c1540c0440c2340c0740c3440c0540c0540c0640c4440c0440c5340c0740c5640c0540c0540c0640c5540c0440c5340c0740c4440c0540c0540c0640c3440c0440c2340c0740c1640c054
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000c517185170c517185170c517185160c517185160c517185170c517185170c517185160c517185160c517185170c517185170c517185160c517185160c517185170c517185170c517185160c51718516
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
04 0a424344
03 11125444
01 54524314
02 5152431b
01 1a1c1459
00 1a1c1459
00 1718141c
02 1718141c
02 1a1c1444
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
00 11120b44
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

