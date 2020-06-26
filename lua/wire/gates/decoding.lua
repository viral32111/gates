--[[---------------------------------------------------------------------
Gates - A collection of useful gates for use with Wiremod.
Copyright (C) 2020 viral32111 (https://viral32111.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see https://www.gnu.org/licenses.
---------------------------------------------------------------------]]--

--[[------------------------------------------------
Setup this script
------------------------------------------------]]--

-- These gates are for encoding string data
GateActions( "Decoding" )

-- Characters to percent-encode (https://developer.mozilla.org/en-US/docs/Glossary/percent-encoding)
local urlSpecialCharacters = { ":", "/", "?", "#", "[", "]", "@", "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "=", "%", " " }

-- Calculate the real value for each percent-encoded special character
local urlRealLookup = {}
for index = 1, #urlSpecialCharacters do
	local character = urlSpecialCharacters[ index ]
	local decimal = utf8.codepoint( character )
	local hex = string.format( "%02X", decimal )
	urlRealLookup[ hex ] = character
end

-- Base32 constants
local base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

--[[------------------------------------------------
Helper functions for later use
------------------------------------------------]]--

-- Clean this up!
function binaryToCharacter(str)
	if #str % 8 ~= 0 then
		error( "Malformed Binary Sequence", 2 )
	end

	local result = ""

	for i = 1, #str, 8 do
		result = result .. utf8.char( tonumber( str:sub( i, i + 7 ), 2 ) )
	end

	return result
end

-- four functions below were stolen from https://raw.githubusercontent.com/aiq/basexx/master/lib/basexx.lua, these need cleaning up, but they work!
local function number_to_bit( num, length )
	local bits = {}

	while num > 0 do
		local rest = math.floor( math.fmod( num, 2 ) )
		table.insert( bits, rest )
		num = ( num - rest ) / 2
	end

	while #bits < length do
		table.insert( bits, "0" )
	end

	return string.reverse( table.concat( bits ) )
end

local function pure_from_bit( str )
	return str:gsub( "........", function ( cc )
		return string.char( tonumber( cc, 2 ) )
	end )
end

local function unexpected_char_error( str, pos )
	local c = string.sub( str, pos, pos )
	return string.format( "unexpected character at position %d: '%s'", pos, c )
end

local function from_basexx( str, alphabet, bits )
	local result = {}
	for i = 1, #str do
		local c = string.sub( str, i, i )
		if c ~= '=' then
			local index = string.find( alphabet, c, 1, true )
			if not index then
				return nil, unexpected_char_error( str, i )
			end
			table.insert( result, number_to_bit( index - 1, bits ) )
		end
	end

	local value = table.concat( result )
	local pad = #value % 8
	return pure_from_bit( string.sub( value, 1, #value - pad ) )
end


--[[------------------------------------------------
Algorithm functions for encoding data
------------------------------------------------]]--

-- Base 2
local function base2( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Placeholder for the final result
	local result = ""

	-- Split the string up every space
	local binaries = string.Explode( " ", input )

	-- Loop through the number of binary values there are
	for index = 1, #binaries do

		-- Fetch the binary value for this iteration
		local binary = binaries[ index ]

		-- Convert the binary value to character
		local decimal = binaryToCharacter( binary )

		-- Append the decimal value to the final result
		result = result .. decimal

	end

	-- Return the final result
	return result

end

-- Base 8
local function base8( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Placeholder for the final result
	local result = ""

	-- Split the string up every space
	local octets = string.Explode( " ", input )

	-- Loop through the number of hex values there are
	for index = 1, #octets do

		-- Fetch the octal value for this iteration
		local octal = octets[ index ]

		-- Convert to the octal to decimal
		local decimal = tonumber( octal, 8 )

		-- Convert decimal to character
		local character = utf8.char( decimal )

		-- Append the character to the final result
		result = result .. character

	end

	-- Return the final result
	return result

end

-- Base 10
local function base10( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Placeholder for the final result
	local result = ""

	-- Split the string up every space
	local decimals = string.Explode( " ", input )

	-- Loop through the number of hex values there are
	for index = 1, #decimals do

		-- Fetch the decimal value for this iteration
		local decimal = tonumber( decimals[ index ], 10 )

		-- Convert decimal to character
		local character = utf8.char( decimal )

		-- Append the character to the final result
		result = result .. character

	end

	-- Return the final result
	return result

end

-- Base 16
local function base16( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Placeholder for the final result
	local result = ""

	-- Split the string up every space
	local hexs = string.Explode( " ", input )

	-- Loop through the number of hex values there are
	for index = 1, #hexs do

		-- Fetch the hex value for this iteration
		local hex = hexs[ index ]

		-- Convert the hex value to decimal
		local decimal = tonumber( hex, 16 )

		-- Convert decimal to character
		local character = utf8.char( decimal )

		-- Append the character to the final result
		result = result .. character

	end

	-- Return the final result
	return result

end

-- Base 32
local function base32( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Clean me up pls
	return from_basexx( string.upper( input ), base32Alphabet, 5 )

end

-- Base 64
local function base64( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Return the base64 decoded version of the input
	return util.Base64Decode( input )

end

-- URL
local function url( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Placeholder for the final result
	local result = ""

	-- Split the string up every percent
	local sections = string.Explode( "%", input )

	-- Loop for the number of sections there are
	for index = 1, #sections do

		-- Get the section for this iteration
		local section = sections[ index ]

		-- Get the first two characters of this section
		local hex = string.sub( section, 1, 2 )

		-- Get everything after those first two characters
		local ending = string.sub( section, 3 )

		-- Decode the percent encoding
		local decoded = urlRealLookup[ hex ]

		-- Is it a valid percent decoding?
		if decoded ~= nil then

			-- Append both the decoded and rest to the end of the result
			result = result .. decoded .. ending

		-- This is just a regular string
		else

			-- Append it to the end of the result
			result = result .. section

		end

	end

	-- Return the final result
	return result

end

--[[------------------------------------------------
Create each gate
------------------------------------------------]]--

-- Base 2
GateActions[ "decoding_base2" ] = {

	-- Name
	name = "Base-2 Decode (Binary)",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base2,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( binary, input )

		-- Return a formatted string
		return string.format( "base2decode(%s) = \"%s\"", input, binary )

	end

}

-- Base 8
GateActions[ "decoding_base8" ] = {

	-- Name
	name = "Base-8 Decode (Octal)",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base8,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( octal, input )

		-- Return a formatted string
		return string.format( "base8decode(%s) = \"%s\"", input, octal )

	end

}

-- Base 10 (equivalent to the 'To Character' gate, but supports multicharacter strings)
GateActions[ "decoding_base10" ] = {

	-- Name
	name = "Base-10 Decode (Decimal)",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base10,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( decimal, input )

		-- Return a formatted string
		return string.format( "base10decode(%s) = \"%s\"", input, decimal )

	end

}

-- Base 16
GateActions[ "decoding_base16" ] = {

	-- Name
	name = "Base-16 Decode (Hex)",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base16,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( hex, input )

		-- Return a formatted string
		return string.format( "base16decode(%s) = \"%s\"", input, hex )

	end

}

-- Base 32
GateActions[ "decoding_base32" ] = {

	-- Name
	name = "Base-32 Decode",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base32,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( b32, input )

		-- Return a formatted string
		return string.format( "base32decode(%s) = \"%s\"", input, b32 )

	end

}

-- Base 64
GateActions[ "decoding_base64" ] = {

	-- Name
	name = "Base-64 Decode",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base64,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( b64, input )

		-- Return a formatted string
		return string.format( "base64decode(%s) = \"%s\"", input, b64 )

	end

}

-- URL
GateActions[ "decoding_url" ] = {

	-- Name
	name = "URL Decode",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = url,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( result, input )

		-- Return a formatted string
		return string.format( "urldecode(%s) = \"%s\"", input, result )

	end

}

--[[------------------------------------------------
Finalise
------------------------------------------------]]--

-- Set the category back to nothing
GateActions()
