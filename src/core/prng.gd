class_name Prng
extends RefCounted
## THE ONE RANDOM NUMBER STREAM - the GDScript half of the source's backend/Prng.cs.
##
## xorshift64* (Vigna 2016) on GDScript's signed 64-bit int. Every step is a plain
## two's-complement op with wrapping; the one logical shift the algorithm needs is
## reproduced with a mask, because GDScript's >> is arithmetic. Bit-identical to the
## C# reference: tests/fixtures/prng-12345.txt holds its first thousand outputs.
##
## Subclass-of-Random on the C# side became: every method that took a Random takes
## a Prng here, and the same Next / Next(max) / Next(min,max) / NextDouble contracts.

## Set once per session before day-zero generation.
static var Session: Prng = Prng.new(1)

var Seed: int
var _x: int

const ZERO_SEED_SENTINEL: int = -7046029254386353131   # 0x9E3779B97F4A7C15 as signed
const MULTIPLIER: int = 2685821657736338717            # 0x2545F4914F6CDD1D
const MASK57: int = 0x01FFFFFFFFFFFFFF                 # clears the 7 sign-extended bits after >> 7
const LOW31: int = 0x7FFFFFFF
const MASK53: int = 0x1FFFFFFFFFFFFF
const TWO_POW_53_INV: float = 1.0 / 9007199254740992.0


func _init(seed: int = 1) -> void:
	Seed = seed
	_x = ZERO_SEED_SENTINEL if seed == 0 else seed


## The raw generator. C# mirror in backend/Prng.cs Next64().
func next64() -> int:
	_x ^= _x << 13
	_x ^= (_x >> 7) & MASK57
	_x ^= _x << 17
	return _x * MULTIPLIER


func _low31() -> int:
	return next64() & LOW31


## System.Random.Next(): a non-negative 31-bit value.
func Next() -> int:
	return _low31()


## System.Random.Next(maxValue): [0, max).
func NextMax(max_value: int) -> int:
	assert(max_value >= 0)
	if max_value <= 1:
		return 0
	return _low31() % max_value


## System.Random.Next(min, max): min + (low31 % range).
func NextRange(min_value: int, max_value: int) -> int:
	assert(min_value <= max_value)
	var range_size: int = max_value - min_value
	if range_size <= 1:
		return min_value
	return min_value + _low31() % range_size


## System.Random.NextDouble(): 53 random bits over [0, 1).
func NextDouble() -> float:
	return float((next64() >> 11) & MASK53) * TWO_POW_53_INV


## The proof: the first `count` raw outputs from `seed`, in the fixture's format.
static func dump(seed: int, count: int) -> PackedStringArray:
	var p := Prng.new(seed)
	var lines := PackedStringArray()
	lines.append("# xorshift64* seed=%d count=%d" % [seed, count])
	for i in count:
		lines.append(str(p.next64()))
	return lines
