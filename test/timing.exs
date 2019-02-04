defmodule CryptoRand.Test.Timing do
  use ExUnit.Case

  def opts,
    do: %{
      uniform_trials: 1_000_000,
      uniform_list_trials: 100_000,
      shuffle_trials: 100_000
    }

  def time(function, label) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
    |> IO.inspect(label: label)
  end

  #
  # random
  #
  def random_enumerable(enumerable, trials, random_fn) do
    fn -> Enum.each(1..trials, fn _ -> random_fn.(enumerable) end) end
  end

  def random_list(list, trials, random_fn) do
    fn -> Enum.each(1..trials, fn _ -> random_fn.(list) end) end
  end

  def random_enumerable_test(len, trials) do
    IO.puts("\n#{trials} random elements from enumerable 1..#{len}")
    enumerable = 1..len
    :rand.seed(:exsp)
    time(random_enumerable(enumerable, trials, &Enum.random/1), "  rand.uniform   (PRNG) ")
    :crypto.rand_seed()
    time(random_enumerable(enumerable, trials, &Enum.random/1), "  rand.uniform (CSPRNG) ")

    time(
      random_enumerable(enumerable, trials, &CryptoRand.random/1),
      "  CryptoRand            "
    )
  end

  def random_list_test(len, trials) do
    IO.puts("\n#{trials} random elements from list len #{len}")
    list = List.duplicate(?z, len)
    :rand.seed(:exsp)
    time(random_list(list, trials, &Enum.random/1), "  rand.uniform   (PRNG) ")
    :crypto.rand_seed()
    time(random_list(list, trials, &Enum.random/1), "  rand.uniform (CSPRNG) ")
    time(random_list(list, trials, &CryptoRand.random/1), "  CryptoRand            ")
  end

  def random_tests(len, trials) do
    random_enumerable_test(len, trials)
    random_list_test(len, trials)
  end

  @tag :random
  test "random list/enumerable 10" do
    random_tests(12, 250_000)
  end

  @tag :random
  @tag timeout: 60_000
  test "random list/enumerable 52" do
    random_tests(52, 100_000)
  end

  @tag :random
  @tag timeout: 60_000
  test "random list/enumerable 256" do
    random_tests(256, 30_000)
  end

  #
  # shuffle
  #
  def shuffle_enumerable(enumerable, trials, shuffle_fn) do
    fn -> Enum.each(1..trials, fn _ -> shuffle_fn.(enumerable) end) end
  end

  def shuffle_list(list, trials, shuffle_fn) do
    fn -> Enum.each(1..trials, fn _ -> shuffle_fn.(list) end) end
  end

  def shuffle_enumerable_test(len, trials) do
    IO.puts("\n#{trials} shuffles of enumerable 1..#{len}")
    enumerable = 1..len
    :rand.seed(:exsp)
    time(shuffle_enumerable(enumerable, trials, &Enum.shuffle/1), "  rand.uniform   (PRNG) ")
    :crypto.rand_seed()
    time(shuffle_enumerable(enumerable, trials, &Enum.shuffle/1), "  rand.uniform (CSPRNG) ")

    time(
      shuffle_enumerable(enumerable, trials, &CryptoRand.shuffle/1),
      "  CryptoRand            "
    )
  end

  def shuffle_list_test(len, trials) do
    IO.puts("\n#{trials} shuffles of list len #{len}")
    list = List.duplicate(?z, len)
    :rand.seed(:exsp)
    time(shuffle_list(list, trials, &Enum.shuffle/1), "  rand.uniform   (PRNG) ")
    :crypto.rand_seed()
    time(shuffle_list(list, trials, &Enum.shuffle/1), "  rand.uniform (CSPRNG) ")
    time(shuffle_list(list, trials, &CryptoRand.shuffle/1), "  CryptoRand            ")
  end

  def shuffle_tests(len, trials) do
    shuffle_enumerable_test(len, trials)
    shuffle_list_test(len, trials)
  end

  @tag :shuffle
  test "shuffle list/enumerable 12" do
    shuffle_tests(12, 250_000)
  end

  @tag :shuffle
  @tag timeout: 180_000
  test "shuffle list/enumerable 26" do
    shuffle_tests(26, 100_000)
  end

  @tag :shuffle
  @tag timeout: 240_000
  test "shuffle list/enumerable 256" do
    shuffle_tests(256, 15_000)
  end

  #
  # take_random
  #
  def take_random(len, count, trials, take_random_fn) do
    fn -> Enum.each(1..trials, fn _ -> take_random_fn.(1..len, count) end) end
  end

  def take_random_enumerable_test(len, count, trials) do
    IO.puts("\n#{trials} take_random #{count} elements from enumerable 1..#{len}")
    :rand.seed(:exsp)
    time(take_random(len, count, trials, &Enum.take_random/2), "  rand.uniform   (PRNG) ")
    :crypto.rand_seed()
    time(take_random(len, count, trials, &Enum.take_random/2), "  rand.uniform (CSPRNG) ")

    time(
      take_random(len, count, trials, &CryptoRand.take_random/2),
      "  CryptoRand            "
    )
  end

  def take_random_list(list, count, trials, take_random_fn) do
    fn ->
      Enum.each(1..trials, fn _ -> take_random_fn.(list, count) end)
    end
  end

  def take_random_list_test(len, count, trials) do
    IO.puts("\n#{trials} trials of take_random #{count} elements from list len #{len}")
    list = List.duplicate(?a, len)

    :rand.seed(:exsp)
    time(take_random_list(list, count, trials, &Enum.take_random/2), "  rand.uniform   (PRNG) ")
    :crypto.rand_seed()
    time(take_random_list(list, count, trials, &Enum.take_random/2), "  rand.uniform (CSPRNG) ")

    time(
      take_random_list(list, count, trials, &CryptoRand.take_random/2),
      "  CryptoRand            "
    )
  end

  def take_random_tests(len, count, trials) do
    take_random_enumerable_test(len, count, trials)
    take_random_list_test(len, count, trials)
  end

  @tag :take_random
  test "take_random list/enumerable 5,26" do
    take_random_tests(26, 5, 100_000)
  end

  @tag :take_random
  test "take_random list/enumerable 10,10" do
    take_random_tests(10, 10, 100_000)
  end

  @tag :take_random
  @tag timeout: 120_000
  test "take_random list/enumerable 10,100" do
    take_random_tests(100, 10, 30_000)
  end

  @tag :take_random
  @tag timeout: 180_000
  test "take_random list/enumerable 50,100" do
    take_random_tests(100, 25, 30_000)
  end

  #
  # uniform integer
  #
  def uniform(max, uniform_fn) do
    fn -> Enum.each(1..opts().uniform_trials, fn _ -> uniform_fn.(max) end) end
  end

  def uniform_test(max) do
    IO.puts("\n#{opts().uniform_trials} uniform ints in range 1..#{max}")

    :rand.seed(:exsp)
    time(uniform(max, &:rand.uniform/1), "  rand.uniform   (PRNG) ")
    :crypto.rand_seed()
    time(uniform(max, &:rand.uniform/1), "  rand.uniform (CSPRNG) ")
    time(uniform(max, &CryptoRand.uniform/1), "  CryptoRand            ")
  end

  @tag :uniform
  test "uniform N" do
    Enum.each([8, 25, 64, 100, 4096, 5000], &uniform_test(&1))
  end

  #
  # uniform integer list
  #
  def uniform_list(max, size, uniform_list_fn) do
    fn -> Enum.each(1..opts().uniform_list_trials, fn _ -> uniform_list_fn.(max, size) end) end
  end

  def uniform_list(size, uniform_list_fn) do
    fn -> Enum.each(1..opts().uniform_list_trials, fn _ -> uniform_list_fn.(size) end) end
  end

  def uniform_list_test({max, size}) do
    uniform_list = &for(_ <- 1..&2, do: :rand.uniform(&1))

    IO.puts(
      "\n#{opts().uniform_list_trials} lists of size #{size} with uniform ints from 1..#{max}"
    )

    :rand.seed(:exsp)
    time(uniform_list(max, size, uniform_list), "  rand.uniform   (PRNG) ")
    :crypto.rand_seed()
    time(uniform_list(max, size, uniform_list), "  rand.uniform (CSPRNG) ")
    time(uniform_list(max, size, &CryptoRand.uniform_list/2), "  CryptoRand            ")
  end

  @tag :uniform_list
  test "uniform list max, size" do
    Enum.each([{16, 8}, {21, 20}, {40, 10}], &uniform_list_test(&1))
  end
end
