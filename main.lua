function love.load()
    -- Physics world setup
    love.physics.setMeter(64) -- 1 meter = 64 pixels
    world = love.physics.newWorld(0, 9.81 * 64, true)
    
    -- Game objects
    boundaries = {}
    PlayerX = {}
    box_i = {}
    particles = {}
    
    createBoundaries()
    createPlayer()
    createEnemies()
    createBoxes()
    createBalls()
    
    -- Enhanced Camera setup
    camera = {
        x = 0, 
        y = 0, 
        scale = 1,
        mode = "follow_player", -- Modes: "follow_player", "follow_enemy", "free_move"
        target = nil,
        freeMoveSpeed = 300,
        minScale = 0.1,
        maxScale = 3.0
    }
    
    -- Camera mode instructions
    cameraInstructions = {
        "F1: Follow Player",
        "F2: Follow Enemy", 
        "F3: Free Move",
        "Wheel or -/+: Zoom",
        "WASD: Free Move",
        "R: Reset Zoom"
    }
end

function love.update(dt)
    world:update(dt)
    updatePlayer(dt)
    updateEnemies(dt)
    updateParticles(dt)
    updateCamera(dt)
end

function love.draw()
    love.graphics.clear(0.15, 0.15, 0.15)
    love.graphics.push()
    
    -- Apply camera transform
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.scale(camera.scale)
    love.graphics.translate(-camera.x, -camera.y)
    
    -- Draw sun
    love.graphics.setColor(1, 0.97, 0.45) -- #fff873
    love.graphics.circle("fill", 0, 0, 12.5)
    
    -- Draw all objects
    for _, boundary in ipairs(boundaries) do
        drawBoundary(boundary)
    end
    
    for _, box in ipairs(box_i) do
        if box.type == "box" then
            drawBox(box)
        elseif box.type == "enemy" then
            drawEnemy(box)
        elseif box.type == "ball" then
            drawBall(box)
        end
    end
    
    drawPlayer(PlayerX[1])
    drawParticles()
    
    love.graphics.pop()
    
    -- Draw UI (not affected by camera)
    drawUI()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f1" then
        camera.mode = "follow_player"
        camera.target = nil
    elseif key == "f2" then
        camera.mode = "follow_enemy"
        camera.target = nil
    elseif key == "f3" then
        camera.mode = "free_move"
        camera.target = nil
    elseif key == "=" or key == "+" then
        camera.scale = math.min(camera.scale + 0.1, 5)
    elseif key == "-" or key == "_" then
        camera.scale = math.max(camera.scale - 0.1, 0.1)
    elseif key == "r" then
        camera.scale = 1.0  -- Reset zoom
    end
end

function love.wheelmoved(x, y)
    -- Zoom in/out with mouse wheel
    local zoomFactor = 1.1
    if y > 0 then
        -- Zoom in
        camera.scale = math.min(camera.scale * zoomFactor, camera.maxScale)
    elseif y < 0 then
        -- Zoom out
        camera.scale = math.max(camera.scale / zoomFactor, camera.minScale)
    end
end

function drawUI()
    love.graphics.setColor(1, 1, 1)
    
    -- Player position
    if PlayerX[1] then
        local px, py = PlayerX[1].body:getPosition()
        love.graphics.print("x: " .. math.floor(px), 10, 10)
        love.graphics.print("y: " .. math.floor(py), 10, 30)
    end
    
    -- Camera info
    love.graphics.print("Camera Mode: " .. camera.mode, 10, 60)
    love.graphics.print("Zoom: " .. string.format("%.2f", camera.scale), 10, 80)
    
    -- Instructions
    love.graphics.print("Camera Controls:", love.graphics.getWidth() - 200, 10)
    for i, instruction in ipairs(cameraInstructions) do
        love.graphics.print(instruction, love.graphics.getWidth() - 200, 30 + i * 20)
    end
    
    -- Target info if following enemy
    if camera.mode == "follow_enemy" and camera.target then
        local tx, ty = camera.target.body:getPosition()
        love.graphics.print("Tracking Enemy", 10, 100)
        love.graphics.print("Enemy Position: " .. math.floor(tx) .. ", " .. math.floor(ty), 10, 120)
    end
