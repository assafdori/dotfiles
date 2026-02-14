#!/bin/zsh
# Benchmark script to measure zsh startup time
# Usage: zsh zsh/bench.zsh

# Run 10 iterations and collect timing data
declare -a times
num_runs=10

echo "Benchmarking zsh startup time ($num_runs runs)..."
echo ""

for i in {1..$num_runs}; do
  # Capture the time output from stderr (3>&1 redirects stderr to stdout)
  output=$( { time zsh -i -c exit; } 2>&1 | grep total )
  
  # Extract the total time value (format: "X.XXXs user Y.YYYs system ZZ% cpu T.TTT total")
  # We want the number right before "total"
  total_time=$(echo "$output" | grep -oE '[0-9]+\.[0-9]+ total' | grep -oE '^[0-9]+\.[0-9]+')
  
  if [[ -z "$total_time" ]]; then
    echo "Error: Could not parse timing output: $output"
    exit 1
  fi
  
  times+=($total_time)
  printf "Run %2d: %7s\n" $i "$total_time"
done

echo ""
echo "========== Statistics =========="

# Find min and max
min=${times[1]}
max=${times[1]}
sum=0

for time in "${times[@]}"; do
  sum=$(echo "$sum + $time" | bc)
  if (( $(echo "$time < $min" | bc -l) )); then
    min=$time
  fi
  if (( $(echo "$time > $max" | bc -l) )); then
    max=$time
  fi
done

# Calculate average
average=$(echo "scale=3; $sum / $num_runs" | bc)

# Sort times for median calculation
sorted_times=($(for t in "${times[@]}"; do echo $t; done | sort -n))

# Calculate median
if (( $num_runs % 2 == 0 )); then
  # Even number of elements: average of two middle elements
  mid1=$(( $num_runs / 2 - 1 ))
  mid2=$(( $num_runs / 2 ))
  median=$(echo "scale=3; (${sorted_times[$((mid1+1))]} + ${sorted_times[$((mid2+1))]}) / 2" | bc)
else
  # Odd number of elements: middle element
  mid=$(( ($num_runs + 1) / 2 ))
  median=${sorted_times[$mid]}
fi

echo "Min:     $min"
echo "Max:     $max"
echo "Average: $average"
echo "Median:  $median"
echo "==============================="
