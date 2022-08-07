local m = {}



function m:init()
  vehicle = self.pool:queue{
    id = 'cc0fe2b7-70bf-4a53-b25d-1a42c8ec2bf9',
    name = 'S-1',
    vehicle_type = 'scooter',
    initial_position = {0, 5, 3},
  }
end


function m:addToGroup(group_name, e)
  if group_name == 'vehicle' then
    local x, y, z = unpack(e.initial_position or {})
    local w, h, d
    if e.vehicle_type == 'scooter' then
      w, h, d = 1.5, 1.4, 2
    end
    e.collider = self.pool.data.world:newBoxCollider(x, y, z, w, h, d)
    e.collider:setFriction(1)
    e.collider:setMass(10)
  end
end


function m:update(dt)
  for i, e in ipairs(self.pool.groups.vehicle.entities) do
    local force = 3000
    local torque = 600
    if lovr.system.isKeyDown('lshift') then
      force = force * 3
    end
    if lovr.system.isKeyDown('w') then
      local v = quat(e.collider:getOrientation()):direction()
      v:mul(dt * force)
      e.collider:applyForce(v)
    end
    if lovr.system.isKeyDown('s') then
      local v = quat(e.collider:getOrientation()):direction()
      v:mul(dt * -force)
      e.collider:applyForce(v)
    end
    if lovr.system.isKeyDown('a') then
      local v = quat(e.collider:getOrientation()):mul(vec3(0, dt * torque, 0))
      e.collider:applyTorque(v)
    end
    if lovr.system.isKeyDown('d') then
      local v = quat(e.collider:getOrientation()):mul(vec3(0, dt * -torque, 0))
      e.collider:applyTorque(v)
    end
    if lovr.system.isKeyDown('space') then
      e.collider:setPose(0, 5, 3)
    end
  end
end


function m:draw()
  local pose = mat4()
  for i, e in ipairs(self.pool.groups.vehicle.entities) do
    pose:set(e.collider:getPose()):scale(0.5, 0.5, 1.2)
    lovr.graphics.setLineWidth(15)
    lovr.graphics.setColor(0.4, 0.4, 0.4, 0.1)
    lovr.graphics.box('line', pose)
  end
end

return m
