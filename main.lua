local bit = require("bit")

function love.load()
    -- Game state
    game = {
        debugMode = false,
        state = "playing", -- playing, paused, gameover, landed
        score = 0,
        message = "",
        messageTimer = 0
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
    blackholes = {}
    whiteholes = {}
    wormholes = {}
    nebulae = {}
    comets = {}
    pulsars = {}
    quasars = {}
    supernovae = {}
    magnetars = {}
    asteroidfields = {}
    spacestations = {}
    bullets = {} -- NEW: Bullets for shooting
    deadEnemies = {} -- NEW: Store dead enemies
    tesseracts = {} -- NEW: Tesseracts (4D hypercubes)
    bionebulae = {} -- NEW: Bio Nebulae
    
    createSolarSystem() -- Create sun and orbiting planets
    createAsteroidBelts() -- Create asteroid belts
    createCosmicObjects() -- Create black holes, white holes, wormholes, and nebulae
    createAdvancedCosmicObjects() -- Create comets, pulsars, quasars, supernovae
    createMagnetars() -- Create magnetars
    createAsteroidFields() -- Create dense asteroid fields
    createSpaceStations() -- Create space stations
    createPlayer()
    createEnemies()
    createBalls()
    
    -- NEW: Create supermassive black hole
    createSupermassiveBlackHole()
    
    -- NEW: Create demon planet
    createDemonPlanet()
    
    -- NEW: Create tesseract near supermassive black hole
    createTesseract()
    
    -- NEW: Create bio nebulae
    createBioNebulae()
    
    -- Enhanced Camera setup for massive space exploration
    camera = {
        x = 0, 
        y = 0, 
        scale = 0.01, -- Start even more zoomed out for massive solar system view
        mode = "follow_player",
        target = nil,
        freeMoveSpeed = 20000, -- Much faster movement for huge space
        minScale = 0.004,     -- Can zoom out to see entire massive solar system
        maxScale = 2.0
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
        "Enter: Visit Planet",
        "L: Land/Takeoff",
        "H: Toggle Controls",
        "Shift: Boost",
        "Space: Brake",
        "C: Toggle Docking Computer",
        "F: Fire Weapons", -- NEW: Shooting instruction
        "F6: Detailed Debug" -- NEW: Detailed debug toggle
    }
    
    -- Debug info
    debugInfo = {
        showPlayerVectors = true,
        showThrusterDirection = true,
        showPhysicsInfo = true,
        showObjectCounts = true,
        showGravityZones = true,
        showDetailedInfo = false, -- NEW: Detailed debug info
        totalGravityForce = {x = 0, y = 0, magnitude = 0} -- NEW: Track gravity force on player
    }
    
    -- Player ship systems
    shipSystems = {
        fuel = 1000,
        maxFuel = 1000,
        health = 100,
        maxHealth = 100,
        shields = 100,
        maxShields = 100,
        energy = 100,
        maxEnergy = 100,
        boostActive = false,
        brakesActive = false,
        autoDock = false,
        landed = false,
        landingPlanet = nil,
        docked = false,
        dockingStation = nil,
        weapons = { -- NEW: Weapons system
            cooldown = 0,
            maxCooldown = 0.3, -- seconds between shots
            damage = 10,
            energyCost = 5
        }
    }
    
    -- Android touch controls
    touchControls = {
        visible = true,
        buttons = {
            {
                id = "up",
                x = love.graphics.getWidth() - 200,
                y = love.graphics.getHeight() - 300,
                width = 50,
                height = 50,
                color = {0, 0.8, 0, 0.5},
                active = false
            },
            {
                id = "left",
                x = love.graphics.getWidth() - 280,
                y = love.graphics.getHeight() - 200,
                width = 50,
                height = 50,
                color = {0, 0.8, 0, 0.5},
                active = false
            },
            {
                id = "right",
                x = love.graphics.getWidth() - 120,
                y = love.graphics.getHeight() - 200,
                width = 50,
                height = 50,
                color = {0, 0.8, 0, 0.5},
                active = false
            },
            {
                id = "down",
                x = love.graphics.getWidth() - 200,
                y = love.graphics.getHeight() - 120,
                width = 50,
                height = 50,
                color = {0, 0.8, 0, 0.5},
                active = false
            },
            {
                id = "rotate_left",
                x = 120,
                y = love.graphics.getHeight() - 200,
                width = 50,
                height = 50,
                color = {0.8, 0.8, 0, 0.5},
                active = false
            },
            {
                id = "rotate_right",
                x = 220,
                y = love.graphics.getHeight() - 200,
                width = 50,
                height = 50,
                color = {0.8, 0.8, 0, 0.5},
                active = false
            },
            {
                id = "zoom_in",
                x = love.graphics.getWidth() - 100,
                y = 100,
                width = 50,
                height = 50,
                color = {0.2, 0.5, 1, 0.5},
                active = false
            },
            {
                id = "zoom_out",
                x = love.graphics.getWidth() - 100,
                y = 180,
                width = 50,
                height = 50,
                color = {0.2, 0.5, 1, 0.5},
                active = false
            }, 
			{
                id = "debug",
                x = love.graphics.getWidth() - 100,
                y = 180,
                width = 50,
                height = 50,
                color = {0.2, 0.5, 1, 0.5},
                active = false
            },
            {
                id = "boost",
                x = love.graphics.getWidth() - 100,
                y = 260,
                width = 50,
                height = 50,
                color = {1, 0.5, 0, 0.5},
                active = false
            },
            {
                id = "brake",
                x = love.graphics.getWidth() - 100,
                y = 340,
                width = 50,
                height = 50,
                color = {1, 0, 0, 0.5},
                active = false
            },
            {
                id = "land",
                x = 300,
                y = love.graphics.getHeight() - 100,
                width = 50,
                height = 50,
                color = {0, 0.5, 1, 0.5},
                active = false
            },
            { -- NEW: Fire button
                id = "fire",
                x = 400,
                y = love.graphics.getHeight() - 100,
                width = 50,
                height = 50,
                color = {1, 0, 0, 0.5},
                active = false
            }
        }
    }
    
    updateTouchButtonPositions()
end




-- NEW: Create tesseract (4D hypercube) - REPLACED
function createTesseract()
    -- local supermassiveBlackHole = blackholes[1] -- Assuming first black hole is supermassive
    -- if not supermassiveBlackHole then return end
    
    -- local bhx, bhy = supermassiveBlackHole.body:getPosition()
    
    -- Place tesseract near the supermassive black hole
    local tesseract = {
        x = 500000, -- Position offset from black hole
        y = 500000,
        size = 2000,
        -- 6 independent rotation angles (planes: XY, XZ, XW, YZ, YW, ZW)
        rotation4D = {0, 0, 0, 0, 0, 0},
        rotationSpeed = {0.6, 0.45, 0.35, 0.55, 0.4, 0.5}, -- radians/sec (tuned)
        pulse = 0,
        pulseSpeed = 0.05,
        energyField = {
            radius = 3000,
            strength = 50,
            rechargeRate = 20 -- Energy recharge per second when nearby
        },
        anomalyField = {
            radius = 5000,
            timeDistortion = 0.5, -- slows down time within field (use in player update if desired)
            quantumFlux = 0.3 -- chance per second for random teleport
        },
        vertices4D = {}, -- Will store 4D vertices
        vertices = {},   -- projected vertices
        edges = {},      -- edges (pairs of vertex indices)
        type = "tesseract",
        pulse = 0
    }
    
    -- Initialize 4D vertices of a tesseract (-1 or 1 in each of 4 dims)
    local vertices4D = {}
    for i = 0, 15 do
        local x = bit.band(i, 1) ~= 0 and 1 or -1
        local y = bit.band(i, 2) ~= 0 and 1 or -1
        local z = bit.band(i, 4) ~= 0 and 1 or -1
        local w = bit.band(i, 8) ~= 0 and 1 or -1
        table.insert(vertices4D, {x, y, z, w})
    end
    tesseract.vertices4D = vertices4D

    -- Define edges: vertices differ by exactly one coordinate
    for i = 1, 16 do
        for j = i + 1, 16 do
            local diff = 0
            for dim = 1, 4 do
                if vertices4D[i][dim] ~= vertices4D[j][dim] then diff = diff + 1 end
            end
            if diff == 1 then
                table.insert(tesseract.edges, {i, j})
            end
        end
    end
    
    table.insert(tesseracts, tesseract)
end


-- HELPER: rotate a 4D vector by a given plane angle
-- plane indices mapping:
-- 1 = XY, 2 = XZ, 3 = XW, 4 = YZ, 5 = YW, 6 = ZW
local function rotate4D(x, y, z, w, angles)
    -- XY rotate (x,y)
    local a = angles[1]; local cx, sx = math.cos(a), math.sin(a)
    local nx, ny = cx*x - sx*y, sx*x + cx*y
    x, y = nx, ny
    -- XZ rotate (x,z)
    a = angles[2]; cx, sx = math.cos(a), math.sin(a)
    nx, nz = cx*x - sx*z, sx*x + cx*z
    x, z = nx, nz
    -- XW rotate (x,w)
    a = angles[3]; cx, sx = math.cos(a), math.sin(a)
    nx, nw = cx*x - sx*w, sx*x + cx*w
    x, w = nx, nw
    -- YZ rotate (y,z)
    a = angles[4]; cx, sx = math.cos(a), math.sin(a)
    ny, nz = cx*y - sx*z, sx*y + cx*z
    y, z = ny, nz
    -- YW rotate (y,w)
    a = angles[5]; cx, sx = math.cos(a), math.sin(a)
    ny, nw = cx*y - sx*w, sx*y + cx*w
    y, w = ny, nw
    -- ZW rotate (z,w)
    a = angles[6]; cx, sx = math.cos(a), math.sin(a)
    nz, nw = cx*z - sx*w, sx*z + cx*w
    z, w = nz, nw

    return x, y, z, w
end


-- NEW: Create bio nebulae
function createBioNebulae()
    for i = 1, 3 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(80000, 150000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local bioNebula = {
            x = x, y = y,
            radius = love.math.random(6000, 12000),
            healthRegen = love.math.random(5, 15), -- Health regeneration per second
            fuelConsumption = love.math.random(3, 8), -- Fuel consumption per second
            pulse = love.math.random(),
            pulseSpeed = love.math.random(0.02, 0.05),
            sporeDrones = {},
            sporeSpawnTimer = 0,
            sporeSpawnInterval = love.math.random(5, 15),
            color = {
                love.math.random(0.1, 0.4),  -- R (low for green/blue dominance)
                love.math.random(0.6, 0.9),  -- G (high for organic green)
                love.math.random(0.3, 0.7),  -- B 
                love.math.random(0.1, 0.3)   -- A
            },
            cellPattern = {},
            type = "bio_nebula"
        }
        
        -- Generate organic cell pattern
        for j = 1, 20 do
            local cellAngle = love.math.random() * math.pi * 2
            local cellDist = love.math.random(0, bioNebula.radius * 0.8)
            table.insert(bioNebula.cellPattern, {
                x = math.cos(cellAngle) * cellDist,
                y = math.sin(cellAngle) * cellDist,
                size = love.math.random(20, 80),
                pulseOffset = love.math.random() * math.pi * 2,
                pulseSpeed = love.math.random(0.1, 0.3)
            })
        end
        
        table.insert(bionebulae, bioNebula)
    end
end

-- NEW: Create spore drone
function createSporeDrone(x, y, bioNebula)
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newCircleShape(15)
    local fixture = love.physics.newFixture(body, shape, 0.3)
    fixture:setSensor(true)
    
    local drone = {
        body = body,
        shape = shape,
        bioNebula = bioNebula,
        life = love.math.random(300, 600), -- frames
        maxLife = 600,
        pulse = 0,
        pulseSpeed = love.math.random(0.1, 0.2),
        movementTimer = 0,
        movementChange = love.math.random(2, 5),
        damage = 2,
        health = 10
    }
    
    -- Give random initial velocity
    local angle = love.math.random() * math.pi * 2
    local speed = love.math.random(50, 150)
    body:setLinearVelocity(math.cos(angle) * speed, math.sin(angle) * speed)
    
    table.insert(bioNebula.sporeDrones, drone)
    return drone
end

-- REPLACED: Update tesseracts (call from updateCosmicObjects or love.update)
function updateTesseracts(dt)
    for _, t in ipairs(tesseracts) do
        -- advance rotation angles
        for i = 1, 6 do
            t.rotation4D[i] = (t.rotation4D[i] + (t.rotationSpeed[i] or 0) * dt) % (math.pi * 2)
        end

        -- pulse
        t.pulse = (t.pulse + t.pulseSpeed * dt) % (math.pi * 2)

        -- project 4D vertices to 3D then 2D
        t.vertices = {}
        local perspective = 2.5 -- safer perspective factor
        for idx, v4 in ipairs(t.vertices4D) do
            local x, y, z, w = v4[1], v4[2], v4[3], v4[4]
            -- apply full 6-plane rotation
            x, y, z, w = rotate4D(x, y, z, w, t.rotation4D)

            -- small scaling so the hypercube isn't too huge
            local scale = 0.9

            -- project 4D -> 3D by perspective on w
            local denom = perspective - (w * 0.6) -- reduce impact of w
            if math.abs(denom) < 0.0001 then denom = 0.0001 * (denom >= 0 and 1 or -1) end
            local px3 = (x * scale) / denom
            local py3 = (y * scale) / denom
            local pz3 = (z * scale) / denom

            -- map 3D to world 2D (ignore true 3D camera; use pz3 for depth sort)
            local worldX = t.x + px3 * t.size
            local worldY = t.y + py3 * t.size

            table.insert(t.vertices, {
                x = worldX,
                y = worldY,
                z = pz3,
                original4D = {v4[1], v4[2], v4[3], v4[4]}
            })
        end

        -- player interactions
        if PlayerX[1] then
            local player = PlayerX[1]
            local px, py = player.body:getPosition()
            local dx, dy = px - t.x, py - t.y
            local distance = math.sqrt(dx*dx + dy*dy)

            -- energy field
            if distance < t.energyField.radius then
                local recharge = (t.energyField.strength * dt)
                shipSystems.energy = math.min(shipSystems.maxEnergy, shipSystems.energy + recharge)
                if love.math.random() < 0.12 then
                    createTesseractEnergyParticle(t.x + love.math.random(-t.size, t.size),
                                                  t.y + love.math.random(-t.size, t.size),
                                                  {0.7,0.3,1,1})
                end
            end

            -- anomaly field effects (frame-rate stable quantum flux)
            if distance < t.anomalyField.radius then
                -- small message occasionally
                if love.math.random() < 0.01 then setGameMessage("TIME DISTORTION", 1.5) end

                -- quantum flux: probability this frame = 1 - exp(-rate * dt)
                local rate = t.anomalyField.quantumFlux or 0.0
                local prob = 1 - math.exp(-rate * dt)
                if love.math.random() < prob then
                    -- teleport somewhere within anomaly radius (but biased outward)
                    local a = love.math.random() * 2 * math.pi
                    local r = love.math.random(t.size * 0.2, t.anomalyField.radius * 0.9)
                    local newX = t.x + math.cos(a) * r
                    local newY = t.y + math.sin(a) * r

                    player.body:setPosition(newX, newY)
                    player.body:setLinearVelocity(0, 0)
                    player.body:setAngularVelocity(0)

                    createTeleportEffect(px, py)
                    createTeleportEffect(newX, newY)
                    setGameMessage("QUANTUM FLUX TELEPORT!", 2.5)
                end
            end
        end
    end
end


-- NEW: Update bio nebulae
function updateBioNebulae(dt)
    for _, bioNebula in ipairs(bionebulae) do
        -- Update pulse
        bioNebula.pulse = bioNebula.pulse + bioNebula.pulseSpeed * dt
        if bioNebula.pulse > math.pi * 2 then
            bioNebula.pulse = bioNebula.pulse - math.pi * 2
        end
        
        -- Update cell patterns
        for _, cell in ipairs(bioNebula.cellPattern) do
            cell.pulseOffset = cell.pulseOffset + cell.pulseSpeed * dt
        end
        
        -- Spawn spore drones
        bioNebula.sporeSpawnTimer = bioNebula.sporeSpawnTimer + dt
        if bioNebula.sporeSpawnTimer >= bioNebula.sporeSpawnInterval then
            bioNebula.sporeSpawnTimer = 0
            
            local angle = love.math.random() * math.pi * 2
            local distance = love.math.random(bioNebula.radius * 0.3, bioNebula.radius * 0.8)
            local spawnX = bioNebula.x + math.cos(angle) * distance
            local spawnY = bioNebula.y + math.sin(angle) * distance
            
            createSporeDrone(spawnX, spawnY, bioNebula)
        end
        
        -- Update spore drones
        for i = #bioNebula.sporeDrones, 1, -1 do
            local drone = bioNebula.sporeDrones[i]
            drone.life = drone.life - 1
            drone.pulse = drone.pulse + drone.pulseSpeed
            drone.movementTimer = drone.movementTimer + dt
            
            -- Change movement direction periodically
            if drone.movementTimer >= drone.movementChange then
                drone.movementTimer = 0
                local angle = love.math.random() * math.pi * 2
                local speed = love.math.random(50, 150)
                drone.body:setLinearVelocity(math.cos(angle) * speed, math.sin(angle) * speed)
            end
            
            -- Remove dead drones
            if drone.life <= 0 or drone.health <= 0 then
                drone.body:destroy()
                table.remove(bioNebula.sporeDrones, i)
            end
        end
        
        -- Check player interaction
        if PlayerX[1] and not shipSystems.landed and not shipSystems.docked then
            local player = PlayerX[1]
            local px, py = player.body:getPosition()
            local dx, dy = px - bioNebula.x, py - bioNebula.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < bioNebula.radius then
                -- Health regeneration
                if shipSystems.health < shipSystems.maxHealth then
                    shipSystems.health = math.min(shipSystems.maxHealth, 
                        shipSystems.health + bioNebula.healthRegen * dt)
                end
                
                -- Fuel consumption
                shipSystems.fuel = math.max(0, shipSystems.fuel - bioNebula.fuelConsumption * dt)
                
                -- Visual feedback
                if love.math.random() < 0.2 then
                    createBioParticle(px, py, bioNebula.color)
                end
            end
            
            -- Check spore drone collisions
            for _, drone in ipairs(bioNebula.sporeDrones) do
                local dx, dy = px - drone.body:getX(), py - drone.body:getY()
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance < 40 then -- Collision radius
                    applyDamage(drone.damage, "Spore Drone")
                    drone.health = 0 -- Destroy drone on collision
                    
                    createDamageEffect(px, py, {0.5, 1, 0.5})
                end
            end
        end
    end
end

-- NEW: Create tesseract energy particle
function createTesseractEnergyParticle(x, y, color)
    local angle = love.math.random() * math.pi * 2
    local speed = love.math.random(50, 200)
    table.insert(particles, {
        x = x, y = y,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        life = love.math.random(30, 60),
        color = color or {0.7, 0.3, 1, 1},
        size = love.math.random(2, 4),
        glow = true
    })
end

-- NEW: Create bio particle
function createBioParticle(x, y, color)
    local angle = love.math.random() * math.pi * 2
    local speed = love.math.random(20, 80)
    table.insert(particles, {
        x = x, y = y,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        life = love.math.random(40, 80),
        color = {color[1], color[2], color[3], 0.7},
        size = love.math.random(1, 3),
        organic = true
    })
end

-- OPTIONAL: improved draw that depth-sorts vertices/edges slightly (replace your drawTesseracts if you want)
function drawTesseracts()
    for _, t in ipairs(tesseracts) do
        local pulseFactor = 0.7 + 0.3 * math.sin(t.pulse)

        -- energy & anomaly fields
        love.graphics.setColor(0.7, 0.3, 1, 0.08 * pulseFactor)
        love.graphics.circle("fill", t.x, t.y, t.energyField.radius)

        love.graphics.setColor(0.9, 0.5, 0.2, 0.04 * pulseFactor)
        love.graphics.circle("fill", t.x, t.y, t.anomalyField.radius)

        -- depth sort vertices by z descending (furthest drawn first)
        table.sort(t.vertices, function(a,b) return a.z < b.z end)

        -- draw edges (use vertex indices so fetch from t.vertices by index)
        love.graphics.setLineWidth(2)
        for _, edge in ipairs(t.edges) do
            local v1 = t.vertices[edge[1]]
            local v2 = t.vertices[edge[2]]
            if v1 and v2 then
                -- color varies by original4D.x and pulse
                local intensity = 0.5 + 0.5 * pulseFactor
                local r = 0.3 + 0.7 * ((v1.original4D[1] + 1) / 2) * intensity
                local g = 0.1 + 0.9 * ((v1.original4D[2] + 1) / 2) * intensity
                local b = 0.7 + 0.3 * ((v1.original4D[3] + 1) / 2) * intensity
                love.graphics.setColor(r, g, b, 0.9 * pulseFactor)
                love.graphics.line(v1.x, v1.y, v2.x, v2.y)
            end
        end
        love.graphics.setLineWidth(1)

        -- vertices
        for _, v in ipairs(t.vertices) do
            local size = 6 + 3 * math.sin(t.pulse + (v.original4D[4] or 0) * math.pi)
            local r = 0.8 + 0.2 * ((v.original4D[1] + 1) / 2)
            local g = 0.4 + 0.6 * ((v.original4D[2] + 1) / 2)
            local b = 1.0
            love.graphics.setColor(r, g, b, 0.95 * pulseFactor)
            love.graphics.circle("fill", v.x, v.y, size)
            love.graphics.setColor(1, 1, 1, 0.6 * pulseFactor)
            love.graphics.circle("fill", v.x, v.y, size * 0.45)
        end

        -- label and debug info
        love.graphics.setColor(1,1,1,0.8)
        love.graphics.print("TESSERACT", t.x - 40, t.y - t.size - 40)
        if game.debugMode then
            love.graphics.print("EnergyField: "..t.energyField.radius, t.x - 40, t.y + t.size + 10)
            love.graphics.print("AnomalyField: "..t.anomalyField.radius, t.x - 40, t.y + t.size + 30)
        end
    end
end

-- NEW: Draw bio nebulae
function drawBioNebulae()
    for _, bioNebula in ipairs(bionebulae) do
        local pulseFactor = 0.8 + 0.2 * math.sin(bioNebula.pulse)
        
        -- Draw main nebula cloud
        love.graphics.setColor(
            bioNebula.color[1], 
            bioNebula.color[2], 
            bioNebula.color[3], 
            bioNebula.color[4] * pulseFactor
        )
        love.graphics.circle("fill", bioNebula.x, bioNebula.y, bioNebula.radius)
        
        -- Draw organic cell pattern
        for _, cell in ipairs(bioNebula.cellPattern) do
            local cellPulse = 0.7 + 0.3 * math.sin(bioNebula.pulse + cell.pulseOffset)
            local cellX = bioNebula.x + cell.x
            local cellY = bioNebula.y + cell.y
            
            -- Cell body
            love.graphics.setColor(
                bioNebula.color[1] + 0.3, 
                bioNebula.color[2] + 0.1, 
                bioNebula.color[3] - 0.2, 
                0.6 * cellPulse
            )
            love.graphics.circle("fill", cellX, cellY, cell.size * cellPulse)
            
            -- Cell nucleus
            love.graphics.setColor(1, 0.8, 0.9, 0.8 * cellPulse)
            love.graphics.circle("fill", cellX, cellY, cell.size * 0.3 * cellPulse)
            
            -- Cell membrane
            love.graphics.setColor(0.2, 0.8, 0.3, 0.4 * cellPulse)
            love.graphics.circle("line", cellX, cellY, cell.size * cellPulse)
        end
        
        -- Draw spore drones
        for _, drone in ipairs(bioNebula.sporeDrones) do
            local x, y = drone.body:getPosition()
            local dronePulse = 0.5 + 0.5 * math.sin(drone.pulse)
            local healthPercent = drone.life / drone.maxLife
            
            -- Drone body
            love.graphics.setColor(0.3, 0.8, 0.4, 0.9 * healthPercent)
            love.graphics.circle("fill", x, y, 15 * dronePulse)
            
            -- Drone core
            love.graphics.setColor(0.9, 1, 0.5, 0.8 * healthPercent)
            love.graphics.circle("fill", x, y, 6 * dronePulse)
            
            -- Health indicator
            if game.debugMode then
                love.graphics.setColor(1, 1, 1, 0.7)
                love.graphics.print(math.floor(healthPercent * 100) .. "%", x - 10, y + 20)
            end
        end
        
        -- Draw label
        love.graphics.setColor(0.2, 1, 0.3, 0.8)
        love.graphics.print("BIO NEBULA", bioNebula.x - 40, bioNebula.y - bioNebula.radius - 30)
        
        -- Draw interaction info
        if PlayerX[1] then
            local player = PlayerX[1]
            local px, py = player.body:getPosition()
            local dx, dy = px - bioNebula.x, py - bioNebula.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < bioNebula.radius then
                love.graphics.setColor(0, 1, 0, 0.8)
                love.graphics.print("HEALTH REGENERATION ACTIVE", bioNebula.x - 80, bioNebula.y + bioNebula.radius + 10)
                love.graphics.print("FUEL CONSUMPTION: " .. bioNebula.fuelConsumption .. "/s", bioNebula.x - 60, bioNebula.y + bioNebula.radius + 30)
            end
        end
    end
end

-- NEW: Create supermassive black hole
function createSupermassiveBlackHole()
    local supermassive = {
        body = love.physics.newBody(world, 0, 500000, "static"), -- Far away from solar system
        radius = 10000, -- Massive size
        gravityRadius = 300000, -- Huge gravity reach
        gravityStrength = 50000000, -- Extremely powerful gravity
        type = "supermassive_blackhole",
        rotation = 0,
        rotationSpeed = 0.001, -- Slow rotation
        damageRadius = 20000,
        damagePerSecond = 100, -- High damage
        name = "SUPERMASSIVE BLACK HOLE"
    }
    
    local shape = love.physics.newCircleShape(supermassive.radius)
    supermassive.fixture = love.physics.newFixture(supermassive.body, shape, 1)
    supermassive.fixture:setSensor(true)
    
    table.insert(blackholes, supermassive)
end

-- NEW: Create demon planet
function createDemonPlanet()
    local angle = love.math.random() * math.pi * 2
    local distance = love.math.random(120000, 180000) -- Far out
    local x = math.cos(angle) * distance
    local y = math.sin(angle) * distance
    
    local demon = createPlanet(x, y, 1200, 3000, 60000, "DEMON PLANET", {0.8, 0.1, 0.1})
    demon.isDemon = true
    demon.horns = {}
    demon.orbitRadius = distance
    demon.orbitSpeed = 0.05
    demon.orbitAngle = angle
    demon.initialAngle = angle
    demon.landingRadius = demon.radius + 100
    demon.canLand = false -- Can't land on demon planet
    
    -- Create horn positions around the planet
    for i = 1, 8 do
        local hornAngle = (i / 8) * math.pi * 2
        table.insert(demon.horns, {
            angle = hornAngle,
            length = love.math.random(150, 250),
            width = love.math.random(30, 60)
        })
    end
    
    table.insert(planets, demon)
end

-- NEW: Create a bullet
function createBullet(x, y, angle)
    local speed = 800
    local vx = math.cos(angle) * speed
    local vy = math.sin(angle) * speed
    
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newCircleShape(5)
    local fixture = love.physics.newFixture(body, shape, 0.1)
    fixture:setSensor(true) -- Don't collide physically, just detect
    
    body:setLinearVelocity(vx, vy)
    
    local bullet = {
        body = body,
        shape = shape,
        life = 2, -- seconds
        damage = shipSystems.weapons.damage
    }
    
    table.insert(bullets, bullet)
    return bullet
end

-- NEW: Update bullets
function updateBullets(dt)
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.life = bullet.life - dt
        
        if bullet.life <= 0 then
            bullet.body:destroy()
            table.remove(bullets, i)
        else
            -- Check collision with enemies
            for j = #enemies, 1, -1 do
                local enemy = enemies[j]
                if not enemy.dead then
                    local bx, by = bullet.body:getPosition()
                    local ex, ey = enemy.body:getPosition()
                    local dx, dy = bx - ex, by - ey
                    local distance = math.sqrt(dx * dx + dy * dy)
                    
                    if distance < 30 then -- Collision radius
                        -- Hit enemy!
                        enemy.health = enemy.health - bullet.damage
                        
                        if enemy.health <= 0 then
                            killEnemy(enemy, j)
                            game.score = game.score + 50
                            createFloatingText(ex, ey - 50, "Enemy Destroyed! +50")
                        else
                            createDamageEffect(ex, ey, {1, 0, 0})
                            createFloatingText(ex, ey - 50, "-" .. bullet.damage)
                        end
                        
                        -- Remove bullet
                        bullet.body:destroy()
                        table.remove(bullets, i)
                        break
                    end
                end
            end
        end
    end
end

-- NEW: Kill enemy and make it float as debris
function killEnemy(enemy, index)
    enemy.dead = true
    enemy.deathTime = love.timer.getTime()
    
    -- Change enemy color to indicate dead
    enemy.deadColor = {0.3, 0.3, 0.3} -- Gray
    
    -- Stop AI behavior but keep physics
    -- The body will continue to move due to physics and gravity
    
    -- Move to dead enemies table
    table.insert(deadEnemies, enemy)
    table.remove(enemies, index)
    
    -- Create explosion effect
    createExplosionEffect(enemy.body:getPosition())
end

-- NEW: Create explosion effect
function createExplosionEffect(x, y)
    for i = 1, 20 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(50, 200)
        table.insert(particles, {
            x = x, y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = love.math.random(20, 40),
            color = {1, 0.5, 0, 1}, -- Orange explosion
            size = love.math.random(2, 5)
        })
    end
end

-- NEW: Fire weapon
function fireWeapon()
    if shipSystems.weapons.cooldown <= 0 and shipSystems.energy >= shipSystems.weapons.energyCost then
        if PlayerX[1] then
            local player = PlayerX[1]
            local x, y = player.body:getPosition()
            local angle = player.body:getAngle()
            
            -- Create bullet at player's position facing forward
            createBullet(x, y, angle)
            
            -- Consume energy
            shipSystems.energy = math.max(0, shipSystems.energy - shipSystems.weapons.energyCost)
            
            -- Set cooldown
            shipSystems.weapons.cooldown = shipSystems.weapons.maxCooldown
            
            -- Create muzzle flash
            local bx, by = player.body:getWorldPoint(0, -player.h / 2)
            for i = 1, 5 do
                local flashAngle = angle + love.math.random(-0.2, 0.2)
                local speed = love.math.random(100, 200)
                table.insert(particles, {
                    x = bx, y = by,
                    vx = math.cos(flashAngle) * speed,
                    vy = math.sin(flashAngle) * speed,
                    life = love.math.random(10, 20),
                    color = {1, 1, 0, 1}, -- Yellow flash
                    size = love.math.random(1, 3)
                })
            end
        end
    end
end


-- NEW: Create supermassive black hole
function createSupermassiveBlackHole()
    local supermassive = {
        body = love.physics.newBody(world, 0, 500000, "static"), -- Far away from solar system
        radius = 10000, -- Massive size
        gravityRadius = 300000, -- Huge gravity reach
        gravityStrength = 50000000, -- Extremely powerful gravity
        type = "supermassive_blackhole",
        rotation = 0,
        rotationSpeed = 0.001, -- Slow rotation
        damageRadius = 20000,
        damagePerSecond = 100, -- High damage
        name = "SUPERMASSIVE BLACK HOLE"
    }
    
    local shape = love.physics.newCircleShape(supermassive.radius)
    supermassive.fixture = love.physics.newFixture(supermassive.body, shape, 1)
    supermassive.fixture:setSensor(true)
    
    table.insert(blackholes, supermassive)
end

-- NEW: Create demon planet
function createDemonPlanet()
    local angle = love.math.random() * math.pi * 2
    local distance = love.math.random(120000, 180000) -- Far out
    local x = math.cos(angle) * distance
    local y = math.sin(angle) * distance
    
    local demon = createPlanet(x, y, 1200, 3000, 60000, "DEMON PLANET", {0.8, 0.1, 0.1})
    demon.isDemon = true
    demon.horns = {}
    demon.orbitRadius = distance
    demon.orbitSpeed = 0.05
    demon.orbitAngle = angle
    demon.initialAngle = angle
    demon.landingRadius = demon.radius + 100
    demon.canLand = false -- Can't land on demon planet
    
    -- Create horn positions around the planet
    for i = 1, 8 do
        local hornAngle = (i / 8) * math.pi * 2
        table.insert(demon.horns, {
            angle = hornAngle,
            length = love.math.random(150, 250),
            width = love.math.random(30, 60)
        })
    end
    
    table.insert(planets, demon)
end

-- NEW: Create a bullet
function createBullet(x, y, angle)
    local speed = 800
    local vx = math.cos(angle) * speed
    local vy = math.sin(angle) * speed
    
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newCircleShape(5)
    local fixture = love.physics.newFixture(body, shape, 0.1)
    fixture:setSensor(true) -- Don't collide physically, just detect
    
    body:setLinearVelocity(vx, vy)
    
    local bullet = {
        body = body,
        shape = shape,
        life = 2, -- seconds
        damage = shipSystems.weapons.damage
    }
    
    table.insert(bullets, bullet)
    return bullet
end

-- NEW: Update bullets
function updateBullets(dt)
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.life = bullet.life - dt
        
        if bullet.life <= 0 then
            bullet.body:destroy()
            table.remove(bullets, i)
        else
            -- Check collision with enemies
            for j = #enemies, 1, -1 do
                local enemy = enemies[j]
                if not enemy.dead then
                    local bx, by = bullet.body:getPosition()
                    local ex, ey = enemy.body:getPosition()
                    local dx, dy = bx - ex, by - ey
                    local distance = math.sqrt(dx * dx + dy * dy)
                    
                    if distance < 30 then -- Collision radius
                        -- Hit enemy!
                        enemy.health = enemy.health - bullet.damage
                        
                        if enemy.health <= 0 then
                            killEnemy(enemy, j)
                            game.score = game.score + 50
                            createFloatingText(ex, ey - 50, "Enemy Destroyed! +50")
                        else
                            createDamageEffect(ex, ey, {1, 0, 0})
                            createFloatingText(ex, ey - 50, "-" .. bullet.damage)
                        end
                        
                        -- Remove bullet
                        bullet.body:destroy()
                        table.remove(bullets, i)
                        break
                    end
                end
            end
        end
    end
end

-- NEW: Kill enemy and make it float as debris
function killEnemy(enemy, index)
    enemy.dead = true
    enemy.deathTime = love.timer.getTime()
    
    -- Change enemy color to indicate dead
    enemy.deadColor = {0.3, 0.3, 0.3} -- Gray
    
    -- Stop AI behavior but keep physics
    -- The body will continue to move due to physics and gravity
    
    -- Move to dead enemies table
    table.insert(deadEnemies, enemy)
    table.remove(enemies, index)
    
    -- Create explosion effect
    createExplosionEffect(enemy.body:getPosition())
end

-- NEW: Create explosion effect
function createExplosionEffect(x, y)
    for i = 1, 20 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(50, 200)
        table.insert(particles, {
            x = x, y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = love.math.random(20, 40),
            color = {1, 0.5, 0, 1}, -- Orange explosion
            size = love.math.random(2, 5)
        })
    end
end

-- NEW: Fire weapon
function fireWeapon()
    if shipSystems.weapons.cooldown <= 0 and shipSystems.energy >= shipSystems.weapons.energyCost then
        if PlayerX[1] then
            local player = PlayerX[1]
            local x, y = player.body:getPosition()
            local angle = player.body:getAngle()
            
            -- Create bullet at player's position facing forward
            createBullet(x, y, angle)
            
            -- Consume energy
            shipSystems.energy = math.max(0, shipSystems.energy - shipSystems.weapons.energyCost)
            
            -- Set cooldown
            shipSystems.weapons.cooldown = shipSystems.weapons.maxCooldown
            
            -- Create muzzle flash
            local bx, by = player.body:getWorldPoint(0, -player.h / 2)
            for i = 1, 5 do
                local flashAngle = angle + love.math.random(-0.2, 0.2)
                local speed = love.math.random(100, 200)
                table.insert(particles, {
                    x = bx, y = by,
                    vx = math.cos(flashAngle) * speed,
                    vy = math.sin(flashAngle) * speed,
                    life = love.math.random(10, 20),
                    color = {1, 1, 0, 1}, -- Yellow flash
                    size = love.math.random(1, 3)
                })
            end
        end
    end
end

function createMagnetars()
    -- Create magnetars (highly magnetic neutron stars)
    for i = 1, 2 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(130000, 200000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local magnetar = {
            body = love.physics.newBody(world, x, y, "static"),
            radius = love.math.random(150, 300),
            magneticRadius = love.math.random(4000, 8000),
            magneticStrength = love.math.random(100000, 300000),
            pulse = 0,
            pulseSpeed = love.math.random(0.1, 0.2),
            flareAngle = love.math.random() * math.pi * 2,
            flareTimer = 0
        }
        
        local shape = love.physics.newCircleShape(magnetar.radius)
        magnetar.fixture = love.physics.newFixture(magnetar.body, shape, 1)
        magnetar.fixture:setSensor(true)
        
        table.insert(magnetars, magnetar)
    end
end

function createAsteroidFields()
    -- Create dense asteroid fields with more hazards
    for i = 1, 3 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(70000, 150000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local field = {
            x = x, y = y,
            radius = love.math.random(5000, 12000),
            density = love.math.random(50, 100),
            asteroids = {}
        }
        
        -- Create asteroids in this field
        for j = 1, field.density do
            local astAngle = love.math.random() * math.pi * 2
            local astDist = love.math.random(0, field.radius)
            local astX = x + math.cos(astAngle) * astDist
            local astY = y + math.sin(astAngle) * astDist
            local size = love.math.random(20, 80)
            
            local asteroid = createAsteroidObj(astX, astY, size)
            asteroid.field = field
            table.insert(field.asteroids, asteroid)
            table.insert(box_i, asteroid)
            
            -- Give field asteroids some random motion
            local speed = love.math.random(50, 200)
            local vx = love.math.random(-speed, speed)
            local vy = love.math.random(-speed, speed)
            asteroid.body:setLinearVelocity(vx, vy)
        end
        
        table.insert(asteroidfields, field)
    end
end

function createSpaceStations()
    -- Create space stations near planets
    for i = 1, 4 do
        local planetIndex = love.math.random(2, #planets) -- Don't put stations near sun
        local planet = planets[planetIndex]
        local px, py = planet.body:getPosition()
        
        local angle = love.math.random() * math.pi * 2
        local distance = planet.radius + love.math.random(800, 1500)
        local x = px + math.cos(angle) * distance
        local y = py + math.sin(angle) * distance
        
        local station = {
            body = love.physics.newBody(world, x, y, "static"),
            radius = love.math.random(200, 400),
            dockingRadius = 150,
            planet = planet,
            rotation = 0,
            rotationSpeed = love.math.random(0.01, 0.03),
            type = "station"
        }
        
        local shape = love.physics.newCircleShape(station.radius)
        station.fixture = love.physics.newFixture(station.body, shape, 1)
        station.fixture:setSensor(true)
        
        -- Give station orbital velocity
        local speed = math.sqrt(planet.gravityStrength / distance) * 0.95
        local vx = -math.sin(angle) * speed
        local vy = math.cos(angle) * speed
        station.body:setLinearVelocity(vx, vy)
        
        table.insert(spacestations, station)
    end
end

function createSolarSystem()
    -- Create the SUN at center with massive gravity
    local sun = createPlanet(0, 0, 5000, 80000, 500000, "SUN", {1, 1, 0}) -- Yellow sun
    sun.fixture:setSensor(false) -- Sun is solid
    sun.isSun = true
    table.insert(planets, sun)
    
    -- Create planets orbiting the sun with colors
    -- Format: {orbitRadius, radius, gravityRadius, gravityStrength, name, orbitSpeed, color}
    local planetData = {
        {15000, 800, 2000, 20000, "Mercury", 100, {0.7, 0.7, 0.7}}, -- Gray
        {25000, 1200, 3000, 35000, "Venus", 130, {0.9, 0.7, 0.3}}, -- Golden
        {35000, 1500, 4000, 50000, "Earth", 1.0, {0.2, 0.4, 0.9}}, -- Blue
        {45000, 1300, 3500, 30000, "Mars", 0.8, {0.8, 0.3, 0.2}}, -- Red
        {60000, 3000, 6000, 150000, "Jupiter", 0.4, {0.8, 0.6, 0.4}}, -- Tan
        {75000, 2800, 5000, 120000, "Saturn", 0.3, {0.9, 0.8, 0.5}}, -- Light yellow
        {90000, 2000, 4000, 80000, "Uranus", 0.2, {0.4, 0.7, 0.9}}, -- Light blue
        {105000, 1900, 3800, 70000, "Neptune", 0.1, {0.2, 0.3, 0.8}}  -- Dark blue
    }
    
    for i, data in ipairs(planetData) do
        local angle = love.math.random() * math.pi * 2
        local x = math.cos(angle) * data[1]
        local y = math.sin(angle) * data[1]
        
        local planet = createPlanet(x, y, data[2], data[3], data[4], data[5], data[7])
        planet.orbitRadius = data[1]
        planet.orbitSpeed = data[6]
        planet.orbitAngle = angle
        planet.initialAngle = angle
        planet.landingRadius = data[2] + 100 -- Landing zone just above surface
        
        table.insert(planets, planet)
    end
    
    -- Create orbiters/moons around planets
    createOrbiters()
end

function createCosmicObjects()
    -- Create black holes
    for i = 1, 3 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(120000, 200000) -- Far out in space
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local blackhole = {
            body = love.physics.newBody(world, x, y, "static"),
            radius = love.math.random(300, 600),
            gravityRadius = love.math.random(5000, 15000),
            gravityStrength = love.math.random(300000, 800000),
            type = "blackhole",
            rotation = 0,
            rotationSpeed = love.math.random(0.01, 0.05),
            damageRadius = love.math.random(1000, 2000),
            damagePerSecond = 50
        }
        
        local shape = love.physics.newCircleShape(blackhole.radius)
        blackhole.fixture = love.physics.newFixture(blackhole.body, shape, 1)
        blackhole.fixture:setSensor(true)
        
        table.insert(blackholes, blackhole)
    end
    
    -- Create white holes (repulsive gravity)
    for i = 1, 2 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(80000, 150000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local whitehole = {
            body = love.physics.newBody(world, x, y, "static"),
            radius = love.math.random(200, 400),
            repulsionRadius = love.math.random(3000, 8000),
            repulsionStrength = love.math.random(100000, 300000),
            type = "whitehole",
            pulse = 0,
            pulseSpeed = love.math.random(0.05, 0.1),
            energyRadius = love.math.random(1000, 2500),
            energyRecharge = 10 -- Energy recharge per second when nearby
        }
        
        local shape = love.physics.newCircleShape(whitehole.radius)
        whitehole.fixture = love.physics.newFixture(whitehole.body, shape, 1)
        whitehole.fixture:setSensor(true)
        
        table.insert(whiteholes, whitehole)
    end
    
    -- Create wormholes (pairs that teleport between each other)
    for i = 1, 2 do
        local angle1 = love.math.random() * math.pi * 2
        local distance1 = love.math.random(60000, 120000)
        local x1 = math.cos(angle1) * distance1
        local y1 = math.sin(angle1) * distance1
        
        local angle2 = angle1 + math.pi + love.math.random(-0.5, 0.5) -- Opposite side
        local distance2 = love.math.random(60000, 120000)
        local x2 = math.cos(angle2) * distance2
        local y2 = math.sin(angle2) * distance2
        
        local wormhole1 = {
            body = love.physics.newBody(world, x1, y1, "static"),
            radius = love.math.random(150, 300),
            type = "wormhole",
            pairX = x2,
            pairY = y2,
            rotation = 0,
            rotationSpeed = love.math.random(0.02, 0.05),
            cooldown = 0,
            stability = love.math.random(80, 100) -- Wormhole stability percentage
        }
        
        local wormhole2 = {
            body = love.physics.newBody(world, x2, y2, "static"),
            radius = love.math.random(150, 300),
            type = "wormhole",
            pairX = x1,
            pairY = y1,
            rotation = math.pi, -- Start rotated relative to pair
            rotationSpeed = love.math.random(0.02, 0.05),
            cooldown = 0,
            stability = wormhole1.stability
        }
        
        local shape1 = love.physics.newCircleShape(wormhole1.radius)
        wormhole1.fixture = love.physics.newFixture(wormhole1.body, shape1, 1)
        wormhole1.fixture:setSensor(true)
        
        local shape2 = love.physics.newCircleShape(wormhole2.radius)
        wormhole2.fixture = love.physics.newFixture(wormhole2.body, shape2, 1)
        wormhole2.fixture:setSensor(true)
        
        table.insert(wormholes, wormhole1)
        table.insert(wormholes, wormhole2)
    end
    
    -- Create nebulae (cosmic gas clouds)
    for i = 1, 5 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(50000, 180000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local nebula = {
            x = x, y = y,
            radius = love.math.random(8000, 20000),
            color = {
                love.math.random(0.3, 0.8),
                love.math.random(0.1, 0.5),
                love.math.random(0.4, 0.9),
                love.math.random(0.05, 0.2)
            },
            pulse = love.math.random(),
            pulseSpeed = love.math.random(0.01, 0.03),
            fuelBonus = love.math.random(5, 15) -- Fuel recharge when flying through
        }
        
        table.insert(nebulae, nebula)
    end
end

function createAdvancedCosmicObjects()
    -- Create comets
    for i = 1, 8 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(50000, 200000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local comet = {
            body = love.physics.newBody(world, x, y, "dynamic"),
            radius = love.math.random(40, 80),
            tailParticles = {},
            tailLength = love.math.random(20, 40),
            speed = love.math.random(500, 1500),
            angle = love.math.random() * math.pi * 2,
            color = {love.math.random(0.7, 1), love.math.random(0.7, 1), love.math.random(0.7, 1)},
            damage = 10,
            iceContent = love.math.random(50, 100) -- Can be mined for fuel
        }
        
        local shape = love.physics.newCircleShape(comet.radius)
        comet.fixture = love.physics.newFixture(comet.body, shape, 0.5)
        comet.fixture:setSensor(true)
        
        -- Set initial velocity
        local vx = math.cos(comet.angle) * comet.speed
        local vy = math.sin(comet.angle) * comet.speed
        comet.body:setLinearVelocity(vx, vy)
        
        table.insert(comets, comet)
    end
    
    -- Create pulsars
    for i = 1, 4 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(100000, 180000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local pulsar = {
            body = love.physics.newBody(world, x, y, "static"),
            radius = love.math.random(200, 400),
            pulseRadius = love.math.random(1000, 3000),
            pulseSpeed = love.math.random(0.1, 0.3),
            pulsePhase = love.math.random() * math.pi * 2,
            beamAngle = 0,
            beamSpeed = love.math.random(0.05, 0.15),
            active = true,
            radiationDamage = 5,
            scanJamRadius = love.math.random(2000, 5000)
        }
        
        local shape = love.physics.newCircleShape(pulsar.radius)
        pulsar.fixture = love.physics.newFixture(pulsar.body, shape, 1)
        pulsar.fixture:setSensor(true)
        
        table.insert(pulsars, pulsar)
    end
    
    -- Create quasars
    for i = 1, 2 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(150000, 250000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local quasar = {
            body = love.physics.newBody(world, x, y, "static"),
            radius = love.math.random(800, 1500),
            gravityRadius = love.math.random(15000, 30000),
            gravityStrength = love.math.random(1000000, 3000000),
            energyRadius = love.math.random(5000, 12000),
            pulse = 0,
            pulseSpeed = love.math.random(0.02, 0.06),
            jets = {
                angle1 = love.math.random() * math.pi * 2,
                angle2 = love.math.random() * math.pi * 2,
                length = love.math.random(5000, 15000)
            },
            jetDamage = 20,
            energyOutput = love.math.random(50, 100) -- Can recharge ship systems
        }
        
        local shape = love.physics.newCircleShape(quasar.radius)
        quasar.fixture = love.physics.newFixture(quasar.body, shape, 1)
        quasar.fixture:setSensor(true)
        
        table.insert(quasars, quasar)
    end
    
    -- Create supernovae remnants
    for i = 1, 3 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(80000, 160000)
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        
        local supernova = {
            x = x, y = y,
            radius = love.math.random(3000, 8000),
            expansion = 0,
            maxExpansion = love.math.random(1.5, 3.0),
            expansionSpeed = love.math.random(0.001, 0.005),
            active = true,
            color = {
                love.math.random(0.8, 1),
                love.math.random(0.4, 0.8),
                love.math.random(0.1, 0.4),
                0.3
            },
            shockwaveDamage = 15,
            remnantBonus = love.math.random(20, 50) -- Resources from studying remnants
        }
        
        table.insert(supernovae, supernova)
    end
end

function createOrbiters()
    for _, planet in ipairs(planets) do
        if not planet.isSun and planet.orbitRadius then
            local numOrbiters = love.math.random(1, 4) -- Moons
            for i = 1, numOrbiters do
                local moonDist = planet.radius + love.math.random(500, 1500) -- Further from planet
                local angle = love.math.random() * math.pi * 2
                local px, py = planet.body:getPosition()
                local ox = px + math.cos(angle) * moonDist
                local oy = py + math.sin(angle) * moonDist
                local moon = createOrbiter(ox, oy, love.math.random(30, 60)) -- Larger moons
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
    local shape = love.physics.newCircleShape(r * 2) -- Larger moons
    local fixture = love.physics.newFixture(body, shape, 0.1)
    fixture:setRestitution(0.3)
    return {
        body = body,
        shape = shape,
        r = r * 2
    }
end

function createPlanet(x, y, radius, gravityRadius, gravityStrength, name, color)
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
        visited = false,
        color = color or {0.5, 0.5, 0.5}, -- Default gray if no color provided
        resources = love.math.random(50, 200), -- Resources available for mining
        canLand = name ~= "SUN" and name ~= "Jupiter" -- Gas giants can't be landed on
    }
end

function createAsteroidBelts()
    -- Create multiple asteroid belts at different distances
    local beltData = {
        {minDist = 50000, maxDist = 55000, count = 200}, -- Between Mars and Jupiter
        {minDist = 80000, maxDist = 85000, count = 150}, -- Beyond Saturn
        {minDist = 120000, maxDist = 125000, count = 100} -- Outer belt
    }
    
    for _, belt in ipairs(beltData) do
        for i = 1, belt.count do
            local angle = love.math.random() * math.pi * 2
            local distance = love.math.random(belt.minDist, belt.maxDist)
            local x = math.cos(angle) * distance
            local y = math.sin(angle) * distance
            local size = love.math.random(10, 50) -- Larger asteroids
            table.insert(box_i, createAsteroidObj(x, y, size))
            
            -- Give asteroids some orbital velocity
            local speed = math.sqrt(500000 / distance) * love.math.random(0.8, 1.2)
            local vx = -math.sin(angle) * speed
            local vy = math.cos(angle) * speed
            box_i[#box_i].body:setLinearVelocity(vx, vy)
        end
    end
end

function createAsteroidObj(x, y, size)
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newRectangleShape(size * 2, size * 2) -- Larger asteroids
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
        w = size * 2,
        h = size * 2,
        size = size * 2,
        damage = 5,
        mineralContent = love.math.random(1, 10) -- Can be mined for resources
    }
end




-- MODIFIED: Update gravity to track total force on player
function updateGravity(dt)
    -- Reset gravity tracking
    debugInfo.totalGravityForce = {x = 0, y = 0, magnitude = 0}
    
    -- Apply planetary gravity
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
        for _, c in ipairs(comets) do table.insert(allBodies, c.body) end
        -- Planets also attract each other (except sun affects planets, planets don't affect sun)
        for _, otherPlanet in ipairs(planets) do
            if otherPlanet ~= planet and not otherPlanet.isSun and planet.isSun then
                table.insert(allBodies, otherPlanet.body)
            end
        end

        for _, body in ipairs(allBodies) do
            local force = applyBodyGravity(body, px, py, planet.gravityRadius, planet.gravityStrength, dt)
            -- Track player gravity
            if body == PlayerX[1].body and force then
                debugInfo.totalGravityForce.x = debugInfo.totalGravityForce.x + force.x
                debugInfo.totalGravityForce.y = debugInfo.totalGravityForce.y + force.y
            end
        end
    end
    
    -- Apply black hole gravity (very strong!)
    for _, blackhole in ipairs(blackholes) do
        local bx, by = blackhole.body:getPosition()
        
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
        for _, c in ipairs(comets) do table.insert(allBodies, c.body) end
        
        for _, body in ipairs(allBodies) do
            local force = applyBodyGravity(body, bx, by, blackhole.gravityRadius, blackhole.gravityStrength, dt)
            -- Track player gravity
            if body == PlayerX[1].body and force then
                debugInfo.totalGravityForce.x = debugInfo.totalGravityForce.x + force.x
                debugInfo.totalGravityForce.y = debugInfo.totalGravityForce.y + force.y
            end
        end
    end
    
    -- Apply white hole repulsion
    for _, whitehole in ipairs(whiteholes) do
        local wx, wy = whitehole.body:getPosition()
        
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
        for _, c in ipairs(comets) do table.insert(allBodies, c.body) end
        
        for _, body in ipairs(allBodies) do
            applyBodyRepulsion(body, wx, wy, whitehole.repulsionRadius, whitehole.repulsionStrength, dt)
        end
    end
    
    -- Apply quasar gravity
    for _, quasar in ipairs(quasars) do
        local qx, qy = quasar.body:getPosition()
        
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
        for _, c in ipairs(comets) do table.insert(allBodies, c.body) end
        
        for _, body in ipairs(allBodies) do
            local force = applyBodyGravity(body, qx, qy, quasar.gravityRadius, quasar.gravityStrength, dt)
            -- Track player gravity
            if body == PlayerX[1].body and force then
                debugInfo.totalGravityForce.x = debugInfo.totalGravityForce.x + force.x
                debugInfo.totalGravityForce.y = debugInfo.totalGravityForce.y + force.y
            end
        end
    end
    
    -- Apply magnetar magnetic forces
    for _, magnetar in ipairs(magnetars) do
        local mx, my = magnetar.body:getPosition()
        
        if PlayerX[1] then
            applyMagnetarEffects(PlayerX[1], mx, my, magnetar, dt)
        end
    end
    
    -- Calculate total gravity magnitude
    debugInfo.totalGravityForce.magnitude = math.sqrt(
        debugInfo.totalGravityForce.x * debugInfo.totalGravityForce.x +
        debugInfo.totalGravityForce.y * debugInfo.totalGravityForce.y
    )
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
        return {x = dirX * force, y = dirY * force}
    end
    return nil
end

function applyBodyRepulsion(body, px, py, repulsionRadius, repulsionStrength, dt)
    local bx, by = body:getPosition()
    local dx, dy = bx - px, by - py
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 0 and distance < repulsionRadius then
        local dirX, dirY = dx / distance, dy / distance
        -- Repulsive force
        local force = repulsionStrength / (distance * distance)
        body:applyForce(dirX * force, dirY * force)
    end
end

function applyMagnetarEffects(player, mx, my, magnetar, dt)
    local px, py = player.body:getPosition()
    local dx, dy = px - mx, py - my
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance < magnetar.magneticRadius then
        -- Magnetic force (attractive/repulsive based on orientation)
        local force = magnetar.magneticStrength / (distance * distance)
        player.body:applyForce(dx/distance * force, dy/distance * force)
        
        -- Disrupt systems if too close
        if distance < magnetar.magneticRadius * 0.3 then
            shipSystems.energy = math.max(0, shipSystems.energy - 5 * dt)
            if shipSystems.energy <= 0 then
                shipSystems.shields = math.max(0, shipSystems.shields - 10 * dt)
            end
        end
    end
end

function updateCosmicObjects(dt)
    -- Update black hole rotation
    for _, blackhole in ipairs(blackholes) do
        blackhole.rotation = blackhole.rotation + blackhole.rotationSpeed
    end
    
    -- Update white hole pulse
    for _, whitehole in ipairs(whiteholes) do
        whitehole.pulse = whitehole.pulse + whitehole.pulseSpeed
        if whitehole.pulse > math.pi * 2 then
            whitehole.pulse = whitehole.pulse - math.pi * 2
        end
    end
    
    -- Update wormhole rotation and cooldown
    for _, wormhole in ipairs(wormholes) do
        wormhole.rotation = wormhole.rotation + wormhole.rotationSpeed
        if wormhole.cooldown > 0 then
            wormhole.cooldown = wormhole.cooldown - dt
        end
    end
    
    -- Update nebula pulse
    for _, nebula in ipairs(nebulae) do
        nebula.pulse = nebula.pulse + nebula.pulseSpeed
        if nebula.pulse > math.pi * 2 then
            nebula.pulse = nebula.pulse - math.pi * 2
        end
    end
    
    -- Update comets
    for _, comet in ipairs(comets) do
        updateComet(comet, dt)
    end
    
    -- Update pulsars
    for _, pulsar in ipairs(pulsars) do
        pulsar.beamAngle = pulsar.beamAngle + pulsar.beamSpeed
        pulsar.pulsePhase = pulsar.pulsePhase + pulsar.pulseSpeed
    end
    
    -- Update quasars
    for _, quasar in ipairs(quasars) do
        quasar.pulse = quasar.pulse + quasar.pulseSpeed
        if quasar.pulse > math.pi * 2 then
            quasar.pulse = quasar.pulse - math.pi * 2
        end
    end
    
    -- Update supernovae
    for _, supernova in ipairs(supernovae) do
        if supernova.active then
            supernova.expansion = supernova.expansion + supernova.expansionSpeed * dt
            if supernova.expansion >= supernova.maxExpansion then
                supernova.active = false
            end
        end
    end
    
    -- Update magnetars
    for _, magnetar in ipairs(magnetars) do
        magnetar.pulse = magnetar.pulse + magnetar.pulseSpeed
        magnetar.flareTimer = magnetar.flareTimer + dt
        if magnetar.flareTimer > 10 then -- Flare every 10 seconds
            magnetar.flareTimer = 0
            createMagnetarFlare(magnetar)
        end
    end
    
    -- Update space stations
    for _, station in ipairs(spacestations) do
        station.rotation = station.rotation + station.rotationSpeed
    end
    
    -- Check wormhole teleportation
    checkWormholeTeleport()
    
    -- Check cosmic object interactions
    checkCosmicObjectInteractions(dt)
    
    -- Check landing/docking conditions
    checkLandingConditions(dt)
end

function createMagnetarFlare(magnetar)
    local x, y = magnetar.body:getPosition()
    for i = 1, 20 do
        local angle = magnetar.flareAngle + love.math.random(-0.5, 0.5)
        local speed = love.math.random(200, 500)
        table.insert(particles, {
            x = x, y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = love.math.random(40, 80),
            color = {0.9, 0.1, 0.1, 1}, -- Red flare particles
            size = love.math.random(2, 5)
        })
    end
end

function updateComet(comet, dt)
    -- Add tail particle
    local x, y = comet.body:getPosition()
    table.insert(comet.tailParticles, {
        x = x, y = y,
        life = comet.tailLength
    })
    
    -- Update tail particles
    for i = #comet.tailParticles, 1, -1 do
        local p = comet.tailParticles[i]
        p.life = p.life - 1
        if p.life <= 0 then
            table.remove(comet.tailParticles, i)
        end
    end
    
    -- Occasionally change direction slightly
    if love.math.random() < 0.01 then
        comet.angle = comet.angle + love.math.random(-0.5, 0.5)
        local vx = math.cos(comet.angle) * comet.speed
        local vy = math.sin(comet.angle) * comet.speed
        comet.body:setLinearVelocity(vx, vy)
    end
end

function checkWormholeTeleport()
    if not PlayerX[1] then return end
    local player = PlayerX[1]
    local px, py = player.body:getPosition()

    for _, wormhole in ipairs(wormholes) do
        if wormhole.cooldown <= 0 then
            local wx, wy = wormhole.body:getPosition()
            local dx, dy = px - wx, py - wy
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance < wormhole.radius then
                -- Teleport player to paired wormhole safely
                player.body:setLinearVelocity(0, 0)
                player.body:setAngularVelocity(0)
                player.body:setPosition(wormhole.pairX, wormhole.pairY)

                wormhole.cooldown = 5
                for _, wh in ipairs(wormholes) do
                    if math.abs(wh.body:getX() - wormhole.pairX) < 1 and math.abs(wh.body:getY() - wormhole.pairY) < 1 then
                        wh.cooldown = 5
                    end
                end

                createTeleportEffect(wx, wy)
                createTeleportEffect(wormhole.pairX, wormhole.pairY)
                game.score = game.score + 50
                createFloatingText(wormhole.pairX, wormhole.pairY - 100, "Wormhole Travel! +50")
                break
            end
        end
    end
end


function checkCosmicObjectInteractions(dt)
    if not PlayerX[1] or shipSystems.landed or shipSystems.docked then return end
    
    local player = PlayerX[1]
    local px, py = player.body:getPosition()
    
    -- Check black hole damage
    for _, blackhole in ipairs(blackholes) do
        local bx, by = blackhole.body:getPosition()
        local dx, dy = px - bx, py - by
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < blackhole.damageRadius then
            local damage = blackhole.damagePerSecond * dt
            applyDamage(damage, "Black Hole Radiation")
            
            -- Visual effect
            if love.math.random() < 0.3 then
                createDamageEffect(px, py, {1, 0, 0})
            end
        end
    end
    
    -- Check white hole energy recharge
    for _, whitehole in ipairs(whiteholes) do
        local wx, wy = whitehole.body:getPosition()
        local dx, dy = px - wx, py - wy
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < whitehole.energyRadius then
            shipSystems.energy = math.min(shipSystems.maxEnergy, 
                shipSystems.energy + whitehole.energyRecharge * dt)
        end
    end
    
    -- Check pulsar radiation
    for _, pulsar in ipairs(pulsars) do
        if pulsar.active then
            local pxr, pyr = pulsar.body:getPosition()
            local dx, dy = px - pxr, py - pyr
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < pulsar.pulseRadius then
                local pulse = 0.5 + 0.5 * math.sin(pulsar.pulsePhase)
                if pulse > 0.8 then -- Only damage during pulse peak
                    local damage = pulsar.radiationDamage * dt
                    applyDamage(damage, "Pulsar Radiation")
                end
            end
        end
    end
    
    -- Check quasar jet damage
    for _, quasar in ipairs(quasars) do
        local qx, qy = quasar.body:getPosition()
        
        -- Check both jets
        for _, jetAngle in ipairs({quasar.jets.angle1, quasar.jets.angle2}) do
            local jetX = qx + math.cos(jetAngle) * quasar.jets.length
            local jetY = qy + math.sin(jetAngle) * quasar.jets.length
            
            -- Simple line segment distance check
            local t = ((px - qx) * (jetX - qx) + (py - qy) * (jetY - qy)) / 
                     ((jetX - qx)^2 + (jetY - qy)^2)
            t = math.max(0, math.min(1, t))
            
            local projX = qx + t * (jetX - qx)
            local projY = qy + t * (jetY - qy)
            
            local distance = math.sqrt((px - projX)^2 + (py - projY)^2)
            
            if distance < 200 then -- Jet width
                local damage = quasar.jetDamage * dt
                applyDamage(damage, "Quasar Jet")
            end
        end
    end
    
    -- Check supernova shockwave
    for _, supernova in ipairs(supernovae) do
        if supernova.active then
            local dx, dy = px - supernova.x, py - supernova.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < supernova.radius * supernova.expansion then
                local damage = supernova.shockwaveDamage * dt
                applyDamage(damage, "Supernova Shockwave")
            end
        end
    end
    
    -- Check nebula fuel bonus
    for _, nebula in ipairs(nebulae) do
        local dx, dy = px - nebula.x, py - nebula.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < nebula.radius then
            shipSystems.fuel = math.min(shipSystems.maxFuel, 
                shipSystems.fuel + nebula.fuelBonus * dt)
        end
    end
    
    -- Check comet collisions and mining
    for _, comet in ipairs(comets) do
        local cx, cy = comet.body:getPosition()
        local dx, dy = px - cx, py - cy
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < comet.radius + 30 then -- Player collision radius
            if shipSystems.shields > 0 then
                applyDamage(comet.damage, "Comet Impact")
            else
                applyDamage(comet.damage * 2, "Comet Impact")
            end
            
            -- Mining opportunity
            if love.math.random() < 0.1 then
                local mined = math.min(comet.iceContent, 5)
                comet.iceContent = comet.iceContent - mined
                shipSystems.fuel = math.min(shipSystems.maxFuel, shipSystems.fuel + mined)
                createFloatingText(px, py - 50, "+" .. mined .. " Fuel")
            end
        end
    end
    
    -- Check asteroid collisions
    for _, asteroid in ipairs(box_i) do
        if asteroid.type == "asteroid" then
            local ax, ay = asteroid.body:getPosition()
            local dx, dy = px - ax, py - ay
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < asteroid.size + 30 then -- Player collision radius
                if shipSystems.shields > 0 then
                    applyDamage(asteroid.damage, "Asteroid Impact")
                else
                    applyDamage(asteroid.damage * 2, "Asteroid Impact")
                end
                
                -- Mining opportunity
                if love.math.random() < 0.05 then
                    local mined = math.min(asteroid.mineralContent, 2)
                    asteroid.mineralContent = asteroid.mineralContent - mined
                    game.score = game.score + mined * 10
                    createFloatingText(px, py - 50, "+" .. (mined * 10) .. " Resources")
                end
            end
        end
    end
end

function applyDamage(amount, source)
    if shipSystems.shields > 0 then
        shipSystems.shields = math.max(0, shipSystems.shields - amount)
        if shipSystems.shields <= 0 then
            setGameMessage("Shields depleted!", 3)
        end
    else
        shipSystems.health = math.max(0, shipSystems.health - amount)
        if shipSystems.health <= 0 then
            game.state = "gameover"
            setGameMessage("Ship destroyed! Game Over", 10)
        end
    end
end

function createDamageEffect(x, y, color)
    for i = 1, 10 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(10, 30)
        table.insert(particles, {
            x = x, y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = love.math.random(20, 40),
            color = color or {1, 0, 0, 1},
            size = love.math.random(1, 3)
        })
    end
end

function checkLandingConditions(dt)
    if not PlayerX[1] then return end
    
    local player = PlayerX[1]
    local px, py = player.body:getPosition()
    local vx, vy = player.body:getLinearVelocity()
    local speed = math.sqrt(vx*vx + vy*vy)
    
    -- Check planet landing
    for _, planet in ipairs(planets) do
        if planet.canLand then
            local plx, ply = planet.body:getPosition()
            local dx, dy = px - plx, py - ply
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < planet.landingRadius then
                if speed < 50 and not shipSystems.landed then -- Safe landing speed
                    if love.keyboard.isDown("l") or isTouchButtonActive("land") then
                        landOnPlanet(planet)
                        break
                    elseif shipSystems.autoDock then
                        landOnPlanet(planet)
                        break
                    end
                end
            end
        end
    end
    
    -- Check space station docking
    for _, station in ipairs(spacestations) do
        local sx, sy = station.body:getPosition()
        local dx, dy = px - sx, py - sy
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < station.dockingRadius then
            if speed < 30 and not shipSystems.docked then -- Safe docking speed
                if love.keyboard.isDown("l") or isTouchButtonActive("land") then
                    dockAtStation(station)
                    break
                elseif shipSystems.autoDock then
                    dockAtStation(station)
                    break
                end
            end
        end
    end
    
    -- Check takeoff conditions
    if shipSystems.landed or shipSystems.docked then
        if love.keyboard.isDown("l") or isTouchButtonActive("land") then
            takeOff()
        end
    end
end

function landOnPlanet(planet)
    shipSystems.landed = true
    shipSystems.landingPlanet = planet
    game.state = "landed"
    
    -- Stop player movement
    PlayerX[1].body:setLinearVelocity(0, 0)
    PlayerX[1].body:setAngularVelocity(0)
    
    -- Position player on planet surface
    local plx, ply = planet.body:getPosition()
    local dx, dy = PlayerX[1].body:getPosition()
    local angle = math.atan2(dy - ply, dx - plx)
    
    PlayerX[1].body:setPosition(
        plx + math.cos(angle) * (planet.radius + 20),
        ply + math.sin(angle) * (planet.radius + 20)
    )
    PlayerX[1].body:setAngle(angle + math.pi/2) -- Orient upright on surface
    
    setGameMessage("Landed on " .. planet.name, 3)
    
    -- Recharge systems while landed
    shipSystems.fuel = shipSystems.maxFuel
    shipSystems.energy = shipSystems.maxEnergy
    shipSystems.shields = shipSystems.maxShields
    if shipSystems.health < shipSystems.maxHealth then
        shipSystems.health = math.min(shipSystems.maxHealth, shipSystems.health + 10)
    end
end

function dockAtStation(station)
    shipSystems.docked = true
    shipSystems.dockingStation = station
    game.state = "landed"
    
    -- Stop player movement
    PlayerX[1].body:setLinearVelocity(0, 0)
    PlayerX[1].body:setAngularVelocity(0)
    
    -- Position player at station
    local sx, sy = station.body:getPosition()
    PlayerX[1].body:setPosition(sx, sy - station.radius - 50)
    PlayerX[1].body:setAngle(0)
    
    setGameMessage("Docked at Space Station", 3)
    
    -- Full recharge and repair at station
    shipSystems.fuel = shipSystems.maxFuel
    shipSystems.energy = shipSystems.maxEnergy
    shipSystems.shields = shipSystems.maxShields
    shipSystems.health = shipSystems.maxHealth
    game.score = game.score + 100
end

function takeOff()
    shipSystems.landed = false
    shipSystems.docked = false
    shipSystems.landingPlanet = nil
    shipSystems.dockingStation = nil
    game.state = "playing"
    
    setGameMessage("Launching...", 2)
end

function setGameMessage(text, duration)
    game.message = text
    game.messageTimer = duration or 3
end

function createTeleportEffect(x, y)
    for i = 1, 30 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(50, 200)
        table.insert(particles, {
            x = x, y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = love.math.random(30, 60),
            color = {0.7, 0.3, 0.9, 1}, -- Purple particles
            size = love.math.random(1, 3)
        })
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
        
        -- Adjust visit distance to be proportional to planet size
        if distance < planet.radius + 200 and not planet.visited then
            planet.visited = true
            game.score = game.score + 100
            createFloatingText(plx, ply - planet.radius - 50, "Visited " .. planet.name .. "! +100")
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
        
        if p.vx then
            p.x = p.x + p.vx
            p.vx = p.vx * 0.98 -- Slow down
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




-- MODIFIED: Update function to include new cosmic objects
function love.update(dt)
    if game.state ~= "playing" and game.state ~= "landed" then return end
    
    -- Update message timer
    if game.messageTimer > 0 then
        game.messageTimer = game.messageTimer - dt
        if game.messageTimer <= 0 then
            game.message = ""
        end
    end
    
    world:update(dt)
    updatePlanetOrbits(dt) -- Update planet positions
    updateGravity(dt) -- Apply planetary gravity
    updateCosmicObjects(dt) -- Update cosmic objects and interactions
    updatePlayer(dt)
    updateEnemies(dt)
    updateParticles(dt)
    updateCamera(dt)
    checkPlanetVisits()
    
    -- NEW: Update bullets
    updateBullets(dt)
    
    -- NEW: Update weapon cooldown
    if shipSystems.weapons.cooldown > 0 then
        shipSystems.weapons.cooldown = shipSystems.weapons.cooldown - dt
    end
    
    -- NEW: Update tesseracts
    updateTesseracts(dt)
    
    -- NEW: Update bio nebulae
    updateBioNebulae(dt)
    
    -- Handle touch controls
    updateTouchControls(dt)
    
    -- Update ship systems
    updateShipSystems(dt)
    
    if love.keyboard.isDown("=") or love.keyboard.isDown("+") then
        camera.scale = math.min(camera.scale + 0.01, 5)
    elseif love.keyboard.isDown("-") or love.keyboard.isDown("_")  then
        camera.scale = math.max(camera.scale - 0.01, 0.001)
    end
end

function updateShipSystems(dt)
    -- Energy regeneration
    if not shipSystems.boostActive then
        shipSystems.energy = math.min(shipSystems.maxEnergy, shipSystems.energy + 5 * dt)
    end
    
    -- Shield regeneration (when not taking damage)
    shipSystems.shields = math.min(shipSystems.maxShields, shipSystems.shields + 2 * dt)
    
    -- Recharge and repair while landed/docked
    if shipSystems.landed or shipSystems.docked then
        shipSystems.fuel = shipSystems.maxFuel
        shipSystems.energy = shipSystems.maxEnergy
        if shipSystems.health < shipSystems.maxHealth then
            shipSystems.health = math.min(shipSystems.maxHealth, shipSystems.health + 10 * dt)
        end
    end
end

function updateTouchButtonPositions()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    for _, button in ipairs(touchControls.buttons) do
        if button.id == "up" then
            button.x, button.y = w - 150, h - 200
        elseif button.id == "left" then
            button.x, button.y = w - 200, h - 150
        elseif button.id == "right" then
            button.x, button.y = w - 100, h - 150
        elseif button.id == "down" then
            button.x, button.y = w - 150, h - 100
        elseif button.id == "rotate_left" then
            button.x, button.y = w - 200, h - 200
        elseif button.id == "rotate_right" then
            button.x, button.y = w - 100, h - 200
        elseif button.id == "zoom_in" then
            button.x, button.y = w - 50, 0
        elseif button.id == "zoom_out" then
            button.x, button.y = w - 100, 0   
		elseif button.id == "debug" then
            button.x, button.y = w - 150, 0
        elseif button.id == "boost" then
            button.x, button.y = w - 200, h - 250
        elseif button.id == "land" then
            button.x, button.y = w - 100, h - 250
        elseif button.id == "brake" then
            button.x, button.y = w - 250, h - 100
        elseif button.id == "fire" then
            button.x, button.y = w - 300, h - 100
        end
    end
end

function love.resize(w, h)
    updateTouchButtonPositions()
end

function updateTouchControls(dt)
    -- Reset button states
    for _, button in ipairs(touchControls.buttons) do
        button.active = false
    end

    -- Handle touch input
    local touches = love.touch.getTouches()
    for _, id in ipairs(touches) do
        local x, y = love.touch.getPosition(id)
        for _, button in ipairs(touchControls.buttons) do
            if x >= button.x and x <= button.x + button.width and
               y >= button.y and y <= button.y + button.height then
                button.active = true
                handleTouchInput(button.id)
            end
        end
    end

    -- Handle mouse input (for desktop)
    if love.mouse.isDown(1) then
        local mx, my = love.mouse.getPosition()
        for _, button in ipairs(touchControls.buttons) do
            if mx >= button.x and mx <= button.x + button.width and
               my >= button.y and my <= button.y + button.height then
                button.active = true
                handleTouchInput(button.id)
            end
        end
    end
end

function isTouchButtonActive(buttonId)
    for _, button in ipairs(touchControls.buttons) do
        if button.id == buttonId and button.active then
            return true
        end
    end
    return false
end

function handleTouchInput(buttonId)
    if not PlayerX[1] then return end
    
    local player = PlayerX[1]
    local body = player.body
    local bx, by = body:getWorldPoint(0, player.h / 2)
    local angle = body:getAngle()
	local speed = 120
    
    if buttonId == "up" then
        if shipSystems.fuel > 0 then
            body:applyForce(0, -speed)
            createPlayerParticle(bx, by, angle)
            shipSystems.fuel = math.max(0, shipSystems.fuel - 0.1)
        end
    elseif buttonId == "down" then
        if shipSystems.fuel > 0 then
            body:applyForce(0, speed)
            createPlayerParticle(bx, by, angle + math.pi)
            shipSystems.fuel = math.max(0, shipSystems.fuel - 0.1)
        end
    elseif buttonId == "left" then
        if shipSystems.fuel > 0 then
            body:applyForce(-speed, 0)
            shipSystems.fuel = math.max(0, shipSystems.fuel - 0.05)
        end
    elseif buttonId == "right" then
        if shipSystems.fuel > 0 then
            body:applyForce(speed, 0)
            shipSystems.fuel = math.max(0, shipSystems.fuel - 0.05)
        end
    elseif buttonId == "rotate_left" then
        body:applyTorque(-speed)
    elseif buttonId == "rotate_right" then
        body:applyTorque(speed)
    elseif buttonId == "zoom_in" then
        camera.scale = math.min(camera.scale + 0.01, camera.maxScale)
    elseif buttonId == "zoom_out" then
        camera.scale = math.max(camera.scale - 0.01, camera.minScale) 
	elseif buttonId == "debug" then
        game.debugMode = not game.debugMode
    elseif buttonId == "boost" then
        if shipSystems.energy > 0 then
            shipSystems.boostActive = true
            local boostForce = 100
            body:applyForce(0, -boostForce)
            createPlayerParticle(bx, by, angle, true)
            shipSystems.energy = math.max(0, shipSystems.energy - 10)
        end
    elseif buttonId == "brake" then
        if shipSystems.energy > 0 then
            shipSystems.brakesActive = true
            local vx, vy = body:getLinearVelocity()
            local brakeForce = 50
            body:applyForce(-vx * brakeForce, -vy * brakeForce)
            shipSystems.energy = math.max(0, shipSystems.energy - 5)
        end
    elseif buttonId == "land" then
        -- Landing/takeoff handled in checkLandingConditions
    elseif buttonId == "fire" then
        fireWeapon()
    end
end

function love.draw()
    love.graphics.clear(0.02, 0.02, 0.08)
    love.graphics.push()
    
    -- Apply camera transform
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.scale(camera.scale)
    love.graphics.translate(-camera.x, -camera.y)
    
    -- Draw stars in background
    drawStars()
    
    -- Draw nebulae
    drawNebulae()
    
    -- NEW: Draw bio nebulae
    drawBioNebulae()
    
    -- Draw all objects
    drawSupernovae()
    drawQuasars()
    drawPulsars()
    drawComets()
    drawMagnetars()
    drawAsteroidFields()
    drawSpaceStations()
    drawWormholes()
    drawWhiteholes()
    drawBlackholes() -- This will include the supermassive black hole
    
    -- NEW: Draw tesseracts
    drawTesseracts()
    
    drawPlanets() -- This will include the demon planet
    drawOrbiters()
    drawAsteroids()
    drawEnemies() -- Updated to show dead enemies
    drawBalls()
    if PlayerX[1] then
        drawPlayer(PlayerX[1])
    end
    drawBullets() -- NEW: Draw bullets
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
    
    -- Draw touch controls
    if touchControls.visible then
        drawTouchControls()
    end
end

function drawMagnetars()
    for _, magnetar in ipairs(magnetars) do
        local x, y = magnetar.body:getPosition()
        local pulse = 0.7 + 0.3 * math.sin(magnetar.pulse)
        
        -- Magnetic field
        love.graphics.setColor(0.9, 0.1, 0.1, 0.1 * pulse)
        love.graphics.circle("fill", x, y, magnetar.magneticRadius)
        
        -- Magnetar body
        love.graphics.setColor(0.9, 0.2, 0.2, 0.9 * pulse)
        love.graphics.circle("fill", x, y, magnetar.radius)
        
        -- Pulsing core
        love.graphics.setColor(1, 1, 1, pulse)
        love.graphics.circle("fill", x, y, magnetar.radius * 0.5)
        
        -- Label
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.print("MAGNETAR", x - 35, y - magnetar.radius - 30)
    end
end

function drawAsteroidFields()
    for _, field in ipairs(asteroidfields) do
        -- Field boundary (debug)
        if game.debugMode then
            love.graphics.setColor(0.5, 0.5, 0, 0.1)
            love.graphics.circle("fill", field.x, field.y, field.radius)
        end
    end
end

function drawSpaceStations()
    for _, station in ipairs(spacestations) do
        local x, y = station.body:getPosition()
        
        -- Station structure
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.circle("fill", x, y, station.radius)
        
        -- Rotating ring
        love.graphics.setColor(0.5, 0.5, 0.7)
        love.graphics.arc("line", x, y, station.radius * 1.2, station.rotation, station.rotation + math.pi * 1.5, 20)
        
        -- Docking area
        love.graphics.setColor(0, 1, 0, 0.3)
        love.graphics.circle("line", x, y, station.dockingRadius)
        
        -- Label
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.print("SPACE STATION", x - 50, y - station.radius - 30)
        
        -- Docking instructions
        if shipSystems.docked and station == shipSystems.dockingStation then
            love.graphics.setColor(0, 1, 0, 0.8)
            love.graphics.print("DOCKED - Press L to launch", x - 80, y + station.radius + 10)
        end
    end
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

function drawNebulae()
    for _, nebula in ipairs(nebulae) do
        local pulseFactor = 0.8 + 0.2 * math.sin(nebula.pulse)
        love.graphics.setColor(nebula.color[1], nebula.color[2], nebula.color[3], nebula.color[4] * pulseFactor)
        love.graphics.circle("fill", nebula.x, nebula.y, nebula.radius)
    end
end

function drawSupernovae()
    for _, supernova in ipairs(supernovae) do
        if supernova.active then
            local pulse = 0.8 + 0.2 * math.sin(supernova.expansion * 10)
            love.graphics.setColor(
                supernova.color[1], 
                supernova.color[2], 
                supernova.color[3], 
                supernova.color[4] * pulse
            )
            love.graphics.circle("fill", supernova.x, supernova.y, supernova.radius * supernova.expansion)
            
            -- Shockwave effect
            love.graphics.setColor(1, 0.8, 0.2, 0.2 * (1 - supernova.expansion/supernova.maxExpansion))
            love.graphics.circle("line", supernova.x, supernova.y, supernova.radius * supernova.expansion * 1.2)
        end
    end
end

function drawQuasars()
    for _, quasar in ipairs(quasars) do
        local x, y = quasar.body:getPosition()
        local pulse = 0.8 + 0.2 * math.sin(quasar.pulse)
        
        -- Energy field
        love.graphics.setColor(0.2, 0.6, 1, 0.2 * pulse)
        love.graphics.circle("fill", x, y, quasar.energyRadius)
        
        -- Main quasar body
        love.graphics.setColor(0.4, 0.8, 1, 0.8 * pulse)
        love.graphics.circle("fill", x, y, quasar.radius)
        
        -- Jets
        love.graphics.setColor(0.8, 0.9, 1, 0.6 * pulse)
        local jet1x = x + math.cos(quasar.jets.angle1) * quasar.jets.length
        local jet1y = y + math.sin(quasar.jets.angle1) * quasar.jets.length
        local jet2x = x + math.cos(quasar.jets.angle2) * quasar.jets.length
        local jet2y = y + math.sin(quasar.jets.angle2) * quasar.jets.length
        
        love.graphics.setLineWidth(20)
        love.graphics.line(x, y, jet1x, jet1y)
        love.graphics.line(x, y, jet2x, jet2y)
        love.graphics.setLineWidth(1)
        
        -- Label
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.print("QUASAR", x - 30, y - quasar.radius - 30)
    end
end

function drawPulsars()
    for _, pulsar in ipairs(pulsars) do
        if pulsar.active then
            local x, y = pulsar.body:getPosition()
            local pulse = 0.5 + 0.5 * math.sin(pulsar.pulsePhase)
            
            -- Pulsar body
            love.graphics.setColor(0.9, 0.9, 0.3, pulse)
            love.graphics.circle("fill", x, y, pulsar.radius)
            
            -- Pulsing energy field
            love.graphics.setColor(1, 1, 0.5, 0.2 * pulse)
            love.graphics.circle("fill", x, y, pulsar.pulseRadius * pulse)
            
            -- Beam
            love.graphics.setColor(1, 1, 0.2, 0.7 * pulse)
            local beamLength = pulsar.pulseRadius * 1.5
            local beamX = x + math.cos(pulsar.beamAngle) * beamLength
            local beamY = y + math.sin(pulsar.beamAngle) * beamLength
            love.graphics.setLineWidth(8)
            love.graphics.line(x, y, beamX, beamY)
            love.graphics.setLineWidth(1)
            
            -- Label
            love.graphics.setColor(1, 1, 1, 0.7)
            love.graphics.print("PULSAR", x - 25, y - pulsar.radius - 30)
        end
    end
end

function drawComets()
    for _, comet in ipairs(comets) do
        local x, y = comet.body:getPosition()
        
        -- Draw tail
        for i, p in ipairs(comet.tailParticles) do
            local alpha = p.life / comet.tailLength
            love.graphics.setColor(comet.color[1], comet.color[2], comet.color[3], alpha * 0.7)
            love.graphics.circle("fill", p.x, p.y, comet.radius * 0.3 * alpha)
        end
        
        -- Draw comet body
        love.graphics.setColor(comet.color[1], comet.color[2], comet.color[3], 0.9)
        love.graphics.circle("fill", x, y, comet.radius)
        
        -- Bright core
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.circle("fill", x, y, comet.radius * 0.5)
        
        -- Ice content indicator
        if game.debugMode then
            love.graphics.setColor(1, 1, 1, 0.7)
            love.graphics.print("Ice: " .. comet.iceContent, x - 20, y + comet.radius + 10)
        end
    end
end

function drawBlackholes()
    for _, blackhole in ipairs(blackholes) do
        local x, y = blackhole.body:getPosition()
        
        -- Special rendering for supermassive black hole
        if blackhole.type == "supermassive_blackhole" then
            -- Draw massive accretion disk
            love.graphics.setColor(0.9, 0.7, 0.3, 0.4)
            love.graphics.circle("fill", x, y, blackhole.radius * 4)
            
            love.graphics.setColor(0.8, 0.6, 0.2, 0.6)
            love.graphics.circle("fill", x, y, blackhole.radius * 3)
            
            love.graphics.setColor(0.7, 0.5, 0.1, 0.8)
            love.graphics.circle("fill", x, y, blackhole.radius * 2)
        else
            -- Regular black hole rendering
            love.graphics.setColor(0.8, 0.6, 0.2, 0.3)
            love.graphics.circle("fill", x, y, blackhole.radius * 2.5)
            
            love.graphics.setColor(0.6, 0.4, 0.1, 0.5)
            love.graphics.circle("fill", x, y, blackhole.radius * 2)
        end
        
        -- Draw event horizon (black circle)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", x, y, blackhole.radius)
        
        -- Draw rotating effect
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.arc("line", x, y, blackhole.radius * 1.5, blackhole.rotation, blackhole.rotation + math.pi * 1.5)
        
        -- Draw gravity zone in debug mode
        if game.debugMode and debugInfo.showGravityZones then
            love.graphics.setColor(1, 0, 0, 0.1)
            love.graphics.circle("fill", x, y, blackhole.gravityRadius)
            love.graphics.setColor(1, 0, 0, 0.3)
            love.graphics.circle("line", x, y, blackhole.damageRadius)
        end
        
        -- Label
        love.graphics.setColor(1, 1, 1, 0.7)
        if blackhole.type == "supermassive_blackhole" then
            love.graphics.print("SUPERMASSIVE BLACK HOLE", x - 100, y - blackhole.radius - 50)
        else
            love.graphics.print("BLACK HOLE", x - 40, y - blackhole.radius - 30)
        end
    end
end


function drawWhiteholes()
    for _, whitehole in ipairs(whiteholes) do
        local x, y = whitehole.body:getPosition()
        local pulseSize = 1 + 0.2 * math.sin(whitehole.pulse)
        
        -- Glowing effect
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.circle("fill", x, y, whitehole.radius * pulseSize * 1.5)
        
        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.circle("fill", x, y, whitehole.radius * pulseSize * 1.2)
        
        -- Main white hole
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.circle("fill", x, y, whitehole.radius * pulseSize)
        
        -- Repulsion zone in debug mode
        if game.debugMode and debugInfo.showGravityZones then
            love.graphics.setColor(0, 1, 1, 0.1)
            love.graphics.circle("fill", x, y, whitehole.repulsionRadius)
            love.graphics.setColor(0, 1, 1, 0.3)
            love.graphics.circle("line", x, y, whitehole.energyRadius)
        end
        
        -- Label
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.print("WHITE HOLE", x - 40, y - whitehole.radius - 30)
    end
end

function drawWormholes()
    for _, wormhole in ipairs(wormholes) do
        local x, y = wormhole.body:getPosition()
        
        -- Outer ring
        love.graphics.setColor(0.5, 0.2, 0.8, 0.6)
        love.graphics.circle("fill", x, y, wormhole.radius)
        
        -- Inner portal with rotation
        love.graphics.setColor(0.7, 0.4, 1, 0.8)
        love.graphics.arc("fill", x, y, wormhole.radius * 0.7, wormhole.rotation, wormhole.rotation + math.pi * 1.8)
        
        -- Center
        love.graphics.setColor(0.9, 0.8, 1, 0.9)
        love.graphics.circle("fill", x, y, wormhole.radius * 0.3)
        
        -- Cooldown indicator
        if wormhole.cooldown > 0 then
            love.graphics.setColor(1, 0, 0, 0.7)
            love.graphics.print("COOLDOWN: " .. string.format("%.1f", wormhole.cooldown), x - 40, y + wormhole.radius + 10)
        else
            love.graphics.setColor(0, 1, 0, 0.7)
            love.graphics.print("ACTIVE", x - 20, y + wormhole.radius + 10)
        end
        
        -- Stability indicator
        if game.debugMode then
            love.graphics.setColor(1, 1, 1, 0.7)
            love.graphics.print("Stability: " .. wormhole.stability .. "%", x - 40, y + wormhole.radius + 30)
        end
        
        -- Label
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.print("WORMHOLE", x - 35, y - wormhole.radius - 30)
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
            love.graphics.setColor(planet.color[1], planet.color[2], planet.color[3])
        else
            -- Regular planet with its color
            love.graphics.setColor(planet.color[1], planet.color[2], planet.color[3])
        end
        
        love.graphics.circle("fill", x, y, planet.radius)
        
        -- Special rendering for demon planet
        if planet.isDemon then
            -- Draw horns
            love.graphics.setColor(0.4, 0.1, 0.1)
            for _, horn in ipairs(planet.horns) do
                local hornX = x + math.cos(horn.angle) * (planet.radius + horn.length/2)
                local hornY = y + math.sin(horn.angle) * (planet.radius + horn.length/2)
                
                love.graphics.push()
                love.graphics.translate(hornX, hornY)
                love.graphics.rotate(horn.angle)
                love.graphics.polygon("fill", 
                    -horn.width/2, -horn.length/2,
                    horn.width/2, -horn.length/2,
                    0, horn.length/2
                )
                love.graphics.pop()
            end
            
            -- Evil glow
            love.graphics.setColor(0.8, 0.1, 0.1, 0.3)
            love.graphics.circle("fill", x, y, planet.radius * 1.2)
        end
        
        -- Planet outline
        love.graphics.setColor(0.4, 0.4, 0.5)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", x, y, planet.radius)
        love.graphics.setLineWidth(1)
        
        -- Landing zone
        if planet.canLand then
            love.graphics.setColor(0, 1, 0, 0.2)
            love.graphics.circle("line", x, y, planet.landingRadius)
        end
        
        -- Planet name if visited or debug
        if planet.visited or game.debugMode then
            love.graphics.setColor(1, 1, 1, 0.7)
            love.graphics.print(planet.name, x - love.graphics.getFont():getWidth(planet.name)/2, y - planet.radius - 20)
        end
        
        -- Landing instructions
        if shipSystems.landed and planet == shipSystems.landingPlanet then
            love.graphics.setColor(0, 1, 0, 0.8)
            love.graphics.print("LANDED - Press L to launch", x - 80, y + planet.radius + 10)
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
            
            -- Mineral content indicator (debug)
            if game.debugMode then
                love.graphics.setColor(1, 1, 1, 0.7)
                love.graphics.print("Minerals: " .. asteroid.mineralContent, x - 30, y + asteroid.size + 5)
            end
        end
    end
end

function createPlayer()
    -- Start player near Earth
    local earth = planets[3] -- Earth is third planet
    local ex, ey = earth.body:getPosition()
    local startX = ex + earth.radius + 500 -- Start further from planet surface
    local startY = ey
	-- local startX, startY = 500000, 500000
    
    local body = love.physics.newBody(world, startX, startY, "dynamic")
    local shape = love.physics.newRectangleShape(30, 60) -- Smaller player
    local fixture = love.physics.newFixture(body, shape, 1.0)
    fixture:setFriction(0.1)
    fixture:setRestitution(0.2)
    
    -- Give player initial orbital velocity around Earth
    local orbitalSpeed = math.sqrt(earth.gravityStrength / 500) * 0.8
    body:setLinearVelocity(0, orbitalSpeed)
    
    PlayerX[1] = {
        body = body,
        shape = shape,
        fixture = fixture,
        w = 30,  -- Smaller width
        h = 60, -- Smaller height
        particles = {}
    }
end

function updatePlayer(dt)
    if not PlayerX[1] or shipSystems.landed or shipSystems.docked then return end
    
    local player = PlayerX[1]
    local body = player.body
    
    -- Get bottom world coordinates
    local bx, by = body:getWorldPoint(0, player.h / 2)
    local angle = body:getAngle()
    local speed = 120
    
    -- Reset boost/brake states
    shipSystems.boostActive = false
    shipSystems.brakesActive = false
    

    -- Space movement - apply forces in the direction the player is facing
    if love.keyboard.isDown("right") then
        if shipSystems.fuel > 0 then
            body:applyForce(speed, 0)
            shipSystems.fuel = math.max(0, shipSystems.fuel - 0.1)
        end
    end
    
    if love.keyboard.isDown("left") then
        if shipSystems.fuel > 0 then
            body:applyForce(-speed, 0)
            shipSystems.fuel = math.max(0, shipSystems.fuel - 0.1)
        end
    end
    
    if love.keyboard.isDown("up") then
        if shipSystems.fuel > 0 then
            body:applyForce(0, -speed)
            shipSystems.fuel = math.max(0, shipSystems.fuel - 0.1)
            
            -- Thruster particles
            createPlayerParticle(bx, by, angle)
        end
    end 
    
    if love.keyboard.isDown("down") then
        if shipSystems.fuel > 0 then
            body:applyForce(0, speed)
            shipSystems.fuel = math.max(0, shipSystems.fuel - 0.1)
            
            -- Thruster particles
            createPlayerParticle(bx, by, angle + math.pi)
        end
    end


    -- Boost system
    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        if shipSystems.energy > 0 then
            shipSystems.boostActive = true
            local boostForce = 300
            body:applyForce(0, -boostForce)
            createPlayerParticle(bx, by, angle, true)
            shipSystems.energy = math.max(0, shipSystems.energy - 20 * dt)
        end
    end

    -- Brake system
    if love.keyboard.isDown("space") then
        if shipSystems.energy > 0 then
            shipSystems.brakesActive = true
            local vx, vy = body:getLinearVelocity()
            local brakeForce = 100
            body:applyForce(-vx * brakeForce, -vy * brakeForce)
            shipSystems.energy = math.max(0, shipSystems.energy - 10 * dt)
        end
    end

    -- Manual rotation in space
    local rotationForce = speed
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

function createPlayerParticle(x, y, angle, isBoost)
    local particleAngle = angle + math.pi + love.math.random(-0.3, 0.3)
    local speed = isBoost and love.math.random(80, 120) or love.math.random(30, 70)
    
    table.insert(PlayerX[1].particles, {
        x = x,
        y = y,
        vx = math.cos(particleAngle) * speed,
        vy = math.sin(particleAngle) * speed,
        life = love.math.random(25, 50),
        isBoost = isBoost or false
    })
end


function drawPlayer(player)
    local x, y = player.body:getPosition()
    
    -- Draw shield if active
    if shipSystems.shields > 0 then
        local shieldAlpha = 0.3 + 0.2 * math.sin(love.timer.getTime() * 5)
        love.graphics.setColor(0, 0.5, 1, shieldAlpha)
        love.graphics.circle("line", x, y, 40)
    end
    
    -- Draw player ship
    if shipSystems.boostActive then
        love.graphics.setColor(1, 0.5, 0) -- Orange during boost
    else
        love.graphics.setColor(0, 0.8, 1) -- Blue spaceship
    end
    love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
    
    -- Draw particles
    drawPlayerParticles(player)
    
    -- Draw player indicator
    love.graphics.setColor(0, 1, 0, 0.5)
    love.graphics.print("PLAYER", x - 20, y - 30)
    
    -- Draw landing/docking indicator if applicable
    if shipSystems.landed then
        love.graphics.setColor(0, 1, 0, 0.8)
        love.graphics.print("LANDED", x - 25, y - 50)
    elseif shipSystems.docked then
        love.graphics.setColor(0, 1, 1, 0.8)
        love.graphics.print("DOCKED", x - 25, y - 50)
    end
end

function drawPlayerParticles(player)
    for _, p in ipairs(player.particles) do
        if p.isBoost then
            love.graphics.setColor(1, 0.5, 0, p.life/40) -- Orange boost particles
            love.graphics.circle("fill", p.x, p.y, 3)
        else
            love.graphics.setColor(1, 1, 0.5, p.life/40) -- Yellow normal particles
            love.graphics.circle("fill", p.x, p.y, 2)
        end
    end
end

function drawTouchControls()
    for _, button in ipairs(touchControls.buttons) do
        -- Draw button background
        local color = button.active and {button.color[1], button.color[2], button.color[3], 1} or button.color
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", button.x + 1, button.y + 1, button.width - 2, button.height - 2, 5)
        
        -- Draw button label
        love.graphics.setColor(1, 1, 1, 1)
        if button.id == "up" then
            love.graphics.print("UP", button.x + button.width/2 - 5, button.y + button.height/2 - 10)
        elseif button.id == "down" then
            love.graphics.print("DW", button.x + button.width/2 - 5, button.y + button.height/2 - 10)
        elseif button.id == "left" then
            love.graphics.print("LF", button.x + button.width/2 - 5, button.y + button.height/2 - 10)
        elseif button.id == "right" then
            love.graphics.print("RH", button.x + button.width/2 - 5, button.y + button.height/2 - 10)
        elseif button.id == "rotate_left" then
            love.graphics.print("RL", button.x + button.width/2 - 10, button.y + button.height/2 - 10)
        elseif button.id == "rotate_right" then
            love.graphics.print("RR", button.x + button.width/2 - 10, button.y + button.height/2 - 10)
        elseif button.id == "zoom_in" then
            love.graphics.print("+", button.x + button.width/2 - 5, button.y + button.height/2 - 10)
        elseif button.id == "zoom_out" then
            love.graphics.print("-", button.x + button.width/2 - 5, button.y + button.height/2 - 10)    
		elseif button.id == "debug" then
            love.graphics.print("dbg", button.x + button.width/2 - 5, button.y + button.height/2 - 10)
        elseif button.id == "boost" then
            love.graphics.print("BST", button.x + button.width/2 - 10, button.y + button.height/2 - 10)
        elseif button.id == "brake" then
            love.graphics.print("BRK", button.x + button.width/2 - 10, button.y + button.height/2 - 10)
        elseif button.id == "land" then
            love.graphics.print("LAND", button.x + button.width/2 - 15, button.y + button.height/2 - 10)
        elseif button.id == "fire" then
            love.graphics.print("FIRE", button.x + button.width/2 - 15, button.y + button.height/2 - 10)
        end
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
        
        local enemy = createEnemyObj(ex, ey, 30, 60, 0)
        
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
        w = 6,
        h = 12,
        particles = {},
        health = 30, -- NEW: Enemy health
        maxHealth = 30,
        dead = false -- NEW: Track if enemy is dead
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
        if not enemy.dead then
            love.graphics.setColor(1, 0.3, 0.3) -- Red enemy ships
        else
            love.graphics.setColor(0.3, 0.3, 0.3) -- Gray dead enemies
        end
        
        local x, y = enemy.body:getPosition()
        love.graphics.polygon("fill", enemy.body:getWorldPoints(enemy.shape:getPoints()))
        
        -- Draw enemy indicator
        if not enemy.dead then
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.print("ENEMY", x - 20, y - 30)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
            love.graphics.print("DEBRIS", x - 20, y - 30)
        end
        
        -- Draw health bar for living enemies
        if not enemy.dead then
            local healthPercent = enemy.health / enemy.maxHealth
            local barWidth = 40
            local barHeight = 4
            
            love.graphics.setColor(1, 0, 0, 0.7)
            love.graphics.rectangle("fill", x - barWidth/2, y - 40, barWidth, barHeight)
            
            love.graphics.setColor(0, 1, 0, 0.7)
            love.graphics.rectangle("fill", x - barWidth/2, y - 40, barWidth * healthPercent, barHeight)
            
            love.graphics.setColor(1, 1, 1, 0.7)
            love.graphics.rectangle("line", x - barWidth/2, y - 40, barWidth, barHeight)
        end
        
        -- Draw particles
        drawEnemyParticles(enemy)
    end
    
    -- NEW: Draw dead enemies from the deadEnemies table
    for _, enemy in ipairs(deadEnemies) do
        love.graphics.setColor(0.3, 0.3, 0.3) -- Gray dead enemies
        local x, y = enemy.body:getPosition()
        love.graphics.polygon("fill", enemy.body:getWorldPoints(enemy.shape:getPoints()))
        
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.print("DEBRIS", x - 20, y - 30)
        
        drawEnemyParticles(enemy)
    end
end


-- NEW: Draw bullets
function drawBullets()
    for _, bullet in ipairs(bullets) do
        local x, y = bullet.body:getPosition()
        love.graphics.setColor(1, 1, 0) -- Yellow bullets
        love.graphics.circle("fill", x, y, 5)
        
        -- Draw trail
        love.graphics.setColor(1, 0.5, 0, 0.5)
        love.graphics.circle("fill", x, y, 3)
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
        local distance = love.math.random(30000, 100000) -- Further out
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance
        local r = love.math.random(20, 60) -- Larger balls
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
            if p.color then
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life/(p.size and p.size * 10 or 255))
            else
                love.graphics.setColor(1, 1, 1, p.life/255)
            end
            local size = p.size or 1
            love.graphics.circle("fill", p.x, p.y, size)
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
        local speed = camera.freeMoveSpeed * dt / 3
        
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
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Use relative positioning for better responsiveness
    local margin = math.min(20, screenWidth * 0.02)
    local fontSize = math.max(10, screenHeight * 0.02)
    local lineHeight = fontSize + 2
    
    -- Set font size for better readability
    local currentFont = love.graphics.getFont()
    if currentFont:getHeight() ~= fontSize then
        love.graphics.setNewFont(fontSize)
    end
    
    love.graphics.setColor(1, 1, 1)
    
    -- Game state and score - top left
    local yPos = margin
    love.graphics.print("State: " .. game.state, margin, yPos)
    love.graphics.print("Score: " .. game.score, margin, yPos + lineHeight)
    
    -- Player position and info
    if PlayerX[1] then
        local px, py = PlayerX[1].body:getPosition()
        love.graphics.print("Position: " .. math.floor(px) .. ", " .. math.floor(py), margin, yPos + lineHeight * 2)
        
        local vx, vy = PlayerX[1].body:getLinearVelocity()
        local speed = math.sqrt(vx*vx + vy*vy)
        love.graphics.print("Speed: " .. string.format("%.1f", speed), margin, yPos + lineHeight * 3)
    end
    
    -- Camera info
    love.graphics.print("Camera Mode: " .. camera.mode, margin, yPos + lineHeight * 4)
    love.graphics.print("Zoom: " .. string.format("%.3f", camera.scale), margin, yPos + lineHeight * 5)
    
    -- Planets visited
    local visited = 0
    for _, planet in ipairs(planets) do
        if planet.visited then visited = visited + 1 end
    end
    love.graphics.print("Planets Visited: " .. visited .. "/" .. #planets, margin, yPos + lineHeight * 6)
    
    -- Object counts - only show in two columns if screen is wide enough
    local objectCountsY = yPos + lineHeight * 7
    if screenWidth > 800 then
        -- Two columns for object counts
        love.graphics.print("Asteroids: " .. #box_i, margin, objectCountsY)
        love.graphics.print("Enemies: " .. #enemies, margin + 150, objectCountsY)
        love.graphics.print("Black Holes: " .. #blackholes, margin, objectCountsY + lineHeight)
        love.graphics.print("Wormholes: " .. #wormholes, margin + 150, objectCountsY + lineHeight)
        love.graphics.print("Comets: " .. #comets, margin, objectCountsY + lineHeight * 2)
        love.graphics.print("Pulsars: " .. #pulsars, margin + 150, objectCountsY + lineHeight * 2)
        love.graphics.print("Quasars: " .. #quasars, margin, objectCountsY + lineHeight * 3)
        love.graphics.print("Magnetars: " .. #magnetars, margin + 150, objectCountsY + lineHeight * 3)
        love.graphics.print("Space Stations: " .. #spacestations, margin, objectCountsY + lineHeight * 4)
        love.graphics.print("Dead Enemies: " .. #deadEnemies, margin + 150, objectCountsY + lineHeight * 4)
        -- NEW: Additional object counts
        love.graphics.print("Tesseracts: " .. #tesseracts, margin, objectCountsY + lineHeight * 5)
        love.graphics.print("Bio Nebulae: " .. #bionebulae, margin + 150, objectCountsY + lineHeight * 5)
    else
        -- Single column for smaller screens
        love.graphics.print("Asteroids: " .. #box_i, margin, objectCountsY)
        love.graphics.print("Enemies: " .. #enemies, margin, objectCountsY + lineHeight)
        love.graphics.print("Black Holes: " .. #blackholes, margin, objectCountsY + lineHeight * 2)
        love.graphics.print("Wormholes: " .. #wormholes, margin, objectCountsY + lineHeight * 3)
        love.graphics.print("Comets: " .. #comets, margin, objectCountsY + lineHeight * 4)
        love.graphics.print("Pulsars: " .. #pulsars, margin, objectCountsY + lineHeight * 5)
        love.graphics.print("Quasars: " .. #quasars, margin, objectCountsY + lineHeight * 6)
        love.graphics.print("Magnetars: " .. #magnetars, margin, objectCountsY + lineHeight * 7)
        love.graphics.print("Space Stations: " .. #spacestations, margin, objectCountsY + lineHeight * 8)
        love.graphics.print("Dead Enemies: " .. #deadEnemies, margin, objectCountsY + lineHeight * 9)
        -- NEW: Additional object counts
        love.graphics.print("Tesseracts: " .. #tesseracts, margin, objectCountsY + lineHeight * 10)
        love.graphics.print("Bio Nebulae: " .. #bionebulae, margin, objectCountsY + lineHeight * 11)
    end
    
    -- Ship systems status - positioned based on screen size
    drawShipSystemsUI(screenWidth, screenHeight)
    
    -- Debug mode indicator
    if game.debugMode then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("DEBUG MODE ACTIVE", margin, screenHeight - lineHeight * 10)
        
        -- NEW: Detailed gravity information
        if debugInfo.showDetailedInfo then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("TOTAL GRAVITY FORCE:", margin, screenHeight - lineHeight * 12)
            love.graphics.print("X: " .. string.format("%.2f", debugInfo.totalGravityForce.x), margin, screenHeight - lineHeight * 11)
            love.graphics.print("Y: " .. string.format("%.2f", debugInfo.totalGravityForce.y), margin, screenHeight - lineHeight * 10)
            love.graphics.print("Magnitude: " .. string.format("%.2f", debugInfo.totalGravityForce.magnitude), margin, screenHeight - lineHeight * 9)
        end
        
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Game message - centered at top
    if game.message ~= "" then
        local messageWidth = love.graphics.getFont():getWidth(game.message)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(game.message, screenWidth/2 - messageWidth/2, margin)
    end
    
    -- Instructions - right side, but adjust based on screen width
    -- local instructionsX = math.max(screenWidth - 250, screenWidth * 0.6)
    -- love.graphics.print("SOLAR SYSTEM EXPLORATION", instructionsX, margin)
    -- for i, instruction in ipairs(cameraInstructions) do
        -- love.graphics.print(instruction, instructionsX, margin + i * lineHeight)
    -- end
    
    -- Game controls - adjust position based on available space
    -- local controlsY = margin + (#cameraInstructions + 2) * lineHeight
    -- if controlsY < screenHeight * 0.7 then
        -- love.graphics.print("Space Controls:", instructionsX, controlsY)
        -- love.graphics.print("Arrow Keys: Thrusters", instructionsX, controlsY + lineHeight)
        -- love.graphics.print("PageUp/Down: Rotate", instructionsX, controlsY + lineHeight * 2)
        -- love.graphics.print("Shift: Boost", instructionsX, controlsY + lineHeight * 3)
        -- love.graphics.print("Space: Brake", instructionsX, controlsY + lineHeight * 4)
        -- love.graphics.print("L: Land/Takeoff", instructionsX, controlsY + lineHeight * 5)
        -- love.graphics.print("C: Auto Dock", instructionsX, controlsY + lineHeight * 6)
        -- love.graphics.print("F: Fire Weapons", instructionsX, controlsY + lineHeight * 7) -- NEW: Fire control
        -- love.graphics.print("Visit planets for points!", instructionsX, controlsY + lineHeight * 8)
        -- love.graphics.print("Use wormholes for teleport!", instructionsX, controlsY + lineHeight * 9)
        -- love.graphics.print("H: Toggle Controls", instructionsX, controlsY + lineHeight * 10)
    -- end
    
    -- Weapon cooldown indicator
    if shipSystems.weapons.cooldown > 0 then
        local cooldownPercent = shipSystems.weapons.cooldown / shipSystems.weapons.maxCooldown
        local cooldownWidth = 100
        local cooldownHeight = 10
        local cooldownX = screenWidth / 2 - cooldownWidth / 2
        local cooldownY = screenHeight - 50
        
        love.graphics.setColor(1, 0, 0, 0.7)
        love.graphics.rectangle("fill", cooldownX, cooldownY, cooldownWidth * cooldownPercent, cooldownHeight)
        
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.rectangle("line", cooldownX, cooldownY, cooldownWidth, cooldownHeight)
        
        love.graphics.print("Weapon Cooldown", cooldownX, cooldownY - 15)
    end
    
    -- Floating text particles
    for _, p in ipairs(particles) do
        if p.text then
            love.graphics.setColor(1, 1, 1, p.life/120)
            love.graphics.print(p.text, p.x, p.y)
        end
    end
end

function drawShipSystemsUI(screenWidth, screenHeight)
    local startY = screenHeight - 100
    local barWidth = math.min(100, screenWidth * 0.2)
    local barHeight = 7
    local margin = math.min(20, screenWidth * 0.02)
    
    -- Fuel
    local fuelPercent = shipSystems.fuel / shipSystems.maxFuel
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Fuel:", margin, startY)
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.rectangle("fill", margin + 50, startY, barWidth * fuelPercent, barHeight)
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.rectangle("line", margin + 50, startY, barWidth, barHeight)
    love.graphics.print(string.format("%.0f/%.0f", shipSystems.fuel, shipSystems.maxFuel), margin + 50 + barWidth + 5, startY)
    
    -- Health
    local healthPercent = shipSystems.health / shipSystems.maxHealth
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Health:", margin, startY + 15)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", margin + 50, startY + 15, barWidth * healthPercent, barHeight)
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.rectangle("line", margin + 50, startY + 25, barWidth, barHeight)
    love.graphics.print(string.format("%.0f/%.0f", shipSystems.health, shipSystems.maxHealth), margin + 50 + barWidth + 5, startY + 15)
    
    -- Shields
    local shieldPercent = shipSystems.shields / shipSystems.maxShields
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Shields:", margin, startY + 30)
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.rectangle("fill", margin + 50, startY + 30, barWidth * shieldPercent, barHeight)
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.rectangle("line", margin + 50, startY + 50, barWidth, barHeight)
    love.graphics.print(string.format("%.0f/%.0f", shipSystems.shields, shipSystems.maxShields), margin + 50 + barWidth + 5, startY + 30)
    
    -- Energy
    local energyPercent = shipSystems.energy / shipSystems.maxEnergy
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Energy:", margin, startY + 45)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", margin + 50, startY + 45, barWidth * energyPercent, barHeight)
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.rectangle("line", margin + 50, startY + 75, barWidth, barHeight)
    love.graphics.print(string.format("%.0f/%.0f", shipSystems.energy, shipSystems.maxEnergy), margin + 50 + barWidth + 5, startY + 45)
    
    -- System status
    love.graphics.setColor(1, 1, 1)
    if shipSystems.landed then
        love.graphics.print("Status: LANDED on " .. shipSystems.landingPlanet.name, margin, startY + 80)
    elseif shipSystems.docked then
        love.graphics.print("Status: DOCKED at Space Station", margin, startY + 80)
    else
        love.graphics.print("Status: IN FLIGHT", margin, startY + 80)
    end
    
    -- Auto dock status
    love.graphics.print("Auto Dock: " .. (shipSystems.autoDock and "ON" or "OFF"), margin, startY + 65)
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
        
        -- Boost indicator
        if shipSystems.boostActive then
            love.graphics.setColor(1, 0.5, 0, 0.8)
            love.graphics.line(bx, by, bx, by - thrusterLength * 2)
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
    elseif key == "r" then
        camera.scale = 0.01
    elseif key == "f5" then
        game.debugMode = not game.debugMode
    elseif key == "f6" then
        debugInfo.showDetailedInfo = not debugInfo.showDetailedInfo
    elseif key == "p" then
        if game.state == "playing" then
            game.state = "paused"
        else
            game.state = "playing"
        end
    elseif key == "return" then
        checkPlanetVisits()
    elseif key == "h" then
        touchControls.visible = not touchControls.visible
    elseif key == "c" then
        shipSystems.autoDock = not shipSystems.autoDock
        setGameMessage("Auto Dock: " .. (shipSystems.autoDock and "ON" or "OFF"), 2)
    elseif key == "l" then
        -- Landing/takeoff handled in checkLandingConditions
    elseif key == "f" then -- NEW: Fire weapon
        fireWeapon()
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


