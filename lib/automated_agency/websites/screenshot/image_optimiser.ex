defmodule AutomatedAgency.Websites.Screenshot.ImageOptimiser do
  @quality 60
  @file_type ".jpg"
  @desktop_resize %{width: 1280, height: 720}

  def optimise_image(image_binary, format, opts \\ []) when is_binary(image_binary) do
    {:ok, image} = Image.from_binary(image_binary)

    image =
      case format do
        :desktop ->
          {:ok, resized} =
            Image.thumbnail(image, @desktop_resize.width, height: @desktop_resize.height)

          resized

        :mobile ->
          image
      end

    {:ok, compressed} = Image.write(image, :memory, suffix: @file_type, quality: @quality)

    if opts[:debug], do: log_compression_stats(image_binary, compressed)

    compressed
  end

  defp log_compression_stats(original, compressed) do
    original_size = byte_size(original)
    compressed_size = byte_size(compressed)
    compression_ratio = (original_size - compressed_size) / original_size * 100
    IO.puts("\nOptimisation Stats:")
    IO.puts("Original Size: #{format_size(original_size)}")
    IO.puts("Optimised Size: #{format_size(compressed_size)}")
    IO.puts("Optimisation Ratio: #{Float.round(compression_ratio, 2)}%")
  end

  defp format_size(bytes) do
    cond do
      bytes < 1024 -> "#{bytes} B"
      bytes < 1024 * 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
      true -> "#{Float.round(bytes / (1024 * 1024), 2)} MB"
    end
  end
end
