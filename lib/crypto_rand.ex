# MIT License
#
# Copyright (c) 2019 Knoxen
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
# OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

defmodule CryptoRand do
  @moduledoc """

  `CryptoRand` provides efficient, crytographically strong versions of several `Enum` functions that
  rely on [`:rand`](http://www.erlang.org/doc/man/rand.html) __uniform__ for underlying
  randomness. `CryptoRand` functions also operate on `String.t()` where appropriate.

  """

  use Bitwise, skip_operators: true

  @doc """
  Clear `CryptoRand` process dictionary entries.
  """
  @spec clear() :: :ok
  def clear(),
    do:
      Enum.each(
        [:crypto_rand_max, :crypto_rand_bytes],
        &Process.delete(&1)
      )


  @doc """
  Returns a random element of `source`.

  Randomness is generated using `rand_bytes/1`.

  Raises `Enum.EmptyError` if `source`is empty.

  This function uses bytes from the function `rand_bytes` to generate a random integer in the range
  [0, n-1], where n is the number of elements in the `source` _enumerable_ or graphemes in the
  `source` _string_. The element at the random integer index is returned.

  ## Example
      iex> CryptoRand.random(1..10)
      7

      iex> CryptoRand.random("aeiou")
      "i"

  """
  @spec random(Enumerable.t() | String.t(), (non_neg_integer -> binary)) :: any
  def random(source, rand_bytes \\ &:crypto.strong_rand_bytes/1)

  def random([], _rand_bytes), do: raise(Enum.EmptyError)
  def random("", _rand_bytes), do: raise(Enum.EmptyError)

  def random([elem], _rand_bytes), do: elem
  def random(<<elem::binary-size(1)>>, _rand_bytes), do: elem

  def random(list, rand_bytes) when is_list(list),
    do: list |> Enum.at(uniform(length(list), rand_bytes) - 1)

  def random(string, rand_bytes) when is_binary(string) do
    pos = uniform(byte_size(string), rand_bytes) - 1
    <<_::binary-size(pos), value::binary-size(1), _::binary>> = string
    value
  end

  def random(enumerable, rand_bytes) do
    case Enum.count(enumerable) do
      0 ->
        raise(Enum.EmptyError)

      1 ->
        Enum.at(enumerable, 0)

      count ->
        Enum.at(enumerable, uniform(count, rand_bytes) - 1)
    end
  end

  @doc """
  Shuffles the elements of `source`.

  Randomness is generated using `rand_bytes/1`.

  Returns a `list` with the elements of an _enumerable_ `source` shuffled or a `String.t()` with the
  graphemes of a _string_ `source` shuffled.

  ## Example

      iex> CryptoRand.shuffle([1,2,3,4,5])
      [5, 2, 3, 4, 1]

      iex> CryptoRand.shuffle(?a..?z)
      'chivgpxldtrokyuqsnjmawzfeb'

      iex> CryptoRand.shuffle("dingosky")
      "ndsyigok"
  """

  @spec shuffle(Enumerable.t() | String.t(), (non_neg_integer -> binary)) :: list | String.t()

  def shuffle(source, rand_bytes \\ &:crypto.strong_rand_bytes/1)

  def shuffle([], _), do: []
  def shuffle("", _), do: ""

  def shuffle([_] = list, _), do: list
  def shuffle(<<_::binary-size(1)>> = string, _), do: string

  def shuffle(list, rand_bytes) when is_list(list) do
    len = length(list)
    shuffle_list(list, len, rand_bytes)
  end

  def shuffle(string, rand_bytes) when is_binary(string),
    do: string |> String.graphemes() |> shuffle(rand_bytes) |> List.to_string()

  def shuffle(enumerable, rand_bytes) do
    {list, len} = list_len(enumerable)
    shuffle_list(list, len, rand_bytes)
  end

  #
  # Private
  #
  defp shuffle_list(list, len, rand_bytes) do
    [uniform_list(len, len, rand_bytes, [], false), list]
    |> List.zip()
    |> Enum.reduce([], fn {ndx, value}, acc -> List.insert_at(acc, ndx, value) end)
  end

  @doc """
  Takes `count` random items from an _enumerable_ `source` or graphemes from a _string_ `source`.

  Returns a `list` for a `source` _enumerable_ and a `String.t()` for a `source` _string_.

  ## Examples

      iex> CryptoRand.take_random(?a..?z, 5)
      'kwvhn'

      iex> CryptoRand.take_random([?a,?e,?i,?o,?u], 3)
      'eao'

      iex> CryptoRand.take_random("dingosky", 3)
      "dgi"

  """
  @spec take_random(
          Enumerable.t() | String.t(),
          non_neg_integer,
          (non_neg_integer -> binary)
        ) :: list | String.t()
  def take_random(source, count, rand_bytes \\ &:crypto.strong_rand_bytes/1)

  def take_random(string, 0, _) when is_binary(string), do: ""

  def take_random(_, 0, _), do: []

  def take_random(string, 1, rand_bytes) when is_binary(string), do: random(string, rand_bytes)

  def take_random(source, 1, rand_bytes), do: [random(source, rand_bytes)]

  def take_random(list, count, rand_bytes)
      when is_list(list) and is_integer(count) and 1 < count,
      do: take_random(list, length(list), count, rand_bytes)

  def take_random(string, count, rand_bytes)
      when is_binary(string) and is_integer(count) and 1 < count,
      do:
        string
        |> String.graphemes()
        |> take_random(byte_size(string), count, rand_bytes)
        |> List.to_string()

  def take_random(enumerable, count, rand_bytes) when is_integer(count) and 1 < count do
    {list, len} = list_len(enumerable)
    take_random(list, len, count, rand_bytes)
  end

  #
  # Private
  #
  defp take_random(list, len, count, rand_bytes) do
    {take, _leave} =
      uniform_list(len, count, rand_bytes, [], false)
      |> Enum.reverse()
      |> Enum.map_reduce(list, &{Enum.at(&2, &1), List.delete_at(&2, &1)})

    take
  end

  @doc """
  Generate random uniform integer in the range 1 to `max`.

  Randomness is generated using `rand_bytes/1`.

  ## Example

      iex> CryptoRand.uniform(16)
      13

  """
  @spec uniform(
          pos_integer,
          (non_neg_integer -> binary)
        ) :: non_neg_integer
  def uniform(max, rand_bytes \\ &:crypto.strong_rand_bytes/1)

  def uniform(1, rand_bytes) when is_function(rand_bytes), do: 1

  def uniform(max, rand_bytes)
      when is_integer(max) and 0 < max and is_function(rand_bytes) do
    [int | _] = uniform_list(max, 1, rand_bytes, [], true)
    int
  end

  @doc """
  Generate `n` random uniform integers in the range 1 to `max`.

  Randomness is generated using `rand_bytes/1`.

  ## Example

      iex> CryptoRand.uniform_list(16, 8)
      [6, 9, 16, 4, 12, 4, 4, 10]

  """
  @spec uniform_list(
          pos_integer,
          non_neg_integer,
          (non_neg_integer -> binary)
        ) :: list
  def uniform_list(max, n, rand_bytes \\ &:crypto.strong_rand_bytes/1)

  def uniform_list(_, 0, _), do: []

  def uniform_list(1, 1, _), do: [1]

  def uniform_list(1, n, _) when is_integer(n) and 1 < n, do: List.duplicate(1, n)

  def uniform_list(max, 1, rand_bytes)
      when is_integer(max) and 0 < max and is_function(rand_bytes),
      do: [uniform(max, rand_bytes)]

  def uniform_list(max, n, rand_bytes)
      when is_integer(max) and 0 < max and is_integer(n) and 0 < n and is_function(rand_bytes),
      do: uniform_list(max, n, rand_bytes, [], true)

  #
  # Private
  #
  defp uniform_list(_, 0, _, list, _), do: list

  # CxNote `true` indicates each element of the returned list will be in the range 1..max
  defp uniform_list(max, size, rand_bytes, list, true) do
    {bits, high_value_bits} = max_params(max)
    {crypto_rand_offset, crypto_rand_bytes} = get_bytes(size, bits, rand_bytes)
    value = slice(bits, crypto_rand_offset, crypto_rand_bytes)

    {max, size, list} =
      cond do
        value < max ->
          # IO.puts("  accept #{value}, shift #{bits} bits")
          shift(bits, crypto_rand_offset, crypto_rand_bytes)
          {max, size - 1, [value + 1 | list]}

        true ->
          {shift, _} =
            Enum.find(high_value_bits, {bits, 0}, fn {_, hv} ->
              value >= hv
            end)

          # IO.puts("  reject #{value}, shift #{shift} bits")
          shift(shift, crypto_rand_offset, crypto_rand_bytes)
          {max, size, list}
      end

    # IO.puts("  max #{max}, size #{size}")
    uniform_list(max, size, rand_bytes, list, true)
  end

  # CxNote `false` indicates each element of the returned list will be in the range 0..ndx-1, where
  # ndx is the element index in the list.

  defp uniform_list(max, size, rand_bytes, list, false) do
    bits = log_ceil(max)
    {crypto_rand_offset, crypto_rand_bytes} = get_bytes(size, bits, rand_bytes)
    value = slice(bits, crypto_rand_offset, crypto_rand_bytes)

    {max, size, list} =
      cond do
        value < max ->
          {max - 1, size - 1, [value | list]}

        true ->
          {max, size, list}
      end

    shift(bits, crypto_rand_offset, crypto_rand_bytes)

    uniform_list(max, size, rand_bytes, list, false)
  end

  @doc """

  Generate a random binary such that `n` integers in the range 0 to `max`-1 can be parsed by
  processing the binary **k** bits at a time, where **k** is the number of bits required to
  represent `max`-1.

  Randomness is generated using `rand_bytes/1`.

  This function provides bytes such that each **k** bits can be used to index into an `enumerable`
  or `String.t()` of length `max`.

  ## Example

      iex> CryptoRand.uniform_bytes(12, 9) |> IO.inspect() |> binary_digits()
      <<148, 137, 83, 155, 160>>
      "10010100 10001001 01010011 10011011 10100000"
      iex> k = max |> :math.log2() |> :math.ceil() |> round()
      4

  For the bytes returned above, 9 integers can be parsed 4 bits at a time with each integer value
  being less than 12. Note none of the 4-bit clusters starts with **11**, which means each 4-bit
  integer will be less than 12, as desired.

  The function `binary_digits/1` is not shown.

  """
  @spec uniform_bytes(
          pos_integer,
          non_neg_integer,
          (non_neg_integer -> binary)
        ) :: binary
  def uniform_bytes(max, n, rand_bytes \\ &:crypto.strong_rand_bytes/1)

  def uniform_bytes(_max, 0, _rand_bytes), do: <<>>

  def uniform_bytes(max, n, rand_bytes)
      when is_integer(max) and 0 < max and is_integer(n) and 0 < n and is_function(rand_bytes) do
    uniform_bytes(max, n, rand_bytes, max |> :math.log2() |> round() |> pow2() |> Kernel.==(max))
  end

  defp uniform_bytes(max, n, rand_bytes, true),
    do: max |> :math.log2() |> Kernel.*(n / 8) |> :math.ceil() |> round() |> rand_bytes.()

  defp uniform_bytes(max, n, rand_bytes, false) do
    # {bits, _} = max_params(max)
    # # num_bits = (n * bits / 8) |> r_ceil() |> Kernel.*(8)
    uniform_bytes(max, n, rand_bytes, <<>>)
  end

  defp uniform_bytes(_, 0, _, uniform_bits) do
    pad = uniform_bits |> bit_size() |> Kernel.rem(8)
    <<uniform_bits::bits, 0::size(pad)>>
  end

  defp uniform_bytes(max, n, rand_bytes, uniform_bits) do
    {bits, high_value_bits} = max_params(max)
    {crypto_rand_offset, crypto_rand_bytes} = get_bytes(n, bits, rand_bytes)
    value = slice(bits, crypto_rand_offset, crypto_rand_bytes)

    {max, n, uniform_bits} =
      cond do
        value < max ->
          # IO.puts("  accept #{value}, shift #{bits} bits")
          shift(bits, crypto_rand_offset, crypto_rand_bytes)
          {max, n - 1, <<value::size(bits), uniform_bits::bits>>}

        true ->
          {shift, _} =
            Enum.find(high_value_bits, {bits, 0}, fn {_, hv} ->
              value >= hv
            end)

          # IO.puts("  reject #{value}, shift #{shift} bits")
          shift(shift, crypto_rand_offset, crypto_rand_bytes)
          {max, n, uniform_bits}
      end

    uniform_bytes(max, n, rand_bytes, uniform_bits)
  end

  #
  # Private
  #
  defp list_len(enumerable) do
    Enum.reduce(enumerable, {[], 0}, fn
      value, {list, len} -> {[value | list], len + 1}
    end)
  end

  defp max_params(max) do
    case Process.get(:crypto_rand_max) do
      {^max, bits, high_value_bits} ->
        {bits, high_value_bits}

      _ ->
        bits = log_ceil(max)
        pow_max = pow2(bits)

        high_value_bits =
          cond do
            max == pow_max - 1 ->
              []

            true ->
              1..(bits - 2)
              |> Enum.scan({bits, pow_max}, fn b, {_, hv} ->
                {bits - b, hv - pow2(b)}
              end)
              |> Enum.take_while(fn {_, hv} -> max <= hv end)
          end

        Process.put(:crypto_rand_max, {max, bits, high_value_bits})
        {bits, high_value_bits}
    end
  end

  defp pow2(n), do: bsl(1, n)

  defp r_ceil(n), do: n |> :math.ceil() |> round()

  defp log_ceil(n), do: n |> :math.log2() |> r_ceil()

  defp get_bytes(size, bits, rand_bytes) do
    {offset, bytes} = Process.get(:crypto_rand_bytes, {0, <<>>})

    if bit_size(bytes) >= offset + bits do
      {offset, bytes}
    else
      more_bytes = (size * bits / 8.0) |> r_ceil() |> rand_bytes.()
      <<_skip::size(offset), keep::bits>> = bytes
      new_offset = rem(offset, 8)
      new_bytes = <<0::size(new_offset), keep::bits, more_bytes::binary>>
      # IO.puts("new bytes: #{binary_digits(new_bytes)}")

      random_uniform_bytes = {new_offset, new_bytes}
      Process.put(:crypto_rand_bytes, random_uniform_bytes)
      random_uniform_bytes
    end
  end

  defp slice(bits, offset, bytes) do
    # IO.puts("offset #{offset}, bits #{bits}")

    <<_skip::size(offset), bits_value::size(bits), _rest::bits>> = bytes
    bits_value
  end

  defp shift(bits, offset, bytes) do
    new_offset = offset + bits
    Process.put(:crypto_rand_bytes, {new_offset, bytes})
    new_offset
  end
end
