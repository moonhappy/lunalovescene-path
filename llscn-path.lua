local Class = require "lib.lunalovescene.lib.middleclass.middleclass"

--[[--
  Graph node represents a singular point that can be addressed and "walked" to.
]]
local LnaGraphNode = Class("LnaGraphNode")
function LnaGraphNode:initialize(position, userObj)
  self.position = position
  self.edges = {}
  self.id = -1
  self.userObj = userObj
end

function LnaGraphNode:addEdge(e)
  self.edges[#self.edges + 1] = e
end

--[[--
  Graph edge represents a connection between two graph nodes.
]]
local LnaGraphEdge = Class("LnaGraphEdge")
function LnaGraphEdge:initialize(node1, node2, cost)
  self.node1 = node1
  self.node2 = node2
  self.cost = cost or 1.0
  if node1 ~= nil then
    node1:addEdge(self)
  end
  if node2 ~= nil then
    node2:addEdge(self)
  end
end

--[[
  The graph map. Start with this class and build the graph using the provided
  functions.
]]
local LnaGraph = Class("LnaGraph")
function LnaGraph:initialize(rootNode)
  rootNode.id = 1
  self.nodes = {rootNode}
  self.edges = {}
end

function LnaGraph:addNodeLink(existingNode, neighbourNode, cost)
  if neighbourNode.id == -1 then
    neighbourNode.id = #self.nodes + 1
    self.nodes[neighbourNode.id] = neighbourNode
  end
  -- Create edge joinin the two nodes
  local aCost = cost or 1.0
  self.edges[#self.edges + 1] = LnaPathEdge:new(existingNode, neighbourNode, aCost)
end

--[[
  Path finder algorithm will produce a traversable path given a graph, start
  node, and end node. Uses Dijkstra's Algorithm.
]]
local LnaPathFinder = Class("LnaPathFinder")
function LnaPathFinder:initialize(graph, startNode, endNode)
  self.result = {}
  -- Quick exit if failing params
  if graph == nil or startNode == nil or endNode == nil then
    return
  end
  -- Prep work
  local q = {}
  local d = {}
  local countNodes = #graph.nodes
  for i=1,countNodes do
    d[graph.nodes[i]] = math.huge
    q[#q + 1] = graph.nodes[i]
  end
  d[startNode] = 0.0
  -- Search for the optimal path
  while #q > 0 do
    local u = self:_nextSmallestDist(q, d)
    -- Find nodes that 'u' connects to and perform relaxation.
    local countEdges = #u.edges
    for i=1,countEdges do
      local forceContinue = true
      local e = u.edges[i]
      local v = nil
      if e.node1 ~= u then
        v = e.node1
      elseif e.node2 ~= u then
        v = e.node2
      else
        forceContinue = false
      end
      -- Test there were no cycles
      if forceContinue and e.cost >= 0.0 then
        if d[v] > d[u] + e.cost then
          d[v] = d[u] + e.cost
          path[v] = u
        end
      end
    end
  end
  -- Complete the path
  local revresult = {}
  local trav = endNode
  while trav ~= startNode do
    revresult[#revresult + 1] = trav
    trav = path[trav]
  end
  -- return
  local countResult = #revresult
  for i=1,countResult do
    self.result[countResult - i + 1] = revresult[i]
  end
end

function LnaPathFinder:_nextSmallestDist(q, d)
  local min = math.huge
  local v = -1
  -- Search queue to find the next node having the smallest distance.
  local countQ = #q
  for i=1,countQ do
    local j = q[i]
    if d[j] <= min then
      min = d[j]
      v = i
    end
  end
  -- Remove the selected to enable queue mechanic
  if v ~= -1 then
    local j = q[v]
    q.remove(v)
    return j
  end
  return nil
end
