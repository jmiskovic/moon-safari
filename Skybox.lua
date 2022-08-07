local m = {}

function m:init()
  self.cube = lovr.graphics.newTexture({
  front     = '1.png',
  right     = '2.png',
  left      = '4.png',
  back      = '3.png',
  bottom    = '6.png',
  top       = '5.png',
  })
end


function m:draw()
  lovr.graphics.setColor(1,1,1)
  lovr.graphics.skybox(self.cube)
end

return m
