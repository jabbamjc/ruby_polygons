$gtk.reset
$gtk.ffi_misc.gtk_dlopen("ext")
#include FFI::FNL

require "app/json.rb"
require "app/polygons.rb"

def tick args
    st = Time.new

    initialize args if args.state.tick_count == 0
    args.outputs.background_color = [169,169,169]
    args.outputs.labels << [1270, 710, args.gtk.current_framerate.round(1), 0, 2, 255, 0, 0]

    args.state.polygons.each do |polygon|
        draw_polygon(args, polygon)
    end

    args.state.polygons[0].translate!(Vec2.new(args.inputs.left_right*4, args.inputs.up_down*4))
    args.state.polygons[0].rotate!(1) if args.inputs.mouse.button_left
    args.state.polygons[0].rotate!(-1) if args.inputs.mouse.button_right

    collision_counter = 0
    args.state.polygons.each_with_index do |polygon_1, i|
        args.state.polygons.each_with_index do |polygon_2, j|
            next if polygon_1 == polygon_2 || j < i
            collision = polygon_1.intersects?(polygon_2)

            if collision
                polygon_1.translate!(collision.normal.invert * Vec2.new((collision.depth / 2), (collision.depth / 2)))
                polygon_2.translate!(collision.normal * Vec2.new((collision.depth / 2), (collision.depth / 2)))

                collision_counter += 1
            end
        end
    end

    #args.state.polygons << Polygon.new(Vec2.new(args.inputs.mouse.x, args.inputs.mouse.y+50), Vec2.new(args.inputs.mouse.x+50, args.inputs.mouse.y+50), Vec2.new(args.inputs.mouse.x+50, args.inputs.mouse.y), Vec2.new(args.inputs.mouse.x, args.inputs.mouse.y)) if args.inputs.keyboard.key_down.p
    args.state.polygons << Polygon.new(Vec2.new(args.inputs.mouse.x, args.inputs.mouse.y), Vec2.new(args.inputs.mouse.x+32, args.inputs.mouse.y-16), Vec2.new(args.inputs.mouse.x, args.inputs.mouse.y-32), Vec2.new(args.inputs.mouse.x-32, args.inputs.mouse.y-16)) if args.inputs.keyboard.key_down.p

    args.outputs.labels << [10, 710, "Polygon Count : #{args.state.polygons.length}", 0, 0, 255, 0, 0]
    args.outputs.labels << [10, 680, "Collisions : #{collision_counter}", 0, 0, 255, 0, 0]

    args.outputs.labels << [1280/2, 710, "WASD or ARROW keys to MOVE", 0, 1, 255, 0, 0]
    args.outputs.labels << [1280/2, 680, "LEFT or RIGHT click mouse to ROTATE", 0, 1, 255, 0, 0]
    args.outputs.labels << [1280/2, 650, "P to create polygon at mouse location", 0, 1, 255, 0, 0]

    et = Time.new
    args.outputs.labels << [1270, 680, "#{(et - st) * 1000}ms", 0, 2, 255, 0, 0]
end

def draw_polygon(args, polygon)
    polygon.points.each_with_index do |point_1, i|
        point_2 = polygon.points[(i + 1) % polygon.points.length]
        draw_line args, point_1, point_2
    end
end

def draw_line(args, p1, p2)
    args.outputs.primitives << {x:p1.x, y:p1.y, x2:p2.x, y2:p2.y, r:225, primitive_marker: :line}
end

def draw_vec(args, vec)
    args.outputs.primitives << {x:0, y:0, x2:vec.x, y2:vec.y, r:225, primitive_marker: :line}
end

def initialize args
    args.state.polygons = []
    args.state.polygons << Polygon.new(Vec2.new(0, 16),Vec2.new(32, 16),Vec2.new(32, 0),Vec2.new(0, 0),)
end