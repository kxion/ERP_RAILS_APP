class HashWithCallbacks < Hash

  # Hash implementation with custom callbacks
  # Supported callbacks:
  #   - :changed -> (changed_items) -
  def initialize(hash, callbacks = [])
    @callbacks = {}
    hash.each { |k, v| self[k] = v }
    @callbacks = callbacks if callbacks
  end

  def []=(key, value)
    res = super(key, value)
    @callbacks[:changed].call({ key => value }) if @callbacks[:changed]
    res
  end
end