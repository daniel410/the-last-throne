-- Compose these two runtime profiles outside Studio for shape-only comparisons.
Vector3 = {new = function(...) return {...} end}
local color
color = function(r, g, b)
    return setmetatable({r, g, b}, {__index = {
        Lerp = function(a, z, t)
            return color(a[1] + (z[1] - a[1])*t, a[2] + (z[2] - a[2])*t, a[3] + (z[3] - a[3])*t)
        end,
    }})
end
Color3 = {fromRGB = function(r, g, b) return color(r/255, g/255, b/255) end}
Enum = {Material = setmetatable({}, {__index = function(_, name) return name end})}

local function array(values)
    local result = {}
    for i, value in ipairs(values) do result[i] = ('%.12g'):format(value) end
    return '[' .. table.concat(result, ',') .. ']'
end

local function profile(module, id, palette)
    local rows = {}
    module.compose(id, palette, function(name, size, at, rgb, material, solid, angles, shape)
        assert(not solid and (not shape or shape == 'Wedge'), name)
        local x, y, z = table.unpack(angles or {0, 0, 0})
        local cx, cy, cz = math.cos(x), math.cos(y), math.cos(z)
        local sx, sy, sz = math.sin(x), math.sin(y), math.sin(z)
        -- CFrame.Angles applies Rx * Ry * Rz.
        local transform = {at[1], at[2], at[3],
            cy*cz, -cy*sz, sy,
            cx*sz + sx*sy*cz, cx*cz - sx*sy*sz, -sx*cy,
            sx*sz - cx*sy*cz, sx*cz + cx*sy*sz, cx*cy}
        -- BasePart.Color stores the channels at byte precision.
        local partColor = {}
        for i, value in ipairs(rgb) do partColor[i] = math.floor(value * 255 + 1e-9) / 255 end
        rows[#rows+1] = ('{"name":%q,"shape":%q,"material":%q,"size":%s,"color":%s,"transform":%s}')
            :format(name, shape or 'Block', material, array(size), array(partColor), array(transform))
    end, function() error('Unexpected beam') end)
    assert(#rows == (id == 'GW-07' and 10 or 15))
    return '[' .. table.concat(rows, ',') .. ']'
end

local palette = {}
local kit = assert(io.open(arg[3])):read('*a')
local paletteSource = assert(kit:match('(Kit%.palette=%b{})'))
assert(load('local Kit = ...; local C = Color3.fromRGB; ' .. paletteSource))(palette)
local function export(path)
    local module = dofile(path)
    return ('{"GW-07":%s,"FV-07":%s}'):format(
        profile(module, 'GW-07', palette.palette.Gloamwood),
        profile(module, 'FV-07', palette.palette.FrozenVale))
end
print(('{"baseline":%s,"candidate":%s}'):format(export(arg[1]), export(arg[2])))
