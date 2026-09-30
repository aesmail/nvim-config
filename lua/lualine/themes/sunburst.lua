-- lualine theme matching colors/sunburst.lua
local c = {
  black = "#000000",
  fg = "#F8F8F8",
  dim = "#AEAEAE",
  bar = "#1A1A1A",
  section = "#2C3033",
  inactive = "#0E0E0E",
  entity = "#89BDFF",
  string = "#65B042",
  regexp = "#E9C062",
  keyword = "#E28964",
  support = "#9B859D",
  storage = "#99CF50",
}

local function mode(color)
  return {
    a = { fg = c.black, bg = color, gui = "bold" },
    b = { fg = c.fg, bg = c.section },
    c = { fg = c.dim, bg = c.bar },
  }
end

return {
  normal = mode(c.entity),
  insert = mode(c.string),
  visual = mode(c.regexp),
  replace = mode(c.keyword),
  command = mode(c.support),
  terminal = mode(c.storage),
  inactive = {
    a = { fg = c.dim, bg = c.inactive },
    b = { fg = c.dim, bg = c.inactive },
    c = { fg = c.dim, bg = c.inactive },
  },
}
