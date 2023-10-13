require "app/vectormath_2d.rb"

class Polygon
    attr_accessor :points

    MAX = 2 ** (([42].pack('i').size * 16) - 2) - 1
    MIN = -MAX - 1

    def initialize(*points)
        @points = points
    end

    def translate!(vec)
        @points.map!{ |p| p + vec}
    end

    def translate(vec)
        Polygon.new(@points.map{ |p| p + vec})
    end

    def rotate!(rad)
        @points.map!{ |p| p.rotate_by!(arithmetic_mean, rad) }
    end

    def rotate(rad)
        Polygon.new(@points.map{ |p| p.rotate_by!(arithmetic_mean, rad) })
    end

    def arithmetic_mean
        center = Vec2.new(0, 0)
        @points.each { |p| center += p }
        center /= Vec2.new(@points.length, points.length) 
        center
    end

    def intersects?(polygon_2)
        normal = Vec2.new(0,0)
        depth = MAX

        @points.each_with_index do |va, i|
            j = (i + 1) % @points.length
            vb = @points[j]

            edge = vb - va
            axis = Vec2.new(-edge.y, edge.x).normalize

            range_a = project_verticies(@points, axis)
            range_b = project_verticies(polygon_2.points, axis)

            if (range_a[:min] >= range_b[:max] ||range_b[:min] >= range_a[:max])
                return false
            end

            axis_depth = [(range_b[:max] - range_a[:min]), (range_a[:max] - range_b[:min])].min
            if axis_depth < depth
                depth = axis_depth
                normal = axis
            end
        end

        polygon_2.points.each_with_index do |va, i|
            j = (i + 1) % polygon_2.points.length
            vb = polygon_2.points[j]

            edge = vb - va
            axis = Vec2.new(-edge.y, edge.x).normalize

            range_a = project_verticies(@points, axis)
            range_b = project_verticies(polygon_2.points, axis)

            if (range_a[:min] >= range_b[:max] ||range_b[:min] >= range_a[:max])
                return false
            end

            axis_depth = [(range_b[:max] - range_a[:min]), (range_a[:max] - range_b[:min])].min
            if axis_depth < depth
                depth = axis_depth
                normal = axis
            end
        end

        depth /= normal.length

        center_1 = self.arithmetic_mean
        center_2 = polygon_2.arithmetic_mean

        direction = center_2 - center_1

        normal.invert! if direction.dot(normal) < 0

        return {depth:depth, normal:normal}
    end

    def project_verticies(points, axis)
        min = MAX
        max = MIN

        points.each do |p|
            projection = p.dot(axis)

            min = projection if projection < min
            max = projection if projection > max
        end

        {min:min, max:max}
    end
end