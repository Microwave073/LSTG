----东方寒月宫3面背景
----作者：火喵
LoadFX('fx:'..'VolumeCloud', 'THlib\\background\\hygbg3\\VolumeCloud.hlsl')
LoadFX('fx:'..'Ripple', 'THlib\\background\\hygbg3\\Ripple.hlsl')
stage_3_background=Class(object)
function stage_3_background:init()
	background.init(self,false)
	stage_1=self
	--rescore
	self.m=8
	LoadImageFromFile('stage_3_water','THlib\\background\\hygbg3\\stage_3_water.png')
	LoadImageFromFile('stage_3_cloud','THlib\\background\\hygbg3\\stage_3_cloud.png')
	LoadImageFromFile('stage_3_lightball','THlib\\background\\hygbg3\\stage_3_lightball.png')
	--
	self.z=5
	Set3D('eye',0,3,3+0.2)
	Set3D('at',0,0,3+3/tan(17.5))
	Set3D('up',0,1,10)
	Set3D('z',0.1,20)
	Set3D('fovy',0.7)
	Set3D('fog',0.1,20,Color(50,0,0,0))
	--
	self.t=6
end

function stage_3_background:frame()
	if self.z<-10 then
		self.z=10
	else
		self.z=self.z-0.05
	end
	self.t=self.t-0.05
	if self.timer%10==0 then  
		New(stage_3_lightball,ran:Float(-3,3),ran:Float(0,1),20+ran:Float(0,12))  
	end
end

function stage_3_background:render()
	SetViewMode'3d'
	RenderClear(lstg.view3d.fog[3])
	local showboss = IsValid(_boss)
	if showboss then
		CreateRenderTarget('stg3_bg')
        PushRenderTarget('stg3_bg')
		RenderClear(lstg.view3d.fog[3])
    end
	--水面波纹
	local x=5
	PostEffectCapture()
	for i=0,10 do
		SetImageState('stage_3_water','',Color(255,255,255,255))
		local z=self.z-10+i*10
		Render4V('stage_3_water',
				x,0,z+10,
				-x,0,z+10,
				-x,0,z,
				x,0,z
				)
		SetImageState('stage_3_water','mul+add',Color(255,255,255,255))
		Render4V('stage_3_water',
				x,0,z+10,
				-x,0,z+10,
				-x,0,z,
				x,0,z
				)
	end
	PostEffectApply("Ripple", "", {timer = self.timer,playerX = player.x})
	
	--体积云
	
	PostEffectCapture()
	
	for i=-1,6 do
		local z=self.z+i*10
		local y=z*tan(atan(3/10))
		Render4V('stage_3_cloud',
					x,3+y,z+10,
					-x,3+y,z+10,
					-x,0+y,z,
					x,0+y,z
					)
		SetImageState('stage_3_cloud','mul+add',Color(255,255,255,255))
		local z=self.z+i*10
		local y=z*tan(atan(1/10))
		local x=7.5
		Render4V('stage_3_cloud',
					x,1+y,z+10,
					-x,1+y,z+10,
					-x,0+y,z,
					x,0+y,z
					)
	end
	PostEffectApply("VolumeCloud", "", {timer = self.timer,_den=0.3;}) 
	--I'a I'a.Cthulhu Fhatgn!
		
		
	if showboss then
		PopRenderTarget('stg3_bg')
		local x,y = WorldToScreen(_boss.x,_boss.y)
		local x1 = x * screen.scale
		local y1 = (screen.height - y) * screen.scale
		local fxr = _boss.fxr or 163
		local fxg = _boss.fxg or 73
		local fxb = _boss.fxb or 164
		PostEffect('stg3_bg',"boss_distortion", "", {
			centerX = x1,
			centerY = y1,
			size = _boss.aura_alpha*200*lstg.scale_3d,
			color = Color(125,fxr,fxg,fxb),
			colorsize = _boss.aura_alpha*200*lstg.scale_3d,
			arg=1500*_boss.aura_alpha/128*lstg.scale_3d,
			timer = self.timer
        })
	end
	SetViewMode'world'
	--
end

--

stage_3_lightball=Class(object)
function stage_3_lightball:init(x,y,z)
	self.bound=false 	self.img='image:stage_3_lightball' 
	self.group=GROUP_GHOST
	self.x=x self.y=y 	self.z=z 
	self.lasttime=30	self.lifetime=7200
	self.omiga=ran:Float(-2,2)
	self.l=0.25*ran:Float(0.75,1.25) self.ts=ran:Float(0.8,3.2)
end
function stage_3_lightball:frame()
	if self.z<-1 then Del(self) end
	self.z=self.z-0.03
	if self.timer==self.lifetime+self.lasttime then Del(self) end
end
function stage_3_lightball:render()
	SetViewMode'3d'
	--
	local l=self.l*(1-0.5*sin(self.timer*self.ts))
	SetImageState(self.img,'mul+add',Color(200,255,255,255))
	Render4V(self.img,
			self.x+l*cos(self.omiga*self.timer)+l*cos(self.omiga*self.timer+90),
			self.y+l*sin(self.omiga*self.timer)+l*sin(self.omiga*self.timer+90),
			self.z,
			self.x+l*cos(self.omiga*self.timer)+l*cos(self.omiga*self.timer-90),
			self.y+l*sin(self.omiga*self.timer)+l*sin(self.omiga*self.timer-90),
			self.z,
			self.x+l*cos(self.omiga*self.timer+180)+l*cos(self.omiga*self.timer-90),
			self.y+l*sin(self.omiga*self.timer+180)+l*sin(self.omiga*self.timer-90),
			self.z,
			self.x+l*cos(self.omiga*self.timer+180)+l*cos(self.omiga*self.timer+90),
			self.y+l*sin(self.omiga*self.timer+180)+l*sin(self.omiga*self.timer+90),
			self.z
			)
	SetViewMode'world'
end