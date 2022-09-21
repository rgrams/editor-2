
shouldRedraw = true

function love.run()
	love.load(love.arg.parseGameArguments(arg), arg)

	-- We don't want the first frame's dt to include time taken by love.load.
	love.timer.step()

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		love.event.pump()
		for name, a,b,c,d,e,f in love.event.poll() do
			if name == "quit" then
				if not love.quit or not love.quit() then
					return a or 0
				end
			end
			love.handlers[name](a,b,c,d,e,f)
		end

		-- Update dt, as we'll be passing it to update
		dt = love.timer.step()

		-- Call update and draw
		love.update(dt)

		if shouldRedraw and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			love.draw()

			love.graphics.present()
			shouldRedraw = false
		end

		love.timer.sleep(1/1000)
	end
end
