_G = _G or getfenv(0)

local TOKEN_PREFIX = '{{'
local TOKEN_SUFFIX = '}}'

local PATTERN_HEX_CODE = string.rep('[0-9a-fA-F]', 6)

local WOW_COLOR = '\124cff'
local WOW_RESET = '\124r'

local defaultSendChatMessage = SendChatMessage;

local colorsByName = {
   red = 'ff4444',
   green = '99cc00',
   blue = '33b5e5',
   purple = 'aa66cc',
   orange = 'ffbb33',
   white = 'ffffff',
   black = '000000'
}
function colorFractionToHex(value)
   return string.format('%02x', math.floor(value * 255 + 0.5))
end
for i, color in ITEM_QUALITY_COLORS do
   local qualityName = _G['ITEM_QUALITY' .. i .. '_DESC']
   if qualityName then
      local name = string.lower(_G['ITEM_QUALITY' .. i .. '_DESC'])
      local hexCode = colorFractionToHex(color.r)
         .. colorFractionToHex(color.g)
         .. colorFractionToHex(color.b)
      colorsByName[name] = hexCode
   end
end

function augmentedSendChatMessage(message, type, language, channel)
   local lastResult = nil

   while true do
      local tStart, tEnd = string.find(
         message,
         TOKEN_PREFIX .. '.-' .. TOKEN_SUFFIX
      )
      if not tStart then
         break
      end
      local token = string.sub(message, tStart, tEnd)
      local convertedToken = convertToken(token)
      if string.len(convertedToken) > 0 then
         lastResult = convertedToken
      end
      message = string.sub(message, 0, tStart - 1)
         .. convertedToken
         .. string.sub(message, tEnd + 1, string.len(message))
   end

   -- Add a color reset at end of message if no such token was specified
   -- by the user.
   if lastResult and lastResult ~= WOW_RESET then
      message = message .. WOW_RESET
   end

   defaultSendChatMessage(message, type, language, channel)
end

function convertToken(token)
   local label = string.sub(
      token,
      string.len(TOKEN_PREFIX) + 1,
      string.len(token) - string.len(TOKEN_PREFIX)
   )

   if string.sub(label, 1, 1) == '#' then
      label = string.sub(label, 2, string.len(label))
      if string.len(label) == 3 then
         label = string.rep(string.sub(label, 1, 1), 2)
            .. string.rep(string.sub(label, 2, 2), 2)
            .. string.rep(string.sub(label, 3, 3), 2)
      end
      return string.find(label, PATTERN_HEX_CODE) and WOW_COLOR .. label or ''
   end

   if label == '/' then
      return WOW_RESET
   end

   local hexCode = colorsByName[label]
   if hexCode then
      return WOW_COLOR .. hexCode
   end

   return ''
end

SendChatMessage = augmentedSendChatMessage