end

-- Enhanced Camera system
function updateCamera(dt)
    if camera.mode == "follow_player" and PlayerX[1] then
        -- Smooth follow player
        local targetX, targetY = PlayerX[1].body:getPosition()
        camera.x = camera.x + (targetX - camera.x) * 0.99
        camera.y = camera.y + (targetY - camera.y) * 0.99
        
    elseif camera.mode == "follow_enemy" then
        -- Follow first enemy
        local enemy = findFirstEnemy()
        if enemy then
            camera.target = enemy
            local targetX, targetY = enemy.body:getPosition()
            camera.x = camera.x + (targetX - camera.x) * 0.99
            camera.y = camera.y + (targetY - camera.y) * 0.99
        elseif PlayerX[1] then
            -- Fallback to player if no enemy
            local targetX, targetY = PlayerX[1].body:getPosition()
            camera.x = camera.x + (targetX - camera.x) * 0.99
            camera.y = camera.y + (targetY - camera.y) * 0.99
        end
        
    elseif camera.mode == "free_move" then
        -- Free movement with WASD
        local speed = camera.freeMoveSpeed * dt / camera.scale
        
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            camera.y = camera.y - speed
        end
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            camera.y = camera.y + speed
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            camera.x = camera.x - speed
        end
        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            camera.x = camera.x + speed
        end
    end
end

function findFirstEnemy()
    for _, obj in ipairs(box_i) do
        if obj.type == "enemy" then
            return obj
        end
    end
    return nil
end

-- -- Boundary creation and drawing
-- function createBoundaries()
    -- -- Floor
    -- table.insert(boundaries, createBoundary(320, 500, 600, 10, 0))
    -- table.insert(boundaries, createBoundary(-100, 350, 600, 10, 0.3))
    -- table.insert(boundaries, createBoundary(-485, 261, 200, 10, 0))
    -- table.insert(boundaries, createBoundary(-265, 589, 600, 10, -0.3))
    
    -- -- Additional platforms
    -- table.insert(boundaries, createBoundary(-700, 605, 300, 10, 0))
    -- table.insert(boundaries, createBoundary(-700, 678, 300, 10, 0))
    -- table.insert(boundaries, createBoundary(-1260, 820, 300, 10, 0))
    -- table.insert(boundaries, createBoundary(-1540, 825, 180, 10, 0))
    -- table.insert(boundaries, createBoundary(-1565, 1005, 250, 10, 0))
    -- table.insert(boundaries, createBoundary(-1300, 1005, 250, 10, 0))
    -- table.insert(boundaries, createBoundary(-1685, 905, 10, 200, 0))
    -- table.insert(boundaries, createBoundary(-980, 749, 300, 10, -0.5))
    -- table.insert(boundaries, createBoundary(-440, 620, 80, 5, 0.4))
    
    -- -- Box boundaries
    -- table.insert(box_i, createBoxObj(-800, 570, 5, 60, 0, 2, 0.2))
    -- table.insert(box_i, createBoxObj(-840, 570, 5, 60, 0, 2, 0.2))
    -- table.insert(box_i, createBoxObj(-820, 300, 65, 25, 0, 0.6, 0.2))
-- end

