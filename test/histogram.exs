defmodule CryptoRand.Test.Histogram do
  use ExUnit.Case, async: true

  import CryptoRand.Test.Util

  #
  # random
  #
  def random_enum_chi_square_test(enumerable),
    do:
      histogram_chi_square_test(Enum.count(enumerable), 10_000, fn ->
        enumerable |> CryptoRand.random() |> Integer.to_string()
      end)

  def random_str_chi_square_test(string),
    do:
      histogram_chi_square_test(String.length(string), 10_000, fn ->
        string |> CryptoRand.random()
      end)

  @tag :random
  test "histogram random enumerable" do
    random_enum_chi_square_test(0..9)
    random_enum_chi_square_test([?a, ?e, ?i, ?o, ?u])
    random_enum_chi_square_test(1..100)
  end

  @tag :random
  test "histogram random string" do
    random_str_chi_square_test("abcde")

    ?A..?Z
    |> Enum.to_list()
    |> to_string()
    |> random_str_chi_square_test()
  end

  def shuffle_enum_chi_square_test(enumerable, ndx),
    do:
      histogram_chi_square_test(Enum.count(enumerable), 10_000, fn ->
        enumerable |> CryptoRand.shuffle() |> Enum.at(ndx)
      end)

  def shuffle_str_chi_square_test(string, ndx),
    do:
      histogram_chi_square_test(String.length(string), 10_000, fn ->
        string |> CryptoRand.shuffle() |> String.at(ndx)
      end)

  @tag :shuffle
  test "histogram shuffle 0..9: ndx 0, 5, 9",
    do:
      [0, 5, 9]
      |> Enum.each(&(0..9 |> shuffle_enum_chi_square_test(&1)))

  @tag :shuffle
  test "histogram shuffle vowels list: ndx 0, 2, 4",
    do:
      [0, 2, 4]
      |> Enum.each(&([?a, ?e, ?i, ?o, ?u] |> shuffle_enum_chi_square_test(&1)))

  @tag :shuffle
  test "histogram shuffle 1..20: ndx 0, 10, 19",
    do:
      [0, 10, 19]
      |> Enum.each(&(1..20 |> shuffle_enum_chi_square_test(&1)))

  @tag :shuffle
  test "histogram shuffle vowels string, ndx 0, 2, 4",
    do:
      [0, 2, 4]
      |> Enum.each(&("aeiou" |> shuffle_str_chi_square_test(&1)))

  @tag :shuffle
  test "histogram shuffle lower alpha string, ndx 10, 20",
    do:
      [10, 20]
      |> Enum.each(&(?a..?z |> Enum.to_list() |> to_string() |> shuffle_str_chi_square_test(&1)))

  #
  # take_random
  #
  def take_random_enum_histogram(source, len, members, trials) do
    1..trials
    |> Enum.reduce(members |> Enum.reduce(%{}, &Map.put(&2, &1, 0)), fn _, acc ->
      sample = CryptoRand.take_random(source, len)

      members
      |> Enum.reduce(acc, fn member, acc_2 ->
        if Enum.member?(sample, member),
          do: Map.put(acc_2, member, acc_2[member] + 1),
          else: acc_2
      end)
    end)
  end

  def take_random_str_histogram(source, len, members, trials) do
    m_chars = members |> String.graphemes()

    1..trials
    |> Enum.reduce(m_chars |> Enum.reduce(%{}, &Map.put(&2, &1, 0)), fn _, acc ->
      sample = CryptoRand.take_random(source, len)

      m_chars
      |> Enum.reduce(acc, fn member, acc_2 ->
        if String.contains?(sample, member),
          do: Map.put(acc_2, member, acc_2[member] + 1),
          else: acc_2
      end)
    end)
  end

  def take_random_chi_square_test(source, members, trials) do
    count = size(source)
    len = size(members)

    histogram_fn =
      if is_binary(source), do: &take_random_str_histogram/4, else: &take_random_enum_histogram/4

    histogram = histogram_fn.(source, len, members, trials)
    expect = trials * len / count
    chi_square_test(histogram, chi_square(histogram, expect), len)
  end

  @tag :take_random
  test "histogram take_random enum" do
    take_random_chi_square_test(?a..?z, [?a, ?e, ?i, ?o, ?u], 100_000)
    take_random_chi_square_test(1..100, Enum.to_list(20..29), 100_000)
  end

  @tag :take_random
  test "histogram take_random str" do
    take_random_chi_square_test(?a..?z |> Enum.to_list() |> to_string(), "aeiou", 100_000)
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

  @tag :uniform
  test "histogram uniform 7..33",
    do:
      7..33
      |> Enum.each(&uniform_chi_square_test(&1))

  @tag :uniform
  test "histogram uniform 65, 69, 77, 93",
    do:
      [65, 69, 77, 93]
      |> Enum.each(&uniform_chi_square_test(&1))

  @tag :uniform
  test "histogram uniform 125, 129, 137",
    do:
      [125, 129, 137]
      |> Enum.each(&uniform_chi_square_test(&1))

  @tag :uniform
  test "histogram uniform 185, 249",
    do:
      [185, 249]
      |> Enum.each(&uniform_chi_square_test(&1))
end
