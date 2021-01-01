--[[---------------------------------------------------------------------
Gates - A collection of useful gates for use with Wiremod.
Copyright (C) 2020 - 2021 viral32111 (https://viral32111.com)

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
GateActions( "Encoding" )

-- Characters to percent-encode (https://developer.mozilla.org/en-US/docs/Glossary/percent-encoding)
local urlSpecialCharacters = { ":", "/", "?", "#", "[", "]", "@", "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "=", "%", " " }

-- Calculate the percent-encoding value for each special character
local urlCodeLookup = {}
for index = 1, #urlSpecialCharacters do
	local character = urlSpecialCharacters[ index ]
	local decimal = utf8.codepoint( character )
	local hex = string.format( "%02X", decimal )
	urlCodeLookup[ character ] = hex
end

-- Base32 constants
local base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
local base32PadMap = { "", "======", "====", "===", "=" }

--[[------------------------------------------------
Helper functions for later use
------------------------------------------------]]--

-- Convert single digit decimal (base 10) to non-padded binary (base 2)
local function decimalToBinary( decimal )

	-- Placeholder for the final binary string
	local binary = ""

	-- Repeat until the argument is zero
	repeat

		-- Get the binary bit (1 or 0)
		local bit = decimal % 2

		-- Append the bit to the start of the binary string
		binary = bit .. binary

		-- Update the argument
		decimal = ( decimal - bit ) / 2

	until decimal == 0

	-- Return the final binary string
	return binary
end

-- three functions below were stolen from https://raw.githubusercontent.com/aiq/basexx/master/lib/basexx.lua, these need cleaning up, but they work!
local function divide_string( str, max )
	local result = {}

	local start = 1
	for i = 1, #str do
		if i % max == 0 then
			table.insert( result, str:sub( start, i ) )
			start = i + 1
		elseif i == #str then
			table.insert( result, str:sub( start, i ) )
		end
	end

	return result
end

local function to_bit( str )
	return str:gsub( '.', function ( c )
		local byte = string.byte( c )
		local bits = {}
		for _ = 1,8 do
			table.insert( bits, byte % 2 )
			byte = math.floor( byte / 2 )
		end
		return table.concat( bits ):reverse()
	end )
end

local function to_basexx( str, alphabet, bits, pad )
	local bitString = to_bit( str )

	local chunks = divide_string( bitString, bits )
	local result = {}
	for _,value in ipairs( chunks ) do
		if ( #value < bits ) then
			value = value .. string.rep( '0', bits - #value )
		end
		local pos = tonumber( value, 2 ) + 1
		table.insert( result, alphabet:sub( pos, pos ) )
	end

	table.insert( result, pad )
	return table.concat( result )
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

	-- Force the string to only contain valid UTF-8 data
	local safeInput = utf8.force( input )

	-- Loop through every character in the string
	for index, decimal in utf8.codes( safeInput ) do

		-- Convert the decimal value to binary
		local binary = decimalToBinary( decimal )

		-- Apply zero padding to the left of the binary number to a max of eight
		local padded = string.format( "%08d ", binary )

		-- Append the padded binary string to the final result
		result = result .. padded

	end

	-- Return the final result without the last character
	return string.sub( result, 1, -2 )

end

-- Base 8
local function base8( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Placeholder for the final result
	local result = ""

	-- Force the string to only contain valid UTF-8 data
	local safeInput = utf8.force( input )

	-- Loop through every character in the string
	for index, decimal in utf8.codes( safeInput ) do

		-- Convert the decimal value to octal and apply zero padding
		local octal = string.format( "%03o ", decimal )

		-- Append the octal value to the final result
		result = result .. octal

	end

	-- Return the final result without the last character
	return string.sub( result, 1, -2 )

end

-- Base 10
local function base10( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Placeholder for the final result
	local result = ""

	-- Force the string to only contain valid UTF-8 data
	local safeInput = utf8.force( input )

	-- Loop through every character in the string
	for index, decimal in utf8.codes( safeInput ) do

		-- Convert the decimal value to a string with a space on the end
		local str = tostring( decimal ) .. " "

		-- Append the string decimal value to the final result
		result = result .. str

	end

	-- Return the final result without the last character
	return string.sub( result, 1, -2 )

end

-- Base 16
local function base16( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Placeholder for the final result
	local result = ""

	-- Force the string to only contain valid UTF-8 data
	local safeInput = utf8.force( input )

	-- Loop through every character in the string
	for index, decimal in utf8.codes( safeInput ) do

		-- Convert the decimal value to uppercase hex with zero padding
		local hex = string.format( "%02X ", decimal )

		-- Append the string decimal value to the final result
		result = result .. hex

	end

	-- Return the final result without the last character
	return string.sub( result, 1, -2 )

end

-- Base 32
local function base32( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Clean me up pls
	return to_basexx( input, base32Alphabet, 5, base32PadMap[ #input % 5 + 1 ] )

end

-- Base 64
local function base64( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Return the base64 encoded version of the input
	return util.Base64Encode( input )

end

-- URL
local function url( gate, input )

	-- If no input is given then return an empty string
	if input == "" then return "" end

	-- Placeholder for the final result
	local result = ""

	-- Force the string to only contain valid UTF-8 data
	local safeInput = utf8.force( input )

	-- Loop through every character in the string
	for index, decimal in utf8.codes( safeInput ) do

		-- Get the character for this iteration
		local character = utf8.char( decimal )

		-- Is this a special character?
		if urlCodeLookup[ character ] ~= nil then

			-- Fetch the percent-encoded version
			local enc = "%" .. urlCodeLookup[ character ]

			-- Append the percent-encoded version to the end of the final result
			result = result .. enc

		-- This is a normal character
		else

			-- Append the normal character to the end of the final result
			result = result .. character

		end

	end

	-- Return the final result
	return result

end

--[[------------------------------------------------
Create each gate
------------------------------------------------]]--

-- Base 2
GateActions[ "encoding_base2" ] = {

	-- Name
	name = "Base-2 Encode (Binary)",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base2,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( binary, input )

		-- Is the length of the result more than 44?
		if string.len( binary ) > 44 then

			-- Truncate the result (binary strings can get very long...)
			binary = string.sub( binary, 1, 44 ) .. "..."

		end

		-- Return a formatted string
		return string.format( "base2encode(%s) = \"%s\"", input, binary )

	end

}

-- Base 8
GateActions[ "encoding_base8" ] = {

	-- Name
	name = "Base-8 Encode (Octal)",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base8,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( octal, input )

		-- Return a formatted string
		return string.format( "base8encode(%s) = \"%s\"", input, octal )

	end

}

-- Base 10 (equivalent to the 'To Byte' gate, but supports multicharacter strings)
GateActions[ "encoding_base10" ] = {

	-- Name
	name = "Base-10 Encode (Decimal)",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base10,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( decimal, input )

		-- Return a formatted string
		return string.format( "base10encode(%s) = \"%s\"", input, decimal )

	end

}

-- Base 16
GateActions[ "encoding_base16" ] = {

	-- Name
	name = "Base-16 Encode (Hex)",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base16,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( hex, input )

		-- Return a formatted string
		return string.format( "base16encode(%s) = \"%s\"", input, hex )

	end

}

-- Base 32
GateActions[ "encoding_base32" ] = {

	-- Name
	name = "Base-32 Encode",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base32,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( b32, input )

		-- Return a formatted string
		return string.format( "base32encode(%s) = \"%s\"", input, b32 )

	end

}

-- Base 64
GateActions[ "encoding_base64" ] = {

	-- Name
	name = "Base-64 Encode",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = base64,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( b64, input )

		-- Return a formatted string
		return string.format( "base64encode(%s) = \"%s\"", input, b64 )

	end

}

-- URL
GateActions[ "encoding_url" ] = {

	-- Name
	name = "URL Encode",

	-- Inputs
	inputs = { "A" },
	inputtypes = { "STRING" },

	-- Output
	output = url,
	outputtypes = { "STRING" },

	-- Tooltip
	label = function( result, input )

		-- Return a formatted string
		return string.format( "urlencode(%s) = \"%s\"", input, result )

	end

}

--[[------------------------------------------------
Finalise
------------------------------------------------]]--

-- Set the category back to nothing
GateActions()
