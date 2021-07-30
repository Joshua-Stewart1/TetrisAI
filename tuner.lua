function randomInteger(max, min)
	math.randomseed(os.clock())
	return math.floor(math.random() * (max-min) + min)
end

function normalize(candidate)
	local norm = math.sqrt(candidate.heightWeight * candidate.heightWeight + 
						   candidate.linesWeight * candidate.linesWeight + 
						   candidate.holesWeight * candidate.holesWeight + 
						   candidate.bumpinessWeight * candidate.bumpinessWeight)
	candidate.heightWeight /= norm
    candidate.linesWeight /= norm
    candidate.holesWeight /= norm
    candidate.bumpinessWeight /= norm
end

function generateRandomCandidate()
	math.randomseed(os.clock())
	candidate = {};
	candidate.heightWeight: Math.random() - 0.5
	candidate.linesWeight: Math.random() - 0.5
	candidate.holesWeight: Math.random() - 0.5,
	candidate.bumpinessWeight: Math.random() - 0.5
	
	normalize(candidate);

	return candidate;
end

--Not sure how to do this function at all
function sort(candidates)
	candidates.sort(function(a, b)
	{
		return b.fitness - a.fitness;
	});
end

function computeFitnesses(candidates, numberOfGames, maxNumberOfMoves)
	for i = 0, table.getn(candidates) do
		local candidate = candidates[i]
		local ai = AI:new{candidate}
		local totalScore = 0
		math.randomseed(os.clock())
		for j = 0, numberOfGames do
			local grid = Grid:new{22,10}
			local workingPieces = {Piece.fromIndex(math.random(0,6)),Piece.fromIndex(math.random(0,6))}
			local workingPiece = workingPiece[0]
			local score = 0
			local numberOfMoves = 0

			while((numberOfMoves++) < maxNumberOfMoves and not(grid.exceeded()) do
				workingPiece = ai._best(grid, workingPieces) 
				while(workingPiece.moveDown(grid)) end
				grid.addPiece(workingPiece)
				score += grid.clearLines()

				for k = 0, k < table.getn(workingPieces)-1 do
					workingPieces[k] = workingPieces[k+1]
				end
				workingPieces[table.getn(workingPieces)-1] = Piece.fromIndex(math.random(0,6)
				workingPiece = workingPieces[0]
			end
			totalScore += score
		end
		candidate.fitness = totalScore
	end
end

function tournamentSelectPair(candidates, ways)
	local indices = {}

	for i = 0, table.getn(candidates) do
		table.insert(indices, i)
	end 

	local fittestCandidateIndex1 = nil
	local fittestCandidateIndex2 = nil

	for i = 0, ways do
		local selectedIndex = indices.splice(randomInteger(0, table.getn(indices), 1)[0] --Not sure of Lua equivalent of splice

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
	local randomInt = randomInteger(0,4)
	
	if randomInt == 0 then
		candidate.heightWeight += quantity
	elseif randomInt == 1 then
		candidate.linesWeight += quantity
	elseif randomInt == 2 then
		candidate.holesWeight += quantity
	else
		candidate.bumpinessWeight += quantity
	end
end

function deleteNLastReplacement(candidates, newCandidates)
	candidates.splice(-table.getn(newCandidates))

	for i = 0, table.getn(newCandidates) do
		table.insert(candidates,newCandidates[i])
	end
	sort(candidates)
end

local config = {}
config.population = 100
config.rounds = 5
config.moves = 200

local candidates = {}

for int i = 0, i < config.population do
	table.insert(candidates, generateRandomCandidate())
end

print("Computing fitnesses of initial population...")
computeFitnesses(candidates, config.rounds, config.moves)
sort(candidates)

local count = 0

while(true) do
	local newCandidates = {}

	for int i = 0, i < 30 do
		local pair = tournamentSelectPair(candidates,10)
		local candidate = crossOver(pair[0],pair[1])
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
	for int i = 0, i < table.getn(candidates) do
		totalFitness += candidates[i].fitness
	end
	console.log("Average fitness = " .. (totalFitness / table.getn(candidates)))
    console.log("Highest fitness = " .. candidates[0].fitness .. "(" .. count .. ")")
    console.log("Fittest candidate = " + candidates[0] + "(" + count + ")") 
end