defmodule CryptoRand.Test.Histogram do
  use ExUnit.Case, async: true

  import CryptoRand.Test.Util

  #
  # random
  #
  def random_chi_square_test(enumerable) do
    len = Enum.count(enumerable)
    sample_fn = fn -> CryptoRand.random(enumerable) |> Integer.to_string() end
    expect = 10_000
    histogram = sample_histogram(len * expect, sample_fn)
    chi_square_test(histogram, chi_square(histogram, expect), len)
  end

  @tag :random
  test "histogram random" do
    random_chi_square_test(0..9)
    random_chi_square_test([?a, ?e, ?i, ?o, ?u])
    random_chi_square_test(1..100)
  end

  #
  # shuffle
  #
  def shuffle_chi_square_test(enumerable, ndx) do
    len = Enum.count(enumerable)
    sample_fn = fn -> enumerable |> CryptoRand.shuffle() |> Enum.at(ndx) end
    expect = 5_000
    histogram = sample_histogram(len * expect, sample_fn)
    chi_square_test(histogram, chi_square(histogram, expect), len)
  end

  @tag :shuffle
  test "histogram shuffle 0..9: ndx 0, 5, 9" do
    enumerable = 0..9
    shuffle_chi_square_test(enumerable, 0)
    shuffle_chi_square_test(enumerable, 5)
    shuffle_chi_square_test(enumerable, 9)
  end

  @tag :shuffle
  test "histogram shuffle vowels list: ndx 0, 2, 4" do
    list = [?a, ?e, ?i, ?o, ?u]
    shuffle_chi_square_test(list, 0)
    shuffle_chi_square_test(list, 2)
    shuffle_chi_square_test(list, 4)
  end

  @tag :shuffle
  test "histogram shuffle 30: ndx 0" do
    shuffle_chi_square_test(1..30, 0)
  end

  @tag :shuffle
  test "histogram shuffle 30: ndx 15" do
    shuffle_chi_square_test(1..30, 15)
  end

  @tag :shuffle
  test "histogram shuffle 30: ndx 29" do
    shuffle_chi_square_test(1..30, 29)
  end

  #
  # take_random
  #
  def take_random_histogram(enumerable, members, trials) do
    len = Enum.count(members)

    1..trials
    |> Enum.reduce(members |> Enum.reduce(%{}, &Map.put(&2, &1, 0)), fn _, acc ->
      sample = CryptoRand.take_random(enumerable, len)

      members
      |> Enum.reduce(acc, fn member, acc_2 ->
        if Enum.member?(sample, member),
          do: Map.put(acc_2, member, acc_2[member] + 1),
          else: acc_2
      end)
    end)
  end

  def take_random_chi_square_test(enumerable, members, trials) do
    histogram = take_random_histogram(enumerable, members, trials)
    len = Enum.count(members)
    expect = trials * len / Enum.count(enumerable)
    chi_square_test(histogram, chi_square(histogram, expect), len)
  end

  @tag :take_random
  test "histogram take_random" do
    take_random_chi_square_test(?a..?z, [?a, ?e, ?i, ?o, ?u, ?y], 100_000)
    take_random_chi_square_test(1..100, Enum.to_list(20..29), 100_000)
  end

  #
  # uniform
  #
  def uniform_chi_square_test(max) do
    expect = 10_000
    sample_fn = fn -> max |> CryptoRand.uniform() |> Integer.to_string() end
    histogram = sample_histogram(max * expect, sample_fn)
    chi_square_test(histogram, chi_square(histogram, expect), max)
  end

  test "histogram" do
    uniform_chi_square_test(8)
    uniform_chi_square_test(20)
  end

  @tag :uniform
  test "histogram uniform 3..31" do
    Enum.each(3..31, &uniform_chi_square_test(&1))
  end

  @tag :uniform
  test "histogram uniform 65" do
    uniform_chi_square_test(65)
  end

  @tag :uniform
  test "histogram uniform 69" do
    uniform_chi_square_test(69)
  end

  @tag :uniform
  test "histogram uniform 77" do
    uniform_chi_square_test(77)
  end

  @tag :uniform
  test "histogram uniform 93" do
    uniform_chi_square_test(93)
  end

  @tag :uniform
  test "histogram uniform 125" do
    uniform_chi_square_test(125)
  end

  @tag :uniform
  test "histogram uniform 129" do
    uniform_chi_square_test(129)
  end

  @tag :uniform
  test "histogram uniform 137" do
    uniform_chi_square_test(137)
  end

  @tag :uniform
  test "histogram uniform 153" do
    uniform_chi_square_test(153)
  end

  @tag :uniform
  test "histogram uniform 185" do
    uniform_chi_square_test(185)
  end

  @tag :uniform
  test "histogram uniform 249" do
    uniform_chi_square_test(249)
  end
end
