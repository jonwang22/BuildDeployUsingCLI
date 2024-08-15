#!/bin/bash
#
# This script is going to retrieve all system resources and have an exit code when one of the resources exceeds a set threshold.

# Setting threshold for CPU, Memory, Disk Storage
CPU_THRESHOLD=80       # Percentage
MEMORY_THRESHOLD=80    # Percentage
DISK_THRESHOLD=80      # Percentage

# Initializing resource threshold exceeded limits.
CPU_EXCEEDED=0
MEMORY_EXCEEDED=0
DISK_EXCEEDED=0

# Check CPU function
function check_cpu() {
	# Here we're using sar to grab our CPU usage over time. Default time frame for records is 10mins for sar.
	# We look for the row named average that takes the average of all the entries in the output
	# We use awk to separate the fields we need to make our calculation.
	cpu_util=$(sar | grep -i "average" | awk '{printf "%.2f\n", 100 - $8}')

	# Here we're checking if our CPU Utilization is greater than the CPU threshold we set.
	# If our utilization exceeds our threshold we output a warning message and set the exceeded mark to 1.
	# If it is not greater, then we'll echo what the current usage is and how much we have before we hit the threshold.
	if  (( $(echo "$cpu_util > $CPU_THRESHOLD" | bc -l) )); then
		echo "Warning: CPU usage is at $cpu_util%. Usage is above the threshold!! Please investigate which processes are taking up CPU. (Current CPU Threshold is set at $CPU_THRESHOLD%)"
                CPU_EXCEEDED=1
        else
		diff=$(echo "$CPU_THRESHOLD - $cpu_util" | bc -l)
		echo "Current CPU usage is $cpu_util%. CPU Utilization is $diff% below our current threshold of $CPU_THRESHOLD%"
	fi	
}


# Check Memory function
function check_mem() {
	# Here we're grabbing our free memory output, isolating the mem row and removing swap.
	# We use awk to isolate field 2 and field 3 which are the values for TotalMem and UsedMem.
	# We divide UsedMem by TotalMem and multiply by 100 to get the percentage of memory utilization.
	mem_util=$(free | awk '/^Mem/ {printf("%.0f", ($3-$6) * 100 / $2)}')
	
	# We are now comparing our current memory utilization to our threshold that we've set.
	# If we see our utilization surpass our threshold then we'll output a warning message and set our MEMORY_EXCEEDED value to 1 to track our exit code.
	if  [[ $mem_util -ge $MEMORY_THRESHOLD ]]; then
		echo "Warning: Memory usage is at $mem_util%. Usage is above the threshold!! Please investigate which processes are taking up memory. (Current Memory Threshold is set at $MEMORY_THRESHOLD%)"
		MEMORY_EXCEEDED=1
	else
		echo "Current memory usage is $mem_util%. Memory is $(echo "$MEMORY_THRESHOLD-$mem_util" | bc)% below our current threshold of $MEMORY_THRESHOLD%"
	fi
}


# Check Disk function
function check_disk() {
	# Here we are running our df command to isolate our partition and calculate the disk usage.
	disk_util=$(df -h | grep "/dev/root" | awk '{printf ("%.0f", $3/$2 * 100)}')
	
	# Similar to the previous functions we're checking the disk utilization and comparing it against the threshold.
	# If utilization exceeds, then we output a warning message and set the exceeded marker to 1.
	if [[ $disk_util -ge $DISK_THRESHOLD ]]; then
		echo "Warning: Disk usage is at $disk_util%. Usage is above the threshold!! Please investigate what is taking up all the disk space. (Current Disk Threshold is set at $DISK_THRESHOLD%)"
		DISK_EXCEEDED=1
	else
		echo "Current disk usage is $disk_util%. Disk is $(echo "$DISK_THRESHOLD-$disk_util" | bc)% below our current threshold of $MEMORY_THRESHOLD%."
	fi
}

# Executing system check
echo "Checking system resources..."
sleep 3
check_cpu
sleep 1
check_mem
sleep 1
check_disk

# Exit with code 0 if no issues, exit code 1 if any EXCEEDED value equals 1.
if [ "$CPU_EXCEEDED" -eq 1 ]; then
	exit 1
elif [ "$MEMORY_EXCEEDED" -eq 1 ]; then
	exit 1
elif [ "$DISK_EXCEEDED" -eq 1 ]; then
	exit 1
else
	exit 0
fi
