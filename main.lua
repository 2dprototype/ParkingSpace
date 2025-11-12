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
        "C: Toggle Docking Computer"
    }
    
    -- Debug info
    debugInfo = {
        showPlayerVectors = true,
        showThrusterDirection = true,
        showPhysicsInfo = true,
        showObjectCounts = true,
        showGravityZones = true
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
        dockingStation = nil
    }
    
    -- Android touch controls
    touchControls = {
        visible = true,
        buttons = {
            {
                id = "up",
                x = love.graphics.getWidth() - 200,
                y = love.graphics.getHeight() - 300,
                width = 80,
                height = 80,
                color = {0, 0.8, 0, 0.7},
                active = false
            },
            {
                id = "left",
                x = love.graphics.getWidth() - 280,
                y = love.graphics.getHeight() - 200,
                width = 80,
                height = 80,
                color = {0, 0.8, 0, 0.7},
                active = false
            },
            {
                id = "right",
                x = love.graphics.getWidth() - 120,
                y = love.graphics.getHeight() - 200,
                width = 80,
                height = 80,
                color = {0, 0.8, 0, 0.7},
                active = false
            },
            {
                id = "down",
                x = love.graphics.getWidth() - 200,
                y = love.graphics.getHeight() - 120,
                width = 80,
                height = 80,
                color = {0, 0.8, 0, 0.7},
                active = false
            },
            {
                id = "rotate_left",
                x = 120,
                y = love.graphics.getHeight() - 200,
                width = 80,
                height = 80,
                color = {0.8, 0.8, 0, 0.7},
                active = false
            },
            {
                id = "rotate_right",
                x = 220,
                y = love.graphics.getHeight() - 200,
                width = 80,
                height = 80,
                color = {0.8, 0.8, 0, 0.7},
                active = false
            },
            {
                id = "zoom_in",
                x = love.graphics.getWidth() - 100,
                y = 100,
                width = 60,
                height = 60,
                color = {0.2, 0.5, 1, 0.7},
                active = false
            },
            {
                id = "zoom_out",
                x = love.graphics.getWidth() - 100,
                y = 180,
                width = 60,
                height = 60,
                color = {0.2, 0.5, 1, 0.7},
                active = false
            },
            {
                id = "boost",
                x = love.graphics.getWidth() - 100,
                y = 260,
                width = 60,
                height = 60,
                color = {1, 0.5, 0, 0.7},
                active = false
            },
            {
                id = "brake",
                x = love.graphics.getWidth() - 100,
                y = 340,
                width = 60,
                height = 60,
                color = {1, 0, 0, 0.7},
                active = false
            },
            {
                id = "land",
                x = 300,
                y = love.graphics.getHeight() - 100,
                width = 100,
                height = 60,
                color = {0, 0.5, 1, 0.7},
                active = false
            }
        }
    }
    
    updateTouchButtonPositions()
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

