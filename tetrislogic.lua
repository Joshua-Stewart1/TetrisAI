function canFit(grid, block, row, col)
	for i, r in ipairs(block) do
		for j, c in ipairs(block[i])) do
			if (block[i][j] and grid[i + row][j + col]) then
				return false
			end
		end
	end
	return true
end

function removeFullRows(grid, cols)
	for i, row in ipairs(grid) do
		if sumRow(row) == cols then
			table.remove(grid, i)
			local a = {}
			for j = 1, cols do
				a[j] = false
			end
			table.insert(grid, 1, a)
		end
	end
end

function drop(grid, block, col)
	local row = 0
	while (canFit(grid, block, row + 1, col)) do
		row = row + 1
	end
	for i, r in ipairs(block) do
		for j, c in ipairs(block[i]) do
			grid[i + row][j + col] = grid[i + row][j + col] or block[i][j]
		end
	end
	removeFullRows(grid, table.maxn(grid[i]))
end

function sumRow(row)
	local x = 0
	for i, c in ipairs(row) do
		x = x + row[i] and 1 or 0
	end
	return x
end

function sumCol(grid, col) do
	local x = 0
	for i, row in ipairs(grid) do
		x = x + row[col] and 1 or 0
	end
	return x
end

function holes(grid) do
	local x = 0
	for i, col in ipairs(grid[1]) do
		for j, row in ipairs(grid) do
			if row[i] then
				x = x + table.maxn(grid) - j - sumCol(grid, i)
				break
			end
		end
	end
	return x
end

function best(grid, block) do
	local x = grid
	local y = 10000
	for i, rot in ipairs(block) do
		for c = 1, table.maxn(grid) - table.maxn(rot), 1 do
			local a = grid
			drop(a, rot, c)
			local z = 0
			while z < table.maxn(a) and sumRow(a[table.maxn(a) - z]) > 0) do z = z + 1 end
			z = z + holes(a) * 10
			if z < y then
				y = z
				x = a
			end
		end
	end
	return x
end

I = {{{true, true, true, true}}, {{true}, {true}, {true}, {true}}}
O = {{{true, true}, {true, true}}}
T = {{{true, true, true}, {false, true, false}}, {{true, false}, {true, true}, {true, false}}, {{false, true, false}, {true, true, true}}, {{false, true}, {true, true}, {false, true}}}
J = {{{true, true, true}, {false, false, true}}, {{false, true}, {false, true}, {true, true}}, {{true, false, false}, {true, true, true}}, {{true, true}, {true, false}, {true, false}}}
L = {{{true, true, true}, {true, false, false}}, {{true, false}, {true, false}, {true, true}}, {{false, false, true}, {true, true, true}}, {{true, true}, {false, true}, {false, true}}}
S = {{{false, true, true}, {true, true, false}}, {{true, false}, {true, true}, {false, true}}}
Z = {{{true, true, false}, {false, true, true}}, {{false, true}, {true, true}, {true, false}}}