defmodule CryptoRand.Test do
  use ExUnit.Case, async: true

  import CryptoRand

  alias CryptoRand.Test.FixedBytes
  alias CryptoRand.Test.Util

  defmodule CryptoRand.Test.FixedBytes.A do
    use FixedBytes,
      bytes: <<0b00011011, 0b00110111, 0b01111001, 0b00101110, 0b11010101>>
  end

  defmodule CryptoRand.Test.FixedBytes.B do
    use FixedBytes, bytes: <<0b11111111, 0b10110101, 0b01000110, 0, 0, 0>>
  end

  alias CryptoRand.Test.FixedBytes.A, as: Fixed_A
  alias CryptoRand.Test.FixedBytes.B, as: Fixed_B

  test "basic" do
    assert is_integer(uniform(100))
    assert 0 < uniform(100)
    assert uniform(100) < 101

    assert random(1..100) <= 100
    assert length(shuffle(1..25)) === 25
    assert length(take_random(1..25, 10)) === 10
  end

  test "invalid max" do
    assert_raise FunctionClauseError, fn ->
      uniform(0)
    end
  end

  test "invalid rand_bytes" do
    assert_raise FunctionClauseError, fn ->
      uniform(4, rand_bytes: <<1, 2>>)
    end
  end

  test "clear process dictionary" do
    atoms = [:crypto_rand_max, :crypto_rand_bytes]
    atoms |> Enum.reduce(true, &(&2 and Process.get(&1) == nil)) |> assert
    uniform(100)
    atoms |> Enum.reduce(true, &(&2 and Process.get(&1) != nil)) |> assert
    clear()
    atoms |> Enum.reduce(true, &(&2 and Process.get(&1) == nil)) |> assert
  end

  test "max 1" do
    assert uniform(1) === 1
  end

  test "max is max" do
    Enum.each(1..48, fn max -> assert uniform(max) < max + 1 end)

    n = 10

    Enum.each(1..48, fn max ->
      uniform_list(max, n) |> Enum.each(fn value -> assert value < max + 1 end)
    end)

    Enum.each(1..48, fn max ->
      bits = max |> :math.log2() |> :math.ceil() |> round()

      uniform_bytes(max, n)
      |> Util.uniform_bytes_to_list(n, bits)
      |> Enum.each(fn value -> assert value < max + 1 end)
    end)
  end

  test "max 2" do
    max = 2
    mod = Fixed_2_Bits_00000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b00000000>>))
    assert mod.uniform(max) === 1

    mod = Fixed_2_Bits_01000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b01000000>>))
    assert mod.uniform(max) === 1

    mod = Fixed_2_Bits_10000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b10000000>>))
    assert mod.uniform(max) === 2

    mod = Fixed_2_Bits_11000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11000000>>))
    assert mod.uniform(max) === 2

    mod = Fixed_2_Bits_00010000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b00010000>>))
    assert mod.uniform(max, false) === 1
    assert mod.uniform(max, false) === 1
    assert mod.uniform(max, false) === 1
    assert mod.uniform(max) === 2
  end

  test "max 3" do
    max = 3
    mod = Fixed_3_Bits_00000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b00000000>>))
    assert mod.uniform(max) === 1

    mod = Fixed_3_Bits_01000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b01000000>>))
    assert mod.uniform(max) === 2

    mod = Fixed_3_Bits_10000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b10000000>>))
    assert mod.uniform(max) === 3

    mod = Fixed_3_Bits_11000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11000000>>))
    assert mod.uniform(max) === 1

    mod = Fixed_3_Bits_11101000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11110100>>))
    assert mod.uniform(max) === 2

    mod = Fixed_3_Bits_11111111_11101000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11111111, 0b11110100>>))
    assert mod.uniform(max) === 2

    mod = Fixed_3_Bits_11110100_10111101
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11110100, 0b10111101>>))
    assert mod.uniform(max, false) === 2
    assert mod.uniform(max, false) === 1
    assert mod.uniform(max, false) === 3
    assert mod.uniform(max, false) === 2
  end

  test "max 4" do
    max = 4
    mod = Fixed_4_Bits_00000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b00000000>>))
    assert mod.uniform(max) === 1

    mod = Fixed_4_Bits_01000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b01000000>>))
    assert mod.uniform(max) === 2

    mod = Fixed_4_Bits_10000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b10000000>>))
    assert mod.uniform(max) === 3

    mod = Fixed_4_Bits_11000100
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11000100>>))
    assert mod.uniform(max, false) === 4
    assert mod.uniform(max, false) === 1
    assert mod.uniform(max, false) === 2
  end

  test "max 5" do
    max = 5
    mod = Fixed_5_Bits_00100000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b00100000>>))
    assert mod.uniform(max) === 2

    mod = Fixed_5_Bits_01100000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b01100000>>))
    assert mod.uniform(max) === 4

    mod = Fixed_5_Bits_10000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b10000000>>))
    assert mod.uniform(max) === 5

    mod = Fixed_5_Bits_10100100
    defmodule(mod, do: use(FixedBytes, bytes: <<0b10100100>>))
    assert mod.uniform(max) === 2

    mod = Fixed_5_Bits_11010000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11001000>>))
    assert mod.uniform(max) === 2

    mod = Fixed_5_Bits_11101000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11101000>>))
    assert mod.uniform(max) === 1

    mod = Fixed_5_Bits_11111000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11111000>>))
    assert mod.uniform(max) === 5

    mod = Fixed_5_Bits_11111010_10000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11111010, 0b10000000>>))
    assert mod.uniform(max) === 3

    mod = Fixed_5_Bits_11101110_11000100
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11101110, 0b11000100>>))
    assert mod.uniform(max, false) === 4
    assert mod.uniform(max) === 1
  end

  test "max 6" do
    max = 6
    mod = Fixed_6_Bits_11101000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11101000>>))
    assert mod.uniform(max) === 6

    mod = Fixed_6_Bits_11111101_10010000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11111101, 0b10010000>>))
    assert mod.uniform(max, false) === 4
    assert mod.uniform(max, false) === 2
  end

  test "max 7" do
    max = 7
    mod = Fixed_7_Bits_11101000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11101000>>))
    assert mod.uniform(max) === 3

    mod = Fixed_7_Bits_11111101_10000000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11111101, 0b11000000>>))
    assert mod.uniform(max, false) === 4
    assert mod.uniform(max) === 5
  end

  test "max 10" do
    max = 10
    mod = Fixed_10_Bits_11001000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11001000>>))
    assert mod.uniform(max) === 3

    mod = Fixed_10_Bits_11100100
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11100100>>))
    assert mod.uniform(max) === 3

    mod = Fixed_10_Bits_11101000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11101000>>))
    assert mod.uniform(max) === 5

    mod = Fixed_10_Bits_11111100_11001000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11111100, 0b11001000>>))
    assert mod.uniform(max, false) === 4
    assert mod.uniform(max, false) === 3
  end

  test "max 11" do
    max = 11
    mod = Fixed_11_Bits_11001000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11001000>>))
    assert mod.uniform(max) === 9

    mod = Fixed_11_Bits_11100100_00100000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11100100, 0b00100000>>))
    assert mod.uniform(max, false) === 3
    assert mod.uniform(max, false) === 2
  end

  test "max 13" do
    max = 13
    mod = Fixed_13_Bits_11111100_11101000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11111100, 0b11101000>>))
    assert mod.uniform(max, false) === 4
    assert mod.uniform(max) === 11
  end

  test "max fixed: misc no-skip" do
    assert Fixed_A.uniform(17) === 4
    assert Fixed_A.uniform(31) === 4
    assert Fixed_A.uniform(32) === 4
    assert Fixed_A.uniform(33) === 7
    assert Fixed_A.uniform(63) === 7
    assert Fixed_A.uniform(64) === 7
    assert Fixed_A.uniform(65) === 14
    assert Fixed_A.uniform(127) === 14
    assert Fixed_A.uniform(128) === 14
    assert Fixed_A.uniform(129) === 28
    assert Fixed_A.uniform(255) === 28
    assert Fixed_A.uniform(256) === 28
    assert Fixed_A.uniform(257) === 55
    assert Fixed_A.uniform(511) === 55
    assert Fixed_A.uniform(512) === 55
    assert Fixed_A.uniform(513) === 109
    assert Fixed_A.uniform(1023) === 109
    assert Fixed_A.uniform(1024) === 109
    assert Fixed_A.uniform(1025) === 218
    assert Fixed_A.uniform(2049) === 436
  end

  test "max fixed: misc with-skip" do
    assert Fixed_B.uniform(17) === 17
    assert Fixed_B.uniform(31) === 31
    assert Fixed_B.uniform(33) === 27
    assert Fixed_B.uniform(63) === 60
    assert Fixed_B.uniform(65) === 25
    assert Fixed_B.uniform(255) === 182
    assert Fixed_B.uniform(257) === 97
    assert Fixed_B.uniform(511) === 214
    assert Fixed_B.uniform(513) === 427
  end

  test "4-bit shifting" do
    mod = Fixed_4_Bit_Shift_11110000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11110000>>))
    assert mod.uniform(9) === 9
    assert mod.uniform(10) === 9
    assert mod.uniform(11) === 9
    assert mod.uniform(12) === 9
    assert mod.uniform(13) === 9
    assert mod.uniform(14) === 9
    assert mod.uniform(15) === 1

    mod = Fixed_4_Bit_Shift_11010000
    defmodule(mod, do: use(FixedBytes, bytes: <<0b11010000>>))
    assert mod.uniform(9) === 5
    assert mod.uniform(12) === 1
  end

  test "n 1..5, max 3 : fixed A" do
    assert Fixed_A.uniform_list(3, 1) === [1]
    assert Fixed_A.uniform_list(3, 2) === [2, 1]
    assert Fixed_A.uniform_list(3, 3) === [3, 2, 1]
    assert Fixed_A.uniform_list(3, 4) === [1, 3, 2, 1]
    assert Fixed_A.uniform_list(3, 5) === [2, 1, 3, 2, 1]
  end

  test "n 1..5, max 3 : fixed B" do
    assert Fixed_B.uniform_list(3, 1) === [3]
    assert Fixed_B.uniform_list(3, 2) === [2, 3]
    assert Fixed_B.uniform_list(3, 3) === [2, 2, 3]
    assert Fixed_B.uniform_list(3, 4) === [2, 2, 2, 3]
    assert Fixed_B.uniform_list(3, 5) === [1, 2, 2, 2, 3]
  end

  test "n 1..5, max 4 : fixed A" do
    assert Fixed_A.uniform_list(4, 1) === [1]
    assert Fixed_A.uniform_list(4, 2) === [2, 1]
    assert Fixed_A.uniform_list(4, 3) === [3, 2, 1]
    assert Fixed_A.uniform_list(4, 4) === [4, 3, 2, 1]
    assert Fixed_A.uniform_list(4, 5) === [1, 4, 3, 2, 1]
  end

  test "n 1..5, max 4 : fixed B" do
    assert Fixed_B.uniform_list(4, 1) === [4]
    assert Fixed_B.uniform_list(4, 2) === [4, 4]
    assert Fixed_B.uniform_list(4, 3) === [4, 4, 4]
    assert Fixed_B.uniform_list(4, 4) === [4, 4, 4, 4]
    assert Fixed_B.uniform_list(4, 5) === [3, 4, 4, 4, 4]
  end

  test "n 1..7, max 5, : fixed A" do
    # Fixed A
    # 0001 1011 0011 0111 0111 1001 0010 1110 1101 0101
    #
    # 000 11 011 001 101 11 011 11 001 001 011
    # |-| xx |-| |-| xxx xx |-| xx |-| |-| |-|
    #  0      3   1          3      1   1   3
    assert Fixed_A.uniform_list(5, 1) === [1]
    assert Fixed_A.uniform_list(5, 2) === [4, 1]
    assert Fixed_A.uniform_list(5, 3) === [2, 4, 1]
    assert Fixed_A.uniform_list(5, 4) === [4, 2, 4, 1]
    assert Fixed_A.uniform_list(5, 5) === [2, 4, 2, 4, 1]
    assert Fixed_A.uniform_list(5, 6) === [2, 2, 4, 2, 4, 1]
    assert Fixed_A.uniform_list(5, 7) === [4, 2, 2, 4, 2, 4, 1]
  end

  test "n 1, max 16" do
    assert Fixed_A.uniform(16, 1) === 2
  end

  test "n 1..5, max 17" do
    # Fixed A
    # 0001 1011 0011 0111 0111 1001 0010 1110 1101 0101
    #
    # 00011 01100 110 111 01111 00100 10 111 01101 0101<
    # |---| |---| xxx xxx |---| |---| xx xxx |---|
    #   3     12            16     4           13

    assert Fixed_A.uniform_list(17, 1) === [4]
    assert Fixed_A.uniform_list(17, 2) === [13, 4]
    assert Fixed_A.uniform_list(17, 3) === [16, 13, 4]
    assert Fixed_A.uniform_list(17, 4) === [5, 16, 13, 4]
    assert Fixed_A.uniform_list(17, 5) === [14, 5, 16, 13, 4]
  end

  #
  # random
  #
  test "random empty" do
    assert_raise Enum.EmptyError, fn ->
      random([])
    end

    assert_raise Enum.EmptyError, fn ->
      random("")
    end
  end

  test "random 1 element" do
    assert random([:a]) === :a
    assert random(?a..?a) === ?a
    assert random("a") === "a"
  end

  test "random vowel list" do
    vowels = [?a, ?e, ?i, ?o, ?u]

    1..100
    |> Enum.each(fn _ ->
      vowels |> Enum.member?(random(vowels)) |> assert
    end)
  end

  test "random vowel string" do
    vowels = "aeiou"

    1..100
    |> Enum.each(fn _ ->
      vowels |> String.contains?(random(vowels)) |> assert
    end)
  end

  #
  # shuffle
  #
  test "shuffle edge cases" do
    assert shuffle([]) === []
    assert shuffle("") === ""

    assert shuffle([:a]) === [:a]
    assert shuffle(?a..?a) === [?a]
    assert shuffle("a") === "a"
  end

  test "shuffle length" do
    assert length(shuffle([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])) === 10
    assert length(shuffle(?a..?z)) === 26
    Enum.each([1, 5, 21], &assert(length(shuffle(1..&1)) === &1))
    assert byte_size(shuffle("abcdef")) === 6
  end

  #
  # take_random
  #
  test "take_random edge cases" do
    assert take_random([0, 1, 2], 0) === []
    assert take_random(?a..?z, 0) === []
    assert take_random("aeiou", 0) === ""

    assert take_random([:a], 1) === [:a]
    assert take_random(?a..?a, 1) === [?a]
    assert take_random("a", 1) === "a"
  end

  test "take_random length" do
    assert length(take_random([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 6)) === 6
    assert length(take_random(?a..?z, 10)) === 10
    Enum.each([8, 13, 21], &assert(length(take_random(1..&1, 8)) === 8))
    assert byte_size(take_random("aeiou", 3)) === 3
  end

  #
  # uniform_list
  #
  test "uniform_list edge cases" do
    assert uniform_list(10, 0) === []
    assert uniform_list(1, 1) === [1]
    assert uniform_list(1, 5) === [1, 1, 1, 1, 1]
    assert is_list(uniform_list(10, 1))
  end
end
