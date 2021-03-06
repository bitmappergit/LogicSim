use Bitwise

#### TODO
  ### Logic:
    ## Core:
      # create splitter to split one bus (a list sent over one connection) into multiple individual connections
      # convert code to use recursive logic functions in Logic.Recursive (will most likely make wrapper functions)
  ### LogicType
    ## Internal:
      # fix xor implementation
    ## Recursive:
      # figure out how to implement a proper multi input xor
#### END

defmodule Logic do
  defmodule Core
    def spawnGate(gateType, inputNode, outputNode) do
      tempGate = spawn(
        Logic,
        :gate,
        [gateType])

      send(inputNode, {:connectItem, tempGate})
      send(outputNode, {:connectItem, tempGate})
      send(tempGate, {inputNode, outputNode})

      tempGate
    end

    def gate(gateType, inputNode, outputNode) do
      case gateType do
        :and ->
          receive do
            {a, b} ->
              send(outputNode, a &&& b)
              gate(:and, inputNode, outputNode)
          end
        :nand ->
          receive do
            {a, b} ->
              send(outputNode, a &&& b |> bnot)
              gate(:nand, inputNode, outputNode)
          end
        :or ->
          receive do
            {a, b} ->
              send(outputNode, a ||| b)
              gate(:or, inputNode, outputNode)
          end
        :nor ->
          receive do
            {a, b} ->
              send(outputNode, a ||| b |> bnot)
              gate(:nor, inputNode, outputNode)
          end
        :xor ->
          receive do
            {a, b} ->
              send(outputNode, a ^^^ b)
              gate(:xor, inputNode, outputNode)
          end
        :xnor ->
          receive do
            {a, b} ->
              send(outputNode, a ^^^ b |> bnot)
              gate(:xnor, inputNode, outputNode)
          end
        :not ->
          receive do
            input ->
              send(outputNode, ~~~input)
              gate(:not, inputNode, outputNode)
          end
        :buffer ->
          receive do
            input ->
              send(outputNode, input)
              gate(:buffer, inputNode, outputNode)
          end
      end
    end

    def gate(gateType) do
      receive do
        {inputNode, outputNode} ->
          gate(gateType, inputNode, outputNode)
      end
    end

    def node(name, connList) do
      nodeName = name
      receive do
        {:getName, source} ->
          send(source, nodeName)
          node(name, connList)
        {:connectItem, item} ->
          node(name, [item | connList])
        {:getConnList, source} ->
          send(source, connList)
          node(name, connList)
        input ->
          Manifold.send(connList, input)
          node(name, connList)
      end
    end

    def test do
      node1 = spawn(
        Logic,
        :node,
        [:testnode1, []])

      node2 = spawn(
        Logic,
        :node,
        [:testnode2,[]])

      send(node2, {:connectItem, self()})

      #the gate is never actually referred to directly and must be prefixed with an underscore
      #this is because connection is handled by the spawnGate/3 function
      _gate1 = spawnGate(:and, node1, node2)

      send(node1, {1, 0})
      receive do
        input ->
          IO.write("""
            Testing AND gate process with inputs {1, 0} into node1, \
            connected to gate1 which is outputting to node2: \
            """)
          IO.puts(input)
      end

      send(node1, {1, 1})
      receive do
        input ->
          IO.write("""
            Testing AND gate process with inputs {1, 1} into node1, \
            connected to gate1 which is outputting to node2: \
            """)
          IO.puts(input)
      end
    end
  end
end