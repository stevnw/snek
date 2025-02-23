local snake, food, menu_snake = {}, {}, {body = {}, length = 32, direction = 'right'}
local gridSize, direction, score, timer, menu_timer = 20, 'right', 0, 0, 0
local game_started, game_over, difficulty = false, false, 'easy'
local speed = {easy = 20, normal = 50}
local bleepSound, gameOverSound

function love.load()
    love.window.setMode(900, 900)
    love.window.setTitle("Snek")
    bleepSound = love.audio.newSource("bleep.mp3", "static")
    gameOverSound = love.audio.newSource("game_over.mp3", "static")
    snake.body, snake.length = {{x = 5, y = 5}}, 1
    menu_snake.body[1] = {x = 5, y = 15}
    for i = 2, menu_snake.length do menu_snake.body[i] = {x = menu_snake.body[i-1].x - 1, y = menu_snake.body[i-1].y} end
    placeFood()
end

function moveMenuSnake()
    local head = {x = menu_snake.body[1].x, y = menu_snake.body[1].y}
    local possible = {'up', 'down', 'left', 'right'}
    local opposite = {up = 'down', down = 'up', left = 'right', right = 'left'}

    if math.random() < 0.1 then
        local valid = {}
        for _, dir in ipairs(possible) do
            local test = {x = head.x, y = head.y}
            if dir == 'up' then test.y = test.y - 1
            elseif dir == 'down' then test.y = test.y + 1
            elseif dir == 'left' then test.x = test.x - 1
            elseif dir == 'right' then test.x = test.x + 1 end

            if test.x < 0 then test.x = 44 elseif test.x > 44 then test.x = 0 end
            if test.y < 0 then test.y = 44 elseif test.y > 44 then test.y = 0 end

            local valid_move = true
            for i = 1, #menu_snake.body - 1 do
                if test.x == menu_snake.body[i].x and test.y == menu_snake.body[i].y then
                    valid_move = false
                    break
                end
            end
            if valid_move and dir ~= opposite[menu_snake.direction] then table.insert(valid, dir) end
        end
        if #valid > 0 then menu_snake.direction = valid[math.random(#valid)] end
    end

    if menu_snake.direction == 'up' then head.y = head.y - 1
    elseif menu_snake.direction == 'down' then head.y = head.y + 1
    elseif menu_snake.direction == 'left' then head.x = head.x - 1
    elseif menu_snake.direction == 'right' then head.x = head.x + 1 end

    if head.x < 0 then head.x = 44 elseif head.x > 44 then head.x = 0 end
    if head.y < 0 then head.y = 44 elseif head.y > 44 then head.y = 0 end

    for i = 1, #menu_snake.body - 1 do
        if head.x == menu_snake.body[i].x and head.y == menu_snake.body[i].y then
            menu_snake.body = {{x = 5, y = 15}}
            for i = 2, menu_snake.length do
                menu_snake.body[i] = {x = menu_snake.body[i-1].x - 1, y = menu_snake.body[i-1].y}
            end
            menu_snake.direction = 'right'
            return
        end
    end

    table.insert(menu_snake.body, 1, head)
    table.remove(menu_snake.body)
end

function love.update(dt)
    if not game_started then
        menu_timer = menu_timer + dt
        if menu_timer >= 1 / speed.normal then
            moveMenuSnake()
            menu_timer = 0
        end
        return
    end
    if not game_over then
        timer = timer + dt
        if timer >= 1 / speed[difficulty] then
            local head = {x = snake.body[1].x, y = snake.body[1].y}
            if direction == 'up' then head.y = head.y - 1
            elseif direction == 'down' then head.y = head.y + 1
            elseif direction == 'left' then head.x = head.x - 1
            elseif direction == 'right' then head.x = head.x + 1 end

            if head.x < 0 then head.x = 44 elseif head.x > 44 then head.x = 0 end
            if head.y < 0 then head.y = 44 elseif head.y > 44 then head.y = 0 end

            if head.x == food.x and head.y == food.y then
                score = score + 1
                snake.length = snake.length + 1
                placeFood()
                love.audio.play(bleepSound)
            end

            table.insert(snake.body, 1, head)
            for i = 2, #snake.body do
                if head.x == snake.body[i].x and head.y == snake.body[i].y then
                    game_over = true
                    love.audio.play(gameOverSound)
                end
            end
            if #snake.body > snake.length then table.remove(snake.body) end
            timer = 0
        end

        if love.keyboard.isDown('up') and direction ~= 'down' then direction = 'up'
        elseif love.keyboard.isDown('down') and direction ~= 'up' then direction = 'down'
        elseif love.keyboard.isDown('left') and direction ~= 'right' then direction = 'left'
        elseif love.keyboard.isDown('right') and direction ~= 'left' then direction = 'right' end
    end
end

function placeFood()
    food.x = math.random(0, 44)
    food.y = math.random(0, 44)
    for _, segment in ipairs(snake.body) do
        if segment.x == food.x and segment.y == food.y then
            placeFood()
            return
        end
    end
end

function love.draw()
    if not game_started then
        love.graphics.setColor(0, 0.5, 0)
        for _, segment in ipairs(menu_snake.body) do
            love.graphics.rectangle("fill", segment.x * gridSize, segment.y * gridSize, gridSize, gridSize)
        end
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(love.graphics.newFont(80))
        love.graphics.printf("Snek", 0, 200, 900, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(30))
        love.graphics.printf("Easy    Normal", 0, 400, 900, "center")
        love.graphics.printf("Quit", 0, 500, 900, "center")
        return
    end

    love.graphics.setColor(0, 1, 0)
    for _, segment in ipairs(snake.body) do
        love.graphics.rectangle("fill", segment.x * gridSize, segment.y * gridSize, gridSize, gridSize)
    end
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", food.x * gridSize, food.y * gridSize, gridSize, gridSize)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)

    if game_over then
        love.graphics.printf("Game Over!\nPress R to restart or M to go to menu", 0, 400, 900, "center")
    end
end

function love.mousepressed(x, y, button)
    if not game_started and button == 1 then
        if y >= 400 and y <= 430 then
            if x >= 350 and x <= 450 then startGame('easy')
            elseif x >= 450 and x <= 550 then startGame('normal') end
        elseif y >= 500 and y <= 530 then love.event.quit() end
    end
end

function love.keypressed(key)
    if game_over and (key == 'r' or key == 'm') then
        if key == 'r' then resetGame() else game_started = false end
    end
end

function startGame(selected_difficulty)
    game_started, difficulty = true, selected_difficulty
    resetGame()
end

function resetGame()
    snake.body, snake.length = {{x = 5, y = 5}}, 1
    direction, score, game_over = 'right', 0, false
    placeFood()
end
