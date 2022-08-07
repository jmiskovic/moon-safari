local m = {}

m.size = 400

local terrain, shader

local shaderCode = {[[
/* VERTEX shader */
out vec4 fragmentView;
out vec3 worldView;

vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
  worldView = (vertex).xyz;
  fragmentView = projection * transform * vertex;
  return fragmentView;
} ]], [[
/* FRAGMENT shader */
#define PI 3.1415926538
in vec4 fragmentView;
in vec3 worldView;
uniform vec3 fogColor;

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv)
{
  float fogAmount = atan(length(fragmentView) * 0.1) * 2.0 / PI;
  vec3 surface = graphicsColor.rgb * texture(image, worldView.xz * 15.).rgb;
  vec4 color = vec4(mix(surface, fogColor, fogAmount), graphicsColor.a);
  return color;
}]]}

local function grid(subdivisions)
  local size = 1 / math.floor(subdivisions or 1)
  local vertices = {}
  local indices  = {}
  for z = -0.5, 0.5, size do
    for x = -0.5, 0.5, size do
      table.insert(vertices, {x, 0, z,                0,1,0,  x + 0.5, z + 0.5})
      table.insert(vertices, {x, 0, z + size,         0,1,0,  x + 0.5, z + 0.5})
      table.insert(vertices, {x + size, 0, z,         0,1,0,  x + 0.5, z + 0.5})
      table.insert(vertices, {x + size, 0, z + size,  0,1,0,  x + 0.5, z + 0.5})
      table.insert(indices, #vertices - 3)
      table.insert(indices, #vertices - 2)
      table.insert(indices, #vertices - 1)
      table.insert(indices, #vertices - 2)
      table.insert(indices, #vertices)
      table.insert(indices, #vertices - 1)
    end
  end
  local meshFormat = {{'lovrPosition', 'float', 3},
                      { 'lovrNormal',      'float', 3 },
                      { 'lovrTexCoord',    'float', 2 }}
  local mesh = lovr.graphics.newMesh(meshFormat, vertices, "triangles", "dynamic", true)
  mesh:setVertexMap(indices)
  return mesh
end


local zn = lovr.math.noise(0,0)

local function terrain(x, z, scale)
  local stretch, amp
  local h = 0
  stretch, amp = 1, 12
  h = h + (lovr.math.noise(x * stretch, z * stretch) - zn) * amp
  stretch, amp = 2, 15
  h = h + (lovr.math.noise(x * stretch, z * stretch) - zn) * amp
  stretch = 8
  h = h + math.atan((lovr.math.noise(x * stretch, z * stretch) - 0.5) * 20) * 2
  return h / scale
end


function m:init()
  --local skyColor = {0.208, 0.208, 0.275}
  --lovr.graphics.setBackgroundColor(skyColor)
  local skyColor = {0, 0, 0}
  lovr.graphics.setLineWidth(2)
  shader = lovr.graphics.newShader(unpack(shaderCode))
  shader:send('fogColor', { lovr.math.gammaToLinear(unpack(skyColor)) })
  self.mesh = grid(300)

  local image_size = 512
  local image = lovr.data.newImage(image_size, image_size, 'r32f')

  for vi = 1, self.mesh:getVertexCount() do
    local x, h, z, nx, ny, nz, u, v = self.mesh:getVertex(vi)
    h = terrain(x, z, self.size)
    self.mesh:setVertex(vi, {x, h, z, nx, ny, nz, u, v})
  end
  for px = 0, image_size - 1 do
    for pz = 0, image_size - 1 do
      local x = (px+1) / image_size - 0.5
      local z = (pz+1) / image_size - 0.5
      local h = terrain(x, z, self.size)
      image:setPixel(px, pz, h)
    end
  end

  self.collider = self.pool.data.world:newHeightfieldCollider(image, self.size)
  self.collider:setRestitution(0)
  self.collider:setFriction(1)
  local surface = lovr.graphics.newTexture('surface.jpg')
  local material = lovr.graphics.newMaterial(surface)
  material:setTransform(0, 0, 0.0050, 0.0050, 0)
  self.mesh:setMaterial(material)
end

function m:draw()
  lovr.graphics.scale(self.size)
  lovr.graphics.setShader(shader)
  lovr.graphics.setColor(0.4, 0.4, 0.4)
  self.mesh:draw()
  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.setShader()
end

return m
