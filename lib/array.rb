# Monkey patching Array to make it easy to do any .each in parallel
# Example - Will run puppet agent -t on each agent in parallel:
# agents.each_in_parallel { |agent|
#   on agent, 'puppet agent -t'
# }
class Array
  def each_in_parallel(&block)
    if Process.respond_to?(:fork)
      method_sym = "#{caller_locations[0]}"
      each do |item|
        out = InParallel._execute_in_parallel(method_sym) {block.call(item)}
        puts "'each_in_parallel' forked process for '#{method_sym}' - PID = '#{out[:pid]}'\n"
      end
      # return the array of values, no need to look up from the map.
      return InParallel.wait_for_processes.values
    end
    puts 'Warning: Fork is not supported on this OS, executing block normally'
    block.call
    each(&block)
  end
end