function createBoundaries()
    -- Floor
    table.insert(boundaries, createBoundary(320, 500, 600, 10, 0))
    table.insert(boundaries, createBoundary(-100, 350, 600, 10, 0.3))
    table.insert(boundaries, createBoundary(-485, 261, 200, 10, 0))
    table.insert(boundaries, createBoundary(-265, 589, 600, 10, -0.3))
    
    -- Additional platforms
    table.insert(boundaries, createBoundary(-700, 605, 300, 10, 0))
    table.insert(boundaries, createBoundary(-700, 678, 300, 10, 0))
    table.insert(boundaries, createBoundary(-1260, 820, 300, 10, 0))
    table.insert(boundaries, createBoundary(-1540, 825, 180, 10, 0))
    table.insert(boundaries, createBoundary(-1565, 1005, 250, 10, 0))
    table.insert(boundaries, createBoundary(-1300, 1005, 250, 10, 0))
    table.insert(boundaries, createBoundary(-1685, 905, 10, 200, 0))
    table.insert(boundaries, createBoundary(-980, 749, 300, 10, -0.5))
    table.insert(boundaries, createBoundary(-440, 620, 80, 5, 0.4))
    
    -- Box boundaries - Made larger and more
    table.insert(box_i, createBoxObj(-800, 570, 8, 80, 0, 2, 0.2))
    table.insert(box_i, createBoxObj(-840, 570, 8, 80, 0, 2, 0.2))
    table.insert(box_i, createBoxObj(-820, 300, 80, 30, 0, 0.6, 0.2))
    

    -- Platform boxes
    table.insert(box_i, createBoxObj(-600, 400, 60, 20, 0, 1.0, 0.3))
    table.insert(box_i, createBoxObj(-500, 380, 40, 25, 0.2, 1.2, 0.4))
    table.insert(box_i, createBoxObj(-400, 350, 70, 15, -0.1, 0.8, 0.2))
    
    -- Tower of boxes
    table.insert(box_i, createBoxObj(-1100, 600, 25, 25, 0, 1.0, 0.3))
    table.insert(box_i, createBoxObj(-1100, 570, 25, 25, 0, 1.0, 0.3))
    table.insert(box_i, createBoxObj(-1100, 540, 25, 25, 0, 1.0, 0.3))
    table.insert(box_i, createBoxObj(-1100, 510, 25, 25, 0, 1.0, 0.3))
    
-- Stacked boxes
    table.insert(box_i, createBoxObj(-1200, 650, 30, 30, 0, 1.5, 0.5))
    table.insert(box_i, createBoxObj(-1170, 650, 30, 30, 0, 1.5, 0.5))
    table.insert(box_i, createBoxObj(-1200, 620, 30, 30, 0, 1.5, 0.5))
    table.insert(box_i, createBoxObj(-1170, 620, 30, 30, 0, 1.5, 0.5))
    
    -- Large platform boxes
    table.insert(box_i, createBoxObj(-300, 500, 100, 20, 0, 2.0, 0.6))
    table.insert(box_i, createBoxObj(-150, 550, 80, 25, 0.3, 1.8, 0.4))
    
    -- Bridge boxes
    table.insert(box_i, createBoxObj(-900, 750, 20, 15, 0, 0.8, 0.2))
    table.insert(box_i, createBoxObj(-880, 750, 20, 15, 0, 0.8, 0.2))
    table.insert(box_i, createBoxObj(-860, 750, 20, 15, 0, 0.8, 0.2))
    table.insert(box_i, createBoxObj(-840, 750, 20, 15, 0, 0.8, 0.2))
    table.insert(box_i, createBoxObj(-820, 750, 20, 15, 0, 0.8, 0.2))
    
    -- Pyramid of boxes
    table.insert(box_i, createBoxObj(-1300, 900, 40, 40, 0, 1.2, 0.4))
    table.insert(box_i, createBoxObj(-1270, 860, 30, 30, 0, 1.2, 0.4))
    table.insert(box_i, createBoxObj(-1330, 860, 30, 30, 0, 1.2, 0.4))
    table.insert(box_i, createBoxObj(-1300, 820, 20, 20, 0, 1.2, 0.4))
    
    -- Floating boxes
    table.insert(box_i, createBoxObj(-200, 250, 25, 25, 0, 0.7, 0.3))
    table.insert(box_i, createBoxObj(-170, 280, 25, 25, 0.5, 0.7, 0.3))
    table.insert(box_i, createBoxObj(-230, 270, 25, 25, -0.3, 0.7, 0.3))
    
    -- Large obstacle boxes
    table.insert(box_i, createBoxObj(-1600, 950, 50, 50, 0, 3.0, 0.8))
    table.insert(box_i, createBoxObj(-1550, 950, 50, 50, 0, 3.0, 0.8))
    table.insert(box_i, createBoxObj(-1500, 950, 50, 50, 0, 3.0, 0.8))
    
    -- Small scattered boxes
    table.insert(box_i, createBoxObj(-100, 600, 15, 15, 0, 0.5, 0.2))
    table.insert(box_i, createBoxObj(-130, 620, 15, 15, 0.2, 0.5, 0.2))
    table.insert(box_i, createBoxObj(-70, 590, 15, 15, -0.1, 0.5, 0.2))
    table.insert(box_i, createBoxObj(-1400, 800, 20, 20, 0, 0.6, 0.3))
    table.insert(box_i, createBoxObj(-1420, 780, 20, 20, 0.3, 0.6, 0.3))
    
    -- Tall thin boxes
    table.insert(box_i, createBoxObj(-1350, 600, 10, 60, 0, 1.0, 0.4))
    table.insert(box_i, createBoxObj(-1370, 600, 10, 60, 0, 1.0, 0.4))
    
    -- Wide flat boxes
    table.insert(box_i, createBoxObj(-500, 650, 80, 12, 0, 1.5, 0.3))
    table.insert(box_i, createBoxObj(-650, 700, 60, 10, 0, 1.3, 0.2))
