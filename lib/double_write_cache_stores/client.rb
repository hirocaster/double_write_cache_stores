class DoubleWriteCacheStores::Client
  def initialize(read_and_write_store_servers, write_only_store_servers = nil)
    @read_and_write_store = read_and_write_store_servers
    if write_only_store_servers
      if read_and_write_store_servers.class != write_only_store_servers.class
        fail "different cache store instance. #{read_and_write_store_servers.class} != #{write_only_store_servers.class}"
      end
      @write_only_store = write_only_store_servers
    end
  end

  def [](key)
    get key
  end

  def get(key)
    get_or_read_method_call key
  end

  def get_cas(key)
    @read_and_write_store.get_cas key
  end

  def set_cas(key, value, cas, options = nil)
    cas_unique = @read_and_write_store.set_cas key, value, cas, options

    if @write_only_store && cas_unique
      set_or_write_method_call @write_only_store, key, value, options
    end

    cas_unique
  end

  def read(key)
    get_or_read_method_call key
  end

  def delete(key)
    @read_and_write_store.delete key
    @write_only_store.delete key if @write_only_store
  end

  def []=(key, value)
    set key, value
  end

  def set(key, value, options = nil)
    write_cache_store key, value, options
  end

  def write(key, value, options = nil)
    write_cache_store key, value, options
  end

  def touch(key)
    result = false
    read_and_write_backend = @read_and_write_store.instance_variable_get('@backend') || @read_and_write_store.instance_variable_get('@data')
    if read_and_write_backend && read_and_write_backend.respond_to?(:touch)
      result = read_and_write_backend.touch key
      write_only_store_touch key
    end
    result
  end

  def flush
    if flush_cache_store || flush_cache_store(:clear)
      true
    else
      false
    end
  end

  private

  def write_cache_store(key, value, options = nil)
    set_or_write_method_call @read_and_write_store, key, value, options
    set_or_write_method_call @write_only_store, key, value, options if @write_only_store
  end

  def set_or_write_method_call cache_store, key, value, options
    if cache_store.respond_to? :set
      cache_store.set key, value, options
    elsif cache_store.respond_to? :write
      cache_store.write key, value, options
    end
  end

  def get_or_read_method_call key
    if @read_and_write_store.respond_to? :get
      @read_and_write_store.get key
    elsif @read_and_write_store.respond_to? :read
      @read_and_write_store.read key
    end
  end

  def flush_cache_store(method = :flush)
    if @read_and_write_store.respond_to? method
      if @write_only_store && @write_only_store.respond_to?(method)
        @write_only_store.send method
      end
      @read_and_write_store.send method
    else
      false
    end
  end

  def write_only_store_touch(key)
    if @write_only_store
      write_only_backend = @write_only_store.instance_variable_get('@backend') || @write_only_store.instance_variable_get('@data')
      if write_only_backend
        write_only_backend.touch key if write_only_backend.respond_to?(:touch)
      end
    end
  end
end
