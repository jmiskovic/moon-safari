_G.math.turn = 2 * math.pi
_G.math.phi  = (1 + math.sqrt(5)) / 2

local nata = require 'nata'

local tags = {}

local pool = nata.new {
  groups = {
    vehicle = {filter = {'id', 'name', 'vehicle_type'}},
  },
  systems = {
    require'Vehicle',
    require'Terrain',
    require'Skybox',
  },
  data = {
    world = lovr.physics.newWorld(0, -9.81, 0, false, tags)
  }
}


pool.data.world:setLinearDamping(0.01)
pool.data.world:setAngularDamping(0.05)

local perspective = mat4():perspective(0.1, 1000, 70, lovr.graphics.getWidth() / lovr.graphics.getHeight())
lovr.graphics.setProjection(1, perspective)


function lovr.update(dt)
  pool:emit('update', dt)
  pool:remove(function(entity) return entity.expired end)
  pool.data.world:update(1/72)
  pool:flush()
end


function lovr.draw()
  lovr.graphics.transform(mat4(vehicle.collider:getPose()):invert())
  lovr.graphics.setColor(1, 1, 1)
  pool:emit('draw')
  lovr.graphics.setColor(0, 1, 0)
end


function lovr.keypressed(...)
  pool:emit('keypressed', ...)
end
