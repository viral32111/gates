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

-- These gates are for bitwise operations
GateActions( "Bitwise" )

--[[------------------------------------------------
Functions for each gate
------------------------------------------------]]--

-- Or
local function bor( gate, ... )

	-- Placeholder for the final result
	local result = nil

	-- Loop through each input
	for index, input in ipairs( { ... } ) do

		-- Skip inputs that aren't wired to anything
		if input == nil then continue end

		-- Convert the integer input to a boolean
		local value = tobool( input )

		-- Has the final result been set yet?
		if result ~= nil then

			-- Update the final result
			result = ( result or value )

		-- The final result has not been set yet
		else

			-- Set the final result
			result = value

		end

	end

	-- Return 1 if the final result is true, or 0 if it isn't
	return result == true and 1 or 0

end

-- And
local function band( gate, ... )

	-- Placeholder for the final result
	local result = nil

	-- Loop through each input
	for index, input in ipairs( { ... } ) do

		-- Skip inputs that aren't wired to anything
		if input == nil then continue end

		-- Convert the integer input to a boolean
		local value = tobool( input )

		-- Has the final result been set yet?
		if result ~= nil then

			-- Update the final result
			result = ( result and value )

		-- The final result has not been set yet
		else

			-- Set the final result
			result = value

		end

	end

	-- Return 1 if the final result is true, or 0 if it isn't
	return result == true and 1 or 0

end

--[[------------------------------------------------
Create each gate
------------------------------------------------]]--

-- Or
GateActions[ "extrabitwise_or" ] = {

	-- Name
	name = "Or (Many)",

	-- Inputs
	inputs = { "A", "B", "C", "D", "E", "F", "G", "H" },
	compact_inputs = 2,

	-- Output
	output = bor,

	-- Tooltip
	label = function( result, ... )

		-- Placeholder for the final tooltip
		local tooltip = ""

		-- Loop through each input
		for index, input in ipairs( { ... } ) do

			-- Check if the input is valid
			if input ~= nil then

				-- Append the input to the end of the tooltip
				tooltip = tooltip .. input .. " or "

			end

		end

		-- Return the tooltip without the last ' or ', and with the final result on the end
		return string.sub( tooltip, 1, -5 ) .. " = " .. result

	end

}

-- And
GateActions[ "extrabitwise_and" ] = {

	-- Name
	name = "And (Many)",

	-- Inputs
	inputs = { "A", "B", "C", "D", "E", "F", "G", "H" },
	compact_inputs = 2,

	-- Output
	output = band,

	-- Tooltip
	label = function( result, ... )

		-- Placeholder for the final tooltip
		local tooltip = ""

		-- Loop through each input
		for index, input in ipairs( { ... } ) do

			-- Check if the input is valid
			if input ~= nil then

				-- Append the input to the end of the tooltip
				tooltip = tooltip .. input .. " and "

			end

		end

		-- Return the tooltip without the last ' and ', and with the final result on the end
		return string.sub( tooltip, 1, -6 ) .. " = " .. result

	end

}

--[[------------------------------------------------
Finalise
------------------------------------------------]]--

-- Set the category back to nothing
GateActions()
