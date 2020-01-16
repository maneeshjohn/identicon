defmodule Identicon.Create do
  
    def main(input) do
        input
            |>hash_input
            |>get_color
            |>build_grid
            |>remove_odd_squares
            |>build_pixel_map
            |>draw_image
            |>save_image(input)
    end

    defp hash_input(input) do
        hex =
            :crypto.hash(:md5, input)
            |>:binary.bin_to_list

        %Identicon.ImageData{ hex: hex }
    end

    defp get_color(%{ hex: [r,g,b | _] } = hex) do
        %Identicon.ImageData{ hex | color: { r,g,b } }
    end

    defp build_grid(%{ hex: hex } = image) do
        grid = hex
            |>Enum.chunk(3)
            |>Enum.flat_map(fn [first,second | _] = row -> row ++ [second,first] end)
            |>Enum.with_index
        
        %Identicon.ImageData{ image | grid: grid }
    end

    defp remove_odd_squares(%{ grid: grid } = image) do
        filtered_grid = grid
            |>Enum.filter(fn { num, _ } -> rem(num, 2) == 0 end)

        %Identicon.ImageData{ image | grid: filtered_grid }
    end

    defp build_pixel_map(%{ grid: grid } = image) do
        pixel_map = grid
            |>Enum.map(fn { _, index } ->
                hor = rem(index,5) * 50
                ver = div(index,5) * 50
                top_left = { hor, ver }
                bottom_right = { hor + 50, ver + 50 }
                { top_left, bottom_right }
            end)

        %Identicon.ImageData{ image | pixel_map: pixel_map }
    end

    defp draw_image(%{ color: color, pixel_map: map }) do
        image = :egd.create(250, 250)
        fill = :egd.color(color)
        
        map
            |>Enum.each(fn { start, stop } ->
                :egd.filledRectangle(image, start, stop, fill)
            end)
        :egd.render(image)
    end

    defp save_image(image, file_name) do
        File.write("#{ file_name }.png", image)
    end
end