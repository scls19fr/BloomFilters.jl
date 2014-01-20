function genhashes(n::Integer, k::Integer)
	hashes = Array(Function, k)
	for i in 1:k
		f(s::Any) = mod(i * hash(s), n) + 1
		hashes[i] = f
	end
	return hashes
end

immutable BloomFilter
	mask::BitVector
	hashes::Vector{Function}
end

function BloomFilter(mask::BitVector, k::Integer)
	BloomFilter(mask, genhashes(length(mask), k))
end

function BloomFilter(n::Integer, hashes::Vector{Function})
	BloomFilter(falses(n), hashes)
end

function BloomFilter(n::Integer, k::Integer)
	BloomFilter(falses(n), genhashes(n, k))
end

function add!(filter::BloomFilter, key::Any)
	for h in filter.hashes
		filter.mask[h(key)] = true
	end
end

function add!(filter::BloomFilter, keys::Vector)
	for key in keys
		add!(filter, key)
	end
end

function contains(filter::BloomFilter, key::Any)
	for h in filter.hashes
		if !filter.mask[h(key)]
			return false
		end
	end
	return true
end

function contains(filter::BloomFilter, keys::Vector)
	m = length(keys)
	res = falses(m)
	for i in 1:m
		res[i] = contains(filter, keys[i])
	end
	return res
end

function show(io::IO, filter::BloomFilter)
	@printf "A Bloom filter\n"
	@printf " * Mask Size: %d\n" length(filter.mask)
	@printf " * Number of Hashes: %d" length(filter.hashes)
end
