
import Foundation

struct Point {
    let x: Double
    let y: Double
}

/*
func generatePoints(qtd: Int) -> [Point] {
    var points = [Point]()

    for _ in 0..<qtd {
        let x = Double.random(in: 0.0...500.0)
        let y = Double.random(in: 0.0...500.0)
        print("\(x), y:\(y)")
        points.append(Point(x: x, y: y: y))
    }
    return points
}

let points = generatePoints(qtd: 10)
print(points)
*/

// let points = [
  // Point(x: 40, y:70),
  // Point(x: 70, y:130),
  // Point(x: 90, y:40),
  // Point(x: 110, y:100),
  // Point(x: 140, y:110),
  // Point(x: 150, y:30),
  // Point(x: 160, y:100),
// ]

let points = [
  Point(x: 266.8647767845756, y:268.2012290659512),
  Point(x: 427.22919883238797, y:462.6444467473151),
  Point(x: 49.34725949520441, y:48.22098393715335),
  Point(x: 26.060625637355063, y:140.19301492207202),
  Point(x: 51.95967003599728, y:47.66967203253025),
  Point(x: 440.76523953433883, y:31.305478881508918),
  Point(x: 274.6848646728995, y:38.82193232227088),
  Point(x: 326.57905264950455, y:419.519258116838),
  Point(x: 366.70016199503357, y:154.74009199232364),
  Point(x: 310.77050799554326, y:137.48282255039973),
]

func distance(point1: Point, point2: Point) -> Double {
    let dx = point2.x - point1.x
    let dy = point2.y - point1.y
    return sqrt(dx * dx + dy * dy)
}

let target = Point(x: 360.0, y: 90.0)

let result = distance(point1: Point(x: 1.0, y: 1.0),
                      point2: Point(x: 2.0, y: 2.0))

print(result)


func closestDistance(points: [Point], target: Point) -> Point? {
    var bestDist = Double(Int.max)
    var bestPoint: Point? = nil
    for point in points {
        let dist = distance(point1: target, point2: point)
        if dist < bestDist {
            bestDist = dist
            bestPoint = point
        }
    }
    return bestPoint
}

if let closestPoint = closestDistance(points: points,
                                      target: target) {
    print("LINEAR: \(closestPoint)")
}


print("---------------")

class Node: CustomStringConvertible {
    let depth: Int
    let point: Point
    let left: Node?
    let right: Node?

    init(depth: Int, point: Point, left: Node?, right: Node?) {
        self.depth = depth
        self.point = point
        self.left  = left
        self.right = right
    }

    var description: String {
        let spaces = String(repeating: "|    ", count: depth)
        return "point: \(point)\n\(spaces)left:\(left?.description ?? "None")\n\(spaces)righ:\(right?.description ?? "None")"
    }
}

let k = 2

func createKdtree(points: [Point], depth: Int = 0) -> Node? {
    if points.isEmpty {
        return nil
    }

   let axis = depth % k // profundidade % dimension

   let sortedPoints = points.sorted {
       if axis == 0 {
           return $0.x < $1.x
       } else {
           return $0.y < $1.y
       }
   }

   let lp = Array(sortedPoints[..<(points.count / 2)])
   let rp = Array(sortedPoints[(points.count / 2 + 1)...])

   return Node(
     depth: depth + 1,
     point: sortedPoints[points.count / 2],
     left: createKdtree(points: lp, depth: depth + 1),
     right: createKdtree(points: rp, depth: depth + 1)
   )
}

guard let tree = createKdtree(points: points) else { exit(1) }
print(tree)


func kdtreeClosestPoint(root: Node?, target: Point, depth: Int = 0, bestPoint: Point? = nil) -> Point? {
    guard let root = root else { return bestPoint }
   
    let axis = depth % k

    var nextBestPoint = root.point
    let nextBranch: Node?

    if let bestPoint = bestPoint {
        if distance(point1: target, point2: root.point) < distance(point1: target, point2: bestPoint) {
            nextBestPoint = root.point
        }
    }

    if axis == 0 {
        if target.x < root.point.x {
            nextBranch = root.left
        } else {
            nextBranch = root.right
        }
    } else {
        if target.y < root.point.y {
            nextBranch = root.left
        } else {
            nextBranch = root.right
        }
    }

    return kdtreeClosestPoint(root: nextBranch, target: target, depth: depth + 1, bestPoint: nextBestPoint)
}




func closestDistance(target: Point, p1: Point?, p2: Point?) -> Point? {
    guard let p1 = p1 else { return p2 }
    guard let p2 = p2 else { return p1 }

    let d1 = distance(point1: target, point2: p1)
    let d2 = distance(point1: target, point2: p2)

    if d1 < d2 { // mais proximo de zero é o candidato melhor!
        return p1
    } else {
        return p2
    }
}

func kdtreeClosestPointFix(root: Node?, target: Point, depth: Int = 0) -> Point? {
    guard let root = root else { return nil }
    let axis = depth % k
    
    let nextBranch: Node?
    var oppositeBranch: Node?

    if axis == 0 {
        if target.x < root.point.x {
            nextBranch = root.left
            oppositeBranch = root.right
        } else {
            nextBranch = root.right
            oppositeBranch = root.left
        }
    } else {
        if target.y < root.point.y {
            nextBranch = root.left
            oppositeBranch = root.right
        } else {
            nextBranch = root.right
            oppositeBranch = root.left
        }
    }

    // checar qual é o ponto mais proximo do alvo
    // 1. o melhor resultado recursivamente de mais mais profunda na arvore
    // 2. ponto de divisao (split) 
    let p1 = kdtreeClosestPointFix(root: nextBranch, target: target, depth: depth + 1)

    var best = closestDistance(target: target,
                               p1: p1,
                               p2: root.point)

    if best != nil {
        if axis == 0 {
           // checar pelo "raio"
            if distance(point1: target, point2: best!) > abs(target.x - root.point.x) {
                let p1 = kdtreeClosestPointFix(root: oppositeBranch, target: target, depth: depth + 1)
                
                best = closestDistance(target: target,
                                       p1: p1,
                                       p2: best!)
            }
        } else {
           // checar pelo "raio"
            if distance(point1: target, point2: best!) > abs(target.y - root.point.y) {
                let p1 = kdtreeClosestPointFix(root: oppositeBranch, target: target, depth: depth + 1)
                
                best = closestDistance(target: target,
                                       p1: p1,
                                       p2: best!)
            }
        }
    }
    
    return best
    
}

if let closestPointTree = kdtreeClosestPointFix(root: tree, target: target) {
    print("NNS:", closestPointTree)
}
