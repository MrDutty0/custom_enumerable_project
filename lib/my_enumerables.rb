module Enumerable
  # Your code goes here
  def my_each
    return to_enum(:my_each) unless block_given?

    for el in self do
      yield el
    end
  end

  def my_each_with_index
    return to_enum(:my_each_with_index) unless block_given?

    index = 0
    my_each do |el|
      yield(*el, index)
      index += 1
    end
  end

  def my_select
    return to_enum(:my_select) unless block_given?

    ans = is_a?(Array) ? [] : {}

    my_each do |el|
      if yield el
        if is_a?(Hash)
          ans[el.first] = el.last
        elsif is_a?(Array)
          ans << el
        end
      end
    end
    ans
  end

  def my_all?(pattern = nil)
    expr = block_given? ? ->(el) { yield el } : ->(el) { pattern === el }
    my_each { |el| return false unless expr.call(el) }
    true
  end

  def my_any?(pattern = nil)
    expr = block_given? ? ->(el) { yield el } : ->(el) { pattern === el }
    my_each { |el| return true if expr.call(el) }
    false
  end

  def my_none?(pattern = nil)
    expr = ->(el) { yield el } if block_given?
    expr = pattern ? ->(el) { pattern === el } : ->(el) { false ^ el} unless block_given?

    my_each { |el| return false if expr.call(el) }
    true
  end

  def my_count(item = nil)
    return size if item.nil? && !block_given? 

    expr = block_given? ? ->(el) { yield el } : ->(el) { el == item }

    occurance = 0
    my_each { |el| occurance += 1 if expr.call(el) }
    occurance
  end

  def my_map(block = nil)
    return to_enum(:my_map) unless block_given? && block.nil?

    ans = []

    expr = block_given? ? ->(el) { yield el } : ->(el) { block.call(el) }
    my_each { |el| ans << expr.call(el) }
    ans
  end

  def my_inject(*args)
    initial_operand = nil
    block = nil

    if block_given?
      initial_operand = args.first if args.size == 1 
    elsif args.size == 2
      initial_operand, block = args
    else
      args.first.is_a?(Proc) ? block = args.first : initial_operand = args.first
    end

    memo = initial_operand || first

    my_each_with_index do |el, idx|
      if block_given?
        next if initial_operand.nil? && idx.zero?

        memo = yield(memo, el)
      else
        next if initial_operand.nil? && idx.zero?

        memo = memo.send(block, el)
      end
    end
    memo
  end
end
