ExUnit.start()

defmodule CryptoRand.Test.FixedBytes do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      @puid_fixed_bytes unquote(opts)[:bytes]

      def rand_bytes(length) do
        # IO.puts(FixedBytes.binary_digits(@puid_fixed_bytes))

        n_bytes = byte_size(@puid_fixed_bytes)

        bytes =
          if length <= n_bytes do
            @puid_fixed_bytes
          else
            pad = 8 * (length - n_bytes)
            <<@puid_fixed_bytes::binary, 0::size(pad)>>
          end

        byte_start =
          case Process.get(:fixed_byte_start) do
            nil -> 0
            fixed_byte_start -> fixed_byte_start
          end

        Process.put(:fixed_byte_start, byte_start + length)
        binary_part(bytes, byte_start, length)
      end

      def uniform(max, auto_reset \\ true)

      def uniform(max, auto_reset) do
        rand = CryptoRand.uniform(max, &rand_bytes/1)
        if auto_reset, do: reset()
        rand
      end

      def uniform_list(max, n, auto_reset \\ true) do
        list = CryptoRand.uniform_list(max, n, &rand_bytes/1)
        if auto_reset, do: reset()
        list
      end

      def reset do
        Process.put(:fixed_byte_start, 0)
        CryptoRand.clear()
      end
    end
  end
end

defmodule CryptoRand.Test.Util do
  @moduledoc false

  use ExUnit.Case

  def uniform_bytes_to_list(bytes, n, bits), do: uniform_bytes_to_list(bytes, n, bits, 0, [])

  defp uniform_bytes_to_list(_, 0, _, _, list), do: list

  defp uniform_bytes_to_list(uniform_bytes, n, bits, offset, list) do
    <<_::size(offset), value::size(bits), _::bits>> = uniform_bytes
    uniform_bytes_to_list(uniform_bytes, n - 1, bits, offset + bits, [value + 1 | list])
  end

  def chi_square(histogram, expect) do
    histogram
    |> Enum.reduce(0, fn {_, value}, acc ->
      diff = value - expect
      acc + diff * diff / expect
    end)
  end

  def chi_square_test(histogram, chi_square, buckets) do
    deg_freedom = buckets - 1
    variance = :math.sqrt(2 * deg_freedom)
    n_sig = 4
    tolerance = n_sig * variance

    passed = chi_square < deg_freedom + tolerance and chi_square > deg_freedom - tolerance

    if !passed, do: IO.inspect(histogram, label: "\nFailed histogram")

    assert passed
  end

  def sample_histogram(trials, sample_fn) do
    1..trials
    |> Enum.reduce(%{}, fn _, map ->
      sample = sample_fn.()
      Map.put(map, sample, (map[sample] || 0) + 1)
    end)
  end

  defp find_indexes(string, chars) when is_binary(string) and is_binary(chars),
    do:
      find_indexes(
        string
        |> String.graphemes(),
        chars
        |> String.graphemes()
      )

  defp find_indexes(str_list, char_list) do
    {_, ndxs} =
      str_list
      |> Enum.reduce({0, []}, fn char, {ndx, ndxs} ->
        next = ndx + 1
        if Enum.member?(char_list, char), do: {next, [ndx] ++ ndxs}, else: {next, ndxs}
      end)

    ndxs
  end

  def positions_histogram_test(list, length, trials, fun) when is_list(list) do
    histogram =
      1..trials
      |> Enum.reduce(%{}, fn _, map ->
        fun.()
        |> find_indexes(list)
        |> Enum.reduce(map, &Map.put(&2, &1, (&2[&1] || 0) + 1))
      end)

    expect = length(list) * trials / length

    chi_square_test(histogram, chi_square(histogram, expect), length)
  end

  def binary_digits(bytes) do
    bytes
    |> :binary.bin_to_list()
    |> Enum.map(
      &("~.2B"
        |> :io_lib.format([&1])
        |> to_string()
        |> String.pad_leading(8, ["0"]))
    )
    |> Enum.join(" ")
  end
end
