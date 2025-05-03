Rin_player = Class(player_class)

function Rin_player:init(slot)
	LoadTexture('Rin_player','THlib/player/rin/rin.png')
	LoadTexture('Rin_support','THlib/player/rin/support.png')
	LoadTexture('Rin_bullet_support','THlib/player/rin/bullet_support.png')
	LoadTexture('Rin_bullet','THlib/player/rin/bullet.png')

	LoadImageGroup('Rin_player','Rin_player',0,0,48,64,8,3,0.5,0.5)
	LoadImage('Rin_bullet_straight','Rin_bullet',36,6,28,5,28,5)
	LoadImage('Rin_bullet_support','Rin_bullet_support',0,0,17,12,17,12)
	LoadImage('Rin_bullet_spell','Rin_bullet',33,25,31,21,31,21)
	
	LoadImageGroup('Rin_support','Rin_support',0,0,18,18,3,1,0.5,0.5)
	for i=1,3 do
		SetImageState('Rin_support'..i,'mul+alpha',Color(0xFFFFFFFF))
	end
	
	LoadPS('bomb_ef','THlib/player/rin/Rin_Bomb.psi','parimg1',16,16)
	LoadPS('bullet_ef','THlib/player/rin/bullet_ef.psi','parimg2',16,16)
	LoadPS('bullet_ef2','THlib/player/rin/bullet_ef2.psi','parimg3',16,16)
	-----------------------------------------
	SetImageState('Rin_bullet_straight','',Color(0xFFFFFFFF))
	SetImageState('Rin_bullet_spell','',Color(0xFFFFFFFF))
	SetImageState('Rin_bullet_support','',Color(0xFFFFFFFF))
	-----------------------------------------
	player_class.init(self, slot)
	self.name='Rin'
	self.hspeed=4.5
	self.lspeed=2
	self.range=15
	self.dmgbonus=1
	self.imgs={}
	self.A=0.75 self.B=0.75
	for i=1,24 do self.imgs[i]='Rin_player'..i end
	self.death_protect=180
	self.support=0
	self.sp={}
	--子机位置表
	self.slist=
	{
		{nil,nil,nil,nil},
		{{0,-45,0,-40},nil,nil,nil},
		{{-20,-45,-10,-40},{20,-45,10,-40},nil,nil},
		{{-35,-15,-22,-25},{0,-45,0,-40},{35,-15,22,-25},nil},
		{{-35,-15,-22,-25},{-20,-45,-10,-40},{20,-45,10,-40},{35,-15,22,-25}},
		{{-35,-15,-60,-20},{-19,-40,-28,-45},{19,-40,28,-45},{35,-15,60,-20}},
	}
	self.anglelist=
	{
		{90,90,90,90},
		{90,90,90,90}, 
		{100,80,90,90}, 
		{110,90,70,90}, 
		{120,100,80,60},
		{85,90,95,100}, 
	}
	for i=1,4 do
		self.sp[i]={0,0,0}
	end
end

function Rin_player:shoot()
	if self.death>0 or self.nextshoot>0 then return end
	
	PlaySound('plst00',0.3,self.x/1024)
	self.nextshoot=4    --发射频率
	
	New(player_bullet_straight,'Rin_bullet_straight',self.x+10,self.y,20,90,2.5)
	New(player_bullet_straight,'Rin_bullet_straight',self.x-10,self.y,20,90,2.5)
	
	if self.support>0 then
		if self.timer%8<4 then
			for i=1,4 do
				if self.sp[i] and self.sp[i][3]>0.5 then
					if self.slow==1 then
						New(player_bullet_trail,'Rin_bullet_support',
							self.supportx+self.sp[i][1],
							self.supporty+self.sp[i][2],
							8,90,self.target,900,1.2)
					else

						for j=-4,4 do
							New(player_bullet_straight,'Rin_bullet_support',
								self.supportx+self.sp[i][1],
								self.supporty+self.sp[i][2],
								20,90+j*self.range*0.5,0.3)
						end
					end
				end
			end
		end
	end
end

function Rin_player:render()
	for i=1,4 do
		if self.sp[i] and self.sp[i][3]>0.5 then
			local frame = math.floor(self.timer/6) % 3 + 1
			Render('Rin_support'..frame,
				  self.supportx+self.sp[i][1],
				  self.supporty+self.sp[i][2])
		end
	end
	player_class.render(self)
end

----------------------------------符卡--------------------------------------
Rin_spell_bullet = Class(player_bullet_straight)

function Rin_spell_bullet:init(img,x,y,v,angle,dmg)
	player_bullet_straight.init(self,img,x,y,v,angle,dmg)
	self.killflag=true
end

function Rin_player:spell()
	PlaySound('nep00',0.8)
	PlaySound('slash',0.8)
	New(bullet_killer,self.x,self.y)
	
	--粒子效果
	New(Rin_bomb_ef,self.x,self.y)
	
	New(tasker,function()
		self.nextshoot=210 --禁射击
		for t=1,21 do 
			for i=1,36 do
				local angle = i*10
				New(Rin_spell_bullet,'Rin_bullet_spell',self.x,self.y,12,angle,0.8)
			end
			task.Wait(10) 
			New(bullet_killer,self.x,self.y) --消弹
		end
	end)
	
	self.nextspell=240
	self.protect=300
end

----------------------------------特效------------------------------------
Rin_bomb_ef = Class(object)

function Rin_bomb_ef:init(x,y)
	self.x=x
	self.y=y
	self.group=GROUP_GHOST
	self.layer=LAYER_PLAYER_BULLET+50
	self.img='bomb_ef'
	self.bound=false
end

function Rin_bomb_ef:frame()
	if self.timer==150 then 
		Kill(self)
	end
	self.x=player.x
	self.y=player.y
end

function Rin_bomb_ef:render()
	object.render(self)
end

function Rin_bomb_ef:kill()
	misc.KeepParticle(self)
end
--------------------------------------------------
Rin_bullet_ef = Class(object)

function Rin_bullet_ef:init(x, y, rot)
	self.x = x
	self.y = y
	self.rot = rot or 90
	self.img = 'bullet_ef'  
	self.layer = LAYER_PLAYER_BULLET + 50
	self.group = GROUP_GHOST
	ParticleFire(self)      
end

function Rin_bullet_ef:frame()
	if self.timer == 4 then
		ParticleStop(self) 
	end
	if self.timer == 15 then
		Del(self)
	end
end

function Rin_bullet_ef:kill()
	misc.KeepParticle(self)
end
-----------------------------------------
Rin_bullet_ef2 = Class(object)

function Rin_bullet_ef2:init(x, y, rot)
	self.x = x
	self.y = y
	self.rot = rot or 90
	self.img = 'bullet_ef2'  
	self.layer = LAYER_PLAYER_BULLET + 50
	self.group = GROUP_GHOST
	ParticleFire(self)      
end

function Rin_bullet_ef2:frame()
	if self.timer == 4 then
		ParticleStop(self) 
	end
	if self.timer == 15 then
		Del(self)
	end
end

function Rin_bullet_ef2:kill()
	misc.KeepParticle(self)
end
--------------------------------------------------------
function Rin_spell_bullet:kill()
	New(Rin_bullet_ef, self.x, self.y, self.rot)
end

function player_bullet_straight:kill()
	New(Rin_bullet_ef2, self.x, self.y, self.rot)
end

function player_bullet_trail:kill()
	New(Rin_bullet_ef, self.x, self.y, self.rot)
end

AddPlayerToPlayerList("Satsuki Rin", "Rin_player", "Rin")