end

function createBoundary(x, y, w, h, angle)
    local body = love.physics.newBody(world, x, y, "static")
    local shape = love.physics.newRectangleShape(w, h)
    local fixture = love.physics.newFixture(body, shape)
    fixture:setFriction(0.5)
    fixture:setRestitution(0.2)
    body:setAngle(angle)
    
    return {
        body = body,
        shape = shape,
        fixture = fixture,
        w = w,
        h = h
    }
end

function drawBoundary(boundary)
    love.graphics.setColor(0, 0, 0)
    local x, y = boundary.body:getPosition()
    love.graphics.polygon("fill", boundary.body:getWorldPoints(boundary.shape:getPoints()))
end

-- Player creation and controls
function createPlayer()
    -- local body = love.physics.newBody(world, -1590, 800, "dynamic")
    local body = love.physics.newBody(world, -820, 0, "dynamic")
    local shape = love.physics.newRectangleShape(12.5, 25)
    local fixture = love.physics.newFixture(body, shape, 1.0)
    fixture:setFriction(0.1)
    fixture:setRestitution(0.2)
    -- body:setFixedRotation(true)
    
    PlayerX[1] = {
        body = body,
        shape = shape,
        fixture = fixture,
        w = 12.5,
        h = 25,
        particles = {}
    }
end

function updatePlayer(dt)
    if not PlayerX[1] then return end
    
    local player = PlayerX[1]
    local body = player.body
    local vx, vy = body:getLinearVelocity()

    -- Get bottom world coordinates (even if rotated)
    local bx, by = body:getWorldPoint(0, player.h / 2)
    
    -- Apply forces based on key presses
    if love.keyboard.isDown("right") then
        body:applyForce(30, 0)
    end
    
    if love.keyboard.isDown("left") then
        body:applyForce(-30, 0)
    end
    
    if love.keyboard.isDown("up") then
        body:applyForce(0, -60)
        -- Emit particle at bottom of player (follows rotation)
        createPlayerParticle(bx, by)
    end 
	
	if love.keyboard.isDown("down") then
        body:applyForce(0, 20)
        -- Emit particle at bottom of player (follows rotation)
        createPlayerParticle(bx, by)
    end

    -- Upright Stabilization (auto balance)
    local angle = body:getAngle()
    local angularVelocity = body:getAngularVelocity()

    local k = 30         -- proportional correction (spring strength)
    local damping = 2.5  -- damping to stop oscillation

    local torque = -angle * k - angularVelocity * damping
    body:applyTorque(torque)
	
	--Manual rotation
	local rotationForce = 45
	if love.keyboard.isDown("pageup") then
		body:applyTorque(-rotationForce)
	end
	if love.keyboard.isDown("pagedown") then
		body:applyTorque(rotationForce)
	end

    -- Update particles
    for i = #player.particles, 1, -1 do
        local p = player.particles[i]
        p.life = p.life - 8 * dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 0.05
        if p.life <= 0 then
            table.remove(player.particles, i)
        end
    end
