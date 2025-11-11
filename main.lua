function love.load()
    -- Game state
    game = {
        debugMode = false,
        state = "playing", -- playing, paused, gameover
        score = 0
    }
    
    -- Physics world setup - ZERO GRAVITY in space
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true) -- No default gravity
    
    -- Game objects
    boundaries = {}
    PlayerX = {}
    box_i = {}
    particles = {}
    enemies = {}
    balls = {}
    planets = {}
    orbiters = {}
    
    createSolarSystem() -- Create sun and orbiting planets
    createAsteroidBelts() -- Create asteroid belts
    createPlayer()
    createEnemies()
    createBalls()
    
    -- Enhanced Camera setup for massive space exploration
    camera = {
        x = 0, 
        y = 0, 
        scale = 0.01, -- Start extremely zoomed out for solar system view
        mode = "follow_player",
        target = nil,
        freeMoveSpeed = 5000, -- Much faster movement for huge space
        minScale = 0.001,     -- Can zoom out to see entire solar system
        maxScale = 3.0
    }
    
    -- Updated instructions for massive space game
    cameraInstructions = {
        "F1: Follow Player",
        "F2: Follow Enemy", 
        "F3: Free Move",
        "Wheel or -/+: Zoom",
        "WASD: Free Move",
        "R: Reset Zoom",
        "F5: Toggle Debug Mode",
        "Enter: Visit Planet"
    }
    
    -- Debug info
    debugInfo = {
        showPlayerVectors = true,
        showThrusterDirection = true,
        showPhysicsInfo = true,
        showObjectCounts = true,
        showGravityZones = true
    }
end

function createSolarSystem()
    -- Create the SUN at center with massive gravity
    local sun = createPlanet(0, 0, 800, 15000, 50000, "SUN")
    sun.fixture:setSensor(false) -- Sun is solid
    sun.isSun = true
    table.insert(planets, sun)
    
    -- Create planets orbiting the sun
    -- Format: {orbitRadius, radius, gravityRadius, gravityStrength, name, orbitSpeed}
    local planetData = {
        {2000, 80, 400, 2000, "Mercury", 1.8},
        {3500, 120, 600, 3500, "Venus", 1.3},
        {5000, 150, 800, 5000, "Earth", 1.0},
        {6500, 130, 700, 3000, "Mars", 0.8},
        {9000, 300, 1200, 15000, "Jupiter", 0.4},
        {12000, 280, 1000, 12000, "Saturn", 0.3},
        {15000, 200, 800, 8000, "Uranus", 0.2},
        {18000, 190, 750, 7000, "Neptune", 0.1}
    }
    
    for i, data in ipairs(planetData) do
        local angle = love.math.random() * math.pi * 2
        local x = math.cos(angle) * data[1]
        local y = math.sin(angle) * data[1]
        
        local planet = createPlanet(x, y, data[2], data[3], data[4], data[5])
        planet.orbitRadius = data[1]
        planet.orbitSpeed = data[6]
        planet.orbitAngle = angle
        planet.initialAngle = angle
        
        table.insert(planets, planet)
    end
    
    -- Create orbiters/moons around planets
    createOrbiters()
end

function createOrbiters()
    for _, planet in ipairs(planets) do
        if not planet.isSun and planet.orbitRadius then
            local numOrbiters = love.math.random(1, 4) -- Moons
            for i = 1, numOrbiters do
                local moonDist = planet.radius + love.math.random(150, 400)
                local angle = love.math.random() * math.pi * 2
                local px, py = planet.body:getPosition()
                local ox = px + math.cos(angle) * moonDist
                local oy = py + math.sin(angle) * moonDist
                local moon = createOrbiter(ox, oy, love.math.random(15, 30))
                moon.isMoon = true
                moon.parentPlanet = planet

                -- Tangential velocity for circular orbit around planet
                local speed = math.sqrt(planet.gravityStrength / moonDist) * 0.7
                local tx = -math.sin(angle) * speed
                local ty = math.cos(angle) * speed
                
                -- Add planet's orbital velocity
                local planetVx, planetVy = planet.body:getLinearVelocity()
                moon.body:setLinearVelocity(tx + planetVx, ty + planetVy)

                table.insert(orbiters, moon)
            end
        end
    end
end

