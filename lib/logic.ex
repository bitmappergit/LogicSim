defmodule Logic do
  def xor(a, b) do
    case {a, b} do
      {true, true} -> false
      {false, false} -> false
      {_, _} -> true
    end
  end

  def spawnGate(gateType, inputNode, outputNode) do
    tempGate = spawn(Logic, :gate, [gateType])
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
            send(outputNode, a and b)
            gate(:and, inputNode, outputNode)
        end
      :nand ->
        receive do
          {a, b} ->
            send(outputNode, not(a and b))
            gate(:nand, inputNode, outputNode)
        end
      :or ->
        receive do
          {a, b} ->
            send(outputNode, a or b)
            gate(:or, inputNode, outputNode)
        end
      :nor ->
        receive do
          {a, b} ->
            send(outputNode, not(a or b))
            gate(:nor, inputNode, outputNode)
        end
      :xor ->
        receive do
          {a, b} ->
            send(outputNode, xor(a, b))
            gate(:xor, inputNode, outputNode)
        end
      :xnor ->
        receive do
          {a, b} ->
            send(outputNode, not(xor(a, b)))
            gate(:xnor, inputNode, outputNode)
        end
      :not ->
        receive do
          input ->
            send(outputNode, not(input))
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
    node1 = spawn(Logic, :node, [:testnode1, []])
    node2 = spawn(Logic, :node, [:testnode2, []])
    send(node2, {:connectItem, self()})
    _gate1 = spawnGate(:and, node1, node2)
    send(node1, {true, false})
    receive do
      input ->
        IO.puts("\nTesting AND gate process with inputs {true, false} into node1, connected to gate1 which is outputting to node2:")
        IO.puts(input)
    end
    send(node1, {true, true})
    receive do
      input ->
        IO.puts("\nTesting AND gate process with inputs {true, true} into node1, connected to gate1 which is outputting to node2:")
        IO.puts(input)
    end
  end
end