function updateGravity(dt)
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
            applyBodyGravity(body, px, py, planet.gravityRadius, planet.gravityStrength, dt)
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
            applyBodyGravity(body, bx, by, blackhole.gravityRadius, blackhole.gravityStrength, dt)
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
            applyBodyGravity(body, qx, qy, quasar.gravityRadius, quasar.gravityStrength, dt)
        end
    end
    
    -- Apply magnetar magnetic forces
    for _, magnetar in ipairs(magnetars) do
        local mx, my = magnetar.body:getPosition()
        
        if PlayerX[1] then
            applyMagnetarEffects(PlayerX[1], mx, my, magnetar, dt)
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
            button.x, button.y = w - 200, h - 280
        elseif button.id == "left" then
            button.x, button.y = w - 280, h - 200
        elseif button.id == "right" then
            button.x, button.y = w - 120, h - 200
        elseif button.id == "down" then
            button.x, button.y = w - 200, h - 120
        elseif button.id == "rotate_left" then
            button.x, button.y = 80, h - 200
        elseif button.id == "rotate_right" then
            button.x, button.y = 180, h - 200
        elseif button.id == "zoom_in" then
            button.x, button.y = w - 100, 100
        elseif button.id == "zoom_out" then
            button.x, button.y = w - 100, 180
        elseif button.id == "boost" then
            button.x, button.y = w - 100, 260
        elseif button.id == "brake" then
            button.x, button.y = w - 100, 340
        elseif button.id == "land" then
            button.x, button.y = 300, h - 100
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
    
    -- Draw nebulae
    drawNebulae()
    
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
    drawBlackholes()
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
        
        -- Draw accretion disk
        love.graphics.setColor(0.8, 0.6, 0.2, 0.3)
        love.graphics.circle("fill", x, y, blackhole.radius * 2.5)
        
        love.graphics.setColor(0.6, 0.4, 0.1, 0.5)
        love.graphics.circle("fill", x, y, blackhole.radius * 2)
        
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
        love.graphics.print("BLACK HOLE", x - 40, y - blackhole.radius - 30)
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
            love.graphics.setColor(planet.color[1], planet.color[2], planet.color[3]) -- Use planet color
        else
            -- Regular planet with its color
            love.graphics.setColor(planet.color[1], planet.color[2], planet.color[3])
        end
        
        love.graphics.circle("fill", x, y, planet.radius)
        
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
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        
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
        elseif button.id == "boost" then
            love.graphics.print("BST", button.x + button.width/2 - 10, button.y + button.height/2 - 10)
        elseif button.id == "brake" then
            love.graphics.print("BRK", button.x + button.width/2 - 10, button.y + button.height/2 - 10)
        elseif button.id == "land" then
            love.graphics.print("LAND", button.x + button.width/2 - 15, button.y + button.height/2 - 10)
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
    local shape = love.physics.newRectangleShape(w, h) -- Smaller enemies
    local fixture = love.physics.newFixture(body, shape, 1.2)
    fixture:setFriction(0.1)
    fixture:setRestitution(0.2)
    -- fixture:setSensor(true)
    
    local enemy = {
        type = "enemy",
        body = body,
        shape = shape,
        fixture = fixture,
        w = 6,   -- Smaller width
        h = 12,  -- Smaller height
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
    love.graphics.print("Black Holes: " .. #blackholes, 10, 190)
    love.graphics.print("Wormholes: " .. #wormholes, 10, 210)
    love.graphics.print("Comets: " .. #comets, 10, 230)
    love.graphics.print("Pulsars: " .. #pulsars, 10, 250)
    love.graphics.print("Quasars: " .. #quasars, 10, 270)
    love.graphics.print("Magnetars: " .. #magnetars, 10, 290)
    love.graphics.print("Space Stations: " .. #spacestations, 10, 310)
    
    -- Ship systems status
    drawShipSystemsUI()
    
    -- Debug mode indicator
    if game.debugMode then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("DEBUG MODE ACTIVE", 10, 350)
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Game message
    if game.message ~= "" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(game.message, love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(game.message)/2, 50)
    end
    
    -- Instructions
    love.graphics.print("SOLAR SYSTEM EXPLORATION", love.graphics.getWidth() - 250, 10)
    for i, instruction in ipairs(cameraInstructions) do
        love.graphics.print(instruction, love.graphics.getWidth() - 250, 10 + i * 20)
    end
    
    -- Game controls
    love.graphics.print("Space Controls:", love.graphics.getWidth() - 250, 310)
    love.graphics.print("Arrow Keys: Thrusters", love.graphics.getWidth() - 250, 330)
    love.graphics.print("PageUp/Down: Rotate", love.graphics.getWidth() - 250, 350)
    love.graphics.print("Shift: Boost", love.graphics.getWidth() - 250, 370)
    love.graphics.print("Space: Brake", love.graphics.getWidth() - 250, 390)
    love.graphics.print("L: Land/Takeoff", love.graphics.getWidth() - 250, 410)
    love.graphics.print("C: Auto Dock", love.graphics.getWidth() - 250, 430)
    love.graphics.print("Visit planets for points!", love.graphics.getWidth() - 250, 450)
    love.graphics.print("Use wormholes for teleport!", love.graphics.getWidth() - 250, 470)
    love.graphics.print("H: Toggle Controls", love.graphics.getWidth() - 250, 490)
    
    -- Floating text particles
    for _, p in ipairs(particles) do
        if p.text then
            love.graphics.setColor(1, 1, 1, p.life/120)
            love.graphics.print(p.text, p.x, p.y)
        end
    end
end

function drawShipSystemsUI()
    local startY = 400
    local barWidth = 150
    local barHeight = 15
    
    -- Fuel
    local fuelPercent = shipSystems.fuel / shipSystems.maxFuel
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Fuel:", 10, startY)
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.rectangle("fill", 60, startY, barWidth * fuelPercent, barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 60, startY, barWidth, barHeight)
    love.graphics.print(string.format("%.0f/%.0f", shipSystems.fuel, shipSystems.maxFuel), 220, startY)
    
    -- Health
    local healthPercent = shipSystems.health / shipSystems.maxHealth
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Health:", 10, startY + 25)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 60, startY + 25, barWidth * healthPercent, barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 60, startY + 25, barWidth, barHeight)
    love.graphics.print(string.format("%.0f/%.0f", shipSystems.health, shipSystems.maxHealth), 220, startY + 25)
    
    -- Shields
    local shieldPercent = shipSystems.shields / shipSystems.maxShields
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Shields:", 10, startY + 50)
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.rectangle("fill", 60, startY + 50, barWidth * shieldPercent, barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 60, startY + 50, barWidth, barHeight)
    love.graphics.print(string.format("%.0f/%.0f", shipSystems.shields, shipSystems.maxShields), 220, startY + 50)
    
    -- Energy
    local energyPercent = shipSystems.energy / shipSystems.maxEnergy
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Energy:", 10, startY + 75)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 60, startY + 75, barWidth * energyPercent, barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 60, startY + 75, barWidth, barHeight)
    love.graphics.print(string.format("%.0f/%.0f", shipSystems.energy, shipSystems.maxEnergy), 220, startY + 75)
    
    -- System status
    love.graphics.setColor(1, 1, 1)
    if shipSystems.landed then
        love.graphics.print("Status: LANDED on " .. shipSystems.landingPlanet.name, 10, startY + 100)
    elseif shipSystems.docked then
        love.graphics.print("Status: DOCKED at Space Station", 10, startY + 100)
    else
        love.graphics.print("Status: IN FLIGHT", 10, startY + 100)
    end
    
    -- Auto dock status
    love.graphics.print("Auto Dock: " .. (shipSystems.autoDock and "ON" or "OFF"), 10, startY + 120)
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
    elseif key == "h" then
        -- Toggle touch controls visibility
        touchControls.visible = not touchControls.visible
    elseif key == "c" then
        -- Toggle auto docking computer
        shipSystems.autoDock = not shipSystems.autoDock
        setGameMessage("Auto Dock: " .. (shipSystems.autoDock and "ON" or "OFF"), 2)
    elseif key == "l" then
        -- Landing/takeoff handled in checkLandingConditions
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