function createOrbiter(x, y, r)
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newCircleShape(r)
    local fixture = love.physics.newFixture(body, shape, 0.1)
    fixture:setRestitution(0.3)
    return {
        body = body,
        shape = shape,
        r = r
    }
end

function createPlanet(x, y, radius, gravityRadius, gravityStrength, name)
    local bodyType = "dynamic"
    if name == "SUN" then
        bodyType = "static" -- Sun doesn't move
    end
    
    local body = love.physics.newBody(world, x, y, bodyType)
    local shape = love.physics.newCircleShape(radius)
    local fixture = love.physics.newFixture(body, shape, 1)
    
    if name ~= "SUN" then
        -- fixture:setSensor(true) -- Make it a sensor for gravity field (except sun)
    end
    
    return {
        body = body,
        shape = shape,
        fixture = fixture,
        radius = radius,
        gravityRadius = gravityRadius,
        gravityStrength = gravityStrength,
        name = name,
        visited = false
    }
end

function createAsteroidBelts()
    -- Create multiple asteroid belts at different distances
    local beltData = {
        {minDist = 7500, maxDist = 8500, count = 200}, -- Between Mars and Jupiter
        {minDist = 13000, maxDist = 14000, count = 150}, -- Beyond Saturn
        {minDist = 20000, maxDist = 22000, count = 100} -- Outer belt
    }
    
    for _, belt in ipairs(beltData) do
        for i = 1, belt.count do
            local angle = love.math.random() * math.pi * 2
            local distance = love.math.random(belt.minDist, belt.maxDist)
            local x = math.cos(angle) * distance
            local y = math.sin(angle) * distance
            local size = love.math.random(5, 25) -- Smaller asteroids
            table.insert(box_i, createAsteroidObj(x, y, size))
            
            -- Give asteroids some orbital velocity
            local speed = math.sqrt(50000 / distance) * love.math.random(0.8, 1.2)
            local vx = -math.sin(angle) * speed
            local vy = math.cos(angle) * speed
            box_i[#box_i].body:setLinearVelocity(vx, vy)
        end
    end
end

function createAsteroidObj(x, y, size)
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newRectangleShape(size, size)
    local fixture = love.physics.newFixture(body, shape, 0.8)
    fixture:setFriction(0.1)
    fixture:setRestitution(0.3)
    
    -- Random rotation
    body:setAngle(love.math.random() * math.pi * 2)
    body:setAngularVelocity(love.math.random(-0.2, 0.2))
    
    return {
        type = "asteroid",
        body = body,
        shape = shape,
        fixture = fixture,
        w = size,
        h = size,
        size = size
    }
end

function updateGravity(dt)
    for _, planet in ipairs(planets) do
        local px, py = planet.body:getPosition()

        -- Apply to all dynamic bodies that can move
        local allBodies = {}

        if PlayerX[1] then table.insert(allBodies, PlayerX[1].body) end
        for _, e in ipairs(enemies) do table.insert(allBodies, e.body) end
        for _, b in ipairs(balls) do table.insert(allBodies, b.body) end
        for _, a in ipairs(box_i) do
            if a.body and a.body:getType() == "dynamic" then
                table.insert(allBodies, a.body)
            end
        end
        for _, o in ipairs(orbiters) do table.insert(allBodies, o.body) end
        -- Planets also attract each other (except sun affects planets, planets don't affect sun)
        for _, otherPlanet in ipairs(planets) do
            if otherPlanet ~= planet and not otherPlanet.isSun and planet.isSun then
                table.insert(allBodies, otherPlanet.body)
            end
        end

        for _, body in ipairs(allBodies) do
            applyBodyGravity(body, px, py, planet.gravityRadius, planet.gravityStrength, dt)
        end
    end
end

function applyBodyGravity(body, px, py, gravityRadius, gravityStrength, dt)
    local bx, by = body:getPosition()
    local dx, dy = px - bx, py - by
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 0 and distance < gravityRadius then
        local dirX, dirY = dx / distance, dy / distance
        -- Realistic inverse-square gravity
        local force = gravityStrength / (distance * distance)
        body:applyForce(dirX * force, dirY * force)
    end
end

function updatePlanetOrbits(dt)
    local sun = planets[1] -- Sun is first planet
    local sunX, sunY = sun.body:getPosition()
    
    for _, planet in ipairs(planets) do
        if not planet.isSun and planet.orbitRadius then
            -- Update orbital position
            planet.orbitAngle = planet.orbitAngle + planet.orbitSpeed * dt * 0.01
            local targetX = sunX + math.cos(planet.orbitAngle) * planet.orbitRadius
            local targetY = sunY + math.sin(planet.orbitAngle) * planet.orbitRadius
            
            -- Smooth movement toward orbital position
            local currentX, currentY = planet.body:getPosition()
            local dx, dy = targetX - currentX, targetY - currentY
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance > 10 then
                local force = distance * 0.1
                planet.body:applyForce(dx/distance * force, dy/distance * force)
            end
        end
    end
end

function checkPlanetVisits()
    if not PlayerX[1] then return end
    
    local px, py = PlayerX[1].body:getPosition()
    
    for _, planet in ipairs(planets) do
        local plx, ply = planet.body:getPosition()
        local dx, dy = px - plx, py - ply
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < planet.radius + 50 and not planet.visited then
            planet.visited = true
            game.score = game.score + 100
            createFloatingText(plx, ply - planet.radius - 30, "Visited " .. planet.name .. "! +100")
        end
    end
end

function createFloatingText(x, y, text)
    table.insert(particles, {
        x = x, y = y,
        text = text,
        life = 120, -- frames
        vy = -0.5
    })
end

function updateParticles(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - 1
        
        if p.vy then
            p.y = p.y + p.vy
        end
        
        if p.life <= 0 then
            table.remove(particles, i)
        end
    end
    
    if PlayerX[1] then
        updatePlayerParticles(PlayerX[1], dt)
    end
    
    for _, enemy in ipairs(enemies) do
        updateEnemyParticles(enemy, dt)
    end
end

function love.update(dt)
    if game.state ~= "playing" then return end
    
    world:update(dt)
    updatePlanetOrbits(dt) -- Update planet positions
    updateGravity(dt) -- Apply planetary gravity
    updatePlayer(dt)
    updateEnemies(dt)
    updateParticles(dt)
    updateCamera(dt)
    checkPlanetVisits()
	
	if love.keyboard.isDown("=") or key == love.keyboard.isDown("+") then
        camera.scale = math.min(camera.scale + 0.01, 5)
    elseif love.keyboard.isDown("-") or key == love.keyboard.isDown("_")  then
        camera.scale = math.max(camera.scale - 0.01, 0.001)
	end
end

function love.draw()
    love.graphics.clear(0.02, 0.02, 0.08) -- Very dark space background
    love.graphics.push()
    
    -- Apply camera transform
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.scale(camera.scale)
    love.graphics.translate(-camera.x, -camera.y)
    
    -- Draw stars in background
    drawStars()
    
    -- Draw all objects
    drawPlanets()
    drawOrbiters()
    drawAsteroids()
    drawEnemies()
    drawBalls()
    if PlayerX[1] then
        drawPlayer(PlayerX[1])
    end
    drawParticles()
    
    -- Draw gravity zones in debug mode
    if game.debugMode and debugInfo.showGravityZones then
        drawGravityZones()
    end
    
    -- Debug drawings
    if game.debugMode then
        drawDebugInfo()
    end
    
    love.graphics.pop()
    
    -- Draw UI (not affected by camera)
    drawUI()
end

function drawStars()
    love.graphics.setColor(1, 1, 1, 0.8)
    for i = 1, 1000 do
        local x = (i * 173) % 50000 - 25000
        local y = (i * 257) % 50000 - 25000
        local size = (i % 3) * 0.5 + 0.5
        love.graphics.points(x, y)
    end
end

function drawPlanets()
    for _, planet in ipairs(planets) do
        local x, y = planet.body:getPosition()
        
        -- Draw gravity zone (debug)
        if game.debugMode and debugInfo.showGravityZones then
            love.graphics.setColor(1, 0.5, 0, 0.1)
            love.graphics.circle("fill", x, y, planet.gravityRadius)
        end
        
        -- Special sun rendering
        if planet.isSun then
            -- Sun glow
            for i = 1, 3 do
                local glowSize = planet.radius * (1 + i * 0.1)
                love.graphics.setColor(1, 0.8, 0, 0.1 / i)
                love.graphics.circle("fill", x, y, glowSize)
            end
            love.graphics.setColor(1, 1, 0) -- Bright yellow sun
        else
            -- Regular planet
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        
        love.graphics.circle("fill", x, y, planet.radius)
        
        -- Planet outline
        love.graphics.setColor(0.4, 0.4, 0.5)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", x, y, planet.radius)
        love.graphics.setLineWidth(1)
        
        -- Planet name if visited or debug
        if planet.visited or game.debugMode then
            love.graphics.setColor(1, 1, 1, 0.7)
            love.graphics.print(planet.name, x - love.graphics.getFont():getWidth(planet.name)/2, y - planet.radius - 20)
        end
    end
end

function drawOrbiters()
    for _, orb in ipairs(orbiters) do
        local x, y = orb.body:getPosition()
        if orb.isMoon then
            love.graphics.setColor(0.8, 0.8, 0.9) -- Moon color
        else
            love.graphics.setColor(0.6, 0.8, 1) -- Other orbiters
        end
        love.graphics.circle("fill", x, y, orb.r)
    end
end

function drawGravityZones()
    for _, planet in ipairs(planets) do
        local x, y = planet.body:getPosition()
        love.graphics.setColor(1, 0.5, 0, 0.1)
        love.graphics.circle("line", x, y, planet.gravityRadius)
        love.graphics.print("Gravity", x + planet.gravityRadius + 5, y - 10)
    end
end

function drawAsteroids()
    for _, asteroid in ipairs(box_i) do
        if asteroid.type == "asteroid" then
            local x, y = asteroid.body:getPosition()
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.polygon("fill", asteroid.body:getWorldPoints(asteroid.shape:getPoints()))
            
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.polygon("line", asteroid.body:getWorldPoints(asteroid.shape:getPoints()))
        end
    end
end

function createPlayer()
    -- Start player near Earth
    local earth = planets[3] -- Earth is third planet
    local ex, ey = earth.body:getPosition()
    local startX = ex + earth.radius + 100
    local startY = ey
    
    local body = love.physics.newBody(world, startX, startY, "dynamic")
    local shape = love.physics.newRectangleShape(12.5, 25)
    local fixture = love.physics.newFixture(body, shape, 1.0)
    fixture:setFriction(0.1)
    fixture:setRestitution(0.2)
    
    -- Give player initial orbital velocity around Earth
    local orbitalSpeed = math.sqrt(earth.gravityStrength / 100) * 0.8
    body:setLinearVelocity(0, orbitalSpeed)
    
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
    
    -- Get bottom world coordinates
    local bx, by = body:getWorldPoint(0, player.h / 2)
    local angle = body:getAngle()
    
    -- Space movement - apply forces in the direction the player is facing
    if love.keyboard.isDown("right") then
        local forceX = math.cos(angle) * 80
        local forceY = math.sin(angle) * 80
        body:applyForce(forceX, forceY)
    end
    
    if love.keyboard.isDown("left") then
        local forceX = math.cos(angle) * -80
        local forceY = math.sin(angle) * -80
        body:applyForce(forceX, forceY)
    end
    
    if love.keyboard.isDown("up") then
        local forceX = math.cos(angle - math.pi/2) * 100
        local forceY = math.sin(angle - math.pi/2) * 100
        body:applyForce(forceX, forceY)
        
        -- Thruster particles
        createPlayerParticle(bx, by, angle)
    end 
    
    if love.keyboard.isDown("down") then
        local forceX = math.cos(angle + math.pi/2) * 60
        local forceY = math.sin(angle + math.pi/2) * 60
        body:applyForce(forceX, forceY)
        
        -- Thruster particles
        createPlayerParticle(bx, by, angle + math.pi)
    end

    -- Manual rotation in space
    local rotationForce = 35
    if love.keyboard.isDown("pageup") then
        body:applyTorque(-rotationForce)
    end
    if love.keyboard.isDown("pagedown") then
        body:applyTorque(rotationForce)
    end

    -- Update particles
    updatePlayerParticles(player, dt)
end

function updatePlayerParticles(player, dt)
    for i = #player.particles, 1, -1 do
        local p = player.particles[i]
        p.life = p.life - 8 * dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        if p.life <= 0 then
            table.remove(player.particles, i)
        end
    end
end

function createPlayerParticle(x, y, angle)
    local particleAngle = angle + math.pi + love.math.random(-0.3, 0.3)
    local speed = love.math.random(20, 50)
    
    table.insert(PlayerX[1].particles, {
        x = x,
        y = y,
        vx = math.cos(particleAngle) * speed,
        vy = math.sin(particleAngle) * speed,
        life = love.math.random(20, 40)
    })
end

function drawPlayer(player)
    love.graphics.setColor(0, 0.8, 1) -- Blue spaceship
    local x, y = player.body:getPosition()
    
    -- Draw player
    love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
    
    -- Draw particles
    drawPlayerParticles(player)
    
    -- Draw player indicator
    love.graphics.setColor(0, 1, 0, 0.5)
    love.graphics.print("PLAYER", x - 20, y - 30)
end

function drawPlayerParticles(player)
    for _, p in ipairs(player.particles) do
        love.graphics.setColor(1, 1, 0.5, p.life/40)
        love.graphics.circle("fill", p.x, p.y, 2)
    end
end

function createEnemies()
    -- Create enemies at different planets
    local enemyPlanets = {planets[2], planets[4], planets[6]} -- Venus, Mars, Saturn
    for _, planet in ipairs(enemyPlanets) do
        local px, py = planet.body:getPosition()
        local angle = love.math.random() * math.pi * 2
        local dist = planet.radius + 150
        local ex = px + math.cos(angle) * dist
        local ey = py + math.sin(angle) * dist
        
        local enemy = createEnemyObj(ex, ey, 12.5, 25, 0)
        
        -- Give enemy orbital velocity
        local speed = math.sqrt(planet.gravityStrength / dist) * 0.9
        local vx = -math.sin(angle) * speed
        local vy = math.cos(angle) * speed
        enemy.body:setLinearVelocity(vx, vy)
        
        table.insert(enemies, enemy)
    end
end

function createEnemyObj(x, y, w, h, angle)
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newRectangleShape(w, h)
    local fixture = love.physics.newFixture(body, shape, 1.2)
    fixture:setFriction(0.1)
    fixture:setRestitution(0.2)
    
    local enemy = {
        type = "enemy",
        body = body,
        shape = shape,
        fixture = fixture,
        w = w,
        h = h,
        particles = {}
    }
    
    return enemy
end

function updateEnemies(dt)
    if not PlayerX[1] then return end
    
    local playerX, playerY = PlayerX[1].body:getPosition()
    
    for _, enemy in ipairs(enemies) do
        updateSingleEnemy(enemy, playerX, playerY, dt)
    end
end

function updateSingleEnemy(enemy, playerX, playerY, dt)
    local body = enemy.body
    local ex, ey = body:getPosition()
    local dx = playerX - ex
    local dy = playerY - ey

    -- Calculate distance to player
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Only chase if player is within reasonable distance
    if distance < 5000 then
        local maxForce = 130 
        local forceMultiplier = 0.05
        
        local desiredForceX = dx * forceMultiplier
        local desiredForceY = dy * forceMultiplier
        local forceMagnitude = math.sqrt(desiredForceX * desiredForceX + desiredForceY * desiredForceY)
        
        if forceMagnitude > maxForce then
            local scale = maxForce / forceMagnitude
            desiredForceX = desiredForceX * scale
            desiredForceY = desiredForceY * scale
        end
        
        body:applyForce(desiredForceX, desiredForceY)
    end

    -- Stabilization
    local currentAngle = body:getAngle()
    local angularVelocity = body:getAngularVelocity()

    local k = 30     
    local damping = 2.5 

    local torque = -currentAngle * k - angularVelocity * damping
    body:applyTorque(torque)

    -- Emit particle at bottom
    local bx, by = body:getWorldPoint(0, enemy.h / 2)
    createEnemyParticle(enemy, bx, by)

    -- Update particles
    updateEnemyParticles(enemy, dt)
end

function updateEnemyParticles(enemy, dt)
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

function createEnemyParticle(enemy, x, y)
    table.insert(enemy.particles, {
        x = x,
        y = y,
        vx = love.math.random(-0.3, 0.3),
        vy = love.math.random(-0.8, 0),
        life = 255
    })
end

function drawEnemies()
    for _, enemy in ipairs(enemies) do
        love.graphics.setColor(1, 0.3, 0.3) -- Red enemy ships
        local x, y = enemy.body:getPosition()
        love.graphics.polygon("fill", enemy.body:getWorldPoints(enemy.shape:getPoints()))
        
        -- Draw enemy indicator
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.print("ENEMY", x - 20, y - 30)
        
        -- Draw particles
        drawEnemyParticles(enemy)
    end
end

function drawEnemyParticles(enemy)
    for _, p in ipairs(enemy.particles) do
        love.graphics.setColor(1, 0.5, 0.5, p.life/255)
        love.graphics.circle("fill", p.x, p.y, 1)
    end
end

function createBalls()
    -- Create some floating space debris/balls
    for i = 1, 20 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(3000, 20000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        local r = love.math.random(10, 30)
        table.insert(balls, createBallObj(x, y, r, love.math.random(-2, 2), 0.1, 0.5))
    end
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
    
    local ball = {
        type = "ball",
        body = body,
        shape = shape,
        fixture = fixture,
        r = r
    }
    
    return ball
end

function drawBalls()
    for _, ball in ipairs(balls) do
        local x, y = ball.body:getPosition()
        local angle = ball.body:getAngle()

        -- Outline
        love.graphics.setColor(0.8, 0.8, 0.2) -- Yellow balls
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
        love.graphics.setLineWidth(1)
    end
end

function drawParticles()
    for _, p in ipairs(particles) do
        if p.text then
            love.graphics.setColor(1, 1, 1, p.life/120)
            love.graphics.print(p.text, p.x, p.y)
        else
            love.graphics.setColor(1, 1, 1, p.life/255)
            love.graphics.circle("fill", p.x, p.y, 1)
        end
    end
end

function updateCamera(dt)
    if camera.mode == "follow_player" and PlayerX[1] then
        local targetX, targetY = PlayerX[1].body:getPosition()
        camera.x = camera.x + (targetX - camera.x) * 0.99
        camera.y = camera.y + (targetY - camera.y) * 0.99
        
    elseif camera.mode == "follow_enemy" then
        local enemy = findFirstEnemy()
        if enemy then
            camera.target = enemy
            local targetX, targetY = enemy.body:getPosition()
            camera.x = camera.x + (targetX - camera.x) * 0.99
            camera.y = camera.y + (targetY - camera.y) * 0.99
        elseif PlayerX[1] then
            local targetX, targetY = PlayerX[1].body:getPosition()
            camera.x = camera.x + (targetX - camera.x) * 0.99
            camera.y = camera.y + (targetY - camera.y) * 0.99
        end
        
    elseif camera.mode == "free_move" then
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
    for _, enemy in ipairs(enemies) do
        return enemy
    end
    return nil
end

function drawUI()
    love.graphics.setColor(1, 1, 1)
    
    -- Game state and score
    love.graphics.print("State: " .. game.state, 10, 10)
    love.graphics.print("Score: " .. game.score, 10, 30)
    
    -- Player position
    if PlayerX[1] then
        local px, py = PlayerX[1].body:getPosition()
        love.graphics.print("Position: " .. math.floor(px) .. ", " .. math.floor(py), 10, 50)
        
        -- Velocity
        local vx, vy = PlayerX[1].body:getLinearVelocity()
        local speed = math.sqrt(vx*vx + vy*vy)
        love.graphics.print("Speed: " .. string.format("%.1f", speed), 10, 70)
    end
    
    -- Camera info
    love.graphics.print("Camera Mode: " .. camera.mode, 10, 90)
    love.graphics.print("Zoom: " .. string.format("%.3f", camera.scale), 10, 110)
    
    -- Planets visited
    local visited = 0
    for _, planet in ipairs(planets) do
        if planet.visited then visited = visited + 1 end
    end
    love.graphics.print("Planets Visited: " .. visited .. "/" .. #planets, 10, 130)
    
    -- Object counts
    love.graphics.print("Asteroids: " .. #box_i, 10, 150)
    love.graphics.print("Enemies: " .. #enemies, 10, 170)
    
    -- Debug mode indicator
    if game.debugMode then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("DEBUG MODE ACTIVE", 10, 190)
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Instructions
    love.graphics.print("SOLAR SYSTEM EXPLORATION", love.graphics.getWidth() - 250, 10)
    for i, instruction in ipairs(cameraInstructions) do
        love.graphics.print(instruction, love.graphics.getWidth() - 250, 10 + i * 20)
    end
    
    -- Game controls
    love.graphics.print("Space Controls:", love.graphics.getWidth() - 250, 190)
    love.graphics.print("Arrow Keys: Thrusters", love.graphics.getWidth() - 250, 210)
    love.graphics.print("PageUp/Down: Rotate", love.graphics.getWidth() - 250, 230)
    love.graphics.print("Visit planets for points!", love.graphics.getWidth() - 250, 250)
    
    -- Floating text particles
    for _, p in ipairs(particles) do
        if p.text then
            love.graphics.setColor(1, 1, 1, p.life/120)
            love.graphics.print(p.text, p.x, p.y)
        end
    end
end

function drawDebugInfo()
    if PlayerX[1] then
        drawPlayerDebugInfo(PlayerX[1])
    end
    
    for _, enemy in ipairs(enemies) do
        drawEnemyDebugInfo(enemy)
    end
    
    -- Draw physics body outlines
    if debugInfo.showPhysicsInfo then
        drawPhysicsDebug()
    end
end

function drawPlayerDebugInfo(player)
    local body = player.body
    local x, y = body:getPosition()
    local angle = body:getAngle()
    
    -- Coordinate axes
    if debugInfo.showPlayerVectors then
        local length = 50
        -- X-axis (red)
        love.graphics.setColor(1, 0, 0, 0.8)
        love.graphics.line(x, y, x + math.cos(angle) * length, y + math.sin(angle) * length)
        -- Y-axis (green)
        love.graphics.setColor(0, 1, 0, 0.8)
        love.graphics.line(x, y, x + math.cos(angle + math.pi/2) * length, y + math.sin(angle + math.pi/2) * length)
    end
    
    -- Velocity vector
    local vx, vy = body:getLinearVelocity()
    love.graphics.setColor(0, 0.5, 1, 0.8)
    love.graphics.line(x, y, x + vx, y + vy)
    love.graphics.print("Velocity: " .. string.format("%.1f", math.sqrt(vx*vx + vy*vy)), x + 20, y - 40)
    
    -- Thruster direction
    if debugInfo.showThrusterDirection then
        local thrusterLength = 30
        local bx, by = body:getWorldPoint(0, player.h / 2) -- Bottom point
        
        -- Up thruster (cyan)
        if love.keyboard.isDown("up") then
            love.graphics.setColor(0, 1, 1, 0.8)
            love.graphics.line(bx, by, bx, by - thrusterLength)
        end
        
        -- Down thruster (yellow)
        if love.keyboard.isDown("down") then
            love.graphics.setColor(1, 1, 0, 0.8)
            love.graphics.line(bx, by, bx, by + thrusterLength)
        end
    end
    
    -- Angular velocity
    local av = body:getAngularVelocity()
    love.graphics.setColor(1, 0.5, 0, 0.8)
    love.graphics.print("Angular Vel: " .. string.format("%.2f", av), x + 20, y - 20)
end

function drawEnemyDebugInfo(enemy)
    local body = enemy.body
    local x, y = body:getPosition()
    
    -- Draw line to player if exists
    if PlayerX[1] then
        local px, py = PlayerX[1].body:getPosition()
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.line(x, y, px, py)
        
        -- Distance to player
        local dx, dy = px - x, py - y
        local distance = math.sqrt(dx*dx + dy*dy)
        love.graphics.print("Dist: " .. string.format("%.1f", distance), x + 15, y - 20)
    end
    
    -- Velocity vector
    local vx, vy = body:getLinearVelocity()
    love.graphics.setColor(1, 0.5, 0.5, 0.8)
    love.graphics.line(x, y, x + vx, y + vy)
end

function drawPhysicsDebug()
    -- Draw asteroids
    love.graphics.setColor(0.5, 0.5, 0, 0.3)
    for _, asteroid in ipairs(box_i) do
        if asteroid.type == "asteroid" then
            love.graphics.polygon("line", asteroid.body:getWorldPoints(asteroid.shape:getPoints()))
        end
    end
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
    -- elseif key == "=" or key == "+" then
        -- camera.scale = math.min(camera.scale + 0.01, 5)
    -- elseif key == "-" or key == "_" then
        -- camera.scale = math.max(camera.scale - 0.01, 0.001)
    elseif key == "r" then
        camera.scale = 0.01  -- Reset to solar system zoom level
    elseif key == "f5" then
        game.debugMode = not game.debugMode
    elseif key == "p" then
        if game.state == "playing" then
            game.state = "paused"
        else
            game.state = "playing"
        end
    elseif key == "return" then
        -- Manual planet visit check
        checkPlanetVisits()
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