end

function drawPlayer(player)
    love.graphics.setColor(0, 0, 0)
    local x, y = player.body:getPosition()
    
    -- Apply shadow effect
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", x + x/50, y + y/50, player.w, player.h)
    
    -- Draw player
    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
    
    -- Draw particles
    love.graphics.setColor(0.5, 0.5, 0.5)
    for _, p in ipairs(player.particles) do
        love.graphics.setColor(1, 1, 1, p.life/255)
        love.graphics.circle("fill", p.x, p.y, 1)
    end
    
    -- Draw player indicator
    love.graphics.setColor(0, 1, 0, 0.5)
    love.graphics.print("$", x - 4, y - 4)
end

function createPlayerParticle(x, y)
    table.insert(PlayerX[1].particles, {
        x = x,
        y = y,
        vx = love.math.random(-0.6, 0.62),
        vy = love.math.random(-1, 0),
        life = 255
    })
end

-- Enemy creation and behavior
function createEnemies()
    -- table.insert(box_i, createEnemyObj(-890, 520, 12.5, 25, 0))
    table.insert(box_i, createEnemyObj(-8900, -520, 12.5, 25, 0))
end

function createEnemyObj(x, y, w, h, angle)
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newRectangleShape(w, h)
    local fixture = love.physics.newFixture(body, shape, 1.2)
    fixture:setFriction(0.1)
    fixture:setRestitution(0.2)
    
    return {
        type = "enemy",
        body = body,
        shape = shape,
        fixture = fixture,
        w = w,
        h = h,
        particles = {}
    }
end

function updateEnemies(dt)
    if not PlayerX[1] then return end
    
    local playerX, playerY = PlayerX[1].body:getPosition()
    
    for _, enemy in ipairs(box_i) do
        if enemy.type == "enemy" then
            local body = enemy.body
            local ex, ey = body:getPosition()
            local dx = playerX - ex
            local dy = playerY - ey

            -- Calculate distance to player
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- MAX FORCE LIMIT 
            local maxForce = 130 
            local forceMultiplier = 0.05
            
            -- Calculate desired force
            local desiredForceX = dx * forceMultiplier
            local desiredForceY = dy * forceMultiplier
            local forceMagnitude = math.sqrt(desiredForceX * desiredForceX + desiredForceY * desiredForceY)
            
            -- Apply force limit
            if forceMagnitude > maxForce then
                local scale = maxForce / forceMagnitude
                desiredForceX = desiredForceX * scale
                desiredForceY = desiredForceY * scale
            end
            
            -- Move toward player with limited force
            body:applyForce(desiredForceX, desiredForceY)

            -- -- Stabilization toward player
            -- local desiredAngle = math.atan2(dy, dx)        -- angle to player
            local currentAngle = body:getAngle()
            local angularVelocity = body:getAngularVelocity()

            -- -- Normalize angle difference (-π to π)
            -- local angleDiff = desiredAngle - currentAngle
            -- angleDiff = (angleDiff + math.pi) % (2 * math.pi) - math.pi

            -- -- PD controller for rotation
            -- local k = 100         -- proportional gain
            -- local damping = 10  -- damping gain

            -- local torque = angleDiff * k - angularVelocity * damping
			
			local k = 30     
			local damping = 2.5 

			local torque = -currentAngle * k - angularVelocity * damping
            body:applyTorque(torque)

            -- Emit particle at bottom (follows rotation)
            local bx, by = body:getWorldPoint(0, enemy.h / 2)
            createEnemyParticle(enemy, bx, by)

            -- Update particles
            for i = #enemy.particles, 1, -1 do
                local p = enemy.particles[i]
                p.life = p.life - 8 * dt
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                p.vy = p.vy + 0.05
                
                if p.life <= 0 then
                    table.remove(enemy.particles, i)
                end
            end
        end
    end
