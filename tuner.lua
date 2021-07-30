function randomInteger(min, max)
	math.randomseed(os.clock())
	return math.random(min, max)
end

function normalize(candidate)
	local norm = math.sqrt(candidate.heightWeight * candidate.heightWeight +
							candidate.linesWeight * candidate.linesWeight +
							candidate.holesWeight * candidate.holesWeight +
							candidate.bumpinessWeight * candidate.bumpinessWeight)
	candidate.heightWeight = candidate.heightWeight / norm
	candidate.linesWeight = candidate.linesWeight / norm
	candidate.holesWeight = candidate.holesWeight / norm
	candidate.bumpinessWeight = candidate.bumpinessWeight / norm
end

function generateRandomCandidate()
	math.randomseed(os.clock())
	local candidate = {}
	candidate.heightWeight = math.random() - 0.5
	candidate.linesWeight = math.random() - 0.5
	candidate.holesWeight = math.random() - 0.5
	candidate.bumpinessWeight = math.random() - 0.5
	
	normalize(candidate)

	return candidate
end

function sort(candidates)
	table.sort(candidates, function(a, b)
		return b.fitness > a.fitness
	end)
end

function computeFitnesses(candidates, numberOfGames, maxNumberOfMoves)
	for i = 1, table.maxn(candidates) do
		local candidate = candidates[i]
		require "tetrisai_"
		local ai = AI:new(candidate)
		local totalScore = 0
		math.randomseed(os.clock())
		for j = 0, numberOfGames do
			require "tetrisgrid"
			local grid = Grid:new(18,10)
			require "tetrispiece"
			local workingPieces = {Piece.fromIndex(math.random(0,6)),Piece.fromIndex(math.random(0,6))}
			local workingPiece = workingPieces[1]
			local score = 0
			local numberOfMoves = 1

			while numberOfMoves < maxNumberOfMoves and not grid:exceeded() do
				workingPiece = ai:best(grid, workingPieces) 
				while workingPiece:moveDown(grid) do end
				grid:addPiece(workingPiece)
				score = score + grid:clearLines()

				workingPieces[1] = workingPieces[2]
				workingPieces[2] = Piece.fromIndex(math.random(0,6))
				workingPiece = workingPieces[1]
				numberOfMoves = numberOfMoves + 1
			end
			totalScore = totalScore + score
		end
		candidate.fitness = totalScore
	end
end

function tournamentSelectPair(candidates, ways)
	local indices = {}

	for i = 1, table.maxn(candidates) do
		table.insert(indices, i)
	end 

	local fittestCandidateIndex1 = nil
	local fittestCandidateIndex2 = nil

	for i = 1, ways do
		local selectedIndex = table.remove(indices, randomInteger(1, table.maxn(indices)))

		if fittestCandidateIndex1 == nil or selectedIndex < fittestCandidateIndex1 then
			fittestCandidateIndex2 = fittestCandidateIndex1
			fittestCandidateIndex1 = selectedIndex
		elseif fittestCandidateIndex2 == nil or selectedIndex < fittestCandidateIndex2 then
			fittestCandidateIndex2 = selectedIndex
		end
	end
	return {candidates[fittestCandidateIndex1], candidates[fittestCandidateIndex2]}
end

function crossOver(candidate1, candidate2)
	local candidate = {}
	candidate.heightWeight = candidate1.fitness * candidate1.heightWeight + candidate2.fitness * candidate2.heightWeight
	candidate.linesWeight = candidate1.fitness * candidate1.linesWeight + candidate2.fitness * candidate2.linesWeight
	candidate.holesWeight = candidate1.fitness * candidate1.holesWeight + candidate2.fitness * candidate2.holesWeight
	candidate.bumpinessWeight = candidate1.fitness * candidate1.bumpinessWeight + candidate2.fitness * candidate2.bumpinessWeight

	normalize(candidate)
	return candidate
end

function mutate(candidate)
	math.randomseed(os.clock())
	local quantity = math.random() * .4 - .2
	local randomInt = randomInteger(0,3)
	
	if randomInt == 0 then
		candidate.heightWeight = candidate.heightWeight + quantity
	elseif randomInt == 1 then
		candidate.linesWeight = candidate.linesWeight + quantity
	elseif randomInt == 2 then
		candidate.holesWeight = candidate.holesWeight + quantity
	else
		candidate.bumpinessWeight = candidate.bumpinessWeight + quantity
	end
end

function deleteNLastReplacement(candidates, newCandidates)
	for i = 1, table.maxn(newCandidates) do
		table.remove(candidates)
	end

	for i = 1, table.maxn(newCandidates) do
		table.insert(candidates,newCandidates[i])
	end
	sort(candidates)
end

function tune()
	local config = {}
	config.population = 100
	config.rounds = 5
	config.moves = 200

	local candidates = {}

	for i = 1, config.population do
		table.insert(candidates, generateRandomCandidate())
	end

	print("Computing fitnesses of initial population...")
	computeFitnesses(candidates, config.rounds, config.moves)
	sort(candidates)

	local count = 0

	while(true) do
		local newCandidates = {}

		for i = 1, 30 do
			local pair = tournamentSelectPair(candidates,10)
			local candidate = crossOver(pair[1],pair[2])
			math.randomseed(os.clock())
			if(math.random() < 0.05) then
				mutate(candidate)
			end
			normalize(candidate)
			table.insert(newCandidates, candidate)
		end

		print("Computing fitnesses of new candidates. (" .. count .. ")")
		computeFitnesses(newCandidates, config.rounds, config.moves)
		deleteNLastReplacement(candidates, newCandidates)
		local totalFitness = 0
		for i = 1, table.maxn(candidates) do
			totalFitness = totalFitness + candidates[i].fitness
		end
		print("Average fitness = " .. (totalFitness / table.maxn(candidates)))
		print("Highest fitness = " .. candidates[1].fitness .. "(" .. count .. ")")
		print("Fittest candidate = " + candidates[1] + "(" + count + ")") 
	end
end
