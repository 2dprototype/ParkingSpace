-- v1.0.0 - 6.10.2022

local seed = 123
local rng = love.math.newRandomGenerator(seed)

local setColor
if love._version_major > 0 then
	function setColor(r, g, b, a)
		love.graphics.setColor(r/255, g/255, b/255, a and a/255)
	end
else
	setColor = love.graphics.setColor
end

local function drawFixture(fixture)
	local shape = fixture:getShape()
	local shapeType = shape:getType()
	-- if (fixture:isSensor()) then setColor(0,0,255,96) end
	if (shapeType == "circle") then
		local x,y = shape:getPoint()
		local radius = shape:getRadius()
		love.graphics.circle("fill",x,y,radius,15)
		love.graphics.circle("line",x,y,radius,15)
		love.graphics.line(x, y, x, radius)
	elseif (shapeType == "polygon") then
		local points = {shape:getPoints()}
		love.graphics.polygon("fill",points)
		love.graphics.polygon("line",points)
	elseif (shapeType == "edge") then
		love.graphics.line(shape:getPoints())
	elseif (shapeType == "chain") then
		love.graphics.line(shape:getPoints())
	end
end

local function drawBody(body)
     local bx,by = body:getPosition()
     local bodyAngle = body:getAngle()

     love.graphics.push()
     love.graphics.translate(bx,by)
     love.graphics.rotate(bodyAngle)

     rng:setSeed(seed)

     local fixtures = body.getFixtures and body:getFixtures() or body:getFixtureList()
     for i=1,#fixtures do
		  if( body:getType() == 'dynamic' ) 
		  then 
		  if(body:isAwake()) then setColor(229, 178, 178, 255/2)
		  else setColor(153, 153, 153, 255/2)
		  end
		  elseif( body:getType() == 'static' ) then setColor(127, 229, 127, 255/2)
		  elseif( body:getType() == 'kinematic' ) then setColor(127, 127, 229, 255/2)
		  end
          drawFixture(fixtures[i])
     end
     love.graphics.pop()
end

local drawnBodies = {}
local function b2debugDraw_scissor_callback(fixture)
	drawnBodies[fixture:getBody()] = true
	return true --search continues until false
end

local function b2debugDraw(world, topLeft_x, topLeft_y, width, height)
	love.graphics.push("all")
	drawnBodies = {}
	world:queryBoundingBox(topLeft_x, topLeft_y, topLeft_x + width, topLeft_y + height, b2debugDraw_scissor_callback)

	love.graphics.setLineWidth(0.1)
	for body in pairs(drawnBodies) do
		drawnBodies[body] = nil
		drawBody(body)
	end

	setColor(135, 206, 235, 255/2)
	love.graphics.setLineWidth(0.1)
	local joints = world.getJoints and world:getJoints() or world:getJointList()
	for i = 1, #joints do
		local joint = joints[i]
		local t = joint:getType()
		if(t =='revolute' or t == 'prismatic' or t == 'rope' or t == 'friction' or t == 'weld' or t == 'wheel' or t == 'gear') then
			local bodyA, bodyB = joint:getBodies()
			local xA, yA = bodyA:getPosition()
			local xB, yB = bodyB:getPosition()
			local x1, y1, x2, y2 = joint:getAnchors()
			love.graphics.line(xA, yA, x1, y1)
			love.graphics.line(x1, y1, x2, y2)
			love.graphics.line(x2, y2, xB, yB)
		end
		if(t =='distance' or t == 'motor' or t == 'mouse') then
			local x1, y1, x2, y2 = joint:getAnchors()
			love.graphics.line(x1, y1, x2, y2)
		end
		if(t =='pulley') then
			local x1, y1, x2, y2 = joint:getAnchors()
			local a1x, a1y, a2x, a2y = joint:getGroundAnchors( )
			
			love.graphics.line(x1, y1, a1x, a1y)
			love.graphics.line(a1x, a1y, a2x, a2y)
			love.graphics.line(a2x, a2y, x2, y2)
		end
	end

	setColor(255, 0, 0, 255/2)
	local contacts = world.getContacts and world:getContacts() or world:getContactList()
	for i = 1, #contacts do
		local x1,y1,x2,y2 = contacts[i]:getPositions()
		if (x1) then
			love.graphics.rectangle("fill", x1 - 1, y1 - 1, 3, 3)
		end
		if (x2) then
			love.graphics.rectangle("fill", x2 - 1, y2 - 1, 3, 3)
		end
	end
	love.graphics.pop()
end

return b2debugDraw