end


function createEnemyParticle(enemy, x, y)
    table.insert(enemy.particles, {
        x = x,
        y = y,
        vx = love.math.random(-0.3, 0.3),
        vy = love.math.random(-0.8, 0),
        life = 255
    })
end


function drawEnemy(enemy)
    love.graphics.setColor(0, 0, 0)
    local x, y = enemy.body:getPosition()
    love.graphics.polygon("fill", enemy.body:getWorldPoints(enemy.shape:getPoints()))
    
    -- Draw enemy indicator
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.print("E", x - 4, y - 4)
    
    -- Draw particles
    for _, p in ipairs(enemy.particles) do
        love.graphics.setColor(1, 1, 1, p.life/255)
        love.graphics.circle("fill", p.x, p.y, 1)
    end
end

-- Box creation and drawing
function createBoxes()
    -- Already created in createBoundaries
end

function createBoxObj(x, y, w, h, angle, density, friction)
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newRectangleShape(w, h)
    local fixture = love.physics.newFixture(body, shape, density or 1.0)
    fixture:setFriction(friction or 0.5)
    fixture:setRestitution(0.2)
    body:setAngle(angle or 0)
    
    return {
        type = "box",
        body = body,
        shape = shape,
        fixture = fixture,
        w = w,
        h = h
    }
end

function drawBox(box)
    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon("fill", box.body:getWorldPoints(box.shape:getPoints()))
end

-- Ball creation and drawing
function createBalls()
    table.insert(box_i, createBallObj(260, 430, 12.5, -700, 2, 0.5))
    table.insert(box_i, createBallObj(-390, 150, 25, -15, 1, 0.1))
    table.insert(box_i, createBallObj(-1590, 1000, 28, 0, 0.1, 0.8))
    table.insert(box_i, createBallObj(-1300, 1000, 30, 0, 0.05, 0.8))
end

function createBallObj(x, y, r, angularVelocity, density, friction)
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newCircleShape(r)
    local fixture = love.physics.newFixture(body, shape, density or 1.0)
    fixture:setFriction(friction or 0.5)
    fixture:setRestitution(0.3)
    
    if angularVelocity then
        body:setAngularVelocity(angularVelocity)
    end
    
    return {
        type = "ball",
        body = body,
        shape = shape,
        fixture = fixture,
        r = r
    }
end

function drawBall(ball)
    local x, y = ball.body:getPosition()
    local angle = ball.body:getAngle()

    -- Outline
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(3)
    love.graphics.circle("line", x, y, ball.r)

    -- Rotating cross
    local cosA, sinA = math.cos(angle), math.sin(angle)
    local r = ball.r

    love.graphics.line(
        x - r * cosA, y - r * sinA,
        x + r * cosA, y + r * sinA
    )
    love.graphics.line(
        x - r * sinA, y + r * cosA,
        x + r * sinA, y - r * cosA
    )
end

-- Particle system
function updateParticles(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - 8 * dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 0.05
        
        if p.life <= 0 then
            table.remove(particles, i)
        end
    end
end

function drawParticles()
    for _, p in ipairs(particles) do
        love.graphics.setColor(1, 1, 1, p.life/255)
        love.graphics.circle("fill", p.x, p.y, 1)